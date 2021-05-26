#include "dm_memory_interface.hpp"


namespace dm
{
    uint32_t DM_MemoryInterface::read_dm(uint32_t addr)
    {
        return *(reinterpret_cast<const uint32_t *>(&dm_register_file) + addr);
    }

    void DM_MemoryInterface::write_dm(uint32_t addr, uint32_t data)
    {
        *(reinterpret_cast<uint32_t *>(&dm_register_file) + addr) = data;
    }
}