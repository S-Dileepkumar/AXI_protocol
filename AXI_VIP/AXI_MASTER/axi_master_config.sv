class axi_master_config extends uvm_object;
    
    `uvm_object_utils(axi_master_config)

    virtual axi_if vif;
    // Configuration parameters
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    extern function new(string name = "axi_master_config");
endclass

//*****************************************function new*************************************/
function axi_master_config::new(string name = "axi_master_config");
    super.new(name);
endfunction    