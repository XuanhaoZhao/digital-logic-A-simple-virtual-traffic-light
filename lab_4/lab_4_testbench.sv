`timescale 1ms/100us
`define sys_clk_half_period 0.5 //系统时钟频率为1kHz，其半周期为0.5ms
module lab_4_testbench();
	// 输入输出端口定义
	output[1:0] state;
	output[6:0] data_high, data_low;

	// 内部寄存器及连线定义
	reg sys_clk, reset;
	wire count_clk;
	wire[6:0] data;
	wire[3:0] data_shi, data_ge;
	traffic_light_controller U(sys_clk, reset, data_high, data_low, state);
	/*iverilog*/
	initial
	begin
		$dumpfile("wave.vcd");// 生成vcd文件名称
		$dumpvars(0, lab_4_testbench);// tb模块名称
	end
	/*iverlog*/

	// 产生测试信号
	initial
	begin
		sys_clk = 1'b0;
		#5;
		reset = 1'b1;
		#5;
		reset = 1'b0;
		#9.5;
		reset = 1'b1;
		#120000 $stop;// 仿真120s停止
	end

	// 产生1kHz的系统时钟sys_clk
	always #`sys_clk_half_period sys_clk = ~sys_clk;
endmodule