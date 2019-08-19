transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Philippe/Documents/ULg/Quadri 2/Digital electronics/Projects/Codes/Mastermind.vhd}

vcom -93 -work work {C:/Users/Philippe/Documents/ULg/Quadri 2/Digital electronics/Projects/Codes/TestBench.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L maxv -L rtl_work -L work -voptargs="+acc"  TestBench

add wave *
view structure
view signals
run 100 sec
