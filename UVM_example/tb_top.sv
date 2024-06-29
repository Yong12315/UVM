`timescale 1ns/1ps

// include UVM macros, and import UVM package.
`include "uvm_macros.svh"
import uvm_pkg::*;

// include user's SV file
`include "my_if.sv"
`include "my_transaction.sv"
`include "my_sequencer.sv"
`include "my_driver.sv"
`include "my_monitor.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_env.sv"
`include "base_test.sv"
`include "my_case0.sv"
`include "my_case1.sv"

module tb_top;

reg                                 clk                         ;
reg                                 rst_n                       ;
reg                [   7: 0]        wr_data                     ;
reg                                 wr_en                       ;
wire               [   7: 0]        rd_data                     ;
wire                                rd_valid                    ;

// instantialize input interface
my_if input_if (clk, rst_n);

// instantialize output interface
my_if output_if (clk, rst_n);

// instantialize DUT(design under test)
dut my_dut (
    .clk                                (clk                        ),
    .rst_n                              (rst_n                      ),
    .wr_data                            (input_if.data              ),
    .wr_en                              (input_if.valid             ),
    .rd_data                            (output_if.data             ),
    .rd_valid                           (output_if.valid            ),
    .empty                              (                           ),
    .full                               (                           ) 
);

// drive clock signal
initial begin
    clk = 0;
    forever begin
        #100 clk = ~clk;
    end
end

// drive reset signal
initial begin
    rst_n = 1'b0;
    #1000;
    rst_n = 1'b1;
end

// running the test
initial begin
    run_test();
end

// set the virtual interface for the driver and monitors in the agent.
initial begin
    uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
    uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);
    uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if);
end

endmodule
