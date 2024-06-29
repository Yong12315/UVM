`ifndef MY_ENV__SV
`define MY_ENV__SV

class my_env extends uvm_env;

    my_agent i_agt;
    my_agent o_agt;
    my_model mdl;
    my_scoreboard scb;
    
    uvm_tlm_analysis_fifo #(my_transaction) agt_scb_fifo;
    uvm_tlm_analysis_fifo #(my_transaction) agt_mdl_fifo;
    uvm_tlm_analysis_fifo #(my_transaction) mdl_scb_fifo;
    
    // constructor of class my_env
    function new(string name = "my_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        // call the parent class's build phase
        super.build_phase(phase);

        // create In_agent instance
        i_agt = my_agent::type_id::create("i_agt", this);
        // create Out_agent instance
        o_agt = my_agent::type_id::create("o_agt", this);

        // set In_agent as active
        i_agt.is_active = UVM_ACTIVE;
        // set Out_agent as passive
        o_agt.is_active = UVM_PASSIVE;

        // create Reference Model instance
        mdl = my_model::type_id::create("mdl", this);
        // create Scoreboard instance
        scb = my_scoreboard::type_id::create("scb", this);

        // Creates instances of TLM(Transaction-Level Modeling) analysis FIFOs
        agt_scb_fifo = new("agt_scb_fifo", this);
        agt_mdl_fifo = new("agt_mdl_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this);

    endfunction

    extern virtual function void connect_phase(uvm_phase phase);
    
    `uvm_component_utils(my_env)
endclass

// connect phase implementation
function void my_env::connect_phase(uvm_phase phase);
    // call the parent class's connect phase
    super.connect_phase(phase);

    // connect analysis port of In_agent ap to export port of Reference Model
    i_agt.ap.connect(agt_mdl_fifo.analysis_export);

    // connect port of Reference Model to 
    mdl.port.connect(agt_mdl_fifo.blocking_get_export);
    mdl.ap.connect(mdl_scb_fifo.analysis_export);
    scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
    o_agt.ap.connect(agt_scb_fifo.analysis_export);
    scb.act_port.connect(agt_scb_fifo.blocking_get_export); 
endfunction

`endif
