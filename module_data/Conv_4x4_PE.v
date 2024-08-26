`define WIDTH 16
`define IDLE 0
`define ACTIVATE 1
module Conv_4x4_PE(clk,rst,
										i_data_in_en,
										i_img_data_0,
										i_img_data_1,
										i_img_data_2,
										i_img_data_3,
										i_weight_0,
										i_weight_1,
										i_weight_2,
										i_weight_3,
										o_data,
										o_data_en);
										
	input						clk;
	input						rst;
	input						i_data_in_en;
	input		[143:0]	i_img_data_0;
	input		[143:0]	i_img_data_1;
	input		[143:0]	i_img_data_2;
	input		[143:0]	i_img_data_3;
	
	input		[143:0]	i_weight_0;
	input		[143:0]	i_weight_1;
	input		[143:0]	i_weight_2;
	input		[143:0]	i_weight_3;
 
	output     [63:0]  o_data;
	output					o_data_en;
	
	wire		signed [`WIDTH-1:0]	H	[11:0];
	wire		signed [`WIDTH-1:0]	V	[11:0];
	
	wire		signed [`WIDTH-1:0]	R0;
	wire		signed [`WIDTH-1:0]	R1;
	wire		signed [`WIDTH-1:0]	R2;
	wire		signed [`WIDTH-1:0]	R3;
	wire		signed [`WIDTH-1:0]	C0;
	wire		signed [`WIDTH-1:0]	C1;
	wire		signed [`WIDTH-1:0]	C2;
	wire		signed [`WIDTH-1:0]	C3;
	wire		signed [`WIDTH-1:0]	PE00;
	wire		signed [`WIDTH-1:0]	PE01;
	wire		signed [`WIDTH-1:0]	PE02;
	wire		signed [`WIDTH-1:0]	PE03;
	wire		signed [`WIDTH-1:0]	PE10;
	wire		signed [`WIDTH-1:0]	PE11;
	wire		signed [`WIDTH-1:0]	PE12;
	wire		signed [`WIDTH-1:0]	PE13;
	wire		signed [`WIDTH-1:0]	PE20;
	wire		signed [`WIDTH-1:0]	PE21;
	wire		signed [`WIDTH-1:0]	PE22;
	wire		signed [`WIDTH-1:0]	PE23;
	wire		signed [`WIDTH-1:0]	PE30;
	wire		signed [`WIDTH-1:0]	PE31;
	wire		signed [`WIDTH-1:0]	PE32;
	wire		signed [`WIDTH-1:0]	PE33;
	
	reg			signed [`WIDTH-1:0]	r_img_buffer_0[0:15];
	reg			signed [`WIDTH-1:0]	r_img_buffer_1[0:15];
	reg			signed [`WIDTH-1:0]	r_img_buffer_2[0:15];
	reg			signed [`WIDTH-1:0]	r_img_buffer_3[0:15];
	
	reg			signed [`WIDTH-1:0]	r_weight_buffer_0[0:15];
	reg			signed [`WIDTH-1:0]	r_weight_buffer_1[0:15];
	reg			signed [`WIDTH-1:0]	r_weight_buffer_2[0:15];
	reg			signed [`WIDTH-1:0]	r_weight_buffer_3[0:15];
	reg						 [3:0]					r_buffer_in_cnt;
	reg						 [3:0]					r_cal_cnt;
	reg						 [3:0]					r_rst_cnt;
	reg													r_mode;
	reg                                                init;
		
	integer 	i;
	always@(posedge clk)begin
		if(rst)begin
			r_buffer_in_cnt 					<= 0;
			r_cal_cnt							<= 0;
			r_rst_cnt								<= 0;
			r_mode								<= `IDLE;
			init                                 <= 1;;
			for(i = 0;i < 16;i=i+1)begin
				r_img_buffer_0[i] 			<= 0;
				r_img_buffer_1[i] 			<= 0;
				r_img_buffer_2[i] 			<= 0;
				r_img_buffer_3[i] 			<= 0;
				r_weight_buffer_0[i]		<= 0;
				r_weight_buffer_1[i]		<= 0;
				r_weight_buffer_2[i]		<= 0;
				r_weight_buffer_3[i]		<= 0;
			end
		end
		case(r_mode)
		  `IDLE:begin
		      if(i_data_in_en)begin
				for(i = 0; i < 9 ;i = i +1)begin
					r_weight_buffer_0[i] 		<= i_weight_0[143-(i*16)-:16];
					r_weight_buffer_1[i + 1] 	<= i_weight_1[143-(i*16)-:16];
					r_weight_buffer_2[i + 2] 	<= i_weight_2[143-(i*16)-:16];
					r_weight_buffer_3[i + 3] 	<= i_weight_3[143-(i*16)-:16];
					r_img_buffer_0[i] 			<= i_img_data_0[143-(i*16)-:16];
					r_img_buffer_1[i + 1] 		<= i_img_data_1[143-(i*16)-:16];
					r_img_buffer_2[i + 2] 		<= i_img_data_2[143-(i*16)-:16];
					r_img_buffer_3[i + 3] 		<= i_img_data_3[143-(i*16)-:16];
				end
				r_buffer_in_cnt                     <= 0;
				r_cal_cnt                           <= 0;
				r_mode								<= `ACTIVATE;
				init <= 1;
			 end
		  end
		  `ACTIVATE : begin
		      r_buffer_in_cnt 							<= r_buffer_in_cnt == 15 ? 15 : r_buffer_in_cnt + 1;
			  r_cal_cnt									<= init ? 0 : r_cal_cnt == 14 ? 0 : r_cal_cnt + 1;
			  init                                      <= 0;
			if(r_cal_cnt==14)begin
			     r_mode <= `IDLE;
		    end
		  end
		endcase
    end
	
	assign R0 	= r_img_buffer_0[r_buffer_in_cnt];
	assign R1 	= r_img_buffer_1[r_buffer_in_cnt];
	assign R2	= r_img_buffer_2[r_buffer_in_cnt];
	assign R3	= r_img_buffer_3[r_buffer_in_cnt];
	
	assign C0	= r_weight_buffer_0[r_buffer_in_cnt];
	assign C1	= r_weight_buffer_1[r_buffer_in_cnt];
	assign C2	= r_weight_buffer_2[r_buffer_in_cnt];
	assign C3	= r_weight_buffer_3[r_buffer_in_cnt];
	
	assign o_data = r_cal_cnt == 11 ? {PE00,PE01,PE02,PE03}: r_cal_cnt == 12 ? 
																	{PE10,PE11,PE12,PE13} : r_cal_cnt == 13 ? 
																	{PE20,PE21,PE22,PE23} : r_cal_cnt == 14 ?
																	{PE30,PE31,PE32,PE33} : 0;
																	
	assign o_data_en	= r_cal_cnt >= 11;
																	
	PE PE_00(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(R0),
		.Input_B(C0),
		.Output_A(H[0]),
		.Output_B(V[0]),
		.Output_C(PE00)
	);
	
	PE PE_01(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[0]),
		.Input_B(C1),
		.Output_A(H[1]),
		.Output_B(V[1]),
		.Output_C(PE01)
	);
	
	PE PE_02(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[1]),
		.Input_B(C2),
		.Output_A(H[2]),
		.Output_B(V[2]),
		.Output_C(PE02)
	);
	
	PE PE_03(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[2]),
		.Input_B(C3),
		.Output_A(),
		.Output_B(V[3]),
		.Output_C(PE03)
	);
	
	PE PE_10(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(R1),
		.Input_B(V[0]),
		.Output_A(H[3]),
		.Output_B(V[4]),
		.Output_C(PE10)
	);
	
	PE PE_11(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[3]),
		.Input_B(V[1]),
		.Output_A(H[4]),
		.Output_B(V[5]),
		.Output_C(PE11)
	);
	
	PE PE_12(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[4]),
		.Input_B(V[2]),
		.Output_A(H[5]),
		.Output_B(V[6]),
		.Output_C(PE12)
	);
	
	PE PE_13(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[5]),
		.Input_B(V[3]),
		.Output_A(),
		.Output_B(V[7]),
		.Output_C(PE13)
	);
	
	PE PE_20(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(R2),
		.Input_B(V[4]),
		.Output_A(H[6]),
		.Output_B(V[8]),
		.Output_C(PE20)
	);
	
	PE PE_21(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[6]),
		.Input_B(V[5]),
		.Output_A(H[7]),
		.Output_B(V[9]),
		.Output_C(PE21)
	);
	
	PE PE_22(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[7]),
		.Input_B(V[6]),
		.Output_A(H[8]),
		.Output_B(V[10]),
		.Output_C(PE22)
	);
	
	PE PE_23(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[8]),
		.Input_B(V[7]),
		.Output_A(),
		.Output_B(V[11]),
		.Output_C(PE23)
	);
	
	PE PE_30(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(R3),
		.Input_B(V[8]),
		.Output_A(H[9]),
		.Output_B(),
		.Output_C(PE30)
	);
	
	PE PE_31(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[9]),
		.Input_B(V[9]),
		.Output_A(H[10]),
		.Output_B(),
		.Output_C(PE31)
	);
	
	PE PE_32(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[10]),
		.Input_B(V[10]),
		.Output_A(H[11]),
		.Output_B(),
		.Output_C(PE32)
	);
	
	PE PE_33(
		.clk(clk),
		.rst(rst || r_cal_cnt == 14),
		.Input_A(H[11]),
		.Input_B(V[11]),
		.Output_A(),
		.Output_B(),
		.Output_C(PE33)
	);

endmodule