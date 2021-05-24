#pragma once

#include "DMI_Types.hpp"

namespace v2dmi {

    class DMI_Handler {
      private:
        static constexpr int waitForResponseLatency = 2;

        void returnResponse(const DMI_Response &response);
        bool receiveRequest(DMI_Request &request);

      public:
        template <class Top>
        void tick(Top *ptop);

      private:
        // internal state
        bool busy = false;
        int latency = 0;
    };

} // namespace v2dmi

#include "DMI_Handler.tpp"
