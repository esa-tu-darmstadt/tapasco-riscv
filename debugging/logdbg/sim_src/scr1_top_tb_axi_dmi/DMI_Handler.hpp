#pragma once

#include "DMI_Types.hpp"
#include "dm_interface.hpp"

namespace v2dmi {

    class DMI_Handler {
      private:
        static constexpr int waitForResponseLatency = 2;
        static constexpr int minIdleCyclesBetweenRequests = 5;

        void returnResponse(const DMI_Response &response);
        bool receiveRequest(DMI_Request &request);

      public:
        DMI_Handler(const std::shared_ptr<dm::DM_TestBenchInterface> &dm_interface) : dm_interface(dm_interface) {}

        template <class Top>
        void tick(Top *ptop);

      private:
        std::shared_ptr<dm::DM_TestBenchInterface> dm_interface;
        // internal state
        bool busy = false;
        int latency = 0;
        int idleCycles = 0;
        unsigned int isRead;
    };

} // namespace v2dmi

#include "DMI_Handler.tpp"
