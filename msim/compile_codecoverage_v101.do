##########################################################################################################
if {[file exists rs_enc_lib/_info] != 0}      then {vdel -lib rs_enc_lib -all}
vlib rs_enc_lib
vmap rs_enc_lib
#vmap unimacro     	"C:/compiled_lib/vivado_2020_1/unimacro/"
#vmap unisim       	"C:/compiled_lib/vivado_2020_1/unisim/"
#################### COMPILE  DESIGN  FILES ##############################################################

#################### COMPILE  DESIGN  FILES ##############################################################
### rs_enc_lib ###
set rs_enc_lib_var "Reed_solomon_encoder"
vcom -2008 -work rs_enc_lib "../$rs_enc_lib_var/hdl/src/vhdl/rs_pkg.vhd"
vcom -2008 -work rs_enc_lib "../$rs_enc_lib_var/hdl/src/vhdl/rs_math_pkg.vhd"
vcom -2008 -work rs_enc_lib "../$rs_enc_lib_var/hdl/src/vhdl/rs_composite_parity_gen.vhd"
##########################################################################################################

do tb_1_stream.do