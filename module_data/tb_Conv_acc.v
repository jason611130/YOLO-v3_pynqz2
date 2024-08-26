`define WIDTH 32

module tb_Conv_acc();

    reg                		clk;
    reg                		rst;
	reg						i_Weight_setup;
	reg						i_chip_en;
    wire 	[63:0]  	o_Data;
	
	wire	[63:0]		input_data;

    reg 		[63:0] 		mem_data			[0:100];
    reg                     start;
    
    integer cnt;
    integer file1;
    integer file2;
    integer status1;
    integer status2;
    integer i;
	integer img_cnt;
	integer total_cnt;

    Frame_Slide tb_conv(
		.clk(clk),
		.rst(rst),
		.i_data(input_data),
		.i_chip_en(i_chip_en),
		.o_data(o_Data),
		.o_done()
    );

    initial begin
        rst = 1;
        clk = 0;
        start = 0;
		mem_data[0] = {53'h0,9'b0_0000_0110,2'b11};
		i_chip_en = 1;
		$display("set_information: %h, ", mem_data[0]);
        // Open the files
        file1 = $fopen("/home/jason/Desktop/Yolo-V3_pynqz2/module_data/test_files/img.txt", "r");
        file2 = $fopen("/home/jason/Desktop/Yolo-V3_pynqz2/module_data/test_files/weight.txt", "r");
        
        if (file1 == 0 || file2 == 0) begin
            $display("Error: Could not open file.");
            $finish;
        end

        // Read data from the files
		for (i = 0; i < 9; i = i + 1) begin
            status2 = $fscanf(file2, "%h", mem_data[i+1]);
            if (status2 != 1) begin
                $display("Error reading data from file at index %0d", i);
                $finish;
            end
            $display("Weight data: %h",mem_data[i+1]);
        end
		
        for (i = 0; i < mem_data[0][10:2]*mem_data[0][10:2]; i = i + 1) begin
            status1 = $fscanf(file1, "%h", mem_data[i+10]);
            if (status1 != 1) begin
                $display("Error reading data from file at index %0d", i);
                $finish;
            end
            $display("img data: %h, ", mem_data[i+10]);
        end
		
		

        // Close the files
        $fclose(file1);
        $fclose(file2);

        // Release reset and start the simulation
        #10;
        rst = 0;
        start = 1;
        #10;
        
         i_chip_en = 0;
        #30000;
        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if(rst)begin
			total_cnt <= 0;
		end
		else begin
		  if(start && total_cnt < 10 +mem_data[0][10:2]*mem_data[0][10:2]-1 )begin
			total_cnt <= total_cnt + 1;
		  end
		end
	end
	
	assign input_data = mem_data[total_cnt];
endmodule