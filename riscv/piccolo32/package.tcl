set name "RV64ACIMU"
if {$::argc > 0} {
    set name [string trim [lindex $::argv 0]]
}
set jtag_version 0
if {$::argc > 1} {
    set jtag_version [string trim [lindex $::argv 1]]
}
puts "package piccolo $name"

set version 0.1
create_project -force $name
if {$jtag_version == 1} {
    add_files [glob Piccolo/src_SSITH_P1/xilinx_ip/hdl/*.v]
} else {
    add_files [glob Piccolo/builds/${name}_Piccolo_verilator/Verilog_RTL/*.v]
}
add_files [glob Piccolo/src_bsc_lib_RTL/*.v]
remove_files  Piccolo/src_bsc_lib_RTL/main.v
update_compile_order -fileset sources_1

if {$jtag_version == 1} {
    set_property top mkP1_Core [current_fileset]
} else {
    set_property top mkCore [current_fileset]
}
update_compile_order -fileset sources_1

remove_files [get_files -filter {IS_AUTO_DISABLED}]

ipx::package_project -root_dir [pwd]/$name -import_files -force
set core [ipx::current_core]
set_property vendor bluespec.com $core
set_property library piccolo $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

if {$jtag_version == 1} {
    ipx::infer_bus_interfaces xilinx.com:interface:jtag_rtl:2.0 [ipx::current_core]

    # TCK is not mapped properly
    ipx::add_port_map TCK [ipx::get_bus_interfaces jtag -of_objects [ipx::current_core]]
    set_property physical_name jtag_tclk [ipx::get_port_maps TCK -of_objects [ipx::get_bus_interfaces jtag -of_objects [ipx::current_core]]]
} else {
    # Get IP definition of DMI
    set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
    set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
    update_ip_catalog

    # Map DMI interface
    ipx::add_bus_interface DMI [ipx::current_core]
    set_property abstraction_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property bus_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    ipx::add_port_map REQ_W_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name dm_dmi_write_dm_addr [ipx::get_port_maps REQ_W_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
    ipx::add_port_map REQ_READ [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name EN_dm_dmi_read_data [ipx::get_port_maps REQ_READ -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
    ipx::add_port_map RSP_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name dm_dmi_read_data [ipx::get_port_maps RSP_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
    ipx::add_port_map REQ_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name dm_dmi_write_dm_word [ipx::get_port_maps REQ_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
    ipx::add_port_map REQ_WRITE [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name EN_dm_dmi_write [ipx::get_port_maps REQ_WRITE -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
    ipx::add_port_map REQ_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name dm_dmi_read_addr_dm_addr [ipx::get_port_maps REQ_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map REQ_VALID [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
    set_property physical_name EN_dm_dmi_read_addr [ipx::get_port_maps REQ_VALID -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]


    set_property driver_value 1 [ipx::get_ports cpu_reset_server_request_put -of_objects [ipx::current_core]]
}


if {[string match *32* $name]} {
	# 32 bit version, need to set address width to 32 bit
	ipx::add_bus_parameter ADDR_WIDTH [ipx::get_bus_interfaces cpu_dmem_master -of_objects [ipx::current_core]]
	set_property value 32 [ipx::get_bus_parameters ADDR_WIDTH -of_objects [ipx::get_bus_interfaces cpu_dmem_master -of_objects [ipx::current_core]]]
}

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core bluespec.com_risc-v_piccolo_$name.zip $core
ipx::unload_core component_1
