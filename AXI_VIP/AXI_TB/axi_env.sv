class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    env_config cfg;
    axi_master_top master_top;
    axi_slave_top slave_top;
    axi_scoreboard scoreboard;

    extern function new(string name = "axi_env", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void end_of_elaboration_phase(uvm_phase phase);
endclass
//*****************************************function new*************************************/
function axi_env::new(string name = "axi_env", uvm_component parent);
    super.new(name, parent);
endfunction

//*****************************************function build phase*************************************/
function void axi_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(env_config)::get(this,"", "env_config", cfg))
        `uvm_fatal(get_type_name(), "cfg not found in uvm_config_db")
   
 
    if(cfg.no_of_masters)
        master_top = axi_master_top::type_id::create("master_top", this);

    if(cfg.no_of_slaves)
        slave_top = axi_slave_top::type_id::create("slave_top", this); 

    if(cfg.no_of_score_board)  
        scoreboard = axi_scoreboard::type_id::create("scoreboard", this);

   
endfunction

//*****************************************function connect phase*************************************/
 function void axi_env::connect_phase(uvm_phase phase);
     super.connect_phase(phase);
	
	master_top.master_agent[0].monitor.mp_write.connect(scoreboard.m_fifoh[0].analysis_export);	
	master_top.master_agent[0].monitor.mp_read.connect(scoreboard.m_fifoh[0].analysis_export);
		
	slave_top.slave_agent[0].monitor.sp_write.connect(scoreboard.s_fifoh[0].analysis_export);	
	slave_top.slave_agent[0].monitor.sp_read.connect(scoreboard.s_fifoh[0].analysis_export);	
	 
 endfunction

//*****************************************function end_of_elaboration phase*************************************/
function void axi_env::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(),"printing of topology from the environment class \n",UVM_LOW)
    uvm_top.print_topology;
endfunction
