set name "RV64ACIMU"
if {$::argc > 0} {
    set name [string trim [lindex $::argv 0]]
}
puts "package flute $name"

set version 0.1
create_project -force $name
add_files [glob Flute/builds/${name}_Flute_verilator/Verilog_RTL/*.v]
add_files [glob Flute/src_bsc_lib_RTL/*.v]
remove_files  Flute/src_bsc_lib_RTL/main.v
update_compile_order -fileset sources_1

set_property top mkCore [current_fileset]
update_compile_order -fileset sources_1

remove_files [get_files -filter {IS_AUTO_DISABLED}]

ipx::package_project -root_dir [pwd]/$name -import_files -force
set core [ipx::current_core]
set_property vendor bluespec.com $core
set_property library flute $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

set_property driver_value 1 [ipx::get_ports cpu_reset_server_request_put -of_objects [ipx::current_core]]

if {[string match *32* $name]} {
	# 32 bit version, need to set address width to 32 bit
	ipx::add_bus_parameter ADDR_WIDTH [ipx::get_bus_interfaces core_mem_master -of_objects [ipx::current_core]]
	set_property value 32 [ipx::get_bus_parameters ADDR_WIDTH -of_objects [ipx::get_bus_interfaces core_mem_master -of_objects [ipx::current_core]]]
}

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core bluespec.com_risc-v_flute_$name.zip $core
ipx::unload_core component_1
