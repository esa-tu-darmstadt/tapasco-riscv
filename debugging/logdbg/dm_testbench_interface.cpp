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
        if (dmi_response_queue.size() >= 1) {
            if (response_queue_lock.try_lock()) {

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