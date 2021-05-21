#include "dm_interface.hpp"

#include <iostream>
#include <sstream>


namespace dm
{
    void OpenOCDServer::handle_connection(int connection_fd)
    {
        std::vector<char> buf(4096);
        ssize_t n;

        /* read data */
        while ((n = recv(connection_fd, buf.data(), buf.size(), 0)) != -1) {
            Request req;
            Response resp;

            /* parse request */
            {
                capn c;
                capn_init_mem(&c, reinterpret_cast<const uint8_t *>(buf.data()), n, 0 /* packed */);

                Request_ptr ptr;
                
                ptr.p = capn_getp(capn_root(&c), 0 /* off */, 1 /* resolve */);
                read_Request(&req, ptr);
            }

            /* build response */
            {
                capn c;
                capn_init_malloc(&c);
                capn_ptr cr = capn_root(&c);
                capn_segment *cs = cr.seg;

                /* THIS IS NOT THREAD SAFE! IT'S THE USER'S RESPONSIBILITY TO ONLY HAVE ONE CONNECTION AT ONCE! */
                resp = dm_interface->process_request(req);

                Response_ptr ptr = new_Response(cs);
                write_Response(&resp, ptr);
                capn_setp(capn_root(&c), 0, ptr.p);

                capn_write_fd(&c, write /* function ptr! */ , connection_fd, 0 /* packed */);
            }
        }

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

    std::string DM_MemoryInterface::req_to_string(const Request& req) const
    {
        std::stringstream ss;

        if (req.isRead)
            ss << "READ ";
        else
            ss << "WRITE ";

        switch (req.type) {
            case Request_RequestType_dtm:
                ss << "DTM";
                break;
            case Request_RequestType_dm:
                ss << "DM";
                break;
            case Request_RequestType_register:
                ss << "REG";
                break;
            case Request_RequestType_memory:
                ss << "MEM";
                break;
            case Request_RequestType_systemBus:
                ss << "BUS";
                break;
            case Request_RequestType_control:
                ss << "CTRL";
                break;
            default:
                return "INVALID";
        }

        ss << " from/to " << std::hex << req.addr;

        if (!req.isRead)
            ss << " value " << req.data;
        
        return ss.str();
    }

    Response DM_MemoryInterface::process_read_dtm(const Request& req)
    {
        if (req.addr == 8)
            return Response{.isRead = req.isRead, .data = 0x71, .success = 1};

        return Response{.isRead = req.isRead, .data = 0x0, .success = 1};
    }

    Response DM_MemoryInterface::process_request(const Request& req)
    {
        std::cout << req_to_string(req) << std::endl;

        switch (req.type) {
            case Request_RequestType_dtm:
                if (req.isRead)
                    return process_read_dtm(req);

                break;
            case Request_RequestType_dm:
                break;
            case Request_RequestType_register:
                break;
            case Request_RequestType_memory:
                break;
            case Request_RequestType_systemBus:
                break;
            case Request_RequestType_control:
                break;
            default:
                std::cout << "WARNING: Unknown request type " << req.type << std::endl;
                break;
        }

        /* error */
        return Response{
            .isRead = req.isRead,
            .success = 0
        };
    }
}