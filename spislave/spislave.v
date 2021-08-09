`default_nettype none
/*

Simple SPI slave in mode TODO

Sisääntulo on shiftirekkari. Ulostulo shiftireggari joka alkaa aina alusta CS:n aktivoituessa (ei sotkeennu)

CS aktiivinen alhaalla. Kun CS nousee niin muu logiikka nappaa mitä o_slaveDataIn rekkariin tuli.  Tää moduli siirtää CS:n pudotessa i_slaveDataOut sisällön talteen työshiftirekkariin ja alkaa nitkuttamaan

CPOL=0, CPHA=0 eli nousevalla kellon reunalla validi. Kello idlaa 0

YKSINKERTAISTUS: Fiksattu koko

*/

module spislave
	#(parameter INPUTLEN=64,parameter OUTPUTLEN=32)(
	input      CLK, //Main clock
	
	output [INPUTLEN-1:0] o_slaveDataIn, //Recieve from wires, output from module
	input [OUTPUTLEN-1:0] i_slaveDataOut,
	output o_transferDone,
	
	//SPI pins
	input i_SPICLK,
	output o_MISO,
	input i_MOSI,
   	input i_CS
	);

reg [OUTPUTLEN-1:0] dataOut; //transfer shift register for transmission
reg [INPUTLEN-1:0] dataIn; //work register while data flows in
reg [INPUTLEN-1:0] slaveDataIn; //This goes to FPGA logic... "to slave"  buffered result


// !!! CLOCK DOMAIN !!!!
// sync SCK to the FPGA clock using a 3-bits shift register
reg [2:0] SCKr;
reg [2:0] SSELr;
reg [1:0] MOSIr;
always @(posedge CLK) begin
	SCKr <= {SCKr[1:0], i_SPICLK};
	SSELr <= {SSELr[1:0], i_CS};
	MOSIr <= {MOSIr[0], i_MOSI};
end

wire SCK_risingedge = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
wire SCK_fallingedge = (SCKr[2:1]==2'b10);  // and falling edges

// same thing for SSEL (CS)

wire SSEL_active = ~SSELr[1];  // SSEL is active low
wire SSEL_startmessage = (SSELr[2:1]==2'b10);  // message starts at falling edge	
wire SSEL_endmessage = (SSELr[2:1]==2'b01);  // message stops at rising edge
wire MOSI_data = MOSIr[1];


//!!!! RECIEVE !!!!!!!!
always @(posedge CLK) begin
  if(SCK_risingedge) begin
    // implement a shift-left register (since we receive the data MSB first)
    dataIn <= {dataIn[INPUTLEN-2:0], MOSI_data};
  end
end

//------------- TRANSMISSION ---------------


//always @(posedge CLK) if(SSEL_startmessage) cnt<=cnt+8'h1;  // count the messages

always @(posedge CLK) begin
	if(SSEL_active) begin
		if(SSEL_startmessage) begin			
			dataOut<=i_slaveDataOut; //Copies fresh data for transfer. The latest, not
		end else begin
	  		if(SCK_fallingedge) begin
	      			dataOut <= {dataOut[OUTPUTLEN-2:0], 1'b0};
	  		end
	  	end
	end
	if(SSEL_endmessage) begin
		slaveDataIn<=dataIn; //Assing output data. No for glitches
	end
end

assign o_MISO = dataOut[OUTPUTLEN-1];  // send MSB first
assign o_transferDone=(SSELr[2:1]==2'b11);
assign o_slaveDataIn=slaveDataIn;

endmodule
