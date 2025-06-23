class slave_driver extends uvm_driver#(axi_trans);

    `uvm_component_utils(slave_driver)
    
    axi_slave_config cfg;
    virtual axi_if.S_DRV_MP vif;

     int array[int];
	 	 
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
    

    extern function new(string name = "slave_driver", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
    extern task to_ip();
    extern task wac_to_mst();
    extern task wdc_to_mst(axi_trans xtn1);
    extern task wrc_to_mst(axi_trans xtn2);
    extern task rac_to_mst();
    extern task rdc_to_mst(axi_trans xtn4);


endclass

//*****************************************function new*************************************/



function slave_driver::new(string name = "slave_driver", uvm_component parent);
    super.new(name, parent);
endfunction


//*****************************************function build phase*************************************/


function void slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
	if(!uvm_config_db #(axi_slave_config)::get(this,"","axi_slave_config",cfg))
        	`uvm_fatal(get_type_name(),"getting is not possible for axi_slave_config in slave_monitor")
endfunction

//*****************************************function connect phase*************************************/


function void slave_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = cfg.vif;
endfunction


//*****************************************task run phase*************************************/


task slave_driver::run_phase(uvm_phase phase);
            forever 
                begin
                    $display("inside the slave driver run phase");
                    to_ip();
                    
                end
endtask



//*****************************************task to_ip*************************************/



task slave_driver::to_ip();

	
	fork
		begin
			wac.get(1);
			wac_to_mst();
			wac.put(1);
			wadc.put(1);
			
		end
		
		begin
			wadc.get(1);
			wdc.get(1);
			wdc_to_mst(q1.pop_front());
			wdc.put(1);
			wdrc.put(1);
		end
		
		begin
			wdrc.get(1);
			wrc.get(1);
			wrc_to_mst(q2.pop_front());
			wrc.put(1);	
		end
	
		begin
			rac.get(1);
			rac_to_mst();
			rac.put(1);
			radc.put(1);
		end
		
		begin
			radc.get(1);
			rdc.get(1);
			rdc_to_mst(q3.pop_front());
			rdc.put(1);
		
		end

	join_any

endtask


//---------------------------------------task to_master -------------------------------------/


task slave_driver::wac_to_mst();

       xtn = axi_trans::type_id::create("xtn");
    
	while(vif.s_drv_cb.AWVALID !== 1)
    	@(vif.s_drv_cb);
	
 
  		vif.s_drv_cb.AWREADY <= 1;
		
  		//while (vif.s_drv_cb.AWVALID !== 1)
 		//@(vif.s_drv_cb);
    		
		begin
			xtn.AWID 	= vif.s_drv_cb.AWID;
			xtn.AWADDR 	= vif.s_drv_cb.AWADDR;
			xtn.AWBURST 	= vif.s_drv_cb.AWBURST;
			xtn.AWSIZE 	= vif.s_drv_cb.AWSIZE;
			xtn.AWLEN 	= vif.s_drv_cb.AWLEN;
				
    		end
	
		@(vif.s_drv_cb)
			vif.s_drv_cb.AWREADY  <= 0;
  		
	q1.push_back(xtn);
	q2.push_back(xtn);
	
		repeat(2)
			@(vif.s_drv_cb);
		

	
	

endtask


task slave_driver::wdc_to_mst(axi_trans xtn1);

	//$display($time," slave driver write data chaneel");
   while(vif.s_drv_cb.WVALID !== 1)
    		@(vif.s_drv_cb);	
   	

	xtn1.addr_cal();
	xtn1.strobe_cal();


	foreach(xtn1.waddress[i])
	begin
//	$display("%0d size ",xtn1.waddress.size);	
	 while(vif.s_drv_cb.WVALID !== 1)
    		@(vif.s_drv_cb);	
       	
	vif.s_drv_cb.WREADY <= 1;
	xtn1.WID = vif.s_drv_cb.WID;
