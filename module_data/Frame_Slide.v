/***************************************************
Software only give one image data one time
It means that take a part(16bits) of 64bits
 
input  to Conv		1 dimension(16bits) 
output from Conv	4 dimension(64bits)

control signal

63~11		10~2				1~0
invaild		img_size		img_dimension

if control signal comes, the next data will be weight for 9 clock
***************************************************/
`define	ctrl_state 			2'b000
`define	weight_state 		2'b001
`define	fullup_img_state 	2'b010
`define	conv_state 		2'b011

module Frame_Slide(	clk,
									rst,
									i_data,
									i_chip_en,
									o_data,
									o_done);
	
	input						clk;
	input						rst;
	input		[63:0] 		i_data;
	input                   i_chip_en;

	output		[63:0]		o_data;
	output						o_done;
	
	reg			[15:0]		r_img_0[0:415];//416*2+3 Prepare last one be the spare
	reg			[15:0]		r_img_1[0:415];
	reg			[15:0]		r_img_2[0:3];
	reg			[8:0]			r_img_index;
	reg			[1:0]			r_img_dimension;
	reg			[8:0]			r_img_size;
	reg			[4:0]			r_weight_cnt;
	reg			[1:0]			r_state;
	reg			[17:0]		r_full_img_cnt;
	reg							r_conv_rdy;
	reg         	[1:0]			r_img_row_index;
	reg			[22:0]		r_total_clk_cnt;
	reg			[9:0]			r_frame_cnt;
	reg         [17:0]      r_conv_data_cnt;
	
	wire 		[143:0]		w_conv_data;
	wire 		[15:0]		w_frame_img_data;
	wire							w_frame_finish_input;
	wire							w_conv_out_en;
	wire			[63:0]		w_conv_out_data;
	wire                    w_frame_data_set;
	wire                   w_finish_conv_input;
	wire                   w_last_input;
	
	
	integer i;
	always@(posedge clk)begin
		if(rst)begin
			r_img_index			<= 0;
			r_img_dimension		<= 0;
			r_img_size				<= 0;
			r_weight_cnt			<= 0;
			r_full_img_cnt			<= 0;
			r_state						<= `ctrl_state;
			r_conv_rdy				<= 0;
			r_img_row_index 	<= 0;
			r_total_clk_cnt			<= 0;
			r_frame_cnt				<= 0;
			r_conv_data_cnt         <= 0;
			for(i = 0; i < 416; i = i + 1)begin
					r_img_0[i]	<= 0; 
					r_img_1[i]	<= 0; 
			end
			for(i = 0; i < 4; i = i + 1)begin
					r_img_2[i]	<= 0;  
			end
		end
		else begin
				case(r_state)

					`ctrl_state:begin
						r_img_index			<= 0;
						r_img_dimension		<= i_data[1:0];
						r_img_size				<= i_chip_en ? i_data[10:2] : 0;
						r_weight_cnt			<= 0;
						r_full_img_cnt			<= 0;
						r_conv_rdy              <= 0 ;
						r_state <= i_chip_en ? `weight_state : `ctrl_state;
					end
					
					`weight_state:begin
						r_weight_cnt		<= r_weight_cnt == 8 ? r_weight_cnt : r_weight_cnt + 1;
						r_state					<= r_weight_cnt == 8 ? `fullup_img_state : `weight_state;
					end
					`fullup_img_state:begin
						r_full_img_cnt 		<=	w_frame_finish_input ? 0 : r_full_img_cnt + 1;
						r_img_index		<=	r_img_row_index == 2 && r_img_index == 2 ? 2 :r_img_index == r_img_size - 1 ? 0 : r_img_index + 1; 
																						
						r_img_row_index	<= 	r_img_index == 	r_img_size - 1 ? r_img_row_index == 2 ? 2 : r_img_row_index + 1 : r_img_row_index;
						
						r_state					<=	r_img_row_index == 2	&& r_img_index == 2 ?`conv_state : `fullup_img_state;
										
					end
					`conv_state:begin
						r_total_clk_cnt		<= r_total_clk_cnt + 1;
						r_frame_cnt			<= r_frame_cnt == r_img_size-1 ? 0 : r_frame_cnt + 1;
						r_state             <= o_done ? `ctrl_state : `conv_state;
				
					end
				endcase
				
		end
	end
	
	always@(posedge clk)begin
		if(r_conv_rdy)begin
			
			for(i = 0; i < r_img_size; i = i + 1)begin
				r_img_0[i] <= r_img_0[i+1];
				r_img_1[i] <= r_img_1[i+1];
			end
			r_img_0[r_img_size-1] 	<= r_img_1[0];
			r_img_1[r_img_size-1] 	<= r_img_2[0];
			r_img_2[0]						<= r_img_2[1];
			r_img_2[1]						<= r_img_2[2];
			r_img_2[2]						<= r_img_2[3];
			r_img_2[3]						<= w_frame_img_data;
		end
		else begin
			case(r_img_row_index)
				2'b00:r_img_0[r_img_index]	<=	w_frame_img_data;
				2'b01:r_img_1[r_img_index]	<=	w_frame_img_data;
				2'b10:r_img_2[r_img_index]	<=	w_frame_img_data;
				default:;
			endcase
		end
		if(r_img_row_index == 2	&& r_img_index == 2)begin
			r_conv_rdy <= 1;
			r_conv_data_cnt <= !w_finish_conv_input && w_frame_data_set ? r_conv_data_cnt + 1 : r_conv_data_cnt;
		end

	end
	

	assign	w_frame_finish_input	= r_full_img_cnt == r_img_size*r_img_size-1 ;
	assign	w_frame_img_data		= i_data[((r_img_dimension+1)*16-1) - : 16];
	assign	w_conv_data				= !r_conv_rdy ? {80'h0000_0000_0000_0000_0000,i_data} :
																					{r_img_0[0],	r_img_0[1], 		r_img_0[2], 		
																					 r_img_1[0],		r_img_1[1],		r_img_1[2],		
																					 r_img_2[0],		r_img_2[1],		r_img_2[2]};
	
	assign o_data 						= w_conv_out_en ? w_conv_out_data  : 0 ;
	assign w_frame_data_set             = (r_frame_cnt < r_img_size-2) & r_conv_rdy && !w_finish_conv_input;
	assign w_finish_conv_input          = r_conv_data_cnt == (r_img_size-2)*(r_img_size-2);
	assign w_last_input                 = r_conv_data_cnt == (r_img_size-2)*(r_img_size-2) - 1 && w_frame_data_set;
	
	Conv_acc Conv_acc_ip(
		.clk(clk),
		.rst(rst),
		.i_data_in_en(w_frame_data_set),
		.i_data(w_conv_data),
		.i_last_input(w_last_input),
		.i_state(r_state),
		.o_data(w_conv_out_data),
		.o_data_en(w_conv_out_en),
		.o_done(o_done)
	);
endmodule