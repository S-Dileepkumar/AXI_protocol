class axi_master_agent extends uvm_agent;

    `uvm_component_utils(axi_master_agent)

    axi_master_config cfg;
    
    master_driver   driver;
    master_monitor  monitor;
    master_sequencer seqrh;

    extern function new(string name = "axi_master_agent", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass

//*****************************************function new*************************************/
function axi_master_agent::new(string name = "axi_master_agent", uvm_component parent);
    super.new(name, parent);
endfunction


//*****************************************function build phase*************************************/
function void axi_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(axi_master_config)::get(this,"","axi_master_config",cfg))
        `uvm_fatal(get_type_name(),"getting is not possible for axi_master_config in axi_master_agent")

  
    monitor = master_monitor::type_id::create("monitor",this);

    if(cfg.is_active == UVM_ACTIVE)
    begin
        driver  = master_driver::type_id::create("driver",this);
        seqrh     = master_sequencer::type_id::create("seqrh",this);
    end

    endfunction


//*****************************************function connect phase*************************************/
function void axi_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	driver.seq_item_port.connect(seqrh.seq_item_export);
endfunction
