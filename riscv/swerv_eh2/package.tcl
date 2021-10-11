puts "package WDC's SweRV_eh2"
# start_gui

# set path variables
set proj_name swerv_eh2
set version 1.4
set src_origin Cores-SweRV-EH2
# -part xc7vx485tffg1157-1

create_project ${proj_name} ${proj_name} -part xc7vx485tffg1157-1
# create_project -in_memory
add_files -scan_for_includes ${src_origin}/snapshots/default/pd_defines.vh ${src_origin}/snapshots/default/eh2_param.vh ${src_origin}/snapshots/default/pic_map_auto.h ${src_origin}/snapshots/default/eh2_pdef.vh ${src_origin}/snapshots/default/defines.h ${src_origin}/snapshots/default/common_defines.vh ${src_origin}/design/lib/ahb_to_axi4.sv ${src_origin}/design/dec/eh2_dec.sv ${src_origin}/design/ifu/eh2_ifu_bp_ctl.sv ${src_origin}/design/eh2_swerv.sv ${src_origin}/design/lib/eh2_lib.sv ${src_origin}/design/eh2_pic_ctrl.sv ${src_origin}/design/lsu/eh2_lsu_bus_buffer.sv ${src_origin}/design/lib/mem_lib.sv ${src_origin}/design/lsu/eh2_lsu_bus_intf.sv ${src_origin}/design/lib/beh_lib.sv ${src_origin}/design/lsu/eh2_lsu_trigger.sv ${src_origin}/design/eh2_dma_ctrl.sv ${src_origin}/design/dmi/dmi_jtag_to_core_sync.v ${src_origin}/design/dmi/dmi_wrapper.v ${src_origin}/design/ifu/eh2_ifu_tb_memread.sv ${src_origin}/design/lsu/eh2_lsu_dccm_mem.sv ${src_origin}/design/exu/eh2_exu_alu_ctl.sv ${src_origin}/design/lsu/eh2_lsu.sv ${src_origin}/design/ifu/eh2_ifu.sv ${src_origin}/design/exu/eh2_exu.sv ${src_origin}/design/dec/eh2_dec_tlu_top.sv ${src_origin}/design/lib/axi4_to_ahb.sv ${src_origin}/design/lsu/eh2_lsu_clkdomain.sv ${src_origin}/design/eh2_swerv_wrapper.sv ${src_origin}/design/ifu/eh2_ifu_btb_mem.sv ${src_origin}/design/dmi/rvjtag_tap.v ${src_origin}/design/ifu/eh2_ifu_compress_ctl.sv ${src_origin}/design/dbg/eh2_dbg.sv ${src_origin}/design/ifu/eh2_ifu_iccm_mem.sv ${src_origin}/design/ifu/eh2_ifu_ifc_ctl.sv ${src_origin}/design/dec/eh2_dec_csr.sv ${src_origin}/design/lsu/eh2_lsu_ecc.sv ${src_origin}/design/ifu/eh2_ifu_mem_ctl.sv ${src_origin}/design/dec/eh2_dec_ib_ctl.sv ${src_origin}/design/exu/eh2_exu_mul_ctl.sv ${src_origin}/design/eh2_mem.sv ${src_origin}/design/include/eh2_def.sv ${src_origin}/design/lsu/eh2_lsu_dccm_ctl.sv ${src_origin}/design/lsu/eh2_lsu_stbuf.sv ${src_origin}/design/exu/eh2_exu_div_ctl.sv ${src_origin}/design/lsu/eh2_lsu_amo.sv ${src_origin}/design/dec/eh2_dec_decode_ctl.sv ${src_origin}/design/ifu/eh2_ifu_aln_ctl.sv ${src_origin}/design/dec/eh2_dec_gpr_ctl.sv ${src_origin}/design/dec/eh2_dec_tlu_ctl.sv ${src_origin}/design/dec/eh2_dec_trigger.sv ${src_origin}/design/ifu/eh2_ifu_ic_mem.sv ${src_origin}/design/lsu/eh2_lsu_lsc_ctl.sv ${src_origin}/design/lsu/eh2_lsu_addrcheck.sv ${src_origin}/design/TOP_eh2_swerv_wrapper.v
import_files ${src_origin}/snapshots/default/pd_defines.vh ${src_origin}/snapshots/default/eh2_param.vh ${src_origin}/snapshots/default/pic_map_auto.h ${src_origin}/snapshots/default/eh2_pdef.vh ${src_origin}/snapshots/default/defines.h ${src_origin}/snapshots/default/common_defines.vh ${src_origin}/design/lib/ahb_to_axi4.sv ${src_origin}/design/dec/eh2_dec.sv ${src_origin}/design/ifu/eh2_ifu_bp_ctl.sv ${src_origin}/design/eh2_swerv.sv ${src_origin}/design/lib/eh2_lib.sv ${src_origin}/design/eh2_pic_ctrl.sv ${src_origin}/design/lsu/eh2_lsu_bus_buffer.sv ${src_origin}/design/lib/mem_lib.sv ${src_origin}/design/lsu/eh2_lsu_bus_intf.sv ${src_origin}/design/lib/beh_lib.sv ${src_origin}/design/lsu/eh2_lsu_trigger.sv ${src_origin}/design/eh2_dma_ctrl.sv ${src_origin}/design/dmi/dmi_jtag_to_core_sync.v ${src_origin}/design/dmi/dmi_wrapper.v ${src_origin}/design/ifu/eh2_ifu_tb_memread.sv ${src_origin}/design/lsu/eh2_lsu_dccm_mem.sv ${src_origin}/design/exu/eh2_exu_alu_ctl.sv ${src_origin}/design/lsu/eh2_lsu.sv ${src_origin}/design/ifu/eh2_ifu.sv ${src_origin}/design/exu/eh2_exu.sv ${src_origin}/design/dec/eh2_dec_tlu_top.sv ${src_origin}/design/lib/axi4_to_ahb.sv ${src_origin}/design/lsu/eh2_lsu_clkdomain.sv ${src_origin}/design/eh2_swerv_wrapper.sv ${src_origin}/design/ifu/eh2_ifu_btb_mem.sv ${src_origin}/design/dmi/rvjtag_tap.v ${src_origin}/design/ifu/eh2_ifu_compress_ctl.sv ${src_origin}/design/dbg/eh2_dbg.sv ${src_origin}/design/ifu/eh2_ifu_iccm_mem.sv ${src_origin}/design/ifu/eh2_ifu_ifc_ctl.sv ${src_origin}/design/dec/eh2_dec_csr.sv ${src_origin}/design/lsu/eh2_lsu_ecc.sv ${src_origin}/design/ifu/eh2_ifu_mem_ctl.sv ${src_origin}/design/dec/eh2_dec_ib_ctl.sv ${src_origin}/design/exu/eh2_exu_mul_ctl.sv ${src_origin}/design/eh2_mem.sv ${src_origin}/design/include/eh2_def.sv ${src_origin}/design/lsu/eh2_lsu_dccm_ctl.sv ${src_origin}/design/lsu/eh2_lsu_stbuf.sv ${src_origin}/design/exu/eh2_exu_div_ctl.sv ${src_origin}/design/lsu/eh2_lsu_amo.sv ${src_origin}/design/dec/eh2_dec_decode_ctl.sv ${src_origin}/design/ifu/eh2_ifu_aln_ctl.sv ${src_origin}/design/dec/eh2_dec_gpr_ctl.sv ${src_origin}/design/dec/eh2_dec_tlu_ctl.sv ${src_origin}/design/dec/eh2_dec_trigger.sv ${src_origin}/design/ifu/eh2_ifu_ic_mem.sv ${src_origin}/design/lsu/eh2_lsu_lsc_ctl.sv ${src_origin}/design/lsu/eh2_lsu_addrcheck.sv
update_compile_order -fileset sources_1

