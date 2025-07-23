#### Template Script for RTL->Gate-Level Flow (generated from RC v08.10-s121_1) 
#
#auri
set WITH_DFT 0

if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"
########################################################
## Include TCL utility scripts..
########################################################


#include load_etc.tcl

##############################################################################
## Preset global variables and attributes
##############################################################################


set DESIGN  $DESIGN 
set top_module $DESIGN
set SYN_EFF high
set MAP_EFF high
set DATE [clock format [clock seconds] -format "%b%d-%T"] 
## The following variables are used for diagnostic purposes only.
## They donot have any effect on the results of synthesis.
## Setting 'map_fancy_names' to 1 tells the tool to name the combinational
## cells based on the criteria that was used when selecting them.
set map_fancy_names 1

## Setting 'iopt_stats' to 1 prints out statistics during incremental
## optimization.
set iopt_stats 1


set _OUTPUTS_PATH outputs
set _LOG_PATH logs
set _REPORTS_PATH reports
#set_attribute wireload_mode $WL_MODE /
set_attribute information_level 7 /

###############################################################
## Library setup
###############################################################


set_attribute library $LIBRARY

####################################################################
## Load Design
####################################################################


read_hdl $FILE_LIST
elaborate $DESIGN
puts "Runtime & Memory after 'read_hdl'"
timestat Elaboration

check_design -unresolved

source constraints1.sdc

####################################################################
## Constraints Setup
####################################################################


puts "The number of exceptions is [llength [find /designs/$DESIGN -exception *]]"
#set_attribute force_wireload <wireload name> "/designs/$DESIGN"

if {![file exists ${_LOG_PATH}]} {
  file mkdir ${_LOG_PATH}
  puts "Creating directory ${_LOG_PATH}"
}

if {![file exists ${_OUTPUTS_PATH}]} {
  file mkdir ${_OUTPUTS_PATH}
  puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}

report timing -lint

###################################################################################
## Define cost groups (clock-clock, clock-output, input-clock, input-output)
###################################################################################

## Uncomment to remove already existing costgroups before creating new ones.
## rm [find /designs/* -cost_group *]

if {[llength [all::all_seqs]] > 0} { 
  define_cost_group -name I2C -design $DESIGN
  define_cost_group -name C2O -design $DESIGN
  define_cost_group -name C2C -design $DESIGN
  path_group -from [all::all_seqs] -to [all::all_seqs] -group C2C -name C2C
  path_group -from [all::all_seqs] -to [all::all_outs] -group C2O -name C2O
  path_group -from [all::all_inps]  -to [all::all_seqs] -group I2C -name I2C
}

define_cost_group -name I2O -design $DESIGN
path_group -from [all::all_inps]  -to [all::all_outs] -group I2O -name I2O
foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] >> $_REPORTS_PATH/${DESIGN}_pretim.rpt
}

