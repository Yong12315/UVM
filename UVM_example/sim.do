# set location of UVM
set UVM_HOME D:/QuestaSim/verilog_src/uvm-1.1d
# set location of UVM DPI liberary 
set UVM_DPI_HOME D:/QuestaSim/uvm-1.1d/win64
# set location of work catalog
set WORK_HOME D:/TrashBin/UVM_example_test

# creat a logic liberary, "work", to store design after complied
vlib work
# complie V or SV file, and indicate their location
vlog +incdir+$UVM_HOME/src -L mtiAv, -L mtiOvm -L mtiUvm -L mtiUPF $UVM_HOME/src/uvm_pkg.sv $WORK_HOME/dut.sv tb_top.sv
# start simulation. "+UVM_TESTNAME=my_case0" indicate whitch case is running.
vsim -novopt -c -sv_lib $UVM_DPI_HOME/uvm_dpi work.tb_top +UVM_TESTNAME=my_case0

# add wave to window
add wave  \
sim:/tb_top/clk \
sim:/tb_top/rst_n \
sim:/tb_top/output_if.data \
sim:/tb_top/output_if.valid \
sim:/tb_top/input_if.data \
sim:/tb_top/input_if.valid

run -all
