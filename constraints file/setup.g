# *************************************************
# * Local Variable settings for this design
# *************************************************
include load_etc.tcl
set LOCAL_DIR "[exec pwd]"
set SYNTH_DIR $LOCAL_DIR
set RTL_PATH $LOCAL_DIR/verilog
set LIB_PATH $LOCAL_DIR/library
set LIBRARY  {fast.lib}
set FILE_LIST  {tollboothcontroller.v}
set SYN_EFFORT   high
set MAP_EFFORT   high
set DESIGN       tollboothcontroller
set THE_DATE  [exec date +%m%d.%H%M]

# *********************************************************
# * Display the system info and Start Time
# *********************************************************
puts "The output file  PREFIX is ${THE_DATE} \n"

set_attr information_level 9 /
set_attr hdl_search_path ${RTL_PATH} /
set_attr lib_search_path ${LIB_PATH} /

