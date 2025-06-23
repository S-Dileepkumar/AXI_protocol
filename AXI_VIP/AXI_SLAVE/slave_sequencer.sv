class slave_sequencer extends uvm_sequencer #(axi_trans);
    `uvm_component_utils(slave_sequencer)
    
    extern function new(string name = "slave_sequencer", uvm_component parent);
endclass

//*****************************************function new*************************************/
function slave_sequencer::new(string name = "slave_sequencer", uvm_component parent);
    super.new(name, parent);
endfunction
