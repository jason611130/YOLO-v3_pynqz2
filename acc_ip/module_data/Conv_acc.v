`define WIDTH 16

module Conv_acc(clk,rst,i_Data,
							i_Weight_setup,
							o_PE_rst_state,
							o_Data,
							o_Data_en
							);
							
	input 											clk;
	input 											rst;
	input 				 	 [63:0]				i_Data;
	input											i_Weight_setup;
	
	output 	reg 		 [15:0]				o_PE_rst_state;
	output				 [63:0]				o_Data;
	output				 						o_Data_en;
	
	wire 		signed [`WIDTH-1:0]	R0;
	wire 		signed [`WIDTH-1:0]	R1;
	wire 		signed [`WIDTH-1:0]	R2;
	wire 		signed [`WIDTH-1:0]	R3;
	wire 		signed [`WIDTH-1:0]	C0;
	wire 		signed [`WIDTH-1:0]	C1;
	wire 		signed [`WIDTH-1:0]	C2;
	wire 		signed [`WIDTH-1:0]	C3;
	
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
	
	wire		signed [`WIDTH-1:0]	H	[11:0];
	wire		signed [`WIDTH-1:0]	V	[11:0];

	reg		signed [`WIDTH-1:0] Data_0	[0:11];			
	reg		signed [`WIDTH-1:0] Data_1	[0:11];			
	reg		signed [`WIDTH-1:0] Data_2	[0:11];			
	reg		signed [`WIDTH-1:0] Data_3	[0:11];

	reg		signed [`WIDTH-1:0] Weight_0	[0:11];			
	reg		signed [`WIDTH-1:0] Weight_1	[0:11];			
	reg		signed [`WIDTH-1:0] Weight_2	[0:11];			
	reg		signed [`WIDTH-1:0] Weight_3	[0:11];
	
	reg						 [63:0]				Result_data	[0:3];
	reg						 [63:0]				r_Data;
	reg						 [3:0]				data_in_cnt;
	reg						 [3:0]				buffer_in_cnt;
	reg						 [3:0]				cal_cnt;
	reg						 [3:0]				i;
	reg                                         init;
	
	
	
	
	PE PE_00(
		.clk(clk),
		.rst(o_PE_rst_state[6]),
		.Input_A(R0),
		.Input_B(C0),
		.Output_A(H[0]),
		.Output_B(V[0]),
		.Output_C(PE00)
	);
	
	PE PE_01(
		.clk(clk),
		.rst(o_PE_rst_state[5]),
		.Input_A(H[0]),
		.Input_B(C1),
		.Output_A(H[1]),
		.Output_B(V[1]),
		.Output_C(PE01)
	);
	
	PE PE_02(
		.clk(clk),
		.rst(o_PE_rst_state[4]),
		.Input_A(H[1]),
		.Input_B(C2),
		.Output_A(H[2]),
		.Output_B(V[2]),
		.Output_C(PE02)
	);
	
	PE PE_03(
		.clk(clk),
		.rst(o_PE_rst_state[3]),
		.Input_A(H[2]),
		.Input_B(C3),
		.Output_A(),
		.Output_B(V[3]),
		.Output_C(PE03)
	);
	
	PE PE_10(
		.clk(clk),
		.rst(o_PE_rst_state[5]),
		.Input_A(R1),
		.Input_B(V[0]),
		.Output_A(H[3]),
		.Output_B(V[4]),
		.Output_C(PE10)
	);
	
	PE PE_11(
		.clk(clk),
		.rst(o_PE_rst_state[4]),
		.Input_A(H[3]),
		.Input_B(V[1]),
		.Output_A(H[4]),
		.Output_B(V[5]),
		.Output_C(PE11)
	);
	
	PE PE_12(
		.clk(clk),
		.rst(o_PE_rst_state[3]),
		.Input_A(H[4]),
		.Input_B(V[2]),
		.Output_A(H[5]),
		.Output_B(V[6]),
		.Output_C(PE12)
	);
	
	PE PE_13(
		.clk(clk),
		.rst(o_PE_rst_state[2]),
		.Input_A(H[5]),
		.Input_B(V[3]),
		.Output_A(),
		.Output_B(V[7]),
		.Output_C(PE13)
	);
	
	PE PE_20(
		.clk(clk),
		.rst(o_PE_rst_state[4]),
		.Input_A(R2),
		.Input_B(V[4]),
		.Output_A(H[6]),
		.Output_B(V[8]),
		.Output_C(PE20)
	);
	
	PE PE_21(
		.clk(clk),
		.rst(o_PE_rst_state[3]),
		.Input_A(H[6]),
		.Input_B(V[5]),
		.Output_A(H[7]),
		.Output_B(V[9]),
		.Output_C(PE21)
	);
	
	PE PE_22(
		.clk(clk),
		.rst(o_PE_rst_state[2]),
		.Input_A(H[7]),
		.Input_B(V[6]),
		.Output_A(H[8]),
		.Output_B(V[10]),
		.Output_C(PE22)
	);
	
	PE PE_23(
		.clk(clk),
		.rst(o_PE_rst_state[1]),
		.Input_A(H[8]),
		.Input_B(V[7]),
		.Output_A(),
		.Output_B(V[11]),
		.Output_C(PE23)
	);
	
	PE PE_30(
		.clk(clk),
		.rst(o_PE_rst_state[3]),
		.Input_A(R3),
		.Input_B(V[8]),
		.Output_A(H[9]),
		.Output_B(),
		.Output_C(PE30)
	);
	
	PE PE_31(
		.clk(clk),
		.rst(o_PE_rst_state[2]),
		.Input_A(H[9]),
		.Input_B(V[9]),
		.Output_A(H[10]),
		.Output_B(),
		.Output_C(PE31)
	);
	
	PE PE_32(
		.clk(clk),
		.rst(o_PE_rst_state[1]),
		.Input_A(H[10]),
		.Input_B(V[10]),
		.Output_A(H[11]),
		.Output_B(),
		.Output_C(PE32)
	);
	
	PE PE_33(
		.clk(clk),
		.rst(o_PE_rst_state[0]),
		.Input_A(H[11]),
		.Input_B(V[11]),
		.Output_A(),
		.Output_B(),
		.Output_C(PE33)
	);
	
	always@(posedge clk)begin
		if(rst)begin
			data_in_cnt <= 0;
			buffer_in_cnt <= 0;
			for(i = 0; i < 12; i = i +1)begin
				Weight_0	[i] <= 0;
				Weight_1	[i] <= 0;
				Weight_2	[i] <= 0;
				Weight_3	[i] <= 0;
				Data_0[i] = 0;
				Data_1[i] = 0;
				Data_2[i] = 0;
				Data_3[i] = 0;
				cal_cnt   = 0;
				init      = 1;
			end
		end
		else begin
			if(i_Weight_setup)begin
				Weight_0[data_in_cnt]   <= i_Data[63:48];
			    Weight_1[data_in_cnt+1]	<= i_Data[47:32];
			    Weight_2[data_in_cnt+2]	<= i_Data[31:16];
			    Weight_3[data_in_cnt+3]	<= i_Data[15:0];
			end
			else begin
				Data_0[data_in_cnt]   <= i_Data[63:48];
				Data_1[data_in_cnt+1] <= i_Data[47:32];
				Data_2[data_in_cnt+2] <= i_Data[31:16];
				Data_3[data_in_cnt+3] <= i_Data[15:0];
				cal_cnt			      <= init ? 0 : cal_cnt + 1;
				init                  <= 0;
				buffer_in_cnt	      <= init ? 0 : buffer_in_cnt == 11 ? 0 : buffer_in_cnt + 1;
			end
			data_in_cnt 	<= data_in_cnt 	    == 8  ? 0 : data_in_cnt + 1;
			
			
		end
	end

	always@(posedge clk)begin
		if(i_Weight_setup)begin
			o_PE_rst_state  <= 16'b0000_0000_0111_1111;
			r_Data          <= 0;
			Result_data[0]  <= 0;
			Result_data[1]  <= 0;
			Result_data[2]  <= 0;
			Result_data[3]  <= 0;
		end
		else begin
		  o_PE_rst_state[15:6]	<= {o_PE_rst_state[6],o_PE_rst_state[15:7]};
		  o_PE_rst_state[5:0]	<= o_PE_rst_state[6:0] >> 1;
		  
		  Result_data[0][63:48] <= o_PE_rst_state[7] == 1 ? PE00 : Result_data[0][63:48];
		  Result_data[0][47:32] <= o_PE_rst_state[6] == 1 ? PE01 : Result_data[0][47:32];
		  Result_data[0][31:16] <= o_PE_rst_state[5] == 1 ? PE02 : Result_data[0][31:16];
		  Result_data[0][15:0]  <= o_PE_rst_state[4] == 1 ? PE03 : Result_data[0][15:0];
		  
		  Result_data[1][63:48] <= o_PE_rst_state[6] == 1 ? PE10 : Result_data[1][63:48];
		  Result_data[1][47:32] <= o_PE_rst_state[5] == 1 ? PE11 : Result_data[1][47:32];
		  Result_data[1][31:16] <= o_PE_rst_state[4] == 1 ? PE12 : Result_data[1][31:16];
		  Result_data[1][15:0]  <= o_PE_rst_state[3] == 1 ? PE13 : Result_data[1][15:0];
		  
		  Result_data[2][63:48] <= o_PE_rst_state[5] == 1 ? PE20 : Result_data[2][63:48];
		  Result_data[2][47:32] <= o_PE_rst_state[4] == 1 ? PE21 : Result_data[2][47:32];
		  Result_data[2][31:16] <= o_PE_rst_state[3] == 1 ? PE22 : Result_data[2][31:16];
		  Result_data[2][15:0]  <= o_PE_rst_state[2] == 1 ? PE23 : Result_data[2][15:0];
		  
		  Result_data[3][63:48] <= o_PE_rst_state[4] == 1 ? PE30 : Result_data[3][63:48];
		  Result_data[3][47:32] <= o_PE_rst_state[3] == 1 ? PE31 : Result_data[3][47:32];
		  Result_data[3][31:16] <= o_PE_rst_state[2] == 1 ? PE32 : Result_data[3][31:16];
		  Result_data[3][15:0]  <= o_PE_rst_state[1] == 1 ? PE33 : Result_data[3][15:0];
		  
	    end
	end
	
	assign	R0 = Data_0	 [buffer_in_cnt];
	assign	R1 = Data_1	 [buffer_in_cnt];
	assign	R2 = Data_2	 [buffer_in_cnt];
	assign	R3 = Data_3	 [buffer_in_cnt];
	assign	C0 = Weight_0 [buffer_in_cnt];
	assign	C1 = Weight_1 [buffer_in_cnt];
	assign	C2 = Weight_2 [buffer_in_cnt];
	assign	C3 = Weight_3 [buffer_in_cnt];
	
	assign	o_Data = o_Data_en ? Result_data[cal_cnt-12] : 0;
	assign 	o_Data_en = cal_cnt >= 12 ;
endmodule

