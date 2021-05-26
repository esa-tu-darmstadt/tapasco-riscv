#include "dm_interface.hpp"

#include <iostream>
#include <sstream>
#include <cassert>


namespace dm
{
    /*
        DM_Interface
     */
   
    Response DM_Interface::process_dtm(const Request& req)
    {
        Response resp{.isRead = req.isRead};

        if (req.isRead) {
            if (req.addr == 0x8) {
                resp.success = 1;
                resp.data = 0x71;

                response_queue_lock.lock();
                response_queue.push(resp);
                response_queue_lock.unlock();
            }

            if (req.addr == 0x10 || req.addr == 0xC) {
                /* data register */
                resp = process_dm(req);
            }
        } else {
            if (req.addr == 0x10 || req.addr == 0xC) {
                /* data register */
                resp = process_dm(req);
            }
        }

        return Response{.isRead = req.isRead, .data = 0x0, .success = 1};
    }

    Response DM_Interface::process_dm(const Request& req)
    {
        if (req.addr > sizeof(DM_RegisterFile) / 4)
                return invalid(req);

        if (req.isRead) {
            uint32_t data = read_dm(req.addr);
            return valid(req, data);
        } else {
            write_dm(req.addr, req.data);
            return valid(req);
        }

        /* I trust nobody */
        assert(false);
    }

    Response DM_Interface::process_register(const Request& req)
    {
        /* register access is done by executing the abstract command "access register" by writing into the command register */
        if (req.isRead) {
            /*
                cmdtype = 0                     read
                aarsize = 2                     access the lowest 32 bit of the register
                aarpostincrement = 0            no
                postexec = 0                    no
                transfer = 1                    do the operation specified by write
                write = 0                       copy data from arg0 portion of data into the specified register
                regno = req.addr                number of registers to access
             */
            uint32_t command = (2 << 20) | (1 << 17) | req.addr;
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_COMMAND) / 4, command);

