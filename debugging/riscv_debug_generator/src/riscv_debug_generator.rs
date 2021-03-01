extern crate capnp;
extern crate capnpc;
extern crate tapasco;
extern crate snafu;
extern crate getset;

use memmap::MmapMut;
use core::fmt::Debug;
use snafu::{ResultExt, Snafu};
use std::process;
use std::io::Read;
use std::os::unix::net::{UnixListener, UnixStream};
use std::time::Duration;
use std::sync::Arc;
use volatile::Volatile;

use tapasco::debug::{DebugControl, DebugGenerator, Error as DebugError};
use tapasco::device::{DeviceSize, DeviceAddress};

mod tapasco_riscv_capnp {
    #![allow(dead_code)]
    include!("../schema/tapasco_riscv_capnp.rs");
}

use capnp::{serialize};
use crate::tapasco_riscv_capnp::{request, response};
use crate::tapasco_riscv_capnp::request::RequestType::{
    Dtm, Dm, Register, Memory, SystemBus, Control};
use crate::tapasco_riscv_capnp::request::Reader as ReqReader;
use crate::tapasco_riscv_capnp::request::ControlType::{
    Halt, Resume, Step, Reset};


#[derive(Debug, Snafu)]
pub enum Error {
    #[snafu(display("Failed to decode TLKM device: {}", source))]
    DeviceInit { source: tapasco::device::Error },

    #[snafu(display("Error executing serialization with cap'n proto: {}", source))]
    CapnpError { source: capnp::Error },

    #[snafu(display("Request was not in schema: {}", source))]
    CapnpSchemaError { source: capnp::NotInSchema},

    #[snafu(display("Error while creating io Socket: {}", source))]
    DebugIoError { source: std::io::Error },

    #[snafu(display("Error: Got a bad request with value: {}", value))]
    InputError { value: usize},
}
 
const SOCKET_FILE_NAME: &str = "/tmp/riscv-debug.sock";

const DMI_DATA_REG: isize = 0x0c;
const DMI_ADDR_REG: isize = 0x10;

const DM_DATA0_REG: u32         = 0x04;
const DM_DATA1_REG: u32         = 0x05;
const DM_DMCONTROL_REG: u32     = 0x10;
const DM_COMMAND_REG: u32       = 0x17;
const DM_SBCS_REG: u32          = 0x38;
const DM_SBADDRESS0_REG: u32    = 0x39;
const DM_SBDATA0_REG: u32       = 0x3c;

pub type Result<T, E = Error> = std::result::Result<T, E>;

#[derive(Debug, Getters)]
pub struct RiscvDebugGenerator {}


impl DebugGenerator for RiscvDebugGenerator {
    fn new(
        &self,
        arch_memory: &Arc<MmapMut>,
        name: String,
        offset: DeviceAddress,
        _size: DeviceSize,
    ) -> Result<Box<dyn DebugControl + Send + Sync>, DebugError> {
        Ok(Box::new(RiscvDebug {
            name: name,
            debug_mem: arch_memory.clone(),
            offset: offset,
        }))
    }
}

#[derive(Debug, Getters)]
pub struct RiscvDebug {
    name: String,
    debug_mem: Arc<MmapMut>,
    offset: DeviceAddress,
}

impl RiscvDebug {
    fn handle_ctrl_c(&self) {
        ctrlc::set_handler(move || {
            println!("received Ctrl+C!");
            match std::fs::remove_file(SOCKET_FILE_NAME) {
                Ok(_) => (),
                Err(e) => panic!("Unable to delete socket file {}: {}", SOCKET_FILE_NAME, e),
            }
            process::exit(0);
        })
        .expect("Error setting Ctrl-C handler");
    }

