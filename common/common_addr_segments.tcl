# TaPaSCo address segments
create_bd_addr_seg -range 0x00004000 -offset 0x11000000 [get_bd_addr_spaces AXIGate_0/maxi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0

set addr_width [get_property CONFIG.ADDR_WIDTH $cpu_dmem]
if {$addr_width == 32} {
	create_bd_addr_seg -range 2G -offset 0x80000000 [get_external_mem_addr_space] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
	create_bd_addr_seg -range 4G -offset 0x00000000 [get_bd_addr_spaces dmaOffset/M_AXI] [get_bd_addr_segs M_AXI/Reg] SEG_MAXI_Reg
	set_property CONFIG.OVERWRITE_BITS 1 [get_bd_cells dmaOffset]
} {
	create_bd_addr_seg -range 256T -offset 0x0001000000000000 [get_external_mem_addr_space] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
	create_bd_addr_seg -range 16E -offset 0x00000000 [get_bd_addr_spaces dmaOffset/M_AXI] [get_bd_addr_segs M_AXI/Reg] SEG_MAXI_Reg
	set_property CONFIG.OVERWRITE_BITS 16 [get_bd_cells dmaOffset]
}

if {$maxi_ports == 2} {
	if {$addr_width == 32} {
		error "A second AXI master is not supported yet on a 32bit RISC-V core."
	}
	create_bd_addr_seg -range 256T -offset 0x0002000000000000 [get_external_mem_addr_space] [get_bd_addr_segs dmaOffset2/S_AXI/reg0] SEG_dmaOffset2_reg0
	create_bd_addr_seg -range 16E -offset 0x00000000 [get_bd_addr_spaces dmaOffset2/M_AXI] [get_bd_addr_segs M_AXI2/Reg] SEG_MAXI2_Reg
	set_property CONFIG.OVERWRITE_BITS 16 [get_bd_cells dmaOffset2]
}

create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs AXIGate_0/saxi/reg0] SEG_AXIGate_0_reg0
create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces S_AXI_BRAM] [get_bd_addr_segs ps_dmem_ctrl/S_AXI/Mem0] SEG_ps_dmem_ctrl_Mem0
create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces S_AXI_BRAM] [get_bd_addr_segs ps_imem_ctrl/S_AXI/Mem0] SEG_ps_imem_ctrl_Mem0


create_specific_addr_segs
