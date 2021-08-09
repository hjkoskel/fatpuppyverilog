/*
MCP4921/MCP4922
*/
`default_nettype none
module mcp4921 #(parameter DACB=0, parameter REFBUFFER=1, parameter GAINONE=1,parameter CLKDIVBITS=2)
	(input CLK,
	input [11:0]i_data,
	input i_trig, //start sending

	output o_SPICLK,
	output o_MOSI,
   	output o_CS
	);

reg [15:0]shiftContent=0;
reg trg;
reg sending=0;
reg [4:0]counter=0;

reg [CLKDIVBITS:0]clockdivider=0;

reg spiclk=0;

always @(posedge CLK) begin


	trg=i_trig;
	if (sending==0) begin
		if (debug_start) begin
			//Start send at here
			counter=0;
			sending=1;
			shiftContent[15]=DACB;
			shiftContent[14]=REFBUFFER;
			shiftContent[13]=GAINONE;
			shiftContent[12]=1; //Not shutdown
			shiftContent[11:0]=i_data;
		end
	end else begin
		clockdivider++;
		if (clockdivider[CLKDIVBITS])begin
			clockdivider=0;
			spiclk=!spiclk;
			if (spiclk==0) begin
				shiftContent={shiftContent[14:0],1'b0};
				counter++;
				if (counter[4]==1) begin // 4bit meni ympäri
					sending=0;
				end
			end
		end
	end
end

wire debug_start;
assign debug_start=i_trig & !trg;

assign o_CS=!sending;
assign o_MOSI=shiftContent[15];
assign o_SPICLK=spiclk;

endmodule
