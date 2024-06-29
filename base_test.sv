`ifndef BASE_TEST__SV
`define BASE_TEST__SV

// define a new class "base_test" that extends "uvm_test"
class base_test extends uvm_test;

    // declear an environment instance env
    my_env         env;
    
    // constructor of class base_test
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

    // this macro provides the necessary infrastructure for the UVM factory and other utilities, 
    // enabling the creation and configuration of base_test.
    `uvm_component_utils(base_test)

endclass

// build phase implementation
function void base_test::build_phase(uvm_phase phase);
    // call parent's "build_phase" to ensure parent class is set
    super.build_phase(phase);
    // creat implementation of my_env
    env  =  my_env::type_id::create("env", this);
endfunction

// Report Phase Implementation
function void base_test::report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;

    // call parent's "report_phase",
    // to ensure reporting actions defined in the parent class are also executed
    super.report_phase(phase);

    // retrieve the global UVM report implementation to server
    server = get_report_server();

    // get number of errors
    err_num = server.get_severity_count(UVM_ERROR);

    if (err_num != 0) begin
        $display("TEST CASE FAILED");
    end
    else begin
        $display("TEST CASE PASSED");
    end
endfunction

`endif
