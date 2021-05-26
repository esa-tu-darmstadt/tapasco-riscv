#ifndef DM_MEMORY_INTERFACE_HPP
#define DM_MEMORY_INTERFACE_HPP

#include "dm_interface.hpp"


namespace dm
{
    /*
        In-memory stuff
     */

    

    class DM_MemoryInterface : public DM_Interface
    {
    private:
        DTM_RegisterFile dtm_register_file;
        DM_RegisterFile dm_register_file;
    public:
        virtual uint32_t read_dm(uint32_t addr) override;
        virtual void write_dm(uint32_t addr, uint32_t data) override;
    };
}

#endif /* DM_MEMORY_INTERFACE_HPP */