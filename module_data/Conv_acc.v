`define 	WIDTH 16
`define	ctrl_state 			2'b00
`define	weight_state 		2'b01
`define	fullup_img_state	2'b10
`define	conv_state 		2'b11

module Conv_acc(	clk,
									rst,
									i_data,
									i_last_input,
									i_data_in_en,
									i_state,
									o_data,
									o_data_en,
									o_done
							);
							
	input 												clk;
	input 												rst;
	input 					 [143:0]				i_data;
	input					 [1:0]					i_state;
	input                                           i_data_in_en;
	input                                           i_last_input;

	output				 	 [63:0]					o_data;
	output				 								o_data_en;
	output                                          o_done;
	wire                                                w_data_en;
	
	wire 		signed [143:0]		w_weight_0;
	wire 		signed [143:0]		w_weight_1;
	wire 		signed [143:0]		w_weight_2;
	wire 		signed [143:0]		w_weight_3;
	

	wire					 	 [63:0]					w_Cal0_data;
	wire					 	 [63:0]					w_Cal1_data;
	wire					 	 [63:0]					w_Cal2_data;
	wire					 	 [63:0]					w_Cal3_data;
	
	wire													w_cal0_out_en;
	wire													w_cal1_out_en;
	wire													w_cal2_out_en;
	wire													w_cal3_out_en;
	
	reg						 [143:0] 				r_img_data	[0:15];			

	reg			signed [`WIDTH-1:0] 		Weight_0	[0:11];			
	reg			signed [`WIDTH-1:0] 		Weight_1	[0:11];			
	reg			signed [`WIDTH-1:0] 		Weight_2	[0:11];			
	reg			signed [`WIDTH-1:0] 		Weight_3	[0:11];

	reg						 [3:0]					data_in_cnt;
	reg						 [3:0]					buffer_in_cnt;
	reg						 [63:0]					r_output_buffer[0:15];
	
	reg						 [1:0]					r_cal0_cnt;
	reg						 [1:0]					r_cal1_cnt;
	reg						 [1:0]					r_cal2_cnt;
	reg                      [1:0]                  r_cal3_cnt;
	reg						 [3:0]					r_output_cnt;
	reg                      [3:0]                  r_complete_cnt;
	reg                      [3:0]                  r_last_cnt;
	reg                                             r_last_input;
	reg                                             r_cal0_en;
	reg                                             r_cal1_en;
	reg                                             r_cal2_en;
	reg                                             r_cal3_en;
	reg                     [63:0]                  r_data;
	reg                                             r_data_en;
	
	integer i;
	
	always@(posedge clk)begin
		if(rst)begin
			data_in_cnt <= 0;
			buffer_in_cnt <= 0;
			r_cal0_en <= 0;
            r_cal1_en <= 0;
            r_cal2_en <= 0;
            r_cal3_en <= 0;
            r_output_cnt <= 0;
            r_data_en <= 0;
			for(i = 0; i < 12; i = i +1)begin
				Weight_0[i]	 	<= 0;
				Weight_1[i]	 	<= 0;
				Weight_2[i]	 	<= 0;
				Weight_3[i]	 	<= 0;
			end
			for(i = 0; i < 9; i = i + 1)begin
				r_img_data[i] 				<= 0;
			end
			for(i = 0; i < 16 ;i = i + 1)begin
			   r_output_buffer[i] <= 0;
			end
			r_complete_cnt              <= 0;
		end
		else begin
			if(i_state == `weight_state)begin
				Weight_0[data_in_cnt]   		<= i_data[63:48];
			    Weight_1[data_in_cnt]		<= i_data[47:32];
			    Weight_2[data_in_cnt]		<= i_data[31:16];
			    Weight_3[data_in_cnt]		<= i_data[15:0];
				data_in_cnt 						<= data_in_cnt 	    == 8  ? 0 : data_in_cnt + 1;
				buffer_in_cnt               <= 0;
				r_complete_cnt              <= 0;
				r_last_cnt                  <= 0;
				r_last_input                <= 0;
			end
			
			else if(i_state == `conv_state)begin
			 if(i_data_in_en)begin
			    r_complete_cnt              <= r_complete_cnt + 1 ;
				r_img_data[buffer_in_cnt]	<= i_data;
				data_in_cnt			<= data_in_cnt + 1;
				buffer_in_cnt	    <= buffer_in_cnt + 1;
              end
              if(i_last_input)begin
                r_last_input <= 1;
              end

              r_cal0_en           <=  !r_cal0_en ? r_complete_cnt == 3  ? 1 : 0 : 0;
              r_cal1_en           <=  !r_cal1_en ? r_complete_cnt == 7  ? 1 : 0 : 0;
              r_cal2_en           <=  !r_cal2_en ? r_complete_cnt == 11 ? 1 : 0 : 0;
              r_cal3_en           <=  !r_cal3_en ? r_complete_cnt == 15 ? 1 : 0 : 0;
			end
		end
	end
	
	always@(posedge clk)begin
		if(rst)begin
			r_cal0_cnt <= 0;
			r_cal1_cnt <= 0;
			r_cal2_cnt <= 0;
			r_cal3_cnt <= 0;
		end
		else begin
			if(w_cal0_out_en)begin
				r_cal0_cnt <= r_cal0_cnt + 1;
			end
			if(w_cal1_out_en)begin
				r_cal1_cnt <= r_cal1_cnt + 1;
			end
			if(w_cal2_out_en)begin
				r_cal2_cnt <= r_cal2_cnt + 1;
			end
			if(w_cal3_out_en)begin
				r_cal3_cnt <= r_cal3_cnt + 1;
			end

			if(r_last_input)begin
			    r_last_cnt <= r_last_cnt == 13 ? 13 : r_last_cnt + 1;
			    r_last_input <= !(r_last_cnt == 13);
			    
			end
			r_data_en    <= w_data_en;
			r_output_cnt   <= r_data_en ? r_output_cnt + 1 : r_output_cnt;
			r_output_buffer[r_cal0_cnt] 		<= w_Cal0_data;
			r_output_buffer[r_cal1_cnt+4] 	<= w_Cal1_data;
			r_output_buffer[r_cal2_cnt+8]	<= w_Cal2_data;
			r_output_buffer[r_cal3_cnt+12]	<= w_Cal3_data;
		end
	end
	assign	w_weight_0 = {Weight_0[0],Weight_0[1],Weight_0[2],Weight_0[3],Weight_0[4],Weight_0[5],Weight_0[6],Weight_0[7],Weight_0[8]};
	assign	w_weight_1 = {Weight_1[0],Weight_1[1],Weight_1[2],Weight_1[3],Weight_1[4],Weight_1[5],Weight_1[6],Weight_1[7],Weight_1[8]};
	assign	w_weight_2 = {Weight_2[0],Weight_2[1],Weight_2[2],Weight_2[3],Weight_2[4],Weight_2[5],Weight_2[6],Weight_2[7],Weight_2[8]};
	assign	w_weight_3 = {Weight_3[0],Weight_3[1],Weight_3[2],Weight_3[3],Weight_3[4],Weight_3[5],Weight_3[6],Weight_3[7],Weight_3[8]};
	
	assign w_data_en = (w_cal0_out_en && r_output_cnt<4) || (w_cal1_out_en && r_output_cnt>=4 && r_output_cnt<8) || (w_cal2_out_en && r_output_cnt>=8 && r_output_cnt<12) || (w_cal3_out_en && r_output_cnt>= 12);
	assign o_data_en = r_data_en;
	assign o_data	 = r_output_buffer[r_output_cnt];
    assign o_done    = r_last_cnt == 14;
	
	Conv_4x4_PE Cal_array_0(
		.clk(clk),
		.rst(rst),
		.i_data_in_en(r_cal0_en || r_last_input),
		.i_img_data_0(r_img_data[0]),
		.i_img_data_1(r_img_data[1]),
		.i_img_data_2(r_img_data[2]),
		.i_img_data_3(r_img_data[3]),
		.i_weight_0(w_weight_0),
		.i_weight_1(w_weight_1),
		.i_weight_2(w_weight_2),
		.i_weight_3(w_weight_3),
		.o_data(w_Cal0_data),
		.o_data_en(w_cal0_out_en)
	);
	
	Conv_4x4_PE Cal_array_1(
		.clk(clk),
		.rst(rst),
		.i_data_in_en(r_cal1_en || r_last_input),
		.i_img_data_0(r_img_data[4]),
		.i_img_data_1(r_img_data[5]),
		.i_img_data_2(r_img_data[6]),
		.i_img_data_3(r_img_data[7]),
		.i_weight_0(w_weight_0),
		.i_weight_1(w_weight_1),
		.i_weight_2(w_weight_2),
		.i_weight_3(w_weight_3),
		.o_data(w_Cal1_data),
		.o_data_en(w_cal1_out_en)
	);
	
	Conv_4x4_PE Cal_array_2(
		.clk(clk),
		.rst(rst),
		.i_data_in_en(r_cal2_en || r_last_input),
		.i_img_data_0(r_img_data[8]),
		.i_img_data_1(r_img_data[9]),
		.i_img_data_2(r_img_data[10]),
		.i_img_data_3(r_img_data[11]),
		.i_weight_0(w_weight_0),
		.i_weight_1(w_weight_1),
		.i_weight_2(w_weight_2),
		.i_weight_3(w_weight_3),
		.o_data(w_Cal2_data),
		.o_data_en(w_cal2_out_en)
	);
	
	Conv_4x4_PE Cal_array_3(
		.clk(clk),
		.rst(rst),
		.i_data_in_en(r_cal3_en || r_last_input),
		.i_img_data_0(r_img_data[12]),
		.i_img_data_1(r_img_data[13]),
		.i_img_data_2(r_img_data[14]),
		.i_img_data_3(r_img_data[15]),
		.i_weight_0(w_weight_0),
		.i_weight_1(w_weight_1),
		.i_weight_2(w_weight_2),
		.i_weight_3(w_weight_3),
		.o_data(w_Cal3_data),
		.o_data_en(w_cal3_out_en)
	);
	
endmodule