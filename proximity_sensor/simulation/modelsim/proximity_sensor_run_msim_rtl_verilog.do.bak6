transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Prithik/Documents/MTRX3700-Repo/proximity_sensor {C:/Users/Prithik/Documents/MTRX3700-Repo/proximity_sensor/sensor_driver.sv}
vlog -sv -work work +incdir+C:/Users/Prithik/Documents/MTRX3700-Repo/proximity_sensor {C:/Users/Prithik/Documents/MTRX3700-Repo/proximity_sensor/proximity.sv}

vlog -sv -work work +incdir+C:/Users/Prithik/Documents/MTRX3700-Repo/proximity_sensor {C:/Users/Prithik/Documents/MTRX3700-Repo/proximity_sensor/tb_proximity.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_proximity

add wave *
view structure
view signals
run -all
