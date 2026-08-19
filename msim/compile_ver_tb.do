##########################################################################################################
if {[file exists work/_info] != 0}      then {vdel -lib work -all}
vlib work
vmap work
#################### COMPILE  DESIGN  FILES ##############################################################
### verification ###
set ver_id ""
vcom -2008 -explicit -work work ../beh/io_utils.vhd
vcom -2008 -explicit -work work ../beh/m_axis_generator.vhd
vcom -2008 -explicit -work work ../ver/tb_RS_enc.vhd
