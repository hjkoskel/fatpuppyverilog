`default_nettype none

/*
FAIMS module running coil and HV switches by parameter
possible HV feedback is done on raspberry or on FPGA.


Selostus:

Ideaalisti parSkipPulses=0 eli joka pulssilla starttaa

PeriodCountdown, kertoo periodin ja pulse countdown
*/

module faims(
	input CLK,
	input i_enable,
	input i_reset,

	input [15:0]i_parFaimsPeriod,
	input [15:0]i_parFaimsPulseLen, //IDEA: limit maximum by bits :D
	input [7:0]i_parSkipPulses, //DCDC converter, skip how many
	input [15:0]i_parWork, //how long draw current
	
	output o_faimsUp,
	output o_faimsDown,
	output o_coilAU,
	output o_coilAD,
	output o_coilBU,
	output o_coilBD
);


reg faimsOn;
reg coilActive=0;
reg modeA=0;

reg [16:0]faimsPeriodCountdown=17'b0;
reg [16:0]faimsPulseCountdown=17'b0;
reg [8:0]skipCounter=9'b0;
reg [16:0]workCountdown=16'b0;

reg prevReset;

always @ (posedge CLK) begin
	if ({prevReset,i_reset}==2'b01) begin
		faimsPeriodCountdown=i_parFaimsPeriod;
		faimsPulseCountdown=i_parFaimsPulseLen;
		skipCounter=i_parSkipPulses;
		workCountdown=i_parWork;
	end else begin		
		faimsPeriodCountdown=faimsPeriodCountdown-1;
		faimsPulseCountdown=faimsPulseCountdown-1;
		workCountdown=workCountdown-1;
		
		if (faimsPeriodCountdown[16]==1) begin//Faims started
			faimsOn<=1;
			faimsPeriodCountdown=i_parFaimsPeriod;
			faimsPulseCountdown=i_parFaimsPulseLen;
			skipCounter--; //Count for 
		end
		if (faimsPulseCountdown[16]==1) begin
			faimsOn<=0;//pulse is over, counter
		end
		if (skipCounter[8]==1) begin
			skipCounter <= i_parSkipPulses;
			coilActive<=1;
			workCountdown=i_parWork;
		end
		if (workCountdown[16]==1) begin
			coilActive<=0;
		end		
	end
	prevReset=i_reset;
end

always @ (posedge coilActive) begin
	modeA=!modeA;
end

assign o_coilAU=coilActive & modeA & i_enable;
assign o_coilBD=coilActive & modeA & i_enable;

assign o_coilAD=coilActive & (!modeA) & i_enable;
assign o_coilBU=coilActive & (!modeA) & i_enable;

assign o_faimsUp=faimsOn & i_enable;
assign o_faimsDown= (!faimsOn) & i_enable;

endmodule

