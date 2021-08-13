#include "DMI_Handler.hpp"

#include <iostream>

namespace v2dmi {

    void DMI_Handler::returnResponse(const DMI_Response &response) {
        dm_interface->push_dmi_response(response);
    }

    bool DMI_Handler::receiveRequest(DMI_Request &request, const volatile bool &run) {
        if (auto req = dm_interface->pop_dmi_request(run)) {
            request = *req;
            return true;
        }

        return false;
    }

    template <class Top>
    void DMI_Handler::tick(Top *ptop, const volatile bool &run) {
        if (latency > 0) {
            // Request flag is only set for one cycle -> clear it
            ptop->dmi_req = 0;
            --latency;
        } else if (busy) {
            // We have waited long enough to read the reponse
            DMI_Response response;
            response.payload = ptop->dmi_rdata;
            response.responseStatus = SUCCESS;
            response.isRead = isRead;
            returnResponse(response);

            // We have processed the request -> clear busy flag
            busy = false;
            // Ensure a minimum of x cycles between the next request!
            idleCycles = idleBetweenRequests;
        } else {
            if (idleCycles > 0) {
                --idleCycles;
            } else {
                DMI_Request request;

                if (receiveRequest(request, run)) {
                    // Returns true if a request is available for processing
                    isRead = request.dmiAccessType == WRITE ? 0 : 1;

                    // Handle request by resolving the pseudo request address and changing values at DM interface ports
                    switch (request.converterAddress) {
                        case CTRL_REG_ADDR: {
                            // AxiToDMI always returns the same values here
                            DMI_Response response;
                            response.payload = 0x0C751;
                            response.responseStatus = SUCCESS;
                            response.isRead = isRead;

                            if (!isRead) {
                                std::cout << "Strange Request!" << std::endl;
                            }

                            returnResponse(response);
                            break;
                        }

                        case IDCODE_REG_ADDR: {
                            // AxiToDMI always returns the same values here
                            DMI_Response response;
                            response.payload = 0x0D41;
                            response.responseStatus = SUCCESS;
                            response.isRead = isRead;

                            if (!isRead) {
                                std::cout << "Strange Request!" << std::endl;
                            }

                            returnResponse(response);
                            break;
                        }

                        case DTMCS_REG_ADDR: {
                            // AxiToDMI always returns the same values here
                            DMI_Response response;
                            response.payload = 0x0D74C;
                            response.responseStatus = SUCCESS;
                            response.isRead = isRead;

                            if (!isRead) {
                                std::cout << "Strange Request!" << std::endl;
                            }

                            returnResponse(response);
                            break;
                        }

                        case DMI_ADDR_REG_ADDR: {
                            // Apply a new addr value
                            //std::cout << "Write DMI addr: " << std::hex << request.payload << std::endl;
                            ptop->dmi_addr = request.payload & 0x7F;

                            // AxiToDMI always returns the same values here
                            DMI_Response response;
                            response.payload = 0x0ADD5;
                            response.responseStatus = SUCCESS;
                            response.isRead = isRead;
                            returnResponse(response);
                            break;
                        }

                        case DMI_REG_ADDR: {
                            // Set wdata register and issue a new DM request
                            //std::cout << "Write DMI wdata: " << std::hex << request.payload << std::endl;
                            // Apply data
                            ptop->dmi_wdata = request.payload;

                            // Issue request
                            ptop->dmi_req = 1;
                            ptop->dmi_wr = request.dmiAccessType == WRITE ? 1 : 0;

                            // Set wait latency and change busy state
                            latency = waitForResponseLatency;
                            busy = true;
                            break;
                        }

                        default:
                            std::cerr << "DMI Handler: Invalid request address: " << std::hex << request.converterAddress << "!" << std::endl;
                            break;
                    }
                }
            }
        }
    }

} // namespace v2dmi