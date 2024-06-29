`ifndef MY_CASE0__SV
`define MY_CASE0__SV

class my_case0 extends base_test;
    function new(string name = "my_case0", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);

    `uvm_component_utils(my_case0)
endclass

class case0_sequence extends uvm_sequence #(my_transaction);

    my_transaction m_trans;

    function  new(string name= "case0_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
      // starting_phase is the pointer pointing to phase because uvm_sequence is not uvm_component
        if(starting_phase != null)
            starting_phase.raise_objection(this);
        repeat (2) begin
         // 这个宏每执行一次，就会向uvm_sequencer发送一个数据，
         // uvm_sequencer每收到一个数据，就会转给uvm_driver
         // 只有在driver中得到并驱动数据需要多个时钟才会占用仿真时间
         // equal 1. create 2. start_item() 3. assert(.randomize()) 4. finish_item()
         //`uvm_do(m_trans)
            `uvm_do_with(m_trans,{m_trans.pload.size()==64;})
        end
        #100;
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case0_sequence)
    
endclass

function void my_case0::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.i_agt.sqr.main_phase", "default_sequence", case0_sequence::type_id::get());
endfunction

`endif
