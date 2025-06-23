class master_sequencer extends uvm_sequencer #(axi_trans);
    `uvm_component_utils(master_sequencer)
    
    extern function new(string name = "master_sequencer", uvm_component parent);
endclass

//*****************************************function new*************************************/
function master_sequencer::new(string name = "master_sequencer", uvm_component parent);
    super.new(name, parent);
endfunction
