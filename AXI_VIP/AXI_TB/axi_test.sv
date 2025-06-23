class axi_test extends uvm_test;

  `uvm_component_utils(axi_test)

    int no_of_masters       =1;
    int no_of_slaves        =1;
    int no_of_score_board   =1;
    
    axi_env     envh;
    env_config  cfg;
    
    
    axi_master_config master_cfg[];
    axi_slave_config  slave_cfg[];

  extern function new(string name = "axi_test", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
endclass

//*****************************************function new*************************************/
function axi_test::new(string name = "axi_test", uvm_component parent);
  super.new(name, parent);
endfunction
//*****************************************function build phase*************************************/

function void axi_test::build_phase(uvm_phase phase);
  super.build_phase(phase);

    master_cfg = new[this.no_of_masters];
    slave_cfg  = new[this.no_of_slaves];

    cfg = env_config::type_id::create("cfg");

    cfg.master_cfg = new[this.no_of_masters];
    cfg.slave_cfg  = new[this.no_of_slaves];

    foreach(master_cfg[i])
    begin
        master_cfg[i] = axi_master_config::type_id::create($sformatf("master_cfg[%0d]",i));

        master_cfg[i].is_active = UVM_ACTIVE;

        if(!uvm_config_db #(virtual axi_if)::get(this, "", "vif", master_cfg[i].vif)) 
            `uvm_fatal(get_type_name(), "VIF not found in uvm_config_db")

        cfg.master_cfg[i] = master_cfg[i];
    end

    foreach(slave_cfg[i])
    begin
        slave_cfg[i] = axi_slave_config::type_id::create($sformatf("slave_cfg[%0d]",i));

        slave_cfg[i].is_active = UVM_ACTIVE;

        if(!uvm_config_db #(virtual axi_if)::get(this, "", "vif", slave_cfg[i].vif)) 
            `uvm_fatal(get_type_name(), "VIF not found in uvm_config_db")

        cfg.slave_cfg[i] = slave_cfg[i];
    end

        cfg.no_of_masters       = this.no_of_masters;
        cfg.no_of_slaves        = this.no_of_slaves;
        cfg.no_of_score_board   = this.no_of_score_board;

        uvm_config_db #(env_config)::set(this, "*", "env_config", cfg);

        envh = axi_env::type_id::create("envh", this);

endfunction

//--------------------------------------------------test1---------------------------------------

class test1 extends axi_test;

	`uvm_component_utils(test1)
	m_subseq_0 ms_0;
  m_subseq_1 ms_1;
  m_subseq_2 ms_2;
	
	extern function new(string name = "test1", uvm_component parent);
	extern task 	      run_phase(uvm_phase phase);
	extern function  void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
	
endclass

	function test1::new(string name = "test1", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void test1::build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

  function void test1::start_of_simulation_phase(uvm_phase phase);
    envh.master_top.master_agent[0].seqrh.set_arbitration(SEQ_ARB_STRICT_FIFO);
  endfunction

	task test1::run_phase(uvm_phase phase);
		ms_0 = m_subseq_0::type_id::create("ms_0");
    ms_1 = m_subseq_1::type_id::create("ms_1");
    ms_2 = m_subseq_2::type_id::create("ms_2");
		phase.raise_objection(this);
		repeat(1)
      fork
			  ms_0.start(envh.master_top.master_agent[0].seqrh);
        ms_1.start(envh.master_top.master_agent[0].seqrh);
        ms_2.start(envh.master_top.master_agent[0].seqrh);
      join
		#6000;
		phase.drop_objection(this);
	endtask
	
