# Generated by vmake version 10.4b

# Define path to each library
LIB_STD = /opt/altera_lite/15.1/modelsim_ase/linuxaloem/../std
LIB_IEEE = /opt/altera_lite/15.1/modelsim_ase/linuxaloem/../ieee
LIB_WORK = pwm_lib
LIB_PWM_LIB = pwm_lib

# Define path to each design unit
IEEE__std_logic_1164 = $(LIB_IEEE)/_lib.qdb
STD__textio = $(LIB_STD)/_lib.qdb
IEEE__numeric_std = $(LIB_IEEE)/_lib.qdb
PWM_LIB__pwm_tb__testbench = $(LIB_PWM_LIB)/_lib.qdb
PWM_LIB__pwm_tb = $(LIB_PWM_LIB)/_lib.qdb
PWM_LIB__pwm_pkg = $(LIB_PWM_LIB)/_lib.qdb
PWM_LIB__pwm__rtl = $(LIB_PWM_LIB)/_lib.qdb
PWM_LIB__pwm = $(LIB_PWM_LIB)/_lib.qdb
VCOM = vcom
VLOG = vlog
VOPT = vopt
SCCOM = sccom

whole_library : $(LIB_PWM_LIB)/_lib.qdb

$(LIB_PWM_LIB)/_lib.qdb : ../../../rtl/misc/pwm/pwm_entity.vhd \
		$(PWM_LIB__pwm_pkg) \
		$(IEEE__numeric_std) \
		$(STD__textio) \
		$(IEEE__std_logic_1164) ../../../rtl/misc/pwm/pwm_arch.vhd \
		$(PWM_LIB__pwm_pkg) \
		$(PWM_LIB__pwm) \
		$(IEEE__numeric_std) \
		$(STD__textio) \
		$(IEEE__std_logic_1164) ../../../rtl/misc/pwm/pwm_pkg.vhd \
		$(IEEE__numeric_std) \
		$(STD__textio) \
		$(IEEE__std_logic_1164) ../../../rtl/misc/pwm/pwm_tb.vhd \
		$(PWM_LIB__pwm_pkg) \
		$(IEEE__numeric_std) \
		$(STD__textio) \
		$(IEEE__std_logic_1164)
	$(VCOM) -work pwm_lib -2008 ../../../rtl/misc/pwm/pwm_pkg.vhd
	$(VCOM) -work pwm_lib -2008 ../../../rtl/misc/pwm/pwm_entity.vhd
	$(VCOM) -work pwm_lib -2008 ../../../rtl/misc/pwm/pwm_arch.vhd
	$(VCOM) -work pwm_lib -2008 ../../../rtl/misc/pwm/pwm_tb.vhd
