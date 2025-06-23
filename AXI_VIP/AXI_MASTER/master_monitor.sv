class master_monitor extends uvm_monitor;
    `uvm_component_utils(master_monitor)
   
	uvm_analysis_port #(axi_trans) mp_write,mp_read;	
 
    axi_master_config cfg;
    virtual axi_if.M_MON_MP vif;

	int mem[int];

	axi_trans xtn,xtn1,xtn2,xtn3,xtn4;

	axi_trans q1[$],q2[$],q3[$],q4[$],q5[$];
    	semaphore wac  = new(1);
	semaphore wdc  = new(1);
	semaphore wrc  = new(1);
	semaphore wadc = new();
	semaphore wdrc = new();
	semaphore rac  = new(1);
	semaphore rdc  = new(1);
	semaphore radc = new();

    
    	extern function new(string name = "master_monitor", uvm_component parent);
    	extern function void build_phase(uvm_phase phase);
    	extern function void connect_phase(uvm_phase phase);
    	extern task run_phase(uvm_phase phase);
    	extern task collect_data();
	
    	extern task get_waddress();
    	extern task get_wdata(axi_trans xtn1);
    	extern task get_wresp(axi_trans xtn2);
   	extern task get_raddress();
    	extern task get_rdata(axi_trans xtn4);
	
endclass : master_monitor


//***************************Num**************function new*************************************/


function master_monitor::new(string name = "master_monitor", uvm_component parent);
    super.new(name, parent);
    mp_write =new("mp_write",this);
    mp_read =new("mp_read",this);

endfunction


//*****************************************function build phase*************************************/

function void master_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(axi_master_config)::get(this,"","axi_master_config",cfg))
    `uvm_fatal(get_type_name(),"getting is not possible for axi_master_config in master_monitor")
endfunction


//*****************************************function connect phase*************************************/

function void master_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	
	vif = cfg.vif;
endfunction

//*****************************************task run phase*************************************/

task master_monitor::run_phase(uvm_phase phase);

 forever
	begin
	collect_data();
	end
endtask


//*****************************************task run phase*************************************/

task master_monitor::collect_data();
	
	xtn = axi_trans::type_id::create("xtn");
	xtn3 = axi_trans::type_id::create("xtn3");
	fork
		begin:write_address
			wac.get(1);
			get_waddress();
			wac.put(1);
			wadc.put(1);
			
		end
		
		begin:write_data
			wadc.get(1);
			wdc.get(1);
			get_wdata(q1.pop_front());
			wdc.put(1);
			wdrc.put(1);
		end
		
		begin:write_response
			wdrc.get(1);
			wrc.get(1);
			get_wresp(q2.pop_front());
			wrc.put(1);	
		end
	
		begin:read_address
			rac.get(1);
			get_raddress();
			rac.put(1);
			radc.put(1);
		end
		
		begin: read_response
			radc.get(1);
			rdc.get(1);
			get_rdata(q3.pop_front());
			rdc.put(1);
		
		end
	join_any

endtask


task master_monitor::get_waddress();
		

  		while ( vif.m_mon_cb.AWREADY !== 1  || vif.m_mon_cb.AWVALID !== 1)
 		@(vif.m_mon_cb);
    		
		begin
			xtn.AWID 	= vif.m_mon_cb.AWID;
			xtn.AWADDR 	= vif.m_mon_cb.AWADDR;
			xtn.AWBURST 	= vif.m_mon_cb.AWBURST;
			xtn.AWSIZE 	= vif.m_mon_cb.AWSIZE;
			xtn.AWLEN 	= vif.m_mon_cb.AWLEN;
			xtn.AWVALID 	= vif.m_mon_cb.AWVALID;
			xtn.AWREADY 	= vif.m_mon_cb.AWREADY;
				
    		end
		q1.push_back(xtn);
		q2.push_back(xtn);
		
		@(vif.m_mon_cb);
		
endtask



