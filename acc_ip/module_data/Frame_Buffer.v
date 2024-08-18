/***************************************************
Software only give one image data one time
It means that take a part(16bits) of 64bits
 
input  to Conv		1 dimension(16bits) 
output from Conv	4 dimension(64bits)

control signal

64~11		10~2				1~0
invaild		img_size		img_dimension

if control signal comes, the next data will be weight for 9 clock
***************************************************/
`define	ctrl_state 		2'b00
`define	weight_state 	2b'01
`define	image_state 	2'b10

module Frame_Slide(	clk,
										rst,
										i_data,
										i_ctrl;
										i_img_size,
										i_img_index,
										o_data,
										o_done);
	
	input						clk;
	input						rst;
	input						i_ctrl;
	input		[63:0] 		i_data;

	output	[63:0]		o_data;
	output					o_done;
	
	reg			[15:0]		r_img	[0:835];//416*2+4 Prepare last one be the spare
	reg			[9:0]		r_img_index;
	reg			[1:0]		r_img_dimension;
	reg			[8:0]		r_img_size;
	reg			[4:0]		r_weight_cnt;
	reg			[1:0]		r_state;
	reg			[17:0]		r_full_img_cnt;
	
	wire 						w_conv_rdy;
	wire 		[143:0]	w_conv_data;
	wire 		[15:0]		w_frame_img_data;
	wire						w_frame_finish_input;
	
	integer i;
	always@(posedge clk)begin
		if(rst)begin
			r_img_index			<= 0;
			r_img_dimension	<= 0;
			r_img_size				<= 0;
			r_weight_cnt			<= 0;
			r_full_img_cnt		<= 0;
			r_state					<= `ctrl_state;
			for(i = 0; i < 836; i = i + 1)begin
					r_img[i]	<= 0; 
			end
		end
		else begin
				
				case(r_state)
					`ctrl_state:begin
						r_img_index			<= 0;
						r_img_dimension	<= i_data[1:0];
						r_img_size				<= i_data[10:2];
						r_weight_cnt			<= 0;
						r_full_img_cnt		<= 0;
						r_state <= `weight_state;
					end
					
					`weight_state:begin
						r_state <= `image_state;
						r_weight_cnt	<= r_weight_cnt == 8 ? r_weight_cnt : r_weight_cnt + 1;
						r_state			<= r_weight_cnt == 8 ? `image_state : `weight_state;
					end
					
					`image_state:begin
						r_full_img_cnt 	<=	w_frame_finish_input ? 0 : r_full_img_cnt + 1;
						r_state				<=	w_frame_finish_input ?`ctrl_state : `image_state;
						r_img_index		<=	w_conv_rdy ? 835 : 
																					(r_img_index == i_img_size-1) || (r_img_index == i_img_size*2-1) ? 
																					r_img_index + (416 - i_img_size+1) : r_img_index + 1;
					end
					default:begin
						r_state <= `ctrl_state;
					end
				endcase
				
		end
	end
	
	always@(posedge clk)begin
		if(w_conv_rdy)begin
			r_img[835]	<= w_frame_img_data;
			for(i = 0; i < 835; i = i + 1)begin
				r_img[i] <= r_img[i+1];
			end
		end
		else begin
			r_img[r_img_index]	<=	w_frame_img_data;	
			
		end
	end
	
	assign	w_frame_finish_input	= r_full_img_cnt == r_img_size*r_img_size-1;
	assign	w_frame_img_data		= i_data[((r_img_dimension+1)*16-1) - : 16];
	assign	w_conv_rdy					= r_img_index == 835 ;
	assign	w_conv_data					= 	!w_conv_rdy ? {80'h00_0000_0000,i_data} :
																						{r_img[0], 	 	r_img[1], 		r_img[2],
																						 r_img[416],	r_img[417],	r_img[418]
																						 r_img[832],	r_img[833],	r_img[834]};
endmodule