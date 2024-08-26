`define WIDTH 16
module PE(clk,rst,Input_A,Input_B,Output_A,Output_B,Output_C);
	input 			   	clk;
	input 				rst;
	input 	signed [`WIDTH-1:0] 	Input_A;
	input 	signed [`WIDTH-1:0] 	Input_B;
	
	output	signed [`WIDTH-1:0] 	Output_A;
	output	signed [`WIDTH-1:0] 	Output_B;
	output	signed [`WIDTH-1:0] 	Output_C;
	
	reg 		signed [`WIDTH-1:0] 	Buffer_A;
	reg 		signed [`WIDTH-1:0] 	Buffer_B;
	reg 		signed [`WIDTH-1:0] 	Buffer_C;
	
	always@(posedge clk)begin
	   if(rst)begin
			Buffer_A <= 0;
			Buffer_B <= 0;
			Buffer_C <= 0;
        end
        else begin
			Buffer_A <= Input_A;
			Buffer_B <= Input_B;
			Buffer_C <= Input_A * Input_B + Buffer_C;
	   end
	end

	assign Output_A = Buffer_A;
	assign Output_B = Buffer_B;
	assign Output_C = Buffer_C;
endmodule