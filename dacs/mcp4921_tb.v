module mcp4921_tb();

reg clk;
reg trig;

reg [11:0]word=12'b010111;

wire spiclk;
wire mosi;
wire cs;


mcp4921 #(.CLKDIVBITS(2)) dut(.CLK(clk),
.i_data(word),
.i_trig(trig),

.o_SPICLK(spiclk),
.o_MOSI(mosi),
.o_CS(cs));

//  0 1 1 1 0 0 0 0 0 0 0 1 0 1 1 1
initial
	begin
	// save data for later
	$dumpfile("dump.vcd");
	$dumpvars(0, dut);
	$display("Start");


	trig=0;
	clk=0;
	repeat(64) begin
	#1 clk=1;
	#1 clk=0;
	end

	trig=1;
        #1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;
	trig=0;
	repeat(200) begin
	#1 clk=1;
	#1 clk=0;
	end

	trig=1;
	repeat(200) begin
	#1 clk=1;
	#1 clk=0;
	end


end

endmodule
