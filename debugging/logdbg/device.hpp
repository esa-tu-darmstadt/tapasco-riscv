#ifndef DEVICE_HPP
#define DEVICE_HPP

#include <iostream>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#include "tlkm_ioctl_cmds.h"


/* This is the driver for our specific device that holds one bitstream. */
#define TLKM_DEVICE_PATH "/dev/tlkm_00"

#define DMI_DATA_REG 0x0c
#define DMI_ADDR_REG 0x10

/* debug module registers */
#define DM_ABSTRACT_DATA_0 0x04
#define DM_ABSTRACT_DATA_1 0x05
#define DM_ABSTRACT_DATA_2 0x06
#define DM_ABSTRACT_DATA_3 0x07
#define DM_ABSTRACT_DATA_4 0x08
#define DM_ABSTRACT_DATA_5 0x09
#define DM_ABSTRACT_DATA_6 0x0a
#define DM_ABSTRACT_DATA_7 0x0b
#define DM_ABSTRACT_DATA_8 0x0c
#define DM_ABSTRACT_DATA_9 0x0d
#define DM_ABSTRACT_DATA_10 0x0e
#define DM_ABSTRACT_DATA_11 0x0f
#define DM_DEBUG_MODULE_CONTROL 0x10
#define DM_DEBUG_MODULE_STATUS 0x11
#define DM_HART_INFO 0x12
#define DM_HART_SUMMARY_1 0x13
#define DM_HART_ARRAY_WINDOW_SELECT 0x14
#define DM_HART_ARRAY_WINDOW 0x15
#define DM_ABSTRACT_CONTROL_AND_STATUS 0x16
#define DM_ABSTRACT_COMMAND 0x17
#define DM_ABSTRACT_COMMAND_AUTOEXEC 0x18
#define DM_CONFIGURATION_STRING_POINTER_0 0x19
#define DM_CONFIGURATION_STRING_POINTER_1 0x1a
#define DM_CONFIGURATION_STRING_POINTER_2 0x1b
#define DM_CONFIGURATION_STRING_POINTER_3 0x1c
#define DM_NEXT_DEBUG_MODULE 0x1d
#define DM_PROGRAM_BUFFER_0 0x20
#define DM_PROGRAM_BUFFER_1 0x21
#define DM_PROGRAM_BUFFER_2 0x22
#define DM_PROGRAM_BUFFER_3 0x23
#define DM_PROGRAM_BUFFER_4 0x24
#define DM_PROGRAM_BUFFER_5 0x25
#define DM_PROGRAM_BUFFER_6 0x26
#define DM_PROGRAM_BUFFER_7 0x27
#define DM_PROGRAM_BUFFER_8 0x28
#define DM_PROGRAM_BUFFER_9 0x29
#define DM_PROGRAM_BUFFER_10 0x2a
#define DM_PROGRAM_BUFFER_11 0x2b
#define DM_PROGRAM_BUFFER_12 0x2c
#define DM_PROGRAM_BUFFER_13 0x2d
#define DM_PROGRAM_BUFFER_14 0x2e
#define DM_PROGRAM_BUFFER_15 0x2f
#define DM_AUTHENTICATION_DATA 0x30
#define DM_HALT_SUMMARY_2 0x34
#define DM_HALT_SUMMARY_3 0x35
#define DM_SYSTEM_BUS_ADDRESS_3 0x37
#define DM_SYSTEM_BUS_ACCESS_CONTROL_AND_STATUS 0x38
#define DM_SYSTEM_BUS_ADDRESS_0 0x39
#define DM_SYSTEM_BUS_ADDRESS_1 0x3a
#define DM_SYSTEM_BUS_ADDRESS_2 0x3b
#define DM_SYSTEM_BUS_DATA_0 0x3c
#define DM_SYSTEM_BUS_DATA_1 0x3d
#define DM_SYSTEM_BUS_DATA_2 0x3e
#define DM_SYSTEM_BUS_DATA_3 0x3f
#define DM_HALT_SUMMARY_0 0x40



