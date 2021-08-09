`default_nettype none
/*
TODO support later triangle vs sawtooth (not really meaningful? get same flow delay)
*/
module sweep(
	input i_stepCLK,
	input i_reset,
	input i_updirection,
	input [11:0]i_start, //12bit DAC
	input [11:0]i_step,
	input [11:0]i_steps,
	input [11:0]i_repeats,//How many points to wait on one vc
	output [11:0]o_result,
	output o_stepping);

//fatal error: failed to place: placed 493 LCs of 1415 / 1280

reg [12:0]rptCounter=0;
reg [12:0]stepCounter=0;
reg [11:0]resultUp=0;
reg [11:0]resultDown=0;

reg stepping=0;

always @ (posedge i_stepCLK) begin

	if (i_reset) begin
		stepCounter={1'b0,i_steps};
		rptCounter={1'b0,i_repeats};
		resultUp=i_start;
		resultDown=i_start;
		stepping=0;
	end else begin
		if (rptCounter[12]==1) begin //repeats rolled over, step
			resultUp=resultUp+i_step;
			resultDown=resultDown-i_step;
			rptCounter={1'b0,i_repeats};
			stepCounter--;
			stepping=1;
		end else begin
			stepping=0;
		end
		rptCounter--;
		if (stepCounter[12]==1)begin//Steps are done
			stepCounter={1'b0,i_steps};
			resultUp=i_start;
			resultDown=i_start;
		end
	end
end

assign o_result=i_updirection?resultUp:resultDown;
assign o_stepping=stepping;
endmodule
