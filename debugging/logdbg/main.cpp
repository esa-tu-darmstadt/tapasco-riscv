#include <iostream>
#include <csignal>
#include <memory>
#include "dm_interface.hpp"

static bool run = true;

static void signal_handler(int signum)
{
    if (signum == SIGINT) {
        std::cout << "Trying to exit..." << std::endl;
        run = false;
    }
}

int main()
{
    std::cout << "WARNING: All numbers are printed as hex from here on!" << std::hex << std::endl;

    std::signal(SIGINT, signal_handler);
    std::shared_ptr<dm::DM_MemoryInterface> dm_interface = std::make_shared<dm::DM_MemoryInterface>();
    dm::OpenOCDServer server("/tmp/riscv-debug.sock", dm_interface);

    server.start_listening();

    while (run) {

    }

    server.stop_listening();

    return 0;
}