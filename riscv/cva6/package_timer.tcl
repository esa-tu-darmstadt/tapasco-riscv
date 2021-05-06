puts "package  OpenHW Group's CVA6"

set name cva6_timer
set version 0.1
create_project -in_memory

add_files {src/clint/timer_top.sv \
            src/clint/clint.sv \
            src/clint/axi_lite_interface.sv \
            src/axi/src/axi_pkg.sv}
#add_files [exec find src/ -type f -name "*.sv"]
#add_files [glob includes/*.{v,sv,h,svh}]
#set_property file_type {Verilog Header} [get_files *.svh]
set_property include_dirs {"include" "src/common_cells/include"} [current_fileset]

# optionally remove unneeded files

update_compile_order -fileset sources_1
set_property top timer_top [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project -root_dir [pwd] -import_files -force
set core [ipx::current_core]
set_property vendor openhwgroup $core
set_property library cva6 $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core risc-v_$name.zip $core
ipx::unload_core component_1