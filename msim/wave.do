onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Control
add wave -noupdate /tb_rs_enc/clk
add wave -noupdate /tb_rs_enc/rst
add wave -noupdate /tb_rs_enc/in_valid
add wave -noupdate /tb_rs_enc/in_ready
add wave -noupdate /tb_rs_enc/in_data
add wave -noupdate /tb_rs_enc/out_valid
add wave -noupdate /tb_rs_enc/out_ready
add wave -noupdate /tb_rs_enc/out_data
add wave -noupdate /tb_rs_enc/C_SYMB_W
add wave -noupdate /tb_rs_enc/C_CODE_N
add wave -noupdate /tb_rs_enc/C_SYMB_K
add wave -noupdate /tb_rs_enc/C_PARITY
add wave -noupdate /tb_rs_enc/CLK_PERIOD
add wave -noupdate -divider RS_ENC_dut
add wave -noupdate /tb_rs_enc/dut/C_MUL_ARCH
add wave -noupdate /tb_rs_enc/dut/C_USE_COMP
add wave -noupdate /tb_rs_enc/dut/C_SYMB_W
add wave -noupdate /tb_rs_enc/dut/C_FIRST_ROOT
add wave -noupdate /tb_rs_enc/dut/C_CODE_N
add wave -noupdate /tb_rs_enc/dut/C_SYMB_K
add wave -noupdate /tb_rs_enc/dut/clk
add wave -noupdate /tb_rs_enc/dut/rst
add wave -noupdate /tb_rs_enc/dut/in_valid
add wave -noupdate /tb_rs_enc/dut/in_ready
add wave -noupdate /tb_rs_enc/dut/in_data
add wave -noupdate /tb_rs_enc/dut/out_valid
add wave -noupdate /tb_rs_enc/dut/out_ready
add wave -noupdate /tb_rs_enc/dut/out_data
add wave -noupdate /tb_rs_enc/dut/data_comp
add wave -noupdate /tb_rs_enc/dut/parity_fb
add wave -noupdate /tb_rs_enc/dut/parity_reg
add wave -noupdate /tb_rs_enc/dut/symbol_count
add wave -noupdate /tb_rs_enc/dut/out_valid_i
add wave -noupdate /tb_rs_enc/dut/C_PARITY_SYMB
add wave -noupdate /tb_rs_enc/dut/C_COMP_SYMB_W
add wave -noupdate /tb_rs_enc/dut/C_COMP_DEG
add wave -noupdate /tb_rs_enc/dut/C_ALPHA
add wave -noupdate /tb_rs_enc/dut/C_GF_POLY
add wave -noupdate /tb_rs_enc/dut/C_OMEGA
add wave -noupdate /tb_rs_enc/dut/C_SUBFIELD_POLY
add wave -noupdate /tb_rs_enc/dut/C_EXTENSION_POLY
add wave -noupdate /tb_rs_enc/dut/C_BETA
add wave -noupdate -expand /tb_rs_enc/dut/C_BASIS_COMP_TO_GF
add wave -noupdate /tb_rs_enc/dut/C_BASIS_GF_TO_COMP
add wave -noupdate /tb_rs_enc/dut/C_GENERATOR_POLY
add wave -noupdate /tb_rs_enc/dut/C_COUNT_W
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {482564250 ps} 0} {{Cursor 4} {7194970000 ps} 1} {{Cursor 5} {7222245100 ps} 1} {{Cursor 6} {510910593539 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 162
configure wave -valuecolwidth 141
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {941298963 ps} {1423863213 ps}