## Forbid usage of cells which are not defined in the .lef file
set_dont_use {ACHCONX2 AND2X6 AND2X8 AND3X6 AND3X8 AND4X6 AND4X8 AO21X1 AO21X2 AO21X4 AO21XL AO22X1 AO22X2 AO22X4 AO22XL BMXIX2 BMXIX4 BUFX6 CLKAND2X12 CLKAND2X2 CLKAND2X3 CLKAND2X4 CLKAND2X6 CLKAND2X8 CLKBUFX6 CLKINVX6 CLKMX2X12 CLKMX2X2 CLKMX2X3 CLKMX2X4 CLKMX2X6 CLKMX2X8 CLKXOR2X1 CLKXOR2X2 CLKXOR2X4 CLKXOR2X8 DFFHQX8 DFFQX1 DFFQX2 DFFQX4 DFFQXL DFFRHQX8 DFFSHQX8 DFFSRHQX8 DLY1X4 DLY2X4 DLY3X4 DLY4X4 EDFFHQX1 EDFFHQX2 EDFFHQX4 EDFFHQX8 INVX6 MDFFHQX1 MDFFHQX2 MDFFHQX4 MDFFHQX8 MX2X6 MX2X8 MX3X1 MX3X2 MX3X4 MX3XL MXI2X6 MXI2X8 MXI3X1 MXI3X2 MXI3X4 MXI3XL NAND2X6 NAND2X8 NAND3X6 NAND3X8 NAND4X6 NAND4X8 NOR2X6 NOR2X8 NOR3X6 NOR3X8 NOR4X6 NOR4X8 OA21X1 OA21X2 OA21X4 OA21XL OA22X1 OA22X2 OA22X4 OA22XL OR2X6 OR2X8 OR3X6 OR3X8 OR4X6 OR4X8 SDFFHQX8 SDFFQX1 SDFFQX2 SDFFQX4 SDFFQXL SDFFRHQX8 SDFFSHQX8 SDFFSRHQX8 SEDFFHQX8 SMDFFHQX1 SMDFFHQX2 SMDFFHQX4 SMDFFHQX8 TBUFX6 TLATNCAX12 TLATNCAX16 TLATNCAX2 TLATNCAX20 TLATNCAX3 TLATNCAX4 TLATNCAX6 TLATNCAX8 TLATNTSCAX12 TLATNTSCAX16 TLATNTSCAX2 TLATNTSCAX20 TLATNTSCAX3 TLATNTSCAX4 TLATNTSCAX6 TLATNTSCAX8 XNOR3X1 XNOR3XL XOR3X1 XOR3XL}

####################################################################################################
## Synthesizing to generic 
####################################################################################################


synthesize -to_generic -eff $SYN_EFF
puts "Runtime & Memory after 'synthesize -to_generic'"
timestat GENERIC
report datapath > $_REPORTS_PATH/${DESIGN}_datapath_generic.rpt




## ungroup -threshold <value>

####################################################################################################
## Synthesizing to gates
####################################################################################################


synthesize -to_mapped -eff $MAP_EFF -no_incr
puts "Runtime & Memory after 'synthesize -to_map -no_incr'"
timestat MAPPED
report datapath > $_REPORTS_PATH/${DESIGN}_datapath_map.rpt

foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_[basename $cg]_post_map.rpt
}


##Intermediate netlist for LEC verification..
write_hdl -lec > ${_OUTPUTS_PATH}/${DESIGN}_intermediate.v
write_do_lec -revised_design ${_OUTPUTS_PATH}/${DESIGN}_intermediate.v -logfile ${_LOG_PATH}/rtl2intermediate.lec.log > ${_OUTPUTS_PATH}/rtl2intermediate.lec.do




synthesize -to_mapped -eff $MAP_EFF -incr   
puts "Runtime & Memory after incremental synthesis"
timestat INCREMENTAL

foreach cg [find / -cost_group -null_ok *] {
  report timing -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_[basename $cg]_post_incr.rpt
}

######################################################################################################
## write Encounter file set (verilog, SDC, config, etc.)
######################################################################################################


#write_design -innovus -basename  ${_OUTPUTS_PATH}/${DESIGN}
report area > $_REPORTS_PATH/${DESIGN}_area.rpt
report datapath > $_REPORTS_PATH/${DESIGN}_datapath_incr.rpt
report gates > $_REPORTS_PATH/${DESIGN}_gates.rpt
write_design -basename ${_OUTPUTS_PATH}/${DESIGN}
write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}.v
write_script > ${_OUTPUTS_PATH}/${DESIGN}.script
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}.sdc


#################################
### write_do_lec
#################################


write_do_lec -golden_design ${_OUTPUTS_PATH}/${DESIGN}_intermediate.v -revised_design ${_OUTPUTS_PATH}/${DESIGN}.v -logfile  ${_LOG_PATH}/intermediate2final.lec.log > ${_OUTPUTS_PATH}/intermediate2final.lec.do
##Uncomment if the RTL is to be compared with the final netlist..
write_do_lec -revised_design ${_OUTPUTS_PATH}/${DESIGN}_m.v -logfile ${_LOG_PATH}/rtl2final.lec.log > ${_OUTPUTS_PATH}/rtl2final.lec.do

puts "Final Runtime & Memory."
timestat FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

file copy [get_attr stdout_log /] ${_LOG_PATH}/.

##quit
