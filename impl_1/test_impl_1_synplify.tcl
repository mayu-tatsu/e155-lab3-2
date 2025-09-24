#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology SBTICE40UP
set_option -part iCE40UP5K
set_option -package SG48I
set_option -speed_grade -6
#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -retiming false; set_option -pipe true

set_option -compiler_compatible 0


set_option -default_enum_encoding default

#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 0
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -rw_check_on_ram 0



#-- set any command lines input by customer

set_option -dup false
set_option -disable_io_insertion false
add_file -constraint {C:/lscc/radiant/2024.2/scripts/tcl/flow/radiant_synplify_vars.tcl}
add_file -verilog {C:/lscc/radiant/2024.2/ip/pmi/pmi_iCE40UP.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2024.2/ip/pmi/pmi_iCE40UP.vhd}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/debouncer.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/clk_gen.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/debouncer_timer.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/keypad.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/keypad_storage.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/lab3_mt.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/sev_seg.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/sev_seg_sel.sv}
add_file -verilog -vlog_std sysv {C:/Users/mtatsumi/my_designs/test/source/impl_1/synchronizer.sv}
#-- top module name
set_option -top_module lab3_mt
set_option -include_path {C:/Users/mtatsumi/my_designs/test}

#-- set result format/file last
project -result_format "vm"
project -result_file "./test_impl_1.vm"

#-- error message log file
project -log_file {test_impl_1.srf}

project -run -clean