# fix buggy filetypes
set_property file_type SystemVerilog [get_files  ${proj_name}/${proj_name}.srcs/sources_1/imports/Cores-SweRV-EH2/design/dmi/dmi_jtag_to_core_sync.v]
set_property file_type SystemVerilog [get_files  ${proj_name}/${proj_name}.srcs/sources_1/imports/Cores-SweRV-EH2/design/dmi/rvjtag_tap.v]
# set_property file_type SystemVerilog [get_files  ${proj_name}/${proj_name}.srcs/sources_1/imports/Cores-SweRV-EH2/snapshots/default/eh2_pdef.vh]

# verilog (1) or ...
set_property top TOP_eh2_swerv_wrapper [current_fileset]
# ... (2) system verilog top file
# set_property top eh2_swerv_wrapper [current_fileset]
update_compile_order -fileset sources_1

# debugging: run synthesis to find bugs
# launch_runs synth_1 -jobs 4

# packaging
ipx::package_project -root_dir [pwd]/${proj_name} -import_files -force
set core [ipx::current_core]
set_property vendor wdc $core
set_property library ${proj_name} $core
set_property name ${proj_name} $core
set_property display_name ${proj_name} $core
set_property description ${proj_name} $core
set_property version $version $core
set_property core_revision 1 $core

# # start_gui

# # Get IP definition of DMI
# set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
# set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
# update_ip_catalog

# if 0 {
#     # Group core JTAG wires as interface port
#     ipx::infer_bus_interfaces xilinx.com:interface:jtag_rtl:2.0 [ipx::current_core]
#     ipx::infer_bus_interface jtag_trst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
# } else {
#     # Add DMI interface port:
#     ipx::add_bus_interface DMI [ipx::current_core]
#     set_property abstraction_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     set_property bus_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     ipx::add_port_map RSP_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     set_property physical_name dmi_reg_rdata [ipx::get_port_maps RSP_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#     ipx::add_port_map REQ_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     set_property physical_name dmi_reg_wdata [ipx::get_port_maps REQ_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#     ipx::add_port_map REQ_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     set_property physical_name dmi_reg_addr [ipx::get_port_maps REQ_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#     ipx::add_port_map REQ_WRITE [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     set_property physical_name dmi_reg_wr_en [ipx::get_port_maps REQ_WRITE -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#     ipx::add_port_map REQ_ACCESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#     set_property physical_name dmi_reg_en [ipx::get_port_maps REQ_ACCESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
# }

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core wdc_risc-v_$proj_name.zip $core
ipx::unload_core component_1
