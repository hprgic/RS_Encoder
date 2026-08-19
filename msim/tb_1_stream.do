do compile_ver_tb.do

vsim -novopt work.tb_RS_enc -t 1ps \
-gFREQ_MCLK=100000000\
-gEXCESSIVE_RND_TEST=0\
-gINPUT_0_RGB_FIG="ppms/pattern00_1764x160.ppm"\

#vsim -t 1ps work.tb_RS_enc

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
do wave.do
log -r /*
run 288 ms