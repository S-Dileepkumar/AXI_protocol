class axi_slave_config extends uvm_object;
    
    `uvm_object_utils(axi_slave_config)
    virtual axi_if vif;
    // Configuration parameters
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    extern function new(string name = "axi_slave_config");
endclass
//*****************************************function new*************************************/
function axi_slave_config::new(string name = "axi_slave_config");
    super.new(name);
endfunction    