module sinc3(mdata1, mclk1, reset,DATA,word_clk);
//DEC256SINC24B

input mclk1; /*used to clk filter*/
input reset; /*used to reset filter*/
input mdata1; /*ip data to be filtered*/

output [15:0] DATA; 
output word_clk;

integer location;
integer info_file;

reg [23:0] ip_data1;
reg [23:0] acc1;
reg [23:0] acc2;
reg [23:0] acc3;
reg [23:0] acc3_d1;
reg [23:0] acc3_d2;
reg [23:0] diff1;
reg [23:0] diff2;
reg [23:0] diff3;
reg [23:0] diff1_d;
reg [23:0] diff2_d;
reg [15:0] DATA;
reg [7:0] word_count;


reg word_clk;
reg init;

/*Perform the Sinc ACTION*/
always @ (mdata1)
	if(mdata1==0)
		ip_data1 <= 0; /* change from a 0 to a -1 for 2's comp */
	else
ip_data1 <= 1;

/*ACCUMULATOR (INTEGRATOR)
Perform the accumulation (IIR) at the speed
of the modulator.
Z = one sample delay
MCLKOUT = modulators conversion bit rate
*/

always @ (negedge mclk1 or posedge reset)
if (reset)
	begin
	/*initialize acc registers on reset*/
	acc1 <= 0;
	acc2 <= 0;
	acc3 <= 0;
	end
else
	begin
	/*perform accumulation process*/
	acc1 <= acc1 + ip_data1;
	acc2 <= acc2 + acc1;
	acc3 <= acc3 + acc2;
	end

/*DECIMATION STAGE (MCLKOUT/ WORD_CLK) */

always @ (posedge mclk1 or posedge reset)
if (reset)
	word_count <= 0;
else
	word_count <= word_count + 1;
always @ (word_count)
	word_clk <= word_count[7];

/*DIFFERENTIATOR (including decimation
stage)
Perform the differentiation stage (FIR) at a
lower speed.
Z = one sample delay
WORD_CLK = output word rate
*/

always @ (posedge word_clk or posedge reset)
if(reset)
begin
acc3_d2 <= 0;
diff1_d <= 0;
diff2_d <= 0;
diff1 <= 0;
diff2 <= 0;
diff3 <= 0;
end
else
begin
diff1 <= acc3 - acc3_d2;
diff2 <= diff1 - diff1_d;
diff3 <= diff2 - diff2_d;
acc3_d2 <= acc3;
diff1_d <= diff1;
diff2_d <= diff2;
end

/* Clock the Sinc output into an output
register
WORD_CLK = output word rate
*/

always @ (posedge word_clk)
begin

DATA[15] <= diff3[23];
DATA[14] <= diff3[22];
DATA[13] <= diff3[21];
DATA[12] <= diff3[20];
DATA[11] <= diff3[19];
DATA[10] <= diff3[18];
DATA[9] <= diff3[17];
DATA[8] <= diff3[16];
DATA[7] <= diff3[15];
DATA[6] <= diff3[14];
DATA[5] <= diff3[13];
DATA[4] <= diff3[12];
DATA[3] <= diff3[11];
DATA[2] <= diff3[10];
DATA[1] <= diff3[9];
DATA[0] <= diff3[8];

end
endmodule
