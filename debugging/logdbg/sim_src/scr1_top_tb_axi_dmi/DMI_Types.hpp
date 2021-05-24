#pragma once

#include <cstdint>

namespace v2dmi {

    typedef enum : uint8_t {
        CTRL_REG_ADDR = 0x00,
        IDCODE_REG_ADDR = 0x04,
        DTMCS_REG_ADDR = 0x08,
        DMI_REG_ADDR = 0x0C,
        DMI_ADDR_REG_ADDR = 0x10
    } DMI_ConverterAddress;

    typedef enum {
        READ,
        WRITE
    } DMI_AccessType;

    typedef struct {
        DMI_ConverterAddress converterAddress;
        uint32_t payload;
        DMI_AccessType dmiAccessType;
    } DMI_Request;

    typedef enum {
        SUCCESS,
        FAILED,
        BUSY
    } DMI_ResponseStatus;

    typedef struct {
        uint32_t payload;
        DMI_ResponseStatus responseStatus;
    } DMI_Response;

} // namespace v2dmi

#include "DMI_Handler.tpp"