    fn handle_client(&self) -> Result<()> {
        let listener = UnixListener::bind(SOCKET_FILE_NAME).context(DebugIoError)?;

        self.handle_ctrl_c();

        //let connection = listener.accept().context(DebugIoError)?;
        //let mut stream = connection.0;

        println!("Handling RISC-V debug connection");


        for stream in listener.incoming() {
            match stream {
                Ok(stream) => {
                    stream.set_read_timeout(Some(Duration::new(1, 0)))
                        .expect("Couldn't set read timeout");
                    loop {
                        // Read a message from socket
                        let mut buffer = [0; 100];
                        let mut stream = stream.try_clone().expect("try_clone failed");
                        match stream.read(&mut buffer).context(DebugIoError)? {
                            x if x < 1 => {
                                println!("Got Message of size 0, closing connection");
                                //return Err(Error::InputError {value: x})
                                //return Ok(())
                                break;
                            },
                            _x => (),//println!("Got input of size: {}", x),
                        };

                        // Decode the message from socket
                        let mut buffer2 = &buffer[..];
                        let message_reader = serialize::read_message_from_flat_slice(&mut buffer2,
                                        ::capnp::message::ReaderOptions::new()).context(CapnpError)?;

                        let request = message_reader.get_root::<request::Reader>().context(CapnpError)?;

                        //let request = request.get_type().context(CapnpSchemaError)?;
                        let copy = stream.try_clone().expect("try_clone failed");

                        match request.get_type() {
                            Ok(Dtm) => match request.get_is_read() {
                                true => self.handle_read_request(request, copy)?,
                                false => self.handle_write_request(request, copy)?,
                            },
                            Ok(Dm) => match request.get_is_read() {
                                true => self.handle_read_dm(request, copy)?,
                                false => self.handle_write_dm(request, copy)?,
                            },
                            Ok(Register) => match request.get_is_read() {
                                true => self.handle_read_register(request, copy)?,
                                false => self.handle_write_register(request, copy)?,
                            },
                            Ok(Memory) => match request.get_is_read() {
                                true => self.handle_read_mem(request, copy)?,
                                false => self.handle_write_mem(request, copy)?,
                            },
                            Ok(SystemBus) => match request.get_is_read() {
                                true => self.handle_read_bus(request, copy)?,
                                false => self.handle_write_bus(request, copy)?,
                            },
                            Ok(Control) => self.handle_run_ctrl(request, copy)?,
                            _ => panic!("Error while checking Request type"),
                        };
                    } // loop
                } // Ok
                Err(_) => {break;}
            } // match
        } // incoming
        Ok(())
    }

    fn handle_read_request(&self, read_req: ReqReader, stream: UnixStream) -> Result<()> {
        if read_req.get_addr() != 0xc {
            println!("Got read at address: {}", read_req.get_addr());
        }

        let r = match read_req.get_addr() {
            // TODO Workaround since DTMCS currently returns wrong val
            x if x == 8 => 0x71,
            x => self.read_dtm(x as isize)?
        };

        if read_req.get_addr() != 0xc {
            println!("Responding read with: {:#X}", r);
        }

        self.send_read_rsp(r as u32, stream)?;

        Ok(())
    }

    fn handle_write_request(&self, write_req: ReqReader, stream: UnixStream) -> Result<()> {
        if write_req.get_addr() != 0x10 {
            println!("Got write at address: {} with {:#X}",
                     write_req.get_addr(), write_req.get_data());
        }

        self.write_dtm(write_req.get_addr() as isize, write_req.get_data())?;

        self.send_write_rsp(stream)?;

        Ok(())
    }

    fn handle_read_dm(&self, req_dm: ReqReader, stream: UnixStream) -> Result<()> {
        let result = self.read_dm(req_dm.get_addr())?;

        self.send_read_rsp(result, stream)?;

        Ok(())
    }

    fn handle_write_dm(&self, req_dm: ReqReader, stream: UnixStream) -> Result<()> {
        self.write_dm(req_dm.get_addr(), req_dm.get_data())?;

        self.send_write_rsp(stream)?;

        Ok(())
    }

    fn handle_read_register(&self, req_reg: ReqReader, stream: UnixStream) -> Result<()> {
        let result = self.read_register(req_reg.get_addr())?;

        self.send_read_rsp(result, stream)?;

        Ok(())
    }

    fn handle_write_register(&self, req_reg: ReqReader, stream: UnixStream) -> Result<()> {
        self.write_register(req_reg.get_addr(), req_reg.get_data())?;

        self.send_write_rsp(stream)?;

        Ok(())
    }

    fn handle_read_mem(&self, req_reg: ReqReader, stream: UnixStream) -> Result<()> {
        let result = self.read_mem(req_reg.get_addr())?;

        self.send_read_rsp(result, stream)?;

        Ok(())
    }

    fn handle_write_mem(&self, req_reg: ReqReader, stream: UnixStream) -> Result<()> {
        self.write_mem(req_reg.get_addr(), req_reg.get_data())?;

        self.send_write_rsp(stream)?;

        Ok(())
    }

    fn handle_read_bus(&self, req_reg: ReqReader, stream: UnixStream) -> Result<()> {
        let result = self.read_bus(req_reg.get_addr())?;

        self.send_read_rsp(result, stream)?;

        Ok(())
    }

    fn handle_write_bus(&self, req_reg: ReqReader, stream: UnixStream) -> Result<()> {
        self.write_bus(req_reg.get_addr(), req_reg.get_data())?;

        self.send_write_rsp(stream)?;

        Ok(())
    }

    fn handle_run_ctrl(&self, req_ctrl: ReqReader, stream: UnixStream) -> Result<()> {
        match req_ctrl.get_ctrl_type() {
            Ok(Halt) => println!("Halt Not yet implemented"),
            Ok(Resume) => self.handle_resume()?,
            Ok(Step) => println!("Step Not yet implemented"),
            Ok(Reset) => println!("Reset Not yet implemented"),
            _ => panic!("Error while checking Request type"),
        };

        self.send_write_rsp(stream)?;

        Ok(())
    }

    fn handle_resume(&self) -> Result<()> {
        self.write_dm(DM_DMCONTROL_REG, 0x40000001)?;

        Ok(())
    }

