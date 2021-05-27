#include "dm_interface.hpp"

#include "ringbuf.hpp"


namespace dm
{
    void RequestResponseFIFO::push_request(const Request& req)
    {
        request_queue_mutex.lock();
        request_queue.push(req);
        request_queue_mutex.unlock();

        /* notfiy AFTER unlocking */
        request_cv.notify_one();
    }

    std::optional<Response> RequestResponseFIFO::pop_response()
    {
        if (!response_queue_mutex.try_lock())
            return std::optional<Response>();

        if (response_queue.empty()) {
            response_queue_mutex.unlock();
            return std::optional<Response>();
        }

        Response resp = response_queue.front();
        response_queue.pop();
        response_queue_mutex.unlock();

        return resp;
    }

    bool RequestResponseFIFO::has_response()
    {
        std::lock_guard<std::mutex> lk(response_queue_mutex);
        return !response_queue.empty();
    }

    void RequestResponseFIFO::wait_for_response(volatile bool& early_abort_neg)
    {
        std::unique_lock<std::mutex> lk(response_queue_mutex);
        response_cv.wait(lk, [this, &early_abort_neg]{ return !response_queue.empty() || !early_abort_neg; });
    }

    void RequestResponseFIFO::push_response(const Response& resp)
    {
        response_queue_mutex.lock();
        response_queue.push(resp);
        response_queue_mutex.unlock();

        /* notfiy AFTER unlocking */
        response_cv.notify_one();
    }

    std::optional<Request> RequestResponseFIFO::pop_request()
    {
        std::optional<Request> result;

        if (request_queue_mutex.try_lock()) {
            if (!request_queue.empty()) {
                result = request_queue.front();
                request_queue.pop();
            }

            request_queue_mutex.unlock();
        }

        return result;
    }

    bool RequestResponseFIFO::has_requests()
    {
        std::lock_guard<std::mutex> lk(request_queue_mutex);
        return !request_queue.empty();
    }

    void RequestResponseFIFO::wait_for_request()
    {
        std::unique_lock<std::mutex> lk(request_queue_mutex);
        request_cv.wait(lk, [this]{ return !request_queue.empty(); });
    }

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

                fifo->push_response(resp);
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

    DM_Interface::DM_Interface(const std::shared_ptr<RequestResponseFIFO>& fifo):
        fifo(fifo)
    {

    }

    /*
        OpenOCDServer
     */

    void OpenOCDServer::handle_connection(int connection_fd)
    {
        std::thread recv_thread([connection_fd, this]() {
            std::cout << "recv_thread started" << std::endl;
            //RingBuf ring_buf(4096);
            std::vector<char> buf(4096);
            ssize_t n;

            while (true) {
                std::cout << "Calling recv()" << std::endl;
                n = recv(connection_fd, buf.data(), buf.size(), 0);

                if (!run_server)
                    break;

                if (n < 0)
                    break; /* some error */

                std::cout << "got " << n << "bytes" << std::endl;

                if (n == 0)
                    continue; /* nothing interesting */

                Request req;

                capn c;
                capn_init_mem(&c, reinterpret_cast<const uint8_t *>(buf.data()), n, 0 /* packed */);

                Request_ptr ptr;
                
                ptr.p = capn_getp(capn_root(&c), 0 /* off */, 1 /* resolve */);
                read_Request(&req, ptr);

                capn_free(&c);

                fifo->push_request(req);
            }

            std::cout << "exiting recv_thread()" << std::endl;
        });

        std::thread send_thread([connection_fd, this]() {
            while (true) {
                if (!run_server)
                    break;

                //fifo->wait_for_response(run_server);

                std::optional<Response> opt_resp = fifo->pop_response();

                if (!opt_resp)
                    continue;

                Response resp = *opt_resp;

                /* this must be done every time, idk why */
                capn c;
                capn_init_malloc(&c);
                capn_ptr cr = capn_root(&c);
                capn_segment *cs = cr.seg;

                Response_ptr ptr = new_Response(cs);
                write_Response(&resp, ptr);
                capn_setp(capn_root(&c), 0, ptr.p);

                int result = capn_write_fd(&c, write /* function ptr! */ , connection_fd, 0 /* packed */);

                capn_free(&c);

                if (result < 0)
                    break; /* some error */
            }

            std::cout << "exiting send_thread()" << std::endl;
        });

        recv_thread.join();
        send_thread.join();

        std::cout << "Connection closed!" << std::endl;

        if (connection_fd != -1)
            close(connection_fd);
    }

    void OpenOCDServer::do_listen()
    {
        std::vector<std::thread> connection_threads;

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
            
            connection_threads.emplace_back(&OpenOCDServer::handle_connection, this, connection_fd);
        }

        for (auto& th : connection_threads)
            if (th.joinable())
                th.join();
    }

    OpenOCDServer::OpenOCDServer(const char *socket_path, const std::shared_ptr<RequestResponseFIFO>& fifo):
        socket_file(socket_path),
        fifo(fifo)
    {
        socket_fd = socket(PF_UNIX, SOCK_STREAM, 0);

        if (socket_fd < 0)
            throw std::runtime_error("Could not create socket!");
        
        struct timeval tv;
        tv.tv_sec = 1;
        tv.tv_usec = 0;
        if (setsockopt(socket_fd, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof(tv)) == -1)
            std::cout << "Could not set socket options" << std::endl;

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
}