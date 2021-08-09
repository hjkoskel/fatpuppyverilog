#Build script
rm *.asc
rm *.bin
rm *.blif


rm ./adcs/dump.vcd
rm ./waveforms/dump.vcd
rm ./spislave/dump.vcd
rm ./nappi/dump.vcd
rm ./dacs/dump.vcd

rm ./adcs/a
rm ./waveforms/a
rm ./spislave/a
rm ./dacs/a

#yosys -p 'synth_ice40 -top top -json fatpuppy.json -blif fatpuppy.blif' fatpuppy.v msg/cmdParser.v waveforms/sweep.v waveforms/faims.v waveforms/coilPulse.v waveforms/faimsPulse.v spislave/spislave.v nappi/nappi.v nappi/watchdog.v nappi/debouncer.v adcs/dualpwmdecode.v adcs/adcplaceholder.v adcs/SPI_MCP3202.v adcs/ADC161S626.v adcs/sinc3.v adcs/cic_filter.v dacs/mcp4921.v && nextpnr-ice40 --hx1k --package vq100 --json fatpuppy.json --pcf puppy1k.pcf --asc fatpuppy.asc && icepack fatpuppy.asc fatpuppy.bin

## Now testing with 8k module
#yosys -p 'synth_ice40 -top top -json fatpuppy.json -blif fatpuppy.blif' fatpuppy.v msg/cmdParser.v waveforms/sweep.v waveforms/faims.v waveforms/coilPulse.v waveforms/faimsPulse.v spislave/spislave.v nappi/nappi.v nappi/watchdog.v nappi/debouncer.v adcs/dualpwmdecode.v adcs/adcplaceholder.v adcs/SPI_MCP3202.v adcs/ADC161S626.v adcs/sinc3.v adcs/cic_filter.v dacs/mcp4921.v && nextpnr-ice40 --hx8k --package ct256 --json fatpuppy.json --pcf puppy8k.pcf --asc fatpuppy.asc && icepack fatpuppy.asc fatpuppy.bin

yosys -p 'synth_ice40 -top top -json fatpuppy.json -blif fatpuppy.blif' fatpuppy.v waveforms/sweep.v msg/cmdParser.v spislave/spislave.v dacs/mcp4921.v adcs/sinc3.v waveforms/faims.v  && nextpnr-ice40 --hx8k --package ct256 --json fatpuppy.json --pcf puppy8k.pcf --asc fatpuppy.asc && icepack fatpuppy.asc fatpuppy.bin




#yosys -p 'synth_ice40 -top top -json fatpuppy.json -blif fatpuppy.blif' fatpuppy.v waveforms/sweep.v msg/cmdParser.v waveforms/faims.v spislave/spislave.v nappi/nappi.v nappi/watchdog.v nappi/debouncer.v adcs/dualpwmdecode.v adcs/adcplaceholder.v adcs/SPI_MCP3202.v adcs/ADC161S626.v dacs/mcp4921.v && nextpnr-ice40 --hx8k --package ct256 --json fatpuppy.json --pcf puppy8k.pcf --asc fatpuppy.asc && icepack fatpuppy.asc fatpuppy.bin


#nextpnr-ice40 --hx8k --package ct256 --json fatpuppy.json --pcf puppy8k.pcf --asc fatpuppy.asc



#Testing slavemodule on 8k
#yosys -p 'synth_ice40 -top top -json slavetest.json -blif slavetest.blif' spislave/spislavemodule.v spislave/spislave.v && nextpnr-ice40 --hx8k --package ct256 --json slavetest.json --pcf puppy8k.pcf --asc slavetest.asc && icepack slavetest.asc slavetest.bin

#slavemodule on 1k
#yosys -p 'synth_ice40 -top top -json slavetest.json -blif slavetest.blif' spislave/spislavemodule.v spislave/spislave.v && nextpnr-ice40 --hx1k --package vq100 --json slavetest.json --pcf puppy1k.pcf --asc slavetest.asc && icepack slavetest.asc slavetest.bin



#LED test
#yosys -p 'synth_ice40 -top top -json test.json -blif test.blif' testcodes/ledtest.v && nextpnr-ice40 --hx8k --package ct256 --json test.json --pcf puppy8k.pcf --asc test.asc && icepack test.asc test.bin


#yosys -p 'synth_ice40 -top top -json test.json -blif test.blif' testcodes/ledtest.v && nextpnr-ice40 --hx1k --package vq100 --json test.json --pcf puppy1k.pcf --asc test.asc && icepack test.asc test.bin