    fn send_read_rsp(&self, response_value: u32, stream: UnixStream) -> Result<()> {
        // Respond with a message
        let mut message = ::capnp::message::Builder::new_default();
        let mut read_rsp = message.init_root::<response::Builder>();

        read_rsp.set_data(response_value);
        read_rsp.set_is_read(true);
        read_rsp.set_success(true);

        serialize::write_message(stream, &message).context(CapnpError)?;

        Ok(())
    }

    fn send_write_rsp (&self, stream: UnixStream) -> Result<()> {
        // Respond with a message to keep in sync
        let mut message = ::capnp::message::Builder::new_default();
        let mut write_rsp = message.init_root::<response::Builder>();
        write_rsp.set_is_read(false);
        write_rsp.set_success(true);

        serialize::write_message(stream, &message).context(CapnpError)?;

        Ok(())
    }

    fn read_bus(&self, addr: u32) -> Result<u32> {
        // 32 bit access and read flag
        let command = (2 << 17) | (1 << 20);
        self.write_dm(DM_SBCS_REG, command)?;
        self.write_dm(DM_SBADDRESS0_REG, addr)?;

        Ok(self.read_dm(DM_SBDATA0_REG)?)
    }

    fn write_bus(&self, addr: u32, data: u32) -> Result<()> {
        // Everything at default
        let command = 0;
        self.write_dm(DM_SBCS_REG, command)?;
        self.write_dm(DM_SBADDRESS0_REG, addr)?;
        self.write_dm(DM_SBDATA0_REG, data)?;

        Ok(())
    }

    fn read_mem(&self, addr: u32) -> Result<u32> {
        // Address in arg1 -> data1
        self.write_dm(DM_DATA1_REG, addr)?;

        // Memory command and 32 bit access
        let command = (2 << 24) | (2 << 20);
        self.write_dm(DM_COMMAND_REG, command)?;

        Ok(self.read_dm(DM_DATA0_REG)?)
    }

    fn write_mem(&self, addr: u32, data: u32) -> Result<()> {
        // Address in arg1 -> data1
        self.write_dm(DM_DATA1_REG, addr)?;
        // Data in arg0 -> data0
        self.write_dm(DM_DATA0_REG, data)?;

        // Write Bit, Transfer bit and 32 bit access
        let command = (2 << 24) | (2 << 20) | (1 << 16);
        self.write_dm(DM_COMMAND_REG, command)?;

        Ok(())
    }

    fn read_register(&self, addr: u32) -> Result<u32> {
        // Transfer bit and 32 bit access
        let command = addr | (1 << 17) | (2 << 20);
        self.write_dm(DM_COMMAND_REG, command)?;

        Ok(self.read_dm(DM_DATA0_REG)?)
    }

    fn write_register(&self, addr: u32, data: u32) -> Result<()> {
        self.write_dm(DM_DATA0_REG, data)?;

        // Write Bit, Transfer bit and 32 bit access
        let command = addr | (1 << 16) | (1 << 17) | (2 << 20);
        self.write_dm(DM_COMMAND_REG, command)?;

        Ok(())
    }

    fn read_dm(&self, addr: u32) -> Result<u32> {
        self.write_dtm(DMI_ADDR_REG, addr)?;

        Ok(self.read_dtm(DMI_DATA_REG)?)
    }

    fn write_dm(&self, addr: u32, data: u32) -> Result<()> {
        // Write address into DMI register
        self.write_dtm(DMI_ADDR_REG, addr)?;

        self.write_dtm(DMI_DATA_REG, data)?;

        Ok(())
    }

    fn read_dtm(&self, address: isize) -> Result<u32>{
        let offset = self.offset as isize;
        unsafe {
            let ptr = self.debug_mem.as_ptr().offset(offset + address);
            let volatile_ptr = ptr as *mut Volatile<u32>;
            Ok((*volatile_ptr).read())
        }
    }

    fn write_dtm(&self, address: isize, data: u32) -> Result<()>{
        let offset = self.offset as isize;
        unsafe {
            let ptr = self.debug_mem.as_ptr().offset(offset + address);
            let volatile_ptr = ptr as *mut Volatile<u32>;
            (*volatile_ptr).write(data);
        }
        Ok(())
    }
}


impl DebugControl for RiscvDebug {
    fn enable_debug(&mut self) -> Result<(), DebugError> {
        println!("Listening to connection in socket: {}", SOCKET_FILE_NAME);

        match self.handle_client() {
            Ok(_) => Ok(()),
            Err(e) => match e {
                Error::DebugIoError{source} => match source.kind() {
                    std::io::ErrorKind::ConnectionReset => {
                        println!("Connection was reset by client, closing debugger!");
                        Ok(())
                    }
                    _other_err => {
                        println!("Unknown IO error while handling client: {}", source);
                        Ok(())
                    }
                }
                other_err => {
                    println!("Unknown error while handling client: {}", other_err);
                    Ok(())
                }
            }
        }
    }
}



