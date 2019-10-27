# Setup IP Packager
create_project -force dummy

ipx::infer_core -vendor user.org -library user -taxonomy /UserIP IP/riscv/VexRiscv

ipx::edit_ip_in_project -upgrade true -name VexRiscvCore -directory vexriscv_pe/vexriscv_pe.tmp IP/riscv/VexRiscv/component.xml

ipx::current_core IP/riscv/VexRiscv/component.xml

update_compile_order -fileset sources_1

set_property vendor_display_name SpinalHDL [ipx::current_core]

set_property company_url https://github.com/SpinalHDL [ipx::current_core]

# Remap Instruction Bus Physical Ports
ipx::add_bus_interface iBusAxi [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property interface_mode master [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property display_name iBusAxi [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property description {Instruction bus} [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

ipx::add_port_map ARCACHE [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_cache [ipx::get_port_maps ARCACHE -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RREADY [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_r_ready [ipx::get_port_maps RREADY -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARBURST [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_burst [ipx::get_port_maps ARBURST -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARREGION [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_region [ipx::get_port_maps ARREGION -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARSIZE [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_size [ipx::get_port_maps ARSIZE -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RRESP [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_r_payload_resp [ipx::get_port_maps RRESP -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARPROT [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_prot [ipx::get_port_maps ARPROT -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RID [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_r_payload_id [ipx::get_port_maps RID -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RVALID [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_r_valid [ipx::get_port_maps RVALID -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARLOCK [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_lock [ipx::get_port_maps ARLOCK -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARADDR [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_addr [ipx::get_port_maps ARADDR -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RLAST [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_r_payload_last [ipx::get_port_maps RLAST -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARID [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_id [ipx::get_port_maps ARID -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARREADY [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_ready [ipx::get_port_maps ARREADY -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARVALID [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_valid [ipx::get_port_maps ARVALID -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARLEN [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_len [ipx::get_port_maps ARLEN -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARQOS [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_ar_payload_qos [ipx::get_port_maps ARQOS -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RDATA [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

set_property physical_name iBusAxi_r_payload_data [ipx::get_port_maps RDATA -of_objects [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]]

# Remap data bus physical ports
ipx::add_bus_interface dBusAxi [ipx::current_core]

set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property interface_mode master [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property display_name dBusAxi [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property description {Data bus} [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

ipx::add_port_map WLAST [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_w_payload_last [ipx::get_port_maps WLAST -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map BREADY [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_b_ready [ipx::get_port_maps BREADY -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWLEN [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_len [ipx::get_port_maps AWLEN -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWQOS [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_qos [ipx::get_port_maps AWQOS -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWREADY [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_ready [ipx::get_port_maps AWREADY -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARBURST [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_burst [ipx::get_port_maps ARBURST -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWPROT [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_prot [ipx::get_port_maps AWPROT -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RRESP [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_r_payload_resp [ipx::get_port_maps RRESP -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARPROT [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_prot [ipx::get_port_maps ARPROT -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RVALID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_r_valid [ipx::get_port_maps RVALID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARLOCK [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_lock [ipx::get_port_maps ARLOCK -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_id [ipx::get_port_maps AWID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RLAST [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_r_payload_last [ipx::get_port_maps RLAST -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_id [ipx::get_port_maps ARID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWCACHE [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_cache [ipx::get_port_maps AWCACHE -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map WREADY [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_w_ready [ipx::get_port_maps WREADY -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map WSTRB [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_w_payload_strb [ipx::get_port_maps WSTRB -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map BRESP [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_b_payload_resp [ipx::get_port_maps BRESP -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map BID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_b_payload_id [ipx::get_port_maps BID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARLEN [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_len [ipx::get_port_maps ARLEN -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARQOS [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_qos [ipx::get_port_maps ARQOS -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RDATA [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_r_payload_data [ipx::get_port_maps RDATA -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map BVALID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_b_valid [ipx::get_port_maps BVALID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARCACHE [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_cache [ipx::get_port_maps ARCACHE -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RREADY [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_r_ready [ipx::get_port_maps RREADY -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWVALID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_valid [ipx::get_port_maps AWVALID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARREGION [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_region [ipx::get_port_maps ARREGION -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARSIZE [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_size [ipx::get_port_maps ARSIZE -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map WDATA [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_w_payload_data [ipx::get_port_maps WDATA -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWSIZE [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_size [ipx::get_port_maps AWSIZE -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map RID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_r_payload_id [ipx::get_port_maps RID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWREGION [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_region [ipx::get_port_maps AWREGION -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARADDR [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_payload_addr [ipx::get_port_maps ARADDR -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWADDR [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_addr [ipx::get_port_maps AWADDR -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARREADY [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_ready [ipx::get_port_maps ARREADY -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map WVALID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_w_valid [ipx::get_port_maps WVALID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map ARVALID [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_ar_valid [ipx::get_port_maps ARVALID -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWLOCK [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_lock [ipx::get_port_maps AWLOCK -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

ipx::add_port_map AWBURST [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property physical_name dBusAxi_aw_payload_burst [ipx::get_port_maps AWBURST -of_objects [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]]

# Associate Clock
ipx::associate_bus_interfaces -busif dBusAxi -clock clk [ipx::current_core]

ipx::associate_bus_interfaces -busif iBusAxi -clock clk [ipx::current_core]

# Active high reset
ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces reset -of_objects [ipx::current_core]]
set_property value ACTIVE_HIGH [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces reset -of_objects [ipx::current_core]]]

# Address spaces
ipx::add_address_space iBusAxi [ipx::current_core]
set_property master_address_space_ref iBusAxi [ipx::get_bus_interfaces iBusAxi -of_objects [ipx::current_core]]

ipx::add_address_space dBusAxi [ipx::current_core]
set_property master_address_space_ref dBusAxi [ipx::get_bus_interfaces dBusAxi -of_objects [ipx::current_core]]

set_property width 32 [ipx::get_address_spaces iBusAxi -of_objects [ipx::current_core]]
set_property width 32 [ipx::get_address_spaces dBusAxi -of_objects [ipx::current_core]]
set_property range 4294967296 [ipx::get_address_spaces iBusAxi -of_objects [ipx::current_core]]
set_property range 4294967296 [ipx::get_address_spaces dBusAxi -of_objects [ipx::current_core]]

# Finish packaging
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
set_property  ip_repo_paths  IP/riscv/VexRiscv [current_project]
update_ip_catalog

