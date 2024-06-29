`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
class my_driver extends uvm_driver#(my_transaction);

    virtual my_if vif;

    `uvm_component_utils(my_driver)
    function new(string name = "my_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // configure virtual interface
        if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
            `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task drive_one_pkt(my_transaction tr);
endclass

task my_driver::main_phase(uvm_phase phase);
    vif.data <= 8'b0;
    vif.valid <= 1'b0;

    // wait for reset deassertion
    while(!vif.rst_n) begin
        @(posedge vif.clk);
    end

    // get transactions from the sequencer and drive them
    while(1) begin
        // request next transaction from sequencer
        seq_item_port.get_next_item(req);

        // call task drive_one_pkt
        drive_one_pkt(req);

        // notifying the sequencer that the current transaction has been processed
        seq_item_port.item_done();
    end
endtask

task my_driver::drive_one_pkt(my_transaction tr);
    byte unsigned     data_q[];
    int  data_size;
    
    // pack tr to data_q and calculate data size of transaction
    data_size = tr.pack_bytes(data_q) / 8; 

    `uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);

    // wait 3 cycles
    repeat(3) @(posedge vif.clk);

    // drive each byte of the packed transaction data onto the interface
    for ( int i = 0; i < data_size; i++ ) begin
        @(posedge vif.clk);
        vif.valid <= 1'b1;
        vif.data <= data_q[i]; 
    end

    @(posedge vif.clk);

    // deassert vaild signal
    vif.valid <= 1'b0;
    `uvm_info("my_driver", "end drive one pkt", UVM_LOW);
endtask


`endif
