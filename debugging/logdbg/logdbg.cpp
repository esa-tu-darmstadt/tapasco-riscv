#include <iostream>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#include "tlkm_ioctl_cmds.h"
#include "device.hpp"


#define TLKM_PATH "/dev/tlkm"
/* This is the driver for our specific device that holds one bitstream. */
#define TLKM_DEVICE_PATH "/dev/tlkm_00"


void print_version(int tlkm_fd)
{
    /* This should work. If it doesn't, there is no hope left. */
    tlkm_ioctl_version_cmd buf;
    
    if (ioctl(tlkm_fd, TLKM_IOCTL_VERSION, &buf)) {
        int e = errno;
        std::cout << "ioctl() failed with error " << strerror(e) << "!\n" <<
            "See dmesg for more info!" << std::endl;
        return;
    }

    std::cout << buf.version << std::endl; 
}

void list_devices(int tlkm_fd)
{
    tlkm_ioctl_enum_devices_cmd buf;

    if (ioctl(tlkm_fd, TLKM_IOCTL_ENUM_DEVICES, &buf)) {
        int e = errno;
        std::cout << "ioctl() failed with error " << strerror(e) << "!\n" <<
            "See dmesg for more info!" << std::endl;
        return;
    }

    for (size_t i = 0; i < buf.num_devs; ++i)
        std::cout << "index=" << i <<
            " dev_id=" << buf.devs[i].dev_id <<
            " vendor_id=" << buf.devs[i].vendor_id <<
            " product_id=" << buf.devs[i].product_id <<
            " name=" << buf.devs[i].name << '\n';

    std::cout << std::endl;
}

int main(int argc, const char **argv)
{
    Device device(TLKM_DEVICE_PATH);

    for (uint32_t i = 0x04; i <= 0x40; ++i) {
        uint32_t reg = device(i);
        std::cout << "reg " << std::hex << i << '=' << reg << std::endl;
    }

    return 0;
}