/*
struct DM_RegisterFile
{
    uint32_t _unused_0[4];
    uint32_t DM_ABSTRACT_DATA_0;
    uint32_t DM_ABSTRACT_DATA_1;
    uint32_t DM_ABSTRACT_DATA_2;
    uint32_t DM_ABSTRACT_DATA_3;
    uint32_t DM_ABSTRACT_DATA_4;
    uint32_t DM_ABSTRACT_DATA_5;
    uint32_t DM_ABSTRACT_DATA_6;
    uint32_t DM_ABSTRACT_DATA_7;
    uint32_t DM_ABSTRACT_DATA_8;
    uint32_t DM_ABSTRACT_DATA_9;
    uint32_t DM_ABSTRACT_DATA_10;
    uint32_t DM_ABSTRACT_DATA_11;
    uint32_t DM_DEBUG_MODULE_CONTROL;
    uint32_t DM_DEBUG_MODULE_STATUS;
    uint32_t DM_HART_INFO;
    uint32_t DM_HART_SUMMARY_1;
    uint32_t DM_HART_ARRAY_WINDOW_SELECT;
    uint32_t DM_HART_ARRAY_WINDOW;
    uint32_t DM_ABSTRACT_CONTROL_AND_STATUS;
    uint32_t DM_ABSTRACT_COMMAND;
    uint32_t DM_ABSTRACT_COMMAND_AUTOEXEC;
    uint32_t DM_CONFIGURATION_STRING_POINTER_0;
    uint32_t DM_CONFIGURATION_STRING_POINTER_1;
    uint32_t DM_CONFIGURATION_STRING_POINTER_2;
    uint32_t DM_CONFIGURATION_STRING_POINTER_3;
    uint32_t DM_NEXT_DEBUG_MODULE;
    uint32_t _unused_1[2];
    uint32_t DM_PROGRAM_BUFFER_0;
    uint32_t DM_PROGRAM_BUFFER_1;
    uint32_t DM_PROGRAM_BUFFER_2;
    uint32_t DM_PROGRAM_BUFFER_3;
    uint32_t DM_PROGRAM_BUFFER_4;
    uint32_t DM_PROGRAM_BUFFER_5;
    uint32_t DM_PROGRAM_BUFFER_6;
    uint32_t DM_PROGRAM_BUFFER_7;
    uint32_t DM_PROGRAM_BUFFER_8;
    uint32_t DM_PROGRAM_BUFFER_9;
    uint32_t DM_PROGRAM_BUFFER_10;
    uint32_t DM_PROGRAM_BUFFER_11;
    uint32_t DM_PROGRAM_BUFFER_12;
    uint32_t DM_PROGRAM_BUFFER_13;
    uint32_t DM_PROGRAM_BUFFER_14;
    uint32_t DM_PROGRAM_BUFFER_15;
    uint32_t DM_AUTHENTICATION_DATA;
    uint32_t _unused_1[3];
    uint32_t DM_HALT_SUMMARY_2;
    uint32_t DM_HALT_SUMMARY_3;
    uint32_t _unused_2[1];
    uint32_t DM_SYSTEM_BUS_ADDRESS_3;
    uint32_t DM_SYSTEM_BUS_ACCESS_CONTROL_AND_STATUS;
    uint32_t DM_SYSTEM_BUS_ADDRESS_0;
    uint32_t DM_SYSTEM_BUS_ADDRESS_1;
    uint32_t DM_SYSTEM_BUS_ADDRESS_2;
    uint32_t DM_SYSTEM_BUS_DATA_0;
    uint32_t DM_SYSTEM_BUS_DATA_1;
    uint32_t DM_SYSTEM_BUS_DATA_2;
    uint32_t DM_SYSTEM_BUS_DATA_3;
    uint32_t DM_HALT_SUMMARY_0;
} __attribute__((packed));
*/

class DM_Interface
{
public:
    int tlkm_device_fd = -1;
    char *mmapped;
    /* Why? I don't know. This seems to somehow come from the organization of PEs. */
    const uintptr_t offset = 0x00010000;

    DM_Interface(const char *device_path);
    ~DM_Interface();

    /*
        Our DTM provides access to the DMI via memory mapped registers. We therefore talk directly
        to the DMI by reading and writing to correct memory locations.
    */
    class DM_Access
    {
    private:
        uint32_t *dmi_data_reg;
        uint32_t *dmi_addr_reg;
        uint32_t off;
    public:
        DM_Access(uint32_t *data_reg, uint32_t *addr_reg, uint32_t reg_off):
            dmi_data_reg(data_reg), dmi_addr_reg(addr_reg), off(reg_off) {}

        operator uint32_t() const
        {
            std::cout << std::hex << dmi_addr_reg << std::endl;

            *dmi_addr_reg = off;
            return *dmi_data_reg;
        }

        void operator=(uint32_t value)
        {
            *dmi_data_reg = value;
            *dmi_addr_reg = off;
        }
    };

    /* DM interface */
    DM_Access operator()(uint32_t reg_off);
};

#endif /* DEVICE_HPP */