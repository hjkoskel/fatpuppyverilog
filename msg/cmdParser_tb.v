`default_nettype none
module cmdParser_tb();

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

	wire [7:0]parFaims_coil;
	wire [9:0]parFaims_period;
	wire [9:0]parFaims_pulse;
	//wire [7:0]parFaims_skips;

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

		.o_parFaims_coil(parFaims_coil),
		.o_parFaims_period(parFaims_period),
		.o_parFaims_pulse(parFaims_pulse));

initial
	begin
	// save data for later
	$dumpfile("dump.vcd");
	$dumpvars(0, dut);
	$display("Start");

	/*
	Data recieved:  ELI MSB ensin
	dataIn <= {dataIn[INPUTLEN-2:0], MOSI_data};
	*/

	#1 mem=0;
	#1 shiftedIn=0;
	#1 mem=64'b0000000000000000000000000000000000000000000000000100000100000001;
	#1 shiftedIn=1;


	#1 shiftedIn=0;
	#1 mem=64'b0000001000000100011100100111111111111111011111111111111100000100;
	#1 shiftedIn=1;

	#1 shiftedIn=0;
	#1 mem=64'b0000000000010111110011100010000000001000000010000000000000000010;
	#1 shiftedIn=1;


	#1 shiftedIn=0;
	#1 mem=64'b0;
	#1 shiftedIn=1;


	end
endmodule
