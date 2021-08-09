`default_nettype none
module faims_tb();

/*
FAIMS module running coil and HV switches by parameter
possible HV feedback is done on raspberry or on FPGA.

*/

reg clk;
reg enable;

reg [9:0]parFaimsPeriod=250;
reg [9:0]parFaimsPulseLen=20; //IDEA: limit maximum by bits :D
reg [7:0]work=50;

reg reset;

wire faimsUp;
wire faimsDown;
wire coilAU;
wire coilAD;
wire coilBU;
wire coilBD;

faims dut(
	.CLK(clk),
	.i_enable(enable),//acts also as reset
	.i_reset(reset),

	.i_parFaimsPeriod(parFaimsPeriod),
	.i_parFaimsPulseLen(parFaimsPulseLen), //IDEA: limit maximum by bits :D
	//.i_parSkipPulses(parSkipPulses), //DCDC converter, skip how many
	.i_parWork(work), //how long draw current

	.o_faimsUp(faimsUp),
	.o_faimsDown(faimsDown),
	.o_coilAU(coilAU),
	.o_coilAD(coilAD),
	.o_coilBU(coilBU),
	.o_coilBD(coilBD)
);

initial begin
	// save data for later
	$dumpfile("dump.vcd");
	$dumpvars(0, dut);
	$display("Start");

	enable=0;
	reset=0;
	clk=0;
	#1 clk=1;
	#1 clk=0;
	enable=1;
	reset=1;
	repeat(1000000) begin
	#1 clk<=1;
	#1 clk<=0;
	end

	reset=0;
	parFaimsPeriod=250;
	parFaimsPulseLen=20; //IDEA: limit maximum by bits :D
	//parSkipPulses=8'd8; //DCDC converter, skip how many
	work=200;
	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;
	end
	reset=1;
	repeat(1000000) begin
	#1 clk<=1;
	#1 clk<=0;
	end

	work=100;
	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;
	end
	reset=0;
	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;
	end
	reset=1;
	repeat(1000000) begin
	#1 clk<=1;
	#1 clk<=0;
	end
end

endmodule
