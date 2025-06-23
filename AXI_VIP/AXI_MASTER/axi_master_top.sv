class axi_master_top extends uvm_env;

    `uvm_component_utils(axi_master_top)
    
    env_config cfg;
    axi_master_agent master_agent[];

    extern function new(string name = "axi_master_top", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
endclass

//*****************************************function new*************************************/
    function axi_master_top::new(string name = "axi_master_top", uvm_component parent);
            super.new(name, parent);
    endfunction

//*****************************************function build phase*************************************/
    function void axi_master_top::build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
                `uvm_fatal(get_type_name(),"getting is not possible for env_config in axi_master_top")

            master_agent = new[cfg.no_of_masters];

            foreach(master_agent[i])
                begin
                    uvm_config_db #(axi_master_config)::set(this, $sformatf("master_agent[%0d]*",i),"axi_master_config",cfg.master_cfg[i]);
                    master_agent[i] = axi_master_agent::type_id::create($sformatf("master_agent[%0d]",i),this);
                end
    endfunction
