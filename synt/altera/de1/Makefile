# Project name
PRJ = rt_sopc_de1

# Hardware variables
ARGS = --read_settings_files=on --write_settings_files=off
VHD	= $(wildcard *.vhd)
SDC	= $(wildcard *.sdc)
BIN = $(wildcard ../../soft/bin/*.bin)

all: $(PRJ).sof

# Links to the compilation flow
map: $(PRJ).map.rpt

fit: $(PRJ).fit.rpt

asm: $(PRJ).sof

sta: $(PRJ).sta.rpt

# Configure the FPGA. Must have compiled before.
config: $(PRJ).sof
	quartus_pgm -c USB-Blaster -m JTAG -o p\;$(PRJ).sof

epcs: $(PRJ).pof
	@echo "Not for the moment :/"
#	quartus_pgm -c USB-Blaster -m AS -o p\;$(PRJ).pof

# Hardware compilation flow
$(PRJ).map.rpt: $(VHD) $(PRJ).qsf $(PRJ).qpf $(RAM)
	quartus_map $(ARGS) $(PRJ) -c $(PRJ)
#	quartus_map --64bit $(ARGS) $(PRJ) -c $(PRJ)

$(PRJ).fit.rpt: $(PRJ).map.rpt
	quartus_fit  $(ARGS) $(PRJ) -c $(PRJ)
#	quartus_fit --64bit $(ARGS) $(PRJ) -c $(PRJ)

$(PRJ).sof: $(PRJ).fit.rpt $(PRJ).sta.rpt
	quartus_asm $(ARGS) $(PRJ) -c $(PRJ)
#	quartus_asm --64bit $(ARGS) $(PRJ) -c $(PRJ)

$(PRJ).pof: $(PRJ).sof

$(PRJ).sta.rpt: $(SDC) $(PRJ).fit.rpt
	quartus_sta $(PRJ) -c $(PRJ)
#	quartus_sta --64bit $(PRJ) -c $(PRJ)

# Cleaning the project
clean:
	rm -rf incremental_db/ db/ hc_output/ $(PRJ).done $(PRJ).flow.rpt $(PRJ).map.rpt $(PRJ).map.summary $(PRJ).map.smsg
	rm -rf $(PRJ).fit.rpt $(PRJ).fit.smsg $(PRJ).fit.summary $(PRJ).pin
	rm -rf $(PRJ).asm.rpt $(PRJ).jdi
	rm -rf $(PRJ).sta.summary $(PRJ).qws
	rm -rf PLLJ_PLLSPE_INFO.txt
	rm -rf greybox_tmp

mrproper: clean
	rm -rf $(PRJ).sof $(PRJ).pof $(PRJ).sta.rpt
