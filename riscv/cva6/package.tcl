puts "package  OpenHW Group's CVA6"

set name cva6
set version 0.1
create_project -in_memory

add_files {src/ariane_top.sv \
            src/alu.sv \
            src/amo_buffer.sv \
            src/ariane_regfile_ff.sv \
            src/ariane.sv \
            src/axi_adapter.sv \
            src/axi_shim.sv \
            src/branch_unit.sv \
            src/commit_stage.sv \
            src/compressed_decoder.sv \
            src/controller.sv \
            src/csr_buffer.sv \
            src/csr_regfile.sv \
            src/decoder.sv \
            src/dromajo_ram.sv \
            src/ex_stage.sv \
            src/fpu_wrap.sv \
            src/id_stage.sv \
            src/instr_realign.sv \
            src/issue_read_operands.sv \
            src/issue_stage.sv \
            src/load_store_unit.sv \
            src/load_unit.sv \
            src/mmu.sv \
            src/multiplier.sv \
            src/mult.sv \
            src/perf_counters.sv \
            src/ptw.sv \
            src/re_name.sv \
            src/scoreboard.sv \
            src/serdiv.sv \
            src/store_buffer.sv \
            src/store_unit.sv \
            src/tlb.sv \
            src/fpu/src/fpnew_cast_multi.sv \
            src/fpu/src/fpnew_classifier.sv \
            src/fpu/src/fpnew_divsqrt_multi.sv \
            src/fpu/src/fpnew_fma_multi.sv \
            src/fpu/src/fpnew_fma.sv \
            src/fpu/src/fpnew_noncomp.sv \
            src/fpu/src/fpnew_opgroup_block.sv \
            src/fpu/src/fpnew_opgroup_fmt_slice.sv \
            src/fpu/src/fpnew_opgroup_multifmt_slice.sv \
            src/fpu/src/fpnew_rounding.sv \
            src/fpu/src/fpnew_top.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_mvp_wrapper.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv \
            src/fpu/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv \
            src/frontend/bht.sv \
            src/frontend/btb.sv \
            src/frontend/frontend.sv \
            src/frontend/instr_queue.sv \
            src/frontend/instr_scan.sv \
            src/frontend/ras.sv \
            src/cache_subsystem/amo_alu.sv \
            src/cache_subsystem/cache_ctrl.sv \
            src/cache_subsystem/cva6_icache_axi_wrapper.sv \
            src/cache_subsystem/cva6_icache.sv \
            src/cache_subsystem/miss_handler.sv \
            src/cache_subsystem/std_cache_subsystem.sv \
            src/cache_subsystem/std_nbdcache.sv \
            src/cache_subsystem/tag_cmp.sv \
            src/cache_subsystem/wt_axi_adapter.sv \
            src/cache_subsystem/wt_cache_subsystem.sv \
            src/cache_subsystem/wt_dcache_ctrl.sv \
            src/cache_subsystem/wt_dcache_mem.sv \
            src/cache_subsystem/wt_dcache_missunit.sv \
            src/cache_subsystem/wt_dcache.sv \
            src/cache_subsystem/wt_dcache_wbuffer.sv \
            src/cache_subsystem/wt_l15_adapter.sv \
            bootrom/dromajo_bootrom.sv \
            src/clint/axi_lite_interface.sv \
            src/clint/clint.sv \
            fpga/src/axi2apb/src/axi2apb_64_32.sv \
            fpga/src/axi2apb/src/axi2apb.sv \
            fpga/src/axi2apb/src/axi2apb_wrap.sv \
            fpga/src/apb_timer/apb_timer.sv \
            fpga/src/apb_timer/timer.sv \
            fpga/src/axi_slice/src/axi_ar_buffer.sv \
            fpga/src/axi_slice/src/axi_aw_buffer.sv \
            fpga/src/axi_slice/src/axi_b_buffer.sv \
            fpga/src/axi_slice/src/axi_r_buffer.sv \
            fpga/src/axi_slice/src/axi_single_slice.sv \
            fpga/src/axi_slice/src/axi_slice.sv \
            fpga/src/axi_slice/src/axi_slice_wrap.sv \
            fpga/src/axi_slice/src/axi_w_buffer.sv \
            src/axi_node/src/apb_regs_top.sv \
            src/axi_node/src/axi_address_decoder_AR.sv \
            src/axi_node/src/axi_address_decoder_AW.sv \
            src/axi_node/src/axi_address_decoder_BR.sv \
            src/axi_node/src/axi_address_decoder_BW.sv \
            src/axi_node/src/axi_address_decoder_DW.sv \
            src/axi_node/src/axi_AR_allocator.sv \
            src/axi_node/src/axi_AW_allocator.sv \
            src/axi_node/src/axi_BR_allocator.sv \
            src/axi_node/src/axi_BW_allocator.sv \
            src/axi_node/src/axi_DW_allocator.sv \
            src/axi_node/src/axi_multiplexer.sv \
            src/axi_node/src/axi_node_arbiter.sv \
            src/axi_node/src/axi_node_intf_wrap.sv \
            src/axi_node/src/axi_node.sv \
            src/axi_node/src/axi_node_wrap_with_slices.sv \
            src/axi_node/src/axi_regs_top.sv \
            src/axi_node/src/axi_request_block.sv \
            src/axi_node/src/axi_response_block.sv \
            src/axi_riscv_atomics/src/axi_res_tbl.sv \
            src/axi_riscv_atomics/src/axi_riscv_amos_alu.sv \
            src/axi_riscv_atomics/src/axi_riscv_amos.sv \
            src/axi_riscv_atomics/src/axi_riscv_atomics.sv \
            src/axi_riscv_atomics/src/axi_riscv_atomics_wrap.sv \
            src/axi_riscv_atomics/src/axi_riscv_lrsc.sv \
            src/axi_riscv_atomics/src/axi_riscv_lrsc_wrap.sv \
            src/axi_mem_if/src/axi2mem.sv \
            src/pmp/src/pmp_entry.sv \
            src/pmp/src/pmp.sv \
            src/rv_plic/rtl/rv_plic_target.sv \
            src/rv_plic/rtl/rv_plic_gateway.sv \
            src/rv_plic/rtl/plic_regmap.sv \
            src/rv_plic/rtl/plic_top.sv \
            src/riscv-dbg/src/dmi_cdc.sv \
            src/riscv-dbg/src/dmi_jtag.sv \
            src/riscv-dbg/src/dmi_jtag_tap.sv \
            src/riscv-dbg/src/dm_csrs.sv \
            src/riscv-dbg/src/dm_mem.sv \
            src/riscv-dbg/src/dm_sba.sv \
            src/riscv-dbg/src/dm_top.sv \
            src/riscv-dbg/debug_rom/debug_rom.sv \
            src/register_interface/src/apb_to_reg.sv \
            src/axi/src/axi_multicut.sv \
            src/common_cells/src/deprecated/generic_fifo.sv \
            src/common_cells/src/deprecated/pulp_sync.sv \
            src/common_cells/src/deprecated/find_first_one.sv \
            src/common_cells/src/rstgen_bypass.sv \
            src/common_cells/src/rstgen.sv \
            src/common_cells/src/stream_mux.sv \
            src/common_cells/src/stream_demux.sv \
            src/common_cells/src/exp_backoff.sv \
            src/util/axi_master_connect.sv \
            src/util/axi_slave_connect.sv \
            src/util/axi_master_connect_rev.sv \
            src/util/axi_slave_connect_rev.sv \
            src/axi/src/axi_cut.sv \
            src/axi/src/axi_join.sv \
            src/axi/src/axi_delayer.sv \
            src/axi/src/axi_to_axi_lite.sv \
            src/fpga-support/rtl/SyncSpRamBeNx64.sv \
            src/common_cells/src/unread.sv \
            src/common_cells/src/sync.sv \
            src/common_cells/src/cdc_2phase.sv \
            src/common_cells/src/spill_register.sv \
            src/common_cells/src/sync_wedge.sv \
            src/common_cells/src/edge_detect.sv \
            src/common_cells/src/stream_arbiter.sv \
            src/common_cells/src/stream_arbiter_flushable.sv \
            src/common_cells/src/deprecated/fifo_v1.sv \
            src/common_cells/src/deprecated/fifo_v2.sv \
            src/common_cells/src/fifo_v3.sv \
            src/common_cells/src/lzc.sv \
            src/common_cells/src/popcount.sv \
            src/common_cells/src/rr_arb_tree.sv \
            src/common_cells/src/deprecated/rrarbiter.sv \
            src/common_cells/src/stream_delay.sv \
            src/common_cells/src/lfsr_8bit.sv \
            src/common_cells/src/lfsr_16bit.sv \
            src/common_cells/src/delta_counter.sv \
            src/common_cells/src/counter.sv \
            src/common_cells/src/shift_reg.sv \
            src/tech_cells_generic/src/pulp_clock_gating.sv \
            src/tech_cells_generic/src/cluster_clock_inverter.sv \
            src/tech_cells_generic/src/pulp_clock_mux2.sv}
