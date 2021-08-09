`default_nettype none
/*
Fatpuppy main module. Actual production software
Important to develop early to see are fpga capabilities enough
*/

module top(
	input CLK,
	input RXD,
	output TXD,

	//SPI from raspberry
	input SPIMOSI,
	output SPIMISO,
	input SPICS,
	input SPICLK,

	//faims board connector
	input HVADC_CLK, //sinc3 this is input
	input HVADC_DATA,

	output VC_LD,
	output VC_CS,
	output VC_CLK,
	output VC_DATA,


	output FAIMS,
	output NOTFAIMS,

	//ion board
	input IONDAT,
	input IONCLK,

	output BIASPOS,
	output BIASNEG,

	//coil driver
	output COIL_UPA,
	output COIL_DOWNA,
	output COIL_UPB,
	output COIL_DOWNB,

	//MISC IO
	input NAPPIBUTTON,
	output NAPPILED,
	output PUMP,
	output IONIZE,//Menee softan timeoutin mukana. Jos softa toimii niin ei hätää
	output RASPBERRY
);

wire vcReset;

reg [16:0]clkCountdown=0;
wire nextStep;
wire millisecClock;
always @ (posedge CLK) begin
	clkCountdown++;
end

//assign spimasterclk = clkCountdown[5];
assign millisecClock = clkCountdown[16];

reg nextVcStep;

sweep vcsweep(
	.i_stepCLK(adcSync&parFlag_sweepOn), //disables clock when not sweeping "pause"
	.i_reset(vcReset),
	.i_updirection(parFlag_sweepUp),
	.i_start(parVc_start),
	.i_step(parVc_step),
	.i_steps(parVc_steps),
	.i_repeats(parVc_repeats),//How many points to wait on one vc
	.o_result(vcDac),
	.o_stepping(nextVcStep)
);





//Input parameter parsing
parameter SETPARBIT_FLAG = 0;
parameter SETPARBIT_VC = 1;
parameter SETPARBIT_FAIMS = 2;

//command flags
wire parFlag_sweepOn;
wire parFlag_shutdown;
wire parFlag_ionize;
wire parFlag_pos;
wire parFlag_neg;
wire parFlag_pumpOn;
wire parFlag_sweepUp;
wire parFlag_attention;
wire parFlag_faimsEnable;

//command vc sweep
wire [11:0] parVc_step;
wire [11:0] parVc_repeats;
wire [11:0] parVc_start;
wire [11:0] parVc_steps;

//command faims parameters
wire [7:0]parFaims_coil;
wire [9:0]parFaims_period;
wire [9:0]parFaims_pulse;
//wire [7:0]parFaims_skips;

//TODO spreadsheet for addresses in packages
reg [3:0]rollCounter;


parameter SHIFTBITS=64; //Simplify, use same range?

wire [SHIFTBITS-1:0]shiftMemIn;
reg [0:SHIFTBITS-1]shiftMemOut;
wire shiftedIn; //Signal telling to go


wire [15:0]ionsAdc;
wire [15:0]dummyWORD;
wire [15:0]hvReadout;
wire [11:0]vcDac;
wire adcSync;

wire shortPress; //Starts when down, triggers when running
wire longPress; //Shutdown

wire computerOperational;


wire ldion;

wire faimsReset;
//This copies output values
always @ (posedge adcSync) begin
	shiftMemOut[15:0]<=ionsAdc; //TÄÄ MUKA TOIMI
	shiftMemOut[16:31]<=hvReadout;
	shiftMemOut[32:43]<=vcDac;
	shiftMemOut[44:52]<=rollCounter;
	shiftMemOut[53]<=shortPress;
	shiftMemOut[54]<=parFlag_ionize;
	shiftMemOut[55]<=parFlag_faimsEnable;
	shiftMemOut[56:63]<=8'b1; //Version
	rollCounter++;
end

	cmdParser parser(
		.i_shiftedIn(shiftedIn),
		.i_mem(shiftMemIn),

		.o_parFlag_sweepOn(parFlag_sweepOn),
		.o_parFlag_shutdown(parFlag_shutdown),
		.o_parFlag_ionize(parFlag_ionize),
		.o_parFlag_pos(parFlag_pos),
		.o_parFlag_neg(parFlag_neg),
		.o_parFlag_pumpOn(parFlag_pumpOn),
		.o_parFlag_sweepUp(parFlag_sweepUp),
		.o_parFlag_attention(parFlag_attention),
		.o_parFlag_faimsEnable(parFlag_faimsEnable),

		.o_vcReset(vcReset),
		.o_parVc_step(parVc_step),
		.o_parVc_repeats(parVc_repeats),
		.o_parVc_start(parVc_start),
		.o_parVc_steps(parVc_steps),

		.o_faimsReset(faimsReset),
		.o_parFaims_coil(parFaims_coil),
		.o_parFaims_period(parFaims_period),
		.o_parFaims_pulse(parFaims_pulse));



spislave #(.INPUTLEN(SHIFTBITS),.OUTPUTLEN(SHIFTBITS)) spishift (
	.CLK(CLK),
	.o_slaveDataIn(shiftMemIn), //Recieve from wires, output from module
	.i_slaveDataOut(shiftMemOut),
	.o_transferDone(shiftedIn),

	//SPI pins
	.i_SPICLK(SPICLK),
	.o_MISO(SPIMISO),
	.i_MOSI(SPIMOSI),
   	.i_CS(SPICS));


//TODO vaihda dac levyltä tähän, vastusarvot

mcp4921 #(.GAINONE(1),.CLKDIVBITS(20)) vcdac(
	.CLK(CLK),
	.i_data(vcDac),
	.i_trig(nextVcStep),//adcSync), //start sending
	.o_SPICLK(VC_CLK),
	.o_MOSI(VC_DATA),
   	.o_CS(VC_CS));

assign VC_LD=0;


/*
dualpwmdecode #(.BITS(16)) adcs(
	.CLK(clkCountdown[4]),//CLK),
	.i_a(HVADC_DATA),
	.i_b(IONDAT),
	.o_a(hvReadout),
	.o_b(ionsAdc),
	.o_sync(adcSync));
*/

wire extraAdcSync;

sinc3 oldadc(
	.mdata1(IONDAT),
	.mclk1(IONCLK),
	.reset(1'b0),
	.DATA(ionsAdc),
	.word_clk(adcSync)
);


sinc3 hvadc(
	.mdata1(HVADC_DATA),
	.mclk1(HVADC_CLK),
	.reset(1'b0),
	.DATA(hvReadout),
	.word_clk(extraAdcSync)
);


//For debugging
assign computerOperational=1;


faims faimswavegen(
	.CLK(CLK),
	.i_enable(parFlag_faimsEnable), // & computerOperational),
	.i_reset(faimsReset),
	.i_parFaimsPeriod(parFaims_period),
	.i_parFaimsPulseLen(parFaims_pulse), //IDEA: limit maximum by bits :D
	//.i_parSkipPulses(parFaims_skips), //DCDC converter, skip how many
	.i_parWork(parFaims_coil), //how long draw current
	.o_faimsUp(FAIMS),
	.o_faimsDown(NOTFAIMS),
	.o_coilAU(COIL_UPA),
	.o_coilAD(COIL_DOWNA),
	.o_coilBU(COIL_UPB),
	.o_coilBD(COIL_DOWNB)
);




assign PUMP=parFlag_pumpOn;
assign IONIZE=parFlag_ionize;
assign NAPPILED=parFlag_pos;
assign RASPBERRY=parFlag_neg;

endmodule
