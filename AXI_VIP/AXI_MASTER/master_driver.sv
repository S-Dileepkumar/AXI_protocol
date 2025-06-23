class master_driver extends uvm_driver#(axi_trans);

    `uvm_component_utils(master_driver)
    
    axi_master_config cfg;
    virtual axi_if.M_DRV_MP vif;


	int mem[int];

	axi_trans q1[$],q2[$],q3[$],q4[$],q5[$];
    	semaphore wac  = new(1);
	semaphore wdc  = new(1);
	semaphore wrc  = new(1);
	semaphore wadc = new();
	semaphore wdrc = new();
	semaphore rac  = new(1);
	semaphore rdc  = new(1);
	semaphore radc = new();

    extern function new(string name = "master_driver", uvm_component parent);

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    extern task to_ip(axi_trans xtn);
    extern task wac_to_slv(axi_trans xtn1);
    extern task wdc_to_slv(axi_trans xtn2);
    extern task wrc_to_slv(axi_trans xtn3);
    extern task rac_to_slv(axi_trans xtn4);
    extern task rdc_to_slv(axi_trans xtn5);

endclass

//*****************************************function new*************************************/
function master_driver::new(string name = "master_driver", uvm_component parent);
    super.new(name, parent);
endfunction

//*****************************************function build phase*************************************/
function void master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(axi_master_config)::get(this,"","axi_master_config",cfg))
    	`uvm_fatal(get_type_name(),"getting is not possible for axi_master_config in master_monitor")

endfunction

//*****************************************function connect phase*************************************/
function void master_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	
	vif = cfg.vif;
endfunction


//*****************************************run phase*************************************/

task master_driver::run_phase(uvm_phase phase);
	$display("inside the driver run phase");
	
	forever
		begin	
			seq_item_port.get_next_item(req);
			
			to_ip(req);

			seq_item_port.item_done();
		end

endtask


//***************************************** task to ip *************************************/

task master_driver::to_ip(axi_trans xtn);
	
	q1.push_back(xtn);
	q2.push_back(xtn);
	q3.push_back(xtn);
	q4.push_back(xtn);
	q5.push_back(xtn);
	
	fork
		begin:write_address
			wac.get(1);
			wac_to_slv(q1.pop_front());
			wac.put(1);
			wadc.put(1);
			
		end
		
		begin:write_data
			wadc.get(1);
			wdc.get(1);
			wdc_to_slv(q2.pop_front());
			wdc.put(1);
			wdrc.put(1);
		end
		
		begin:write_response
			wdrc.get(1);
			wrc.get(1);
			wrc_to_slv(q3.pop_front());
			wrc.put(1);	
		end
	
		begin:read_address
			rac.get(1);
			rac_to_slv(q4.pop_front());
			rac.put(1);
			radc.put(1);
		end
		
		begin: read_response
			radc.get(1);
			rdc.get(1);
			rdc_to_slv(q5.pop_front());
			rdc.put(1);
		
		end
	join_any

endtask




//***************************************** task write address channel*************************************/

task master_driver::wac_to_slv(axi_trans xtn1);
$display($time ," master driver write address channel");
xtn1.print();	

	@(vif.m_drv_cb);
	@(vif.m_drv_cb)
	begin
  		 
		vif.m_drv_cb.AWID 	<= xtn1.AWID;
		vif.m_drv_cb.AWADDR 	<= xtn1.AWADDR;
		vif.m_drv_cb.AWLEN 	<= xtn1.AWLEN;
		vif.m_drv_cb.AWSIZE 	<= xtn1.AWSIZE;
		vif.m_drv_cb.AWBURST 	<= xtn1.AWBURST;
		vif.m_drv_cb.AWVALID 	<= 1;
	end

	
	while(vif.m_drv_cb.AWREADY !== 1 )
		@(vif.m_drv_cb);
	
	vif.m_drv_cb.AWVALID <= 1'b0;

	repeat(2)
	@(vif.m_drv_cb);

endtask


//***************************************** task write data channel*************************************/


task master_driver::wdc_to_slv(axi_trans xtn2);

	//$display($time," master driver write data channel");
	@(vif.m_drv_cb);
	vif.m_drv_cb.WID <= xtn2.WID;

	foreach(xtn2.WDATA[i])
		begin
			vif.m_drv_cb.WDATA  <= xtn2.WDATA[i];
			vif.m_drv_cb.WSTRB  <= xtn2.WSTRB[i];
			vif.m_drv_cb.WVALID <= 1;	
			

			while(vif.m_drv_cb.WREADY !==1 )
				@(vif.m_drv_cb);
				
	
			if(i == xtn2.AWLEN)
				vif.m_drv_cb.WLAST <= 1;
						
			
			@(vif.m_drv_cb);
			vif.m_drv_cb.WVALID <= 0;
			
		end
	
		vif.m_drv_cb.WLAST <= 0;
	
	repeat(2)
		@(vif.m_drv_cb);

endtask



task master_driver::wrc_to_slv(axi_trans xtn3);
	
	vif.m_drv_cb.BREADY <= 1'b1;

	xtn3.BID =  vif.m_drv_cb.BID;	

	while(vif.m_drv_cb.BVALID !== 1 )
		@(vif.m_drv_cb);
		
	xtn3.BRESP =  vif.m_drv_cb.BRESP;
	
	vif.m_drv_cb.BREADY <= 1'b0;
	
	
	repeat(2)
		@(vif.m_drv_cb);
endtask


task master_driver::rac_to_slv(axi_trans xtn4);

	@(vif.m_drv_cb);
	@(vif.m_drv_cb)
	begin
  	
		vif.m_drv_cb.ARID 	<= xtn4.ARID;
		vif.m_drv_cb.ARADDR 	<= xtn4.ARADDR;
		vif.m_drv_cb.ARLEN 	<= xtn4.ARLEN;
		vif.m_drv_cb.ARSIZE 	<= xtn4.ARSIZE;
		vif.m_drv_cb.ARBURST 	<= xtn4.ARBURST;
		vif.m_drv_cb.ARVALID 	<= 1;
	end


	while(vif.m_drv_cb.ARREADY !== 1 )
		@(vif.m_drv_cb);
	
	vif.m_drv_cb.ARVALID <= 1'b0;

	repeat(2)
	@(vif.m_drv_cb);


endtask


task master_driver::rdc_to_slv(axi_trans xtn5);

while(vif.m_drv_cb.RVALID !== 1)
    	@(vif.m_drv_cb);	
   	

	xtn5.addr_cal();
	

	@(vif.m_drv_cb);
       		vif.m_drv_cb.RREADY <= 1;

	foreach(xtn5.raddress[i])
	begin	
		
	if(i == 0 )
		@(vif.m_drv_cb);
    	
		@(vif.m_drv_cb);	

		mem[xtn5.raddress[i]] = vif.m_drv_cb.RDATA;
		vif.m_drv_cb.RREADY <= 1;
	//	$display("raddrss %0d    i %0d    r_data  %0d",xtn5.raddress[i],i,vif.m_drv_cb.RDATA);
			
	end	

	

//	@(vif.m_drv_cb);
	vif.m_drv_cb.RREADY <= 0;

	

	repeat(2)
		@(vif.m_drv_cb);
endtask
