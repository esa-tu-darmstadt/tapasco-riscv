# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDRESS_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_PROTOCOL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BYTES_PER_WORD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MEM_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "READ_ONLY" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDRESS_WIDTH { PARAM_VALUE.ADDRESS_WIDTH } {
	# Procedure called to update ADDRESS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDRESS_WIDTH { PARAM_VALUE.ADDRESS_WIDTH } {
	# Procedure called to validate ADDRESS_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_PROTOCOL { PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to update AXI_PROTOCOL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_PROTOCOL { PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to validate AXI_PROTOCOL
	return true
}

proc update_PARAM_VALUE.BYTES_PER_WORD { PARAM_VALUE.BYTES_PER_WORD } {
	# Procedure called to update BYTES_PER_WORD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYTES_PER_WORD { PARAM_VALUE.BYTES_PER_WORD } {
	# Procedure called to validate BYTES_PER_WORD
	return true
}

proc update_PARAM_VALUE.ID_WIDTH { PARAM_VALUE.ID_WIDTH } {
	# Procedure called to update ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ID_WIDTH { PARAM_VALUE.ID_WIDTH } {
	# Procedure called to validate ID_WIDTH
	return true
}

proc update_PARAM_VALUE.MEM_SIZE { PARAM_VALUE.MEM_SIZE } {
	# Procedure called to update MEM_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_SIZE { PARAM_VALUE.MEM_SIZE } {
	# Procedure called to validate MEM_SIZE
	return true
}

proc update_PARAM_VALUE.READ_ONLY { PARAM_VALUE.READ_ONLY } {
	# Procedure called to update READ_ONLY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_ONLY { PARAM_VALUE.READ_ONLY } {
	# Procedure called to validate READ_ONLY
	return true
}


proc update_MODELPARAM_VALUE.BYTES_PER_WORD { MODELPARAM_VALUE.BYTES_PER_WORD PARAM_VALUE.BYTES_PER_WORD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYTES_PER_WORD}] ${MODELPARAM_VALUE.BYTES_PER_WORD}
}

proc update_MODELPARAM_VALUE.ADDRESS_WIDTH { MODELPARAM_VALUE.ADDRESS_WIDTH PARAM_VALUE.ADDRESS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDRESS_WIDTH}] ${MODELPARAM_VALUE.ADDRESS_WIDTH}
}

proc update_MODELPARAM_VALUE.MEM_SIZE { MODELPARAM_VALUE.MEM_SIZE PARAM_VALUE.MEM_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_SIZE}] ${MODELPARAM_VALUE.MEM_SIZE}
}

proc update_MODELPARAM_VALUE.ID_WIDTH { MODELPARAM_VALUE.ID_WIDTH PARAM_VALUE.ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID_WIDTH}] ${MODELPARAM_VALUE.ID_WIDTH}
}

proc update_MODELPARAM_VALUE.READ_ONLY { MODELPARAM_VALUE.READ_ONLY PARAM_VALUE.READ_ONLY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_ONLY}] ${MODELPARAM_VALUE.READ_ONLY}
}

proc update_MODELPARAM_VALUE.AXI_PROTOCOL { MODELPARAM_VALUE.AXI_PROTOCOL PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_PROTOCOL}] ${MODELPARAM_VALUE.AXI_PROTOCOL}
}

