PROJECT=per_pwm

TOP=$(PROJECT)_tb

all: compile

compile: $(PROJECT)_lib/ $(RAM)
	make -f modelsim.make

gui: compile
	vsim -novopt $(PROJECT)_lib.$(TOP)

nogui: compile
	vsim -c -do nogui.do -novopt $(PROJECT)_lib.$(TOP)

$(PROJECT)_lib/: 
	vlib $(PROJECT)_lib
	vmap work $(PWD)/$(PROJECT)_lib

ghdl:
	make -f ghdl.make

gtkwave:
	make -f ghdl.make gtkwave

clean:
	rm -rf $(PROJECT)_lib modelsim.ini
	rm -rf transcript  vsim.wlf
	make -f ghdl.make clean
