package axi_package;
    
    import uvm_pkg::*;
//include "uvm_macros.svh"
    `include "uvm_macros.svh"

//configuration files
    `include "axi_master_config.sv"
    `include "axi_slave_config.sv"
    `include "env_config.sv"

// master transaction file
    `include "axi_trans.sv"

//master agent files
    `include "master_driver.sv"
    `include "master_monitor.sv"
    `include "master_sequencer.sv"
    `include "master_sequence.sv"
    `include "axi_master_agent.sv"
    `include "axi_master_top.sv"

// slave transaction file
  //  `include "axi_slave_trans.sv"

//slave agent files
    `include "slave_driver.sv"
    `include "slave_monitor.sv"
    `include "slave_sequencer.sv"
    `include "axi_slave_agent.sv"
    `include "axi_slave_top.sv"

    
    `include "axi_scoreboard.sv"
    `include "axi_env.sv"
    `include "axi_test.sv"
    
endpackage
