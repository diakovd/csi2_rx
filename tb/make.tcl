vlib work
vlog -sv -f files
#vopt +acc tb_csi2 -L unisim -o tb_csi2_opt
#vsim tb_csi2_opt
vsim -novopt tb_csi2
do wave.do
run -all
