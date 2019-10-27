# Create instance: taiga_0, and set properties
set taiga_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] taiga_0 ]
set cpu_clk [get_bd_pins taiga_0/clk]

# Create interface connections
set axi_io_port [get_bd_intf_pins taiga_0/m_axi]
set axi_mem_port [get_bd_intf_pins taiga_0/m_axi_cache]

set ibram [get_bd_intf_pins taiga_0/instruction_bram]
set dbram [get_bd_intf_pins taiga_0/data_bram]

# Create port connections
connect_bd_net [get_bd_pins RVController_0/rv_reset] [get_bd_pins taiga_0/rst]

# Create specific address segments
create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces taiga_0/m_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces taiga_0/m_axi_cache] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
