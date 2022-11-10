
module generate_1s(sys_clk, reset, y);
	//定义输入输出端口
	input sys_clk, reset;
	output y;
	
	//内部寄存器定义
	reg y;
	reg [9 : 0] cnt;
	
	//逻辑实现
	always@(posedge sys_clk or negedge reset)
	begin
		if(!reset)
		begin
			y <= 1'b0;
			cnt <= 10'd0;
		end
		else
		begin
			if(cnt == 10'd999)
			begin
			y <= 1'b1;
			cnt <= 10'd0;
			end
			else
			begin
				y <= 1'b0;
				cnt <= cnt + 1;
			end
		end
	end
endmodule

module counter(count_clk, reset, data);
	//输入输出端口定义
	input count_clk, reset;
	output [6 : 0] data; //50~20, 20~0循环减计数
	
	//内部寄存器定义
	reg [6 : 0] data;
	
	//逻辑实现
	always@(posedge count_clk or negedge reset)
	begin
		if(!reset) data <= 7'd50; //异步复位
		else if(data == 7'd0) data <= 7'd50;
		else data <= data - 7'd1;
	end
endmodule

module controller(clk, reset, din, state);
	//定义输入输出端口
	input clk, reset;
	input [6 : 0] din;
	output [1 : 0] state;
	
	//内部寄存器定义
	reg [1 : 0] state, current_state, next_state;
	
	//状态编码
	parameter red = 2'b00, green = 2'b01;
	
	//时序逻辑实现状态转移
	always@(posedge clk or negedge reset)
	begin
		if(!reset) current_state <= red;
		else current_state <= next_state;
	end
	
	//组合逻辑实现转移条件判断
	always@(current_state or din)
	begin
		case(current_state)
			red: next_state = (din == 7'd50) ? green : red;
			green: next_state = (din == 7'd30) ? red : green;
		endcase
	end
	
	//组合逻辑实现输出
	always@(current_state)
	begin
		case(current_state)
			red: state = 2'b00;
			green: state = 2'b01;
		endcase
	end
endmodule

module splitter(data, data_shi, data_ge);
	//输入输出端口定义
	input [6 : 0] data;
	output [3 : 0] data_shi;
	output [3 : 0] data_ge;
	
	//内部寄存器定义
	reg [3 : 0] data_shi, data_ge;
	reg [6 : 0] data_display;
	
	//显示数据转换
	always@(data)
	begin
		if(data >= 7'd20) data_display = data - 7'd20;
		else data_display = data;
	end
	
	//用左移加3法将7位二进制数转换为两个4位的BCD码
	integer i;
	always@(data)
	begin
		data_shi = 4'd0;
		data_ge = 4'd0;
		
		for(i = 6; i >= 0; i = i - 1)
		begin
			if(data_ge >= 4'd5) data_ge = data_ge + 4'd3;
			if(data_shi >= 4'd5) data_shi = data_shi + 4'd3;
		
			data_shi = data_shi << 1;
			data_shi[0] = data_ge[3];
			data_ge = data_ge << 1;
			data_ge[0] = data_display[i];
		end
	end
endmodule

module decoder5_7(reset, data_shi, data_ge, data_high, data_low);
	//输入输出端口定义
	input reset;
	input [3 : 0] data_shi, data_ge;
	output [6 : 0] data_high, data_low;
	
	//内部寄存器定义
	reg [6 : 0] data_high, data_low;
	
	//译码个位数
	always@(reset or data_ge)
	begin
		if(!reset)
		begin
			data_high <= 7'b0000110; //7'h06
			data_low <= 7'b0000001; //7'h01
		end
		else
		begin
			case(data_ge)
				4'd0: data_low <= 7'b0000001; //7'h01
				4'd1: data_low <= 7'b1001111; //7'h4f
				4'd2: data_low <= 7'b0010010; //7'h12
				4'd3: data_low <= 7'b0000110; //7'h06
				4'd4: data_low <= 7'b1001100; //7'h4c
				4'd5: data_low <= 7'b0101100; //7'h2c
				4'd6: data_low <= 7'b0100000; //7'h20
				4'd7: data_low <= 7'b0001111; //7'h0f
				4'd8: data_low <= 7'b0000000; //7'h00
				4'd9: data_low <= 7'b0000100; //7'h04
				default: data_low <= 7'b0110000; //7'h48
			endcase
		end
	end
	
	//译码十位数
	always@(reset or data_shi)
	begin
		if(!reset)
		begin
			data_high <= 7'b0000110; //7'h06
			data_low <= 7'b0000001; //7'h01
		end
		else
		begin
			case(data_shi)
				4'd0: data_high <= 7'b0000001; //7'h01
				4'd1: data_high <= 7'b1001111; //7'h4f
				4'd2: data_high <= 7'b0010010; //7'h12
				4'd3: data_high <= 7'b0000110; //7'h06
				default: data_high <= 7'b0110000; //7'h48
			endcase
		end
	end
endmodule

module traffic_light_controller(sys_clk, reset, data_high, data_low, state);
	//输入输出端口定义
	input sys_clk, reset;
	output [1 : 0] state;
	output [6 : 0] data_high, data_low;
	
	//内部寄存器及连线定义
	wire count_clk;
	wire [6 : 0] data;
	wire [3 : 0] data_shi, data_ge;
	
	//逻辑实现
	generate_1s		generate_1s_m0(.sys_clk(sys_clk), .reset(reset), .y(count_clk));
	counter			counter_m0(.count_clk(count_clk), .reset(reset), .data(data));
	controller		controller_m0(.clk(count_clk), .reset(reset), .din(data), .state(state));
	splitter		splitter_m0(.data(data), .data_shi(data_shi), .data_ge(data_ge));
	decoder5_7		decoder5_7_m0(.reset(reset), .data_shi(data_shi), .data_ge(data_ge), .data_high(data_high), .data_low(data_low));
endmodule

