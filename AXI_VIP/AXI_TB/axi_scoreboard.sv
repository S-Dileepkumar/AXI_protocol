class axi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axi_scoreboard)

	  env_config cfg;

	axi_trans xtn1,xtn2;
	
	static int read_compared , write_compared, read_receive, write_receive, read_compare_failed, write_compare_failed ;

	uvm_tlm_analysis_fifo #(axi_trans) m_fifoh[];
	uvm_tlm_analysis_fifo #(axi_trans)  s_fifoh[];


	covergroup write_address_cg; 
		option.per_instance = 1;

		awaddr 	: coverpoint xtn1.AWADDR  {bins awaddr_bin   = {[0:32'hffff_ffff]};}
		awsize 	: coverpoint xtn1.AWSIZE  {bins awsize_bin[] = {[0:2]};}
		awburst : coverpoint xtn1.AWBURST {bins awburst_bin[]= {[0:2]};}
		awlen 	: coverpoint xtn1.AWLEN   {bins awlen        = {[0:15]};}
		bresp 	: coverpoint xtn1.BRESP   {bins bresp_bin    = {0};}

		WRITE_ADDR_CROSS : cross awburst,awlen,awsize;
	endgroup
	
	covergroup write_data_cg with function sample(int i);
	option.per_instance = 1;
	
		wdata  :   coverpoint xtn1.WDATA[i]{bins wdata_bin={[0:32'hffff_ffff]};}

		wstrb  :   coverpoint xtn1.WSTRB[i]{
						      bins wstrobe_bin0={4'b1111};
                                                      bins wstrobe_bin1={4'b1100};
                                                      bins wstrobe_bin2={4'b0011};
                                                      bins wstrobe_bin3={4'b1000};
                                                      bins wstrobe_bin4={4'b0100};
                                                      bins wstrobe_bin5={4'b0010};
                                                      bins wstrobe_bin6={4'b0001};
                                                      bins wstrobe_bin7={4'b1110};
                                                                }
                WRITE_DATA_CROSS: cross wdata,wstrb;

		
	endgroup
	
	covergroup read_address_cg;
	option.per_instance=1;

		araddr :   coverpoint xtn1.ARADDR {bins araddr_bin={[0:'hffff_ffff]};}
		arburst:   coverpoint xtn1.ARBURST {bins arburst_bin[]={[0:2]};}
		arsize :   coverpoint xtn1.ARSIZE  {bins arsize_bin[]={[0:2]};}
		arlen  :   coverpoint xtn1.ARLEN   {bins arlen_bin={[0:15]};}
	
                READ_ADDR: cross arburst,arsize,arlen;
         endgroup
		
	covergroup read_data_cg with function sample(int i);
	option.per_instance=1;
	
		rdata  :   coverpoint xtn1.RDATA[i]{bins rdata_bin={[0:'hffff_ffff]};}
		rresp  :   coverpoint xtn1.RRESP[i]{bins rresp_bin={0};}
	
         endgroup
		

	

    
    extern function new(string name = "axi_scoreboard", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
endclass

// //*****************************************function new*************************************/
function axi_scoreboard::new(string name = "axi_scoreboard", uvm_component parent);
    
	super.new(name, parent);
	
	write_address_cg = new();
	write_data_cg    = new();
	read_address_cg  = new();
	read_data_cg     = new();
    
endfunction

// //*****************************************function build_phase*************************************/
function void axi_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(env_config)::get(this,"", "env_config", cfg))
        `uvm_fatal(get_type_name(), "cfg not found in uvm_config_db")

	m_fifoh = new[cfg.no_of_masters];
	s_fifoh = new[cfg.no_of_slaves];

	foreach(m_fifoh[i]) 
    		m_fifoh[i] = new($sformatf("m_fifoh[%0d]",i),this);
	
	foreach(s_fifoh[i]) 
    		s_fifoh[i] = new($sformatf("s_fifoh[%0d]",i),this);

	
endfunction



task axi_scoreboard::run_phase(uvm_phase phase);
	
	forever
	begin
		fork 
		m_fifoh[0].get(xtn1);
		s_fifoh[0].get(xtn2);

		join
	
		xtn1.print();
		xtn2.print();
	
		if(xtn1.AWADDR || xtn2.AWADDR) write_receive++;
				
		if(xtn1.ARADDR || xtn2.ARADDR) read_receive++;
		
		
		if(xtn1.compare(xtn2))
			begin
				if(xtn1.AWADDR && xtn2.AWADDR) 	
					write_compared++; 
				
				if(xtn1.ARADDR && xtn2.ARADDR) 
					read_compared++;

				write_address_cg.sample();
					read_address_cg.sample();
				//	if(xtn1.WVALID)
						begin
					            foreach(xtn1.WDATA[i])
                                                               begin
						             	write_data_cg.sample(i);
                                                               end
						end
				//	if(xtn2.RVALID)
						begin
						    foreach(xtn1.RDATA[i])
                                                              begin
						           	read_data_cg.sample(i);
                                                              end
						end

			end
		else
		  `uvm_error("Scoreboard","Master and Slave Packet Mismatch");	
		
	$display("write received %0d \n read received %0d \n\n write compared %0d \n read compared %0d \n",write_receive,read_receive,write_compared,read_compared);
	end

endtask


function void axi_scoreboard::report_phase(uvm_phase phase);

	`uvm_info(get_type_name(),$sformatf("write received %0d",write_receive),UVM_NONE);
	`uvm_info(get_type_name(),$sformatf("read received  %0d",read_receive),UVM_NONE);
	`uvm_info(get_type_name(),$sformatf("write compared %0d",write_compared),UVM_NONE);
	`uvm_info(get_type_name(),$sformatf("read compared  %0d",read_compared),UVM_NONE);
	//`uvm_info(get_type_name(),$sformatf("write not_compared  %0d",write_compare_failed),UVM_NONE);
	//`uvm_info(get_type_name(),$sformatf("read  not_compared  %0d",read_compare_failed),UVM_NONE);

endfunction
