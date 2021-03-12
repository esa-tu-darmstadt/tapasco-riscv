extern crate capnp;
extern crate capnpc;
extern crate tapasco;
extern crate snafu;
extern crate getset;
extern crate riscv_debug_generator;

use core::fmt::Debug;
use std::fs::read;
use std::collections::HashMap;
use std::process;
use tapasco::debug::DebugGenerator;
use tapasco::device::{Device, DataTransferLocal as Transfer};
use tapasco::device::PEParameter::{Single64, DataTransferLocal};
use tapasco::tlkm::TLKM;
use snafu::{ResultExt, Snafu};

use riscv_debug_generator::riscv_debug_generator::{
    RiscvDebugGenerator, Error as RiscvError
};

#[derive(Debug, Snafu)]
pub enum Error {
    #[snafu(display("Failed to initialize TLKM object: {}", source))]
    TLKMInit { source: tapasco::tlkm::Error },

    #[snafu(display("Error during RISC-V debugging: {}", source))]
    RiscvDebugError { source: RiscvError},

    #[snafu(display("Failed to decode TLKM device: {}", source))]
    DeviceInit { source: tapasco::device::Error },

    #[snafu(display("Error while creating io Socket: {}", source))]
    DebugIoError { source: std::io::Error },

    #[snafu(display("Error while enabling debug: {}", source))]
    DebugEnableError { source: tapasco::job::Error },

    #[snafu(display("Error while releasing pe: {}", source))]
    ReleasePeError { source: tapasco::job::Error },

    #[snafu(display("Error while executing Job: {}", source))]
    JobError { source: tapasco::job::Error },

    #[snafu(display("Error while parsing PE IDJob: {}", source))]
    ParsePeIdError { source: std::num::ParseIntError },
}

pub type Result<T, E = Error> = std::result::Result<T, E>;

const DEFAULT_PE_ID: usize = 1744;

fn allocate_devices(
            tlkm: &TLKM,
            debug_generators: HashMap<String, Box<dyn DebugGenerator + Sync + Send>>
        ) -> Result<Vec<Device>> {
    let mut devices = tlkm.device_enum(&debug_generators).context(TLKMInit {})?;

    for x in devices.iter_mut() {
        println!(
            "Device {}: Name: {}, Vendor: {}, Product {}",
            x.id(),
            x.name(),
            x.vendor(),
            x.product()
        );
        println!("Allocating ID {} exclusively.", x.id());
        x.change_access(tapasco::tlkm::tlkm_access::TlkmAccessExclusive)
            .context(DeviceInit {})?;
    }

    Ok(devices)
}

fn print_status(devices: &Vec<Device>) -> Result<()> {
    for x in devices {
        println!("Device {}", x.id());
        println!("{:?}", x.status());
    }
    Ok(())
}

fn debug_binary(device: &Device, file_name: &String, pe_id: usize) -> Result<()> {
    let mut pe1 = device.acquire_pe(pe_id).context(DeviceInit)?;

    println!("Starting PE1");
    if file_name.to_owned() != "".to_string() {
        // Read in RISC-V binary file
        let bytes = read(file_name).context(DebugIoError)?;
        // Start the PE with the binary and two local arguements
        pe1.start(
            vec![
                DataTransferLocal(
                    Transfer {
                        data: bytes.clone().into_boxed_slice(),
                        free: true,
                        from_device: false,
                        to_device: true,
                        fixed: None,
                    },
                ),
                //Single64(42),
                //Single64(1337),
            ]
        ).context(JobError)?;
    } else {
        pe1.start(vec![]).context(JobError)?;
    }

    println!("Started PE1");

    // enabling debug will create the UNIX socket
    pe1.enable_debug().unwrap();

    match pe1.release(false, true) {
        Ok(ret) => println!("Got return value: {:?}", ret),
        Err(e) => return Err(Error::ReleasePeError{ source: e }),
    };

    Ok(())
}

fn start_debugging() -> Result<()> {
    // Get file_name and pe_id from CLI arguments
    let args: Vec<String> = std::env::args().collect();
    let empty = "".to_string();
    let file_name: &String = match args.len() {
        x if x > 1 => &args[1],
        _ => &empty,
    };
    let pe_id: usize = match args.len() {
        x if x > 2 => args[2].parse().context(ParsePeIdError)?,
        _ => DEFAULT_PE_ID,
    };

    // Create a hash map with the RiscvDebugGenerator
    let mut debug_generators: HashMap<String, Box<dyn DebugGenerator + Sync + Send>> = HashMap::new();
    // TODO rename to RiscvDebug
    debug_generators.insert("RiscvDebug".to_string(), Box::new(RiscvDebugGenerator{}));

    // Prepare device and PE
    let tlkm = TLKM::new().context(TLKMInit)?;
    let devices = allocate_devices(&tlkm, debug_generators)?;
    print_status(&devices)?;

    debug_binary(&devices[0], &file_name, pe_id)?;

    Ok(())
}

fn main() {
    if let Err(e) = start_debugging() {
        println!("Debugging returned error:\n{}", e);
        process::exit(1);
    }

    println!("Debugging Finished");
}