#add_files [exec find src/ -type f -name "*.sv"]
#add_files [glob includes/*.{v,sv,h,svh}]
#set_property file_type {Verilog Header} [get_files *.svh]
set_property include_dirs {"include" "src/common_cells/include"} [current_fileset]

# optionally remove unneeded files

update_compile_order -fileset sources_1
set_property top ariane_top [current_fileset]
update_compile_order -fileset sources_1

#write_verilog top.v

ipx::package_project -root_dir [pwd] -import_files -force
set core [ipx::current_core]
set_property vendor openhwgroup $core
set_property library cva6 $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

# Get IP definition of DMI
#set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
#set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
#update_ip_catalog

#if 0 {
#    # Group core JTAG wires as interface port
#    ipx::infer_bus_interfaces xilinx.com:interface:jtag_rtl:2.0 [ipx::current_core]
#    ipx::infer_bus_interface jtag_trst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
#} else {
#    # Add DMI interface port:
#    ipx::add_bus_interface DMI [ipx::current_core]
#    set_property abstraction_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property bus_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    ipx::add_port_map RSP_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_rdata [ipx::get_port_maps RSP_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_wdata [ipx::get_port_maps REQ_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_addr [ipx::get_port_maps REQ_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_WRITE [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_wr [ipx::get_port_maps REQ_WRITE -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_ACCESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_req [ipx::get_port_maps REQ_ACCESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#}

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core risc-v_$name.zip $core
ipx::unload_core component_1
