`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV
class my_monitor extends uvm_monitor;

    virtual my_if vif;

    uvm_analysis_port #(my_transaction)  ap;
    
    `uvm_component_utils(my_monitor)

    // constructor
    function new(string name = "my_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        // call the parent class's build phase
        super.build_phase(phase);

        // configure virtual interface
        if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
            `uvm_fatal("my_monitor", "virtual interface must be set for vif!!!")
        
        // create analysis port
        ap = new("ap", this);
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(my_transaction tr);

endclass

// main phase
task my_monitor::main_phase(uvm_phase phase);
    my_transaction tr;
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
    end
endtask

// collect_one_pkt
task my_monitor::collect_one_pkt(my_transaction tr);
    byte unsigned data_q[$];
    byte unsigned data_array[];
    logic [7:0] data;
    logic valid = 0;
    int data_size;
    
    // wait until vaild is high
    while(1) begin
        @(posedge vif.clk);
        if(vif.valid) break;
    end
    
    `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);

    // push data to dynamic queue while valid is high
    while(vif.valid) begin
        data_q.push_back(vif.data);
        @(posedge vif.clk);
    end

    // create an array whose size is equal to queue
    data_size  = data_q.size();   
    data_array = new[data_size];

    // copy data in queue to array
    for ( int i = 0; i < data_size; i++ ) begin
        data_array[i] = data_q[i]; 
    end

    tr.pload = new[data_size - 18]; //da sa, e_type, crc

    // unpack data_array and put it in tr, then calculate data size
    data_size = tr.unpack_bytes(data_array) / 8; 
    
    `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
