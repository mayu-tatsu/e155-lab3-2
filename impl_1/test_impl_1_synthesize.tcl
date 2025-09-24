if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/mtatsumi/my_designs/test"
if {![file exists {C:/Users/mtatsumi/my_designs/test/impl_1}]} {
  file mkdir {C:/Users/mtatsumi/my_designs/test/impl_1}
}
cd {C:/Users/mtatsumi/my_designs/test/impl_1}
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- test_impl_1.vm test_impl_1.ldc
if {[file normalize "C:/Users/mtatsumi/my_designs/test/impl_1/test_impl_1_synplify.tcl"] != [file normalize "./test_impl_1_synplify.tcl"]} {
  file copy -force "C:/Users/mtatsumi/my_designs/test/impl_1/test_impl_1_synplify.tcl" "./test_impl_1_synplify.tcl"
}
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "test_impl_1_synplify.tcl" -log "test_impl_1.srf"} result options ]} {
    file delete -force -- test_impl_1.vm test_impl_1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o test_impl_1_syn.udb test_impl_1.vm] [list test_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
