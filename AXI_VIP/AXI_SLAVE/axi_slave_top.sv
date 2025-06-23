class axi_slave_top extends uvm_env;

    `uvm_component_utils(axi_slave_top)
    
    env_config cfg;
    axi_slave_agent slave_agent[];

    extern function new(string name = "axi_slave_top", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
endclass

//*****************************************function new*************************************/
    function axi_slave_top::new(string name = "axi_slave_top", uvm_component parent);
            super.new(name, parent);
    endfunction

//*****************************************function build phase*************************************/
    function void axi_slave_top::build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
                `uvm_fatal(get_type_name(),"getting is not possible for env_config in axi_slave_top")

            slave_agent = new[cfg.no_of_slaves];

            foreach(slave_agent[i])
                begin

                uvm_config_db #(axi_slave_config)::set(this, $sformatf("slave_agent[%0d]*",i),"axi_slave_config",cfg.slave_cfg[i]);
                slave_agent[i] = axi_slave_agent::type_id::create($sformatf("slave_agent[%0d]",i),this);
                
                end
    endfunction