task master_monitor::get_wdata(axi_trans xtn1);

	while(vif.m_mon_cb.WVALID !== 1 || vif.m_mon_cb.WREADY !==1)
    		@(vif.m_mon_cb);	
   	
	xtn1.WID 	= vif.m_mon_cb.WID;
	xtn1.WVALID 	= vif.m_mon_cb.WVALID;
	xtn1.WREADY 	= vif.m_mon_cb.WREADY;
	xtn1.WDATA 	= new[xtn1.AWLEN+1];
	xtn1.WSTRB 	= new[xtn1.AWLEN+1];
		
	foreach(xtn1.WDATA[i])
	begin

	
	while(vif.m_mon_cb.WVALID !== 1 || vif.m_mon_cb.WREADY !==1)
    		begin @(vif.m_mon_cb); end

	@(vif.m_mon_cb);
	xtn1.WSTRB[i] = vif.m_mon_cb.WSTRB;
	
//	if(i == 0 )
//		@(vif.m_mon_cb);
	
	case(vif.m_mon_cb.WSTRB)
			
			4'b0001 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[7:0];
			
			4'b0011 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[15:0];
			
			4'b0111 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[23:0];
			
			4'b1111 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[31:0];
			
			4'b0010 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[15:8];
			
			4'b0100 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[23:16];
			
			4'b1000 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[31:24];
			
			4'b1100 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[31:16];
			
			4'b0110 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[23:8];
			
			4'b1110 : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[31:8];

			default : xtn1.WDATA[i] = vif.m_mon_cb.WDATA[31:0];
		endcase
	
	end

endtask


task master_monitor::get_wresp(axi_trans xtn2);

	while(vif.m_mon_cb.BVALID !== 1 || vif.m_mon_cb.BREADY !==1)
	@(vif.m_mon_cb);
		
	@(vif.m_mon_cb);
	xtn2.BID 	=  vif.m_mon_cb.BID;
	xtn2.BRESP 	=  vif.m_mon_cb.BRESP;
	xtn2.BVALID 	=  vif.m_mon_cb.BVALID;
	xtn2.BREADY	=  vif.m_mon_cb.BREADY;
	
	@(vif.m_mon_cb);
	//$display("master  monitor");
	//xtn2.print();
	mp_write.write(xtn2);
	
endtask

task master_monitor::get_raddress();
	
	while(vif.m_mon_cb.ARVALID !== 1 || vif.m_mon_cb.ARREADY !== 1)
    		@(vif.m_mon_cb);
		
	begin
		xtn3.ARID 	= vif.m_mon_cb.ARID;
		xtn3.ARADDR 	= vif.m_mon_cb.ARADDR;
		xtn3.ARBURST 	= vif.m_mon_cb.ARBURST;
		xtn3.ARSIZE 	= vif.m_mon_cb.ARSIZE;
		xtn3.ARLEN 	= vif.m_mon_cb.ARLEN;
		xtn3.ARLEN 	= vif.m_mon_cb.ARLEN;
		
		xtn3.ARREADY 	= vif.m_mon_cb.ARREADY;
		xtn3.ARVALID 	= vif.m_mon_cb.ARVALID;
	end
	
	q3.push_back(xtn3);
	@(vif.m_mon_cb);


endtask

task master_monitor::get_rdata(axi_trans xtn4);

	while(vif.m_mon_cb.RVALID !== 1 || vif.m_mon_cb.RREADY !== 1)
		@(vif.m_mon_cb);
	
	xtn4.RID 	= vif.m_mon_cb.RID;
	xtn4.RDATA 	= new[xtn4.ARLEN+1];

	

	foreach(xtn4.RDATA[i])
	begin
		while(vif.m_mon_cb.RVALID !== 1 || vif.m_mon_cb.RREADY !== 1)
			@(vif.m_mon_cb);

		@(vif.m_mon_cb);
		xtn4.RDATA[i] = vif.m_mon_cb.RDATA;
		

	end	

	//$display("master read data chanel");
	//xtn4.print();
	mp_read.write(xtn4);
endtask
