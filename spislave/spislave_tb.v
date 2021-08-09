module spislave_tb();

	wire [4:0]dataI;
	wire done;
	wire pinMISO;
	
	reg clk;
	reg [4:0]dataO;
	reg pinCLK;
	reg pinMOSI;
	reg pinCS;
	
	
spislave #(.INPUTLEN(5), .OUTPUTLEN(5)) dut(
	.CLK(clk),
	.o_slaveDataIn(dataI), //Recieve from wires, output from module
	.i_slaveDataOut(dataO),
	.o_transferDone(done),
	
	.i_SPICLK(pinCLK),
	.o_MISO(pinMISO),
	.i_MOSI(pinMOSI),
   	.i_CS(pinCS));


initial
	begin           
	// save data for later
	$dumpfile("dump.vcd");
	$dumpvars(0, dut);
	$display("Start");


	pinCLK=0;
	pinMOSI=0;
	pinCS=1;
	clk=0;
	dataO=5;
	
	repeat(4) begin
	#1 clk=1;
	#1 clk=0;
	end

	pinCS=0;

	repeat(5) begin
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;
	#1 pinCLK=1;
	
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;

	#1 pinCLK=0;
	end

	pinMOSI=1;
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;
	#1 pinCLK=1;
	
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;

	#1 pinCLK=0;
	pinMOSI=0;

	repeat(5) begin
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;
	#1 pinCLK=1;
	
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;

	#1 pinCLK=0;
	end

	pinCS=1;
	
	repeat(5) begin
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;
	#1 pinCLK=1;
	
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;

	#1 pinCLK=0;
	end


	pinCS=0;
	
	repeat(5) begin
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;
	#1 pinCLK=1;
	
	#1 clk=1;
	#1 clk=0;
	#1 clk=1;
	#1 clk=0;

	#1 pinCLK=0;
	end
	
	end

endmodule
