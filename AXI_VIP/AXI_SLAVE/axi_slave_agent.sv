class axi_slave_agent extends uvm_agent;

    `uvm_component_utils(axi_slave_agent)

    axi_slave_config cfg;
    
    slave_driver   driver;
    slave_monitor  monitor;
    slave_sequencer seqrh;

    extern function new(string name = "axi_slave_agent", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass : axi_slave_agent

//*****************************************function new*************************************/
function axi_slave_agent::new(string name = "axi_slave_agent", uvm_component parent);
    super.new(name, parent);
endfunction


//*****************************************function build phase*************************************/
function void axi_slave_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(axi_slave_config)::get(this,"","axi_slave_config",cfg))
        `uvm_fatal(get_type_name(),"getting is not possible for axi_slave_config in axi_slave_agent")

  
    monitor = slave_monitor::type_id::create("monitor",this);

    if(cfg.is_active == UVM_ACTIVE)
    begin
        driver  = slave_driver::type_id::create("driver",this);
        seqrh     = slave_sequencer::type_id::create("seqrh",this);
    end

    endfunction



//*****************************************function connect phase*************************************/
function void axi_slave_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	driver.seq_item_port.connect(seqrh.seq_item_export);
endfunction
