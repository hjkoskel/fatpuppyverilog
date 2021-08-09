`default_nettype none
`timescale 1ns/1ps
module sweep_tb();


reg stepClk;
reg reset;
reg updirection=1;
reg [11:0]parStart=0; //12bit DAC
reg [11:0]parStep=1;
reg [11:0]parSteps=4095;
reg [11:0]parRepeats=512;

wire [11:0]result;
wire stepping;

sweep dut(
  .i_stepCLK(stepClk),
  .i_reset(reset),
  .i_updirection(updirection),
  .i_start(parStart), //12bit DAC
  .i_step(parStep),
  .i_steps(parSteps),
  .i_repeats(parRepeats),//How many points to wait on one vc
  .o_result(result),
  .o_stepping(stepping));

initial
	begin
	// save data for later
	$dumpfile("dump.vcd");
	$dumpvars(0, dut);
	$display("Start");

  repeat(10) begin
	#1 stepClk=1;
	#1 stepClk=0;
	end
  #1 reset=1;
  repeat(10) begin
	#1 stepClk=1;
	#1 stepClk=0;
	end
  #1 reset=0;
  repeat(10240) begin
	#1 stepClk=1;
	#1 stepClk=0;
	end




  end

endmodule
