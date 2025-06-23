class env_config extends uvm_object;
    
    `uvm_object_utils(env_config)

    // Configuration parameters
    int no_of_masters =1;
    int no_of_slaves =1;
    int no_of_score_board =1;
    
    axi_master_config master_cfg[];
    axi_slave_config slave_cfg[];

    extern function new(string name = "env_config");
endclass
//*****************************************function new*************************************/
function env_config::new(string name = "env_config");
    super.new(name);
endfunction    