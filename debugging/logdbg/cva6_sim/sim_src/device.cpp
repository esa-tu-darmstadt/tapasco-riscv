#include "device.hpp"


/*
const DMI_DATA_REG: isize = 0x0c;
const DMI_ADDR_REG: isize = 0x10;

const DM_DATA0_REG: u32         = 0x04;
const DM_DATA1_REG: u32         = 0x05;
const DM_DMCONTROL_REG: u32     = 0x10;
const DM_COMMAND_REG: u32       = 0x17;
const DM_SBCS_REG: u32          = 0x38;
const DM_SBADDRESS0_REG: u32    = 0x39;
const DM_SBDATA0_REG: u32       = 0x3c;
*/

DM_Interface::DM_Interface(const char *device_path)
{
    tlkm_device_fd = open(device_path, O_RDWR);

    if (tlkm_device_fd == -1)
        throw std::runtime_error("Could not open device file!");

    std::cout << "Opened device file!" << std::endl;

    mmapped = reinterpret_cast<char *>(mmap(nullptr, 0x20000, PROT_READ | PROT_WRITE, MAP_SHARED, tlkm_device_fd, 0));

    if (mmapped == MAP_FAILED) {
        int err_num = errno;
        std::cout << strerror(err_num) << std::endl;

        close(tlkm_device_fd);
        throw std::runtime_error("Could not map memory!");
    }

    std::cout << "Mapped core control memory!" << std::endl;
}

DM_Interface::~DM_Interface()
{
    munmap(mmapped, 0x20000);
    close(tlkm_device_fd);

    std::cout << "Unmapped memory and closed device!" << std::endl;
}

DM_Interface::DM_Access Device::operator()(uint32_t reg_off)
{
    std::cout << offset + DMI_DATA_REG << std::endl;

    return DM_Access(reinterpret_cast<uint32_t *>(mmapped + offset + DMI_DATA_REG),
        reinterpret_cast<uint32_t *>(mmapped + offset + DMI_ADDR_REG),
        reg_off);
}