`default_nettype none
module gencmd_tb();
	reg shiftedIn;
	reg [63:0]mem;
	
	wire parFlag_sweepOn;
	wire parFlag_shutdown;
	wire parFlag_ionize;
	wire parFlag_pos;
	wire parFlag_neg;
	wire parFlag_pumpOn;
	wire parFlag_sweepUp;
	wire parFlag_attention;
	wire parFlag_faimsEnable;

	wire vcReseted;
	wire [11:0] parVc_step;
	wire [11:0] parVc_repeats;
	wire [11:0] parVc_start;
	wire [11:0] parVc_steps;

	wire [15:0]parFaims_coil;
	wire [15:0]parFaims_period;
	wire [15:0]parFaims_pulse;
	wire [7:0]parFaims_skips;

	wire faimsReset;

	cmdParser dut(
		.i_shiftedIn(shiftedIn),
		.i_mem(mem),
	
		.o_parFlag_sweepOn(parFlag_sweepOn),
		.o_parFlag_shutdown(parFlag_shutdown),
		.o_parFlag_ionize(parFlag_ionize),
		.o_parFlag_pos(parFlag_pos),
		.o_parFlag_neg(parFlag_neg),
		.o_parFlag_pumpOn(parFlag_pumpOn),
		.o_parFlag_sweepUp(parFlag_sweepUp),
		.o_parFlag_attention(parFlag_attention),
		.o_parFlag_faimsEnable(parFlag_faimsEnable),
		
		.o_vcReset(vcReseted),
		.o_parVc_step(parVc_step),
		.o_parVc_repeats(parVc_repeats),
		.o_parVc_start(parVc_start),
		.o_parVc_steps(parVc_steps),

		.o_faimsReset(faimsReset),
		.o_parFaims_coil(parFaims_coil),
		.o_parFaims_period(parFaims_period),
		.o_parFaims_pulse(parFaims_pulse),
		.o_parFaims_skips(parFaims_skips));
	
	
	
reg clk;
reg enable;

reg [15:0]parFaimsPeriod=10;
reg [15:0]parFaimsPulseLen=5; //IDEA: limit maximum by bits :D
reg [7:0]parSkipPulses=0; //DCDC converter, skip how many
reg [15:0]work=3;

reg reset;

wire faimsUp;
wire faimsDown;
wire coilAU;
wire coilAD;
wire coilBU;
wire coilBD;




faims faimswavegen(
	.CLK(clk),
	.i_enable(parFlag_faimsEnable),
	.i_reset(faimsReset),
	.i_parFaimsPeriod(parFaims_period),
	.i_parFaimsPulseLen(parFaims_pulse), //IDEA: limit maximum by bits :D
	.i_parSkipPulses(parFaims_skips), //DCDC converter, skip how many
	.i_parWork(parFaims_coil), //how long draw current
	.o_faimsUp(faimsUp),
	.o_faimsDown(faimsDown),
	.o_coilAU(coilAU),
	.o_coilAD(coilAD),
	.o_coilBU(coilBU),
	.o_coilBD(coilBD)
);

initial
	begin           
	// save data for later
	$dumpfile("dump.vcd");
	$dumpvars(0, dut);
	$dumpvars(0, faimswavegen);

	$display("Start");

	/*
	Data recieved:  ELI MSB ensin
	dataIn <= {dataIn[INPUTLEN-2:0], MOSI_data};
	*/

	#1 mem=0;
	#1 shiftedIn=0;
	//#1 mem=64'b0000000000000000000000000000000000000000000000000100000100000001;
	#1 mem=64'b0000000000000000000000000000000000000000000000010100000100000001;
	#1 shiftedIn=1;

	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;	
	end

	
	#1 shiftedIn=0;
	//#1 mem=64'b00000010 0000010001110010 01111111 11111111 01111111 11111111 00000100;
	//	#1 mem=64'b0000001000000100011100100111111111111111011111111111111100000100;
	//		#1 mem=64'b1100000000001011111000000000001000111001011111111111111100000100;
	#1 mem=64'b0001000000000000001000000000010111110000000010111110000000000100;
	#1 shiftedIn=1;

	/*
	Lopputuloksena
	parWork 65534=1111111111111110  NOK
	parFaims_period, annettu 4000 eli 40000==1111111111111110 NOK
	parFaims_pulse, annettu 200 =2000 = 0100111000100000 OK
	skip= 64 = 01000000	OK
	
	EI PITÄIS MUUTTUA
	
	*/


	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;	
	end

	#1 shiftedIn=0;
	#1 mem=64'b0000000000010111110011100010000000001000000010000000000000000010;
	#1 shiftedIn=1;

	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;	
	end

	#1 shiftedIn=0;
	#1 mem=64'b0;
	#1 shiftedIn=1;

	repeat(10000) begin
	#1 clk<=1;
	#1 clk<=0;	
	end
	
end

/*

Process name Coil
formatstring=%016b
bitstring=1000 0000 0000 00000
Process name Period
formatstring=%016b
bitstring=1000 0000 0000 0000 00000000000000001
Process name Pulse
formatstring=%016b
bitstring=1000000000000000000000000000000010000011111010000
Process name Skips
formatstring=%08b
bitstring=100000000000000000000000000000001000001111101000000000011



*/


endmodule
