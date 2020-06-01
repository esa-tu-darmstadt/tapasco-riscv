puts "package WDC's SweRV"

set name swerv_eh1
set version 0.1
create_project -in_memory

add_files [glob swerv_eh1/design/**.{v,sv,h}]
add_files [glob swerv_eh1/design/*/*.{v,sv,h}]
add_files [glob swerv_eh1/configs/snapshots/default/*.{sv,vh}]
set_property file_type {Verilog Header} [get_files swerv_eh1/configs/snapshots/default/pic_ctrl_verilator_unroll.sv]

# optionally remove unneeded files

update_compile_order -fileset sources_1
set_property top swerv_wrapper_verilog [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project -root_dir [pwd]/swerv_eh1 -import_files -force
set core [ipx::current_core]
set_property vendor wdc $core
set_property library swerv $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

# Group core JTAG wires as interface port
ipx::infer_bus_interfaces xilinx.com:interface:jtag_rtl:2.0 [ipx::current_core]

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core wdc_risc-v_$name.zip $core
ipx::unload_core component_1