//	$display($time ," slave driver wready is set to 1");
	
	
	if(i == 0 )
		@(vif.s_drv_cb);
		
		@(vif.s_drv_cb);

	case(vif.s_drv_cb.WSTRB)
			
			4'b0001 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[7:0];
			
			4'b0011 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[15:0];
			
			4'b0111 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[23:0];
			
			4'b1111 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[31:0];
			
			4'b0010 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[15:8];
			
			4'b0100 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[23:16];
			
			4'b1000 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[31:24];
			
			4'b1100 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[31:16];
			
			4'b0110 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[23:8];
			
			4'b1110 : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[31:8];

			default : array[xtn1.waddress[i]] = vif.s_drv_cb.WDATA[31:0];
		endcase;
	
		//$display($time ," slave driver  i %0d strobe %0d \t %b",i,vif.s_drv_cb.WSTRB,vif.s_drv_cb.WSTRB);	
	end
	
//##	@(vif.s_drv_cb);
	vif.s_drv_cb.WREADY <= 0;

		
	//foreach(xtn1.WSTRB[i]) $display("slave driver wstrobe %0d   %b ",xtn1.WSTRB[i],xtn1.WSTRB[i]);
		
		repeat(2)
			@(vif.s_drv_cb);
endtask


task slave_driver::wrc_to_mst(axi_trans xtn2);

	while(vif.s_drv_cb.BREADY !==1 )
	@(vif.s_drv_cb);

	vif.s_drv_cb.BID    <= xtn2.AWID;
       	vif.s_drv_cb.BRESP  <= 0;
       	vif.s_drv_cb.BVALID <= 1;
		
	@(vif.s_drv_cb);
       	
       	vif.s_drv_cb.BRESP  <= 2'bx;
	vif.s_drv_cb.BVALID  <= 0;
	
//	$display("the array[i] collected in the slave drive ");
//	foreach(array[i]) $display("slave driver array[%0d] %b",i,array[i]);
		repeat(2)
			@(vif.s_drv_cb);

endtask


task slave_driver::rac_to_mst();

 xtn3 = axi_trans::type_id::create("xtn3");
    
	while(vif.s_drv_cb.ARVALID !== 1)
    	@(vif.s_drv_cb);
	
 
  		vif.s_drv_cb.ARREADY <= 1;
		
  	//	while ( vif.s_drv_cb.ARREADY !== 1  && vif.s_drv_cb.ARVALID !== 1)
 	//	@(vif.s_drv_cb);
    		
		begin
			xtn3.ARID 	= vif.s_drv_cb.ARID;
			xtn3.ARADDR 	= vif.s_drv_cb.ARADDR;
			xtn3.ARBURST 	= vif.s_drv_cb.ARBURST;
			xtn3.ARSIZE 	= vif.s_drv_cb.ARSIZE;
			xtn3.ARLEN 	= vif.s_drv_cb.ARLEN;
				
    	
		end
	
	
	
		@(vif.s_drv_cb)
			vif.s_drv_cb.ARREADY  <= 0;
  		
	q3.push_back(xtn3);
	
		repeat(2)
			@(vif.s_drv_cb);
		
	
	


endtask

task slave_driver::rdc_to_mst(axi_trans xtn4);
	
	xtn4.RID = xtn4.ARID;
	@(vif.s_drv_cb);
	vif.s_drv_cb.RID <= xtn4.RID;

//	$display("this is xtn4");	
//	xtn4.print();

	for(int i =0; i<xtn4.ARLEN+1; i++)
	begin
		begin
			vif.s_drv_cb.RDATA  <= $random;
			vif.s_drv_cb.RVALID <= 1;
			vif.s_drv_cb.RRESP  <= 0;
		//	$display("                                 enter the slave rdata i %0d  == %0d ",i,vif.s_drv_cb.RDATA);
			while(vif.s_drv_cb.RREADY !==1 )
				@(vif.s_drv_cb);
	
			if(i == xtn4.ARLEN)
				vif.s_drv_cb.RLAST <= 1;
			
		end
			@(vif.s_drv_cb);		
	end


	vif.s_drv_cb.RVALID <= 0;
	vif.s_drv_cb.RLAST  <= 0;
	vif.s_drv_cb.RRESP  <= 'bx;
	
	repeat(2)
		@(vif.s_drv_cb);


endtask
