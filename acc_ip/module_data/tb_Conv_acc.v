`define WIDTH 32

module tb_Conv_acc();

    reg                	clk;
    reg                	rst;
	reg					i_Weight_setup;

	reg    [63:0]		w_Data;
	wire				o_Data_en;
    wire [63:0]  	o_Data;
	wire [14:0]  	o_PE_state;

    reg 	[63:0] 		img			[0:8];
    reg 	[63:0] 		weight 	[0:8];
   
    
    integer cnt;
    integer file1;
    integer file2;
    integer status1;
    integer status2;
    integer i;
	integer img_cnt;
	integer total_cnt;

    Conv_acc tb_conv(
        .clk(clk),
        .rst(rst),
        .i_Data(w_Data),
		.i_Weight_setup(i_Weight_setup),
		.o_Data(o_Data),
		.o_Data_en(o_Data_en),
		.o_PE_rst_state(o_PE_state)
    );

    initial begin
        rst = 1;
        clk = 0;
        cnt = 0;
        total_cnt = 0;
        // Open the files
        file1 = $fopen("/home/jason/Desktop/acc_ip/img.txt", "r");
        file2 = $fopen("/home/jason/Desktop/acc_ip/weight.txt", "r");
        
        if (file1 == 0 || file2 == 0) begin
            $display("Error: Could not open file.");
            $finish;
        end

        // Read data from the files
        for (i = 0; i < 9; i = i + 1) begin
            status1 = $fscanf(file1, "%h", img[i]);
            if (status1 != 1) begin
                $display("Error reading data from file at index %0d", i);
                $finish;
            end
            $display("Read data: %h, ", img[i]);
        end
		
		for (i = 0; i < 9; i = i + 1) begin
            status2 = $fscanf(file2, "%h", weight[i]);
            if (status2 != 1) begin
                $display("Error reading data from file at index %0d", i);
                $finish;
            end
            $display("Read data: %h",weight[i]);
        end

        // Close the files
        $fclose(file1);
        $fclose(file2);

        // Release reset and start the simulation
        #10;
        rst = 0;
        #300;
        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (rst) begin
            w_Data = 0;
			i_Weight_setup = 1;
			img_cnt = 0;
        end 
		else begin
			if(cnt<9)begin
				w_Data = weight[cnt];
			end
			else begin
				if(img_cnt<9)begin
					i_Weight_setup = 0;
					w_Data = img[img_cnt];
					img_cnt = img_cnt+1;
				end
				else begin 
					w_Data = 0;
				end
			end
			cnt = cnt +1 ;
		end
	 end

endmodule