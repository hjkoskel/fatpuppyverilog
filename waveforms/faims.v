`default_nettype none

/*
FAIMS module running coil and HV switches by parameter
possible HV feedback is done on raspberry or on FPGA.


Selostus:

Ideaalisti parSkipPulses=0 eli joka pulssilla starttaa

PeriodCountdown, kertoo periodin ja pulse countdown

Havaintoja 17 kesäkuuta kunnon diodeilla
- Skip pulses, SEN SAA NOLLAKSI KUNNON DIODEILLA
- Periodi ei mieltä yli 100kHz Eli 10us  siis 1000 rekkari.  10bit riittää 1024
- Faims pulssi voi olla mitä tahansa siis sama kuin period
- parWork ei mieltä yli 2us eli jos step 0.01. 200 SIIS 8bit riittää?

HUOMIOITAVAA:

Kelan räpsy jää soimaan vähän. FAIMSsia pitäisi käyttää mahdollisimman kaukana kelan transienteista

Eli tuetaan alle 50 prosenttia FAIMS pulssia. ylösvetävää faims trankkua pitää käyttää vain pulssiin.
Muuten pidetään hiljaisessa maassa.  Konkasta menee läpi AC ei DC.

*/

module faims(
	input CLK,
	input i_enable,
	input i_reset,

	input [9:0]i_parFaimsPeriod,
	input [9:0]i_parFaimsPulseLen, //IDEA: limit maximum by bits :D
	//input [7:0]i_parSkipPulses, //DCDC converter, skip how many
	input [7:0]i_parWork, //how long draw current

	output o_faimsUp,
	output o_faimsDown,
	output o_coilAU,
	output o_coilAD,
	output o_coilBU,
	output o_coilBD
);

/*
Tiivistys:

FAIMS periodicountteri laskee alas
	Resetistä lähtee uus FAIMS periodi että muuntajaperiodi
Faims tippuu kun aika, coil sammuu kun aika

Tähän tarvii myös rajoitteen.
JOS work on päällä enemmän kuin X prosenttia ajasta, niin sit disabloitu
ohjelmointikielellä raja olisi X<100* i_parWork/i_parFaimsPeriod

Sääntö. Ei yli 50 prosentin work ratiota?

*/
reg active;

reg [10:0]faimsPeriodCountdown=11'b0;
reg [10:0]faimsHalfCountdown=11'b0; //Half period
reg [10:0]faimsPulseCountdown=11'b0;
reg [8:0]workCountdown=9'b0;
reg prevReset=0;

reg modeA=0;

reg faimsOn=0;
reg coilActive=0;

always @ (posedge CLK) begin
	if ({prevReset,i_reset}==2'b01) begin
		faimsPeriodCountdown={1'b0,i_parFaimsPeriod};
		faimsHalfCountdown={1'b0,1'b0,i_parFaimsPeriod[9:1]};
		faimsPulseCountdown={1'b0,i_parFaimsPulseLen};
		workCountdown={1'b0,i_parWork};
		faimsOn=0;
		coilActive=0;
		modeA=0;
	end else begin
		if (faimsPeriodCountdown[10]==1) begin//Faims started
			faimsPeriodCountdown={1'b0,i_parFaimsPeriod};
			faimsHalfCountdown={1'b0,1'b0,i_parFaimsPeriod[9:1]};
			faimsPulseCountdown={1'b0,i_parFaimsPulseLen};
			workCountdown={1'b0,i_parWork};
			coilActive=0;
			modeA=!modeA;
		end else begin
			faimsPeriodCountdown--;
			faimsHalfCountdown--; //TODO vai vertailu tiettyyn lukuun?
		end

		if (faimsPulseCountdown[10]==1) begin //Picks upper half
			faimsOn=0;//pulse is over, counter
		end else begin
			faimsOn=1;
			faimsPulseCountdown--;
		end

		if (faimsHalfCountdown[10]==1) begin
			if (workCountdown[8]==1) begin
				coilActive=0;
			end else begin
				coilActive=1;
				workCountdown--;
			end
		end

	end
	prevReset=i_reset;
end



/*

wire faimsOn;
reg coilActive=0;
reg modeA=0;

reg [10:0]faimsPeriodCountdown=11'b0;
reg [10:0]faimsPulseCountdown=11'b0;
//reg [8:0]skipCounter=9'b0;
reg [10:0]workCountdown=11'b0;

reg prevReset;


faimsPulse faimsPulser(
	.CLK(CLK),
	.i_enable(i_enable),//acts also as reset
	.i_reset(i_reset),

	.i_period(i_parFaimsPeriod),
	.i_pulse(i_parFaimsPulseLen), //IDEA: limit maximum by bits :D

	.o_active(faimsOn)
);


coilPulse coilPulser(
	.CLK(CLK),
	.i_enable(i_enable),//acts also as reset
	.i_reset(i_reset),

	.i_trig(faimsOn), //trigger pulse,

	//.i_parSkipPulses(i_parSkipPulses), //DCDC converter, skip how many
	.i_parWork(i_parWork), //how long draw current

	.o_coilAU(o_coilAU),
	.o_coilAD(o_coilAD),
	.o_coilBU(o_coilBU),
	.o_coilBD(o_coilBD)
);


*/
assign o_faimsUp=faimsOn & i_enable;
assign o_faimsDown= (!faimsOn) & i_enable;


//wire coilLimiter;
//assign coilLimiter=faimsHalfCountdown[10];

assign o_coilAU=coilActive & modeA & i_enable;// & (~coilLimiter);
assign o_coilBD=coilActive & modeA & i_enable;// & (~coilLimiter);
assign o_coilAD=coilActive & (!modeA) & i_enable;// & (~coilLimiter);
assign o_coilBU=coilActive & (!modeA) & i_enable;// & (~coilLimiter);


endmodule
