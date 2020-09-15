# TaPaSCo address segments
create_bd_addr_seg -range 0x00004000 -offset 0x11000000 [get_bd_addr_spaces AXIGate_0/maxi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces dmaOffset/M_AXI] [get_bd_addr_segs M_AXI/Reg] SEG_MAXI_Reg
create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs AXIGate_0/saxi/reg0] SEG_AXIGate_0_reg0
create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces S_AXI_BRAM] [get_bd_addr_segs ps_dmem_ctrl/S_AXI/Mem0] SEG_ps_dmem_ctrl_Mem0
create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces S_AXI_BRAM] [get_bd_addr_segs ps_imem_ctrl/S_AXI/Mem0] SEG_ps_imem_ctrl_Mem0

create_specific_addr_segs