            return valid(req, read_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_DATA_0) / 4));
        } else {
            /*
                cmdtype = 0                     read
                aarsize = 2                     access the lowest 32 bit of the register
                aarpostincrement = 0            no
                postexec = 1                    execute the program in the program buffer exactly once after this operation
                transfer = 1                    do the operation specified by write
                write = 0                       copy data from arg0 portion of data into the specified register
                regno = req.addr                number of registers to access
             */
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_DATA_0) / 4, req.data);
            uint32_t command = (2 << 20) | (1 << 17) | (1 << 16) | req.addr;
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_COMMAND) / 4, command);

            return valid(req);
        }

        /* I trust nobody */
        assert(false);
    }

    Response DM_Interface::process_memory(const Request& req)
    {
        if (req.isRead) {
            /*
                cmdtype = 2                     memory access
                aamvirtual = 0                  physical address
                aamsize = 2                     access lowest 32 bit of memory
                aampostincrement = 0            no
                write = 0                       copy data from memory into [arg1, arg0]
                target-specific = 0             unused
             */
            /* memory location in reg1 */
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_DATA_1) / 4, req.addr);

            /* write command to command register */
            uint32_t command = (2 << 24) | (2 << 20);
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_COMMAND) / 4, command);

            return valid(req, read_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_DATA_0) / 4));
        } else {
            /*
                cmdtype = 2                     memory access
                aamvirtual = 0                  physical address
                aamsize = 2                     access lowest 32 bit of memory
                aampostincrement = 0            no
                write = 1                       copy data from [arg1, arg0] into memory
                target-specific = 0             unused
             */
            /* memory location in reg1 */
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_DATA_1) / 4, req.addr);

            /* data in reg0 */
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_DATA_0) / 4, req.data);

            /* write command to command register */
            uint32_t command = (2 << 24) | (2 << 20) | (1 << 16);
            write_dm(offsetof(DM_RegisterFile, DM_ABSTRACT_COMMAND) / 4, command);

            return valid(req);
        }

        /* I trust nobody */
        assert(false);
    }

    Response DM_Interface::process_bus(const Request& req)
    {
        if (req.isRead) {
            /*
                sbversion = 0
                sbbusyerror = 0
                sbbusy = 0
                sbreadonaddr = 1                sbaddress is incremented by access size
                sbaccess = 2                    32 bit access
                sbautoincrement = 0
                sbreadondata = 0
                sberror = 0
                sbasize = 0
                ...
             */

            uint32_t command = (2 << 17) | (1 << 20);
            write_dm(offsetof(DM_RegisterFile, DM_SYSTEM_BUS_ACCESS_CONTROL_AND_STATUS) / 4, command);
            write_dm(offsetof(DM_RegisterFile, DM_SYSTEM_BUS_ADDRESS_0) / 4, command);

            return valid(req, read_dm(offsetof(DM_RegisterFile, DM_SYSTEM_BUS_DATA_0) / 4));
        } else {
            /* TODO: Everything at default, really? */
            uint32_t command = 0;

            write_dm(offsetof(DM_RegisterFile, DM_SYSTEM_BUS_ACCESS_CONTROL_AND_STATUS) / 4, command);
            write_dm(offsetof(DM_RegisterFile, DM_SYSTEM_BUS_ADDRESS_0) / 4, req.addr);
            write_dm(offsetof(DM_RegisterFile, DM_SYSTEM_BUS_DATA_0) / 4, req.data);

            return valid(req);
        }

        /* I trust nobody */
        assert(false);
    }

    Response DM_Interface::process_control(const Request& req)
    {
        switch (req.ctrlType) {
            case Request_ControlType_halt:
                std::cout << "Halt not implemented!" << std::endl;
                return valid(req);
                break;
	        case Request_ControlType_resume:
                write_dm(offsetof(DM_RegisterFile, DM_DEBUG_MODULE_CONTROL), 0x40000001);
                std::cout << "Resuming..." << std::endl;
                return valid(req);
	        case Request_ControlType_step:
            std::cout << "Step not implemented!" << std::endl;
                return valid(req);
                break;
	        case Request_ControlType_reset:
                std::cout << "Reset not implemented!" << std::endl;
                return valid(req);
            default:
                std::cout << "Unknown control type!" << std::endl;
                return invalid(req);
        }

        return invalid(req);
    }

    Response DM_Interface::process_request(const Request& req)
    {
        std::cout << req_to_string(req) << std::endl;

        switch (req.type) {
            case Request_RequestType_dtm:
                return process_dtm(req);
            case Request_RequestType_dm:
                return process_dm(req);
            case Request_RequestType_register:
                return process_register(req);
            case Request_RequestType_memory:
                return process_memory(req);
            case Request_RequestType_systemBus:
                return process_bus(req);
            case Request_RequestType_control:
                return process_control(req);
            default:
                std::cout << "WARNING: Unknown request type " << req.type << std::endl;
                break;
        }

        /* error */
        return invalid(req);
    }

    void DM_Interface::push_request(const Request& req)
    {
        request_queue_lock.lock();
        request_queue.push(req);
        request_queue_lock.unlock();
    }

    std::optional<Response> DM_Interface::pop_response()
    {
        std::optional<Response> result;

        if (response_queue_lock.try_lock()) {
            if (!response_queue.empty()) {
                Response resp = response_queue.front();
                response_queue.pop();
                result = resp;
            }

            response_queue_lock.unlock();
        }

        return result;
    }

    /*
        OpenOCDServer
     */

    void OpenOCDServer::handle_connection(int connection_fd)
    {
        std::vector<char> buf(4096);
        ssize_t n;

        /* read data */
        while (true) {
            n = recv(connection_fd, buf.data(), buf.size(), MSG_DONTWAIT);

            if (n < 0) {
                if (errno != EAGAIN && errno != EWOULDBLOCK)
                    break; /* some error */

                /* check for response and build it */
                auto dm_resp = dm_interface->pop_response();

                if (dm_resp) {
                    capn c;
                    capn_init_malloc(&c);
                    capn_ptr cr = capn_root(&c);
                    capn_segment *cs = cr.seg;

                    /* THIS IS NOT THREAD SAFE! IT'S THE USER'S RESPONSIBILITY TO ONLY HAVE ONE CONNECTION AT ONCE! */
                    //resp = dm_interface->process_request(req);

                    Response resp = *dm_resp;

                    Response_ptr ptr = new_Response(cs);
                    write_Response(&resp, ptr);
                    capn_setp(capn_root(&c), 0, ptr.p);

                    capn_write_fd(&c, write /* function ptr! */ , connection_fd, 0 /* packed */);

                    capn_free(&c);
                }
            } else {
                //std::cout << "Received " << n << " bytes!" << std::endl;

                /* parse request */
                if (n > 0) {
                    Request req;

                    capn c;
                    capn_init_mem(&c, reinterpret_cast<const uint8_t *>(buf.data()), n, 0 /* packed */);

                    Request_ptr ptr;
                    
                    ptr.p = capn_getp(capn_root(&c), 0 /* off */, 1 /* resolve */);
                    read_Request(&req, ptr);

                    capn_free(&c);

                    dm_interface->push_request(req);
                }
            }            
        }

        std::cout << "Connection closed!" << std::endl;

        if (connection_fd != -1)
            close(connection_fd);
    }

    void OpenOCDServer::do_listen()
    {
        while (run_server) {
            /* only 1 connection at a time */
            int connection_fd = accept(socket_fd, nullptr, nullptr);

            if (connection_fd == -1) {
                if (errno == EWOULDBLOCK) {
                    //std::cout << "No pending connections; sleeping for one second!" << std::endl;
                    sleep(1);
                    continue;
                } else {
                    std::cout << "Error when accepting connection!" << std::endl;
                    break;
                }
            }
            
            std::cout << "Accepting connection..." << std::endl;
            std::thread th(&OpenOCDServer::handle_connection, this, connection_fd);
            th.detach();
        }
    }

    OpenOCDServer::OpenOCDServer(const char *socket_path, const std::shared_ptr<DM_Interface>& dm_interface):
        socket_file(socket_path),
        dm_interface(dm_interface)
    {
        socket_fd = socket(PF_UNIX, SOCK_STREAM | SOCK_NONBLOCK, 0);

        if (socket_fd < 0)
            throw std::runtime_error("Could not create socket!");
        
        std::cout << "Socket created!" << std::endl;

        unlink(socket_path);
        addr_str.sun_family = AF_UNIX;
        std::strcpy(addr_str.sun_path, socket_path);

        socklen_t addr_len = sizeof(addr_str.sun_family) + std::strlen(addr_str.sun_path);

        if (bind(socket_fd, (struct sockaddr *)&addr_str, addr_len))
            throw std::runtime_error("Could not bind socket!");

        if (listen(socket_fd, 5))
            throw std::runtime_error("Could not listen on socket!");
    }

    OpenOCDServer::~OpenOCDServer()
    {
        stop_listening();
        close(socket_fd);
        unlink(socket_file);
    }

    void OpenOCDServer::start_listening()
    {
        listen_thread = std::thread(&OpenOCDServer::do_listen, this);
        std::cout << "Started listening!" << std::endl;
    }

    void OpenOCDServer::stop_listening()
    {
        run_server = false;

        if (listen_thread.joinable()) {
            listen_thread.join();
            std::cout << "Stopped listening!" << std::endl;
        }
    }

    uint32_t DM_MemoryInterface::read_dm(uint32_t addr)
    {
        return *(reinterpret_cast<const uint32_t *>(&dm_register_file) + addr);
    }

    void DM_MemoryInterface::write_dm(uint32_t addr, uint32_t data)
    {
        *(reinterpret_cast<uint32_t *>(&dm_register_file) + addr) = data;
    }

    /*
        TB stuff
     */

    uint32_t DM_TestBenchInterface::read_dm(uint32_t addr)
    {
        v2dmi::DMI_Request req{
            .converterAddress = v2dmi::DMI_ConverterAddress::DMI_ADDR_REG_ADDR,
            .payload = addr,
            .dmiAccessType = v2dmi::DMI_AccessType::WRITE
        };

        dmi_request_queue.push(req);

        req = v2dmi::DMI_Request{
            .converterAddress = v2dmi::DMI_ConverterAddress::DMI_REG_ADDR,
            .payload = 0,
            .dmiAccessType = v2dmi::DMI_AccessType::READ
        };

        dmi_request_queue.push(req);

        /* unused */
        return 0;
    }

    void DM_TestBenchInterface::write_dm(uint32_t addr, uint32_t data)
    {
        v2dmi::DMI_Request req{
            .converterAddress = v2dmi::DMI_ConverterAddress::DMI_ADDR_REG_ADDR,
            .payload = addr,
            .dmiAccessType = v2dmi::DMI_AccessType::WRITE
        };

        dmi_request_queue.push(req);

        req = v2dmi::DMI_Request{
            .converterAddress = v2dmi::DMI_ConverterAddress::DMI_REG_ADDR,
            .payload = data,
            .dmiAccessType = v2dmi::DMI_AccessType::WRITE
        };

        dmi_request_queue.push(req);
    }

    void DM_TestBenchInterface::tick()
    {
        /* try to fetch request from socket */
        if (request_queue_lock.try_lock()) {
            if (!request_queue.empty()) {
                Request req = request_queue.front();
                request_queue.pop();

                std::cout << req_to_string(req) << std::endl;

                /* this will eventually push something onto the DMI request queue */
                switch (req.type) {
                    case Request_RequestType_dtm:
                        process_dtm(req);
                        break;
                    case Request_RequestType_dm:
                        process_dm(req);
                        break;
                    case Request_RequestType_register:
                        process_register(req);
                        break;
                    case Request_RequestType_memory:
                        process_memory(req);
                        break;
                    case Request_RequestType_systemBus:
                        process_bus(req);
                        break;
                    case Request_RequestType_control:
                        process_control(req);
                        break;
                    default:
                        std::cout << "WARNING: Unknown request type " << req.type << std::endl;
                        break;
                }
            }
            
            request_queue_lock.unlock();
        }

        /* try to fetch DMI response */
        if (dmi_response_queue.size() >= 2) {
            if (response_queue_lock.try_lock()) {

                // We always expect 2 DMI responses per Openocd request!
                dmi_response_queue.pop();
                v2dmi::DMI_Response dmi_resp = dmi_response_queue.front();
                dmi_response_queue.pop();

                Response resp{
                    .isRead = dmi_resp.isRead,
                    .data = dmi_resp.payload,
                    .success = dmi_resp.responseStatus
                };
                
                response_queue.push(resp);
                response_queue_lock.unlock();
            }
        }
    }

    std::optional<v2dmi::DMI_Request> DM_TestBenchInterface::pop_dmi_request()
    {
        if (!dmi_request_queue.empty()) {
            v2dmi::DMI_Request req = dmi_request_queue.front();
            dmi_request_queue.pop();
            return req;
        }

        return std::optional<v2dmi::DMI_Request>();
    }
    
    void DM_TestBenchInterface::push_dmi_response(const v2dmi::DMI_Response& resp)
    {
        dmi_response_queue.push(resp);
    }
}