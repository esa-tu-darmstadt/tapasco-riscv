#include "dm_testbench_interface.hpp"


namespace dm
{
    /*
        TB stuff
     */
    uint32_t DM_TestBenchInterface::read_dm(uint32_t addr)
    {

        v2dmi::DMI_Request req = v2dmi::DMI_Request{
            .converterAddress = static_cast<v2dmi::DMI_ConverterAddress>(addr),
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
            .converterAddress = static_cast<v2dmi::DMI_ConverterAddress>(addr),
            .payload = data,
            .dmiAccessType = v2dmi::DMI_AccessType::WRITE
        };

        dmi_request_queue.push(req);
    }


    std::optional<v2dmi::DMI_Request> DM_TestBenchInterface::pop_dmi_request()
    {
        // Loop until we have a dmi request!
        do {
            // Handle waiting requests
            if (!dmi_request_queue.empty()) {
                v2dmi::DMI_Request req = dmi_request_queue.front();
                dmi_request_queue.pop();
                return req;
            }

            // No more waiting request, check for new ones and wait if there is none
            if (!fifo->has_requests()) {
                fifo->wait_for_request();
            }

            /* try to fetch request from socket */
            std::optional<Request> opt_req = fifo->pop_request();

            if (opt_req) {
                Request req = *opt_req;
                //std::cout << req_to_string(req) << std::endl;

                /* this will eventually push something onto the DMI request queue */
                switch (req.type) {
                    case Request_RequestType_dtm:
                        process_dtm(req);
                        break;
                    case Request_RequestType_control:
                        process_control(req);
                        break;
                    default:
                        std::cout << "WARNING: Unknown request type " << req.type << std::endl;
                        break;
                }
            }
        }while(1);

        return std::optional<v2dmi::DMI_Request>();
    }

    void DM_TestBenchInterface::push_dmi_response(const v2dmi::DMI_Response &dmi_resp) {
        Response resp{
            .isRead = dmi_resp.isRead,
            .data = dmi_resp.payload,
            .success = dmi_resp.responseStatus};

        fifo->push_response(resp);
    }
}