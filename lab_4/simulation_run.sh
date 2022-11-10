echo "开始编译"
iverilog -o wave ./traffic_light_contorller.sv lab_4_testbench.sv
echo "编译完成"

echo "生成波形文件"
vvp -n wave -lxt2 
cp wave.vcd wave.lxt

echo "打开波形文件"
gtkwave wave.vcd
