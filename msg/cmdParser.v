`default_nettype none
/*
Parsing memory to values. Much easier to unit test
*/



module cmdParser
	#(parameter SHIFTBITS=64)(
	input i_shiftedIn,
	input [SHIFTBITS-1:0]i_mem,

	output o_parFlag_sweepOn,
	output o_parFlag_shutdown,
	output o_parFlag_ionize,
	output o_parFlag_pos,
	output o_parFlag_neg,
	output o_parFlag_pumpOn,
	output o_parFlag_sweepUp,
	output o_parFlag_attention,
	output o_parFlag_faimsEnable,

	output o_vcReset,
	output [11:0] o_parVc_step,
	output [11:0] o_parVc_repeats,
	output [11:0] o_parVc_start,
	output [11:0] o_parVc_steps,

	output o_faimsReset,
	output [7:0]o_parFaims_coil,
	output [9:0]o_parFaims_period,
	output [9:0]o_parFaims_pulse);


reg rparFlag_sweepOn=1;
reg rparFlag_shutdown=0;
reg rparFlag_ionize=0;
reg rparFlag_pos=0;
reg rparFlag_neg=0;
reg rparFlag_pumpOn=0;
reg rparFlag_sweepUp=1;
reg rparFlag_attention=0;
reg rparFlag_faimsEnable=0;


reg rResetVc;
/*
reg [11:0] rparVc_step=1;
reg [11:0] rparVc_repeats=512;
reg [11:0] rparVc_start=0;
reg [11:0] rparVc_steps=4095;
*/
reg [11:0] rparVc_step=4;
reg [11:0] rparVc_repeats=1024;
reg [11:0] rparVc_start=0;
reg [11:0] rparVc_steps=1024;


reg rResetFaims;

//Default values for debug?

reg [7:0]rparFaims_coil=0;
reg [9:0]rparFaims_period=0;
reg [9:0]rparFaims_pulse=0;
//reg [7:0]rparFaims_skips=8'h8;


wire funbit0=i_mem[0];
wire funbit1=i_mem[1];
wire funbit2=i_mem[2];

always @ (posedge i_shiftedIn) begin
	if(funbit0) begin
		rparFlag_sweepOn<=i_mem[8]; //bit0=1
		rparFlag_shutdown<=i_mem[9]; //bit1=2
		rparFlag_ionize<=i_mem[10]; //bit2=4
		rparFlag_pos<=i_mem[11]; //bit3=8
		rparFlag_neg<=i_mem[12]; //bit4=16
		rparFlag_pumpOn<=i_mem[13];
		rparFlag_sweepUp<=i_mem[14];
		rparFlag_attention<=i_mem[15]; //Device wants attention, press key etc..
		rparFlag_faimsEnable<=i_mem[16];
	end
	if(funbit1) begin //if (shiftMemIn[SETPARBIT_VC]) begin
		//rparVc_step<=mem[19:8];
		rparVc_step[11]<=i_mem[8];
		rparVc_step[10]<=i_mem[9];
		rparVc_step[9]<=i_mem[10];
		rparVc_step[8]<=i_mem[11];
		rparVc_step[7]<=i_mem[12];
		rparVc_step[6]<=i_mem[13];
		rparVc_step[5]<=i_mem[14];
		rparVc_step[4]<=i_mem[15];
		rparVc_step[3]<=i_mem[16];
		rparVc_step[2]<=i_mem[17];
		rparVc_step[1]<=i_mem[18];
		rparVc_step[0]<=i_mem[19];


		rparVc_repeats[11]<=i_mem[20];
		rparVc_repeats[10]<=i_mem[21];
		rparVc_repeats[9]<=i_mem[22];
		rparVc_repeats[8]<=i_mem[23];
		rparVc_repeats[7]<=i_mem[24];
		rparVc_repeats[6]<=i_mem[25];
		rparVc_repeats[5]<=i_mem[26];
		rparVc_repeats[4]<=i_mem[27];
		rparVc_repeats[3]<=i_mem[28];
		rparVc_repeats[2]<=i_mem[29];
		rparVc_repeats[1]<=i_mem[30];
		rparVc_repeats[0]<=i_mem[31];

		rparVc_start[11]<=i_mem[32];
		rparVc_start[10]<=i_mem[33];
		rparVc_start[9]<=i_mem[34];
		rparVc_start[8]<=i_mem[35];
		rparVc_start[7]<=i_mem[36];
		rparVc_start[6]<=i_mem[37];
		rparVc_start[5]<=i_mem[38];
		rparVc_start[4]<=i_mem[39];
		rparVc_start[3]<=i_mem[40];
		rparVc_start[2]<=i_mem[41];
		rparVc_start[1]<=i_mem[42];
		rparVc_start[0]<=i_mem[43];

		rparVc_steps[11]<=i_mem[44];
		rparVc_steps[10]<=i_mem[45];
		rparVc_steps[9]<=i_mem[46];
		rparVc_steps[8]<=i_mem[47];
		rparVc_steps[7]<=i_mem[48];
		rparVc_steps[6]<=i_mem[49];
		rparVc_steps[5]<=i_mem[50];
		rparVc_steps[4]<=i_mem[51];
		rparVc_steps[3]<=i_mem[52];
		rparVc_steps[2]<=i_mem[53];
		rparVc_steps[1]<=i_mem[54];
		rparVc_steps[0]<=i_mem[55];
		rResetVc=1;
	end else begin
		rResetVc=0;
	end
	if(funbit2) begin //if (shiftMemIn[SETPARBIT_FAIMS]) begin

		/* Liian iso, pienennetään
		rparFaims_coil[15]<=i_mem[8];
		rparFaims_coil[14]<=i_mem[9];
		rparFaims_coil[13]<=i_mem[10];
		rparFaims_coil[12]<=i_mem[11];
		rparFaims_coil[11]<=i_mem[12];
		rparFaims_coil[10]<=i_mem[13];
		rparFaims_coil[9]<=i_mem[14];
		rparFaims_coil[8]<=i_mem[15];
		rparFaims_coil[7]<=i_mem[16];
		rparFaims_coil[6]<=i_mem[17];
		rparFaims_coil[5]<=i_mem[18];
		rparFaims_coil[4]<=i_mem[19];
		rparFaims_coil[3]<=i_mem[20];
		rparFaims_coil[2]<=i_mem[21];
		rparFaims_coil[1]<=i_mem[22];
		rparFaims_coil[0]<=i_mem[23];
		*/
		rparFaims_coil[7]<=i_mem[8];
		rparFaims_coil[6]<=i_mem[9];
		rparFaims_coil[5]<=i_mem[10];
		rparFaims_coil[4]<=i_mem[11];
		rparFaims_coil[3]<=i_mem[12];
		rparFaims_coil[2]<=i_mem[13];
		rparFaims_coil[1]<=i_mem[14];
		rparFaims_coil[0]<=i_mem[15];


		/*pienennetään
		rparFaims_period[15]<=i_mem[24];
		rparFaims_period[14]<=i_mem[25];
		rparFaims_period[13]<=i_mem[26];
		rparFaims_period[12]<=i_mem[27];
		rparFaims_period[11]<=i_mem[28];
		rparFaims_period[10]<=i_mem[29];
		rparFaims_period[9]<=i_mem[30];
		rparFaims_period[8]<=i_mem[31];
		rparFaims_period[7]<=i_mem[32];
		rparFaims_period[6]<=i_mem[33];
		rparFaims_period[5]<=i_mem[34];
		rparFaims_period[4]<=i_mem[35];
		rparFaims_period[3]<=i_mem[36];
		rparFaims_period[2]<=i_mem[37];
		rparFaims_period[1]<=i_mem[38];
		rparFaims_period[0]<=i_mem[39];
		*/
		rparFaims_period[9]<=i_mem[16];
		rparFaims_period[8]<=i_mem[17];
		rparFaims_period[7]<=i_mem[18];
		rparFaims_period[6]<=i_mem[19];
		rparFaims_period[5]<=i_mem[20];
		rparFaims_period[4]<=i_mem[21];
		rparFaims_period[3]<=i_mem[22];
		rparFaims_period[2]<=i_mem[23];
		rparFaims_period[1]<=i_mem[24];
		rparFaims_period[0]<=i_mem[25];

		/* pienennetään
		rparFaims_pulse[15]<=i_mem[40];
		rparFaims_pulse[14]<=i_mem[41];
		rparFaims_pulse[13]<=i_mem[42];
		rparFaims_pulse[12]<=i_mem[43];
		rparFaims_pulse[11]<=i_mem[44];
		rparFaims_pulse[10]<=i_mem[45];
		rparFaims_pulse[9]<=i_mem[46];
		rparFaims_pulse[8]<=i_mem[47];
		rparFaims_pulse[7]<=i_mem[48];
		rparFaims_pulse[6]<=i_mem[49];
		rparFaims_pulse[5]<=i_mem[50];
		rparFaims_pulse[4]<=i_mem[51];
		rparFaims_pulse[3]<=i_mem[52];
		rparFaims_pulse[2]<=i_mem[53];
		rparFaims_pulse[1]<=i_mem[54];
		rparFaims_pulse[0]<=i_mem[55];
		*/
		rparFaims_pulse[9]<=i_mem[26];
		rparFaims_pulse[8]<=i_mem[27];
		rparFaims_pulse[7]<=i_mem[28];
		rparFaims_pulse[6]<=i_mem[29];
		rparFaims_pulse[5]<=i_mem[30];
		rparFaims_pulse[4]<=i_mem[31];
		rparFaims_pulse[3]<=i_mem[32];
		rparFaims_pulse[2]<=i_mem[33];
		rparFaims_pulse[1]<=i_mem[34];
		rparFaims_pulse[0]<=i_mem[35];

		/*
		rparFaims_skips[7]<=i_mem[56];
		rparFaims_skips[6]<=i_mem[57];
		rparFaims_skips[5]<=i_mem[58];
		rparFaims_skips[4]<=i_mem[59];
		rparFaims_skips[3]<=i_mem[60];
		rparFaims_skips[2]<=i_mem[61];
		rparFaims_skips[1]<=i_mem[62];
		rparFaims_skips[0]<=i_mem[63];
		*/

		rResetFaims=1;
	end else begin
		rResetFaims=0;
	end
end


assign o_parFlag_sweepOn=rparFlag_sweepOn;
assign o_parFlag_shutdown=rparFlag_shutdown;
assign o_parFlag_ionize=rparFlag_ionize;
assign o_parFlag_pos=rparFlag_pos;
assign o_parFlag_neg=rparFlag_neg;
assign o_parFlag_pumpOn=rparFlag_pumpOn;
assign o_parFlag_sweepUp=rparFlag_sweepUp;
assign o_parFlag_attention=rparFlag_attention;
assign o_parFlag_faimsEnable=rparFlag_faimsEnable;

assign o_vcReset=rResetVc;
assign o_parVc_step=rparVc_step;
assign o_parVc_repeats=rparVc_repeats;
assign o_parVc_start=rparVc_start;
assign o_parVc_steps=rparVc_steps;

assign o_faimsReset=rResetFaims;
assign o_parFaims_coil=rparFaims_coil;
assign o_parFaims_period=rparFaims_period;
assign o_parFaims_pulse=rparFaims_pulse;


endmodule
