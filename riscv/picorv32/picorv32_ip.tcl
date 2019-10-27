create_project -force package_picorv32 package_picorv32 -part xc7z020clg400-1
ipx::infer_core -vendor user.org -library user -taxonomy /UserIP IP/riscv/PicoRV32
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory package_picorv32/package_picorv32.tmp IP/riscv/PicoRV32/component.xml
ipx::current_core IP/riscv/PicoRV32/component.xml
update_compile_order -fileset sources_1
set_property library riscv [ipx::current_core]
set_property name Pico [ipx::current_core]
set_property name picorv32 [ipx::current_core]
set_property display_name PicoRV32 [ipx::current_core]
set_property description {RISC-V CPU with AXI4-Lite support} [ipx::current_core]
set_property vendor_display_name cloffordwolf [ipx::current_core]
set_property previous_version_for_upgrade user.org:user:picorv32_axi:1.0 [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core IP/riscv/PicoRV32/user.org_riscv_picorv32_1.0.zip [ipx::current_core]
close_project -delete
set_property  ip_repo_paths IP/riscv/PicoRV32 [current_project]
update_ip_catalog
