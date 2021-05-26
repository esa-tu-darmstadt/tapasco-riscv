#ifndef DM_TESTBENCH_INTERFACE_HPP
#define DM_TESTBENCH_INTERFACE_HPP

#include "dm_interface.hpp"


namespace dm
{
    /*
        TB stuff
     */

    class DM_TestBenchInterface : public DM_Interface
    {
    private:
        /* DMI requests/reponses */
        std::queue<v2dmi::DMI_Request> dmi_request_queue;
        std::queue<v2dmi::DMI_Response> dmi_response_queue;
    public:
        uint32_t read_dm(uint32_t addr) override;
        void write_dm(uint32_t addr, uint32_t data) override;

        void tick();

        /* interface for test bench */
        std::optional<v2dmi::DMI_Request> pop_dmi_request();
        void push_dmi_response(const v2dmi::DMI_Response& resp);
    };
}

#endif /* DM_TESTBENCH_INTERFACE_HPP */