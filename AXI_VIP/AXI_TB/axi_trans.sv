// this test  is done to prove the correctness of the transactions

class axi_trans extends uvm_sequence_item;

	`uvm_object_utils(axi_trans)
// ad the properties 
//
rand bit [3:0]AWID;
rand bit [31:0]AWADDR;
rand bit [3:0]AWLEN;
rand bit [2:0]AWSIZE;
rand bit [1:0]AWBURST;
 bit AWVALID;
 bit AWREADY;

// WRITE DATA CHANNEL
rand bit [31:0]WDATA[];
rand bit [3:0]WID;
rand bit [3:0]WSTRB[];
 bit WLAST;
 bit WVALID;
 bit WREADY;

// RESPONSE CHANNEL
rand bit [3:0]BID; 
 bit [1:0]BRESP;
 bit BVALID;
 bit BREADY;
// READ ADDRESS CHANNEL
rand bit [3:0]ARID;
rand bit [31:0]ARADDR;
rand bit [3:0]ARLEN;
rand bit [2:0]ARSIZE;
rand bit [1:0]ARBURST;
 bit ARVALID;
 bit ARREADY;

// READ DATA CHANNEL
rand bit [31:0]RDATA[];
rand bit [3:0]RID;
 bit [1:0]RRESP;
 bit RLAST;
 bit RVALID;
 bit RREADY;


constraint c1{ (AWID == WID) && (AWID == BID) ; }

constraint c2{ AWSIZE inside{0,1,2};}

constraint c3{ AWBURST != 3;}

constraint c4{ (WDATA.size == AWLEN+1); (WSTRB.size == AWLEN+1);}

constraint c5{ ARID == RID;}

constraint c6{ARSIZE inside{0,1,2};}

constraint c7{ARBURST != 3;}

constraint c8{ AWADDR inside{[0:4095]}; ARADDR inside{[0:4095]};}

constraint c9{if((AWBURST || ARBURST) == (0 || 2))
			{ AWADDR % (2**AWSIZE) == 0}; 
			{ ARADDR % (2**ARSIZE) == 0};
	      }

constraint c10{(AWBURST == 2) -> (AWLEN inside{2,4,8,16});}


int unsigned wstart_address, rstart_address;
int unsigned wnumber_bytes , rnumber_bytes;
int unsigned data_bus_bytes = 4; 
int unsigned waligned_address,raligned_address;
int unsigned wburst_length , rburst_length;
int unsigned waddress[] ,raddress[];
int unsigned w_wrap_boundary, r_wrap_boundary;
int unsigned wlower_byte_lane , wupper_byte_lane;
int unsigned wwaligned_address;
bit [3:0]array;
	
		extern function new(string name="axi_trans");
		extern function void do_print(uvm_printer printer);
		extern function void post_randomize();
		extern function void  addr_cal();
		extern function void  strobe_cal();

endclass


//-----------------------------------------------------------function new--------------------------------------------------------------
	function axi_trans::new(string name ="axi_trans");
		super.new(name);
	endfunction


 //-----------------------------------------------------------print method--------------------------------------------------------------

	function void axi_trans::do_print(uvm_printer printer);
	super.do_print(printer);

		printer.print_field("AWID",    this.AWID ,4,UVM_DEC);
		printer.print_field("AWADDR",  this.AWADDR,32,UVM_DEC);
		printer.print_field("AWLEN",   this.AWLEN,4,UVM_DEC);
		printer.print_field("AWSIZE",  this.AWSIZE,3,UVM_DEC);
		printer.print_field("AWBURST", this.AWBURST,2,UVM_DEC);
		printer.print_field("AWVALID", this.AWVALID,1,UVM_DEC);
		printer.print_field("AWREADY", this.AWREADY,1,UVM_DEC);
		printer.print_field("WID ",    this.WID,4,UVM_DEC);
		
		foreach(WDATA[i])
		printer.print_field($sformatf("WDATA[%0d]",i),   this.WDATA[i],32,UVM_BIN);
		
		foreach(WSTRB[i])
		printer.print_field($sformatf("WSTRB[%0d]",i),   this.WSTRB[i],4,UVM_BIN);
		
		printer.print_field("WLAST",   this.WLAST,1,UVM_DEC);
		printer.print_field("WVALID",  this.WVALID,1,UVM_DEC);
		printer.print_field("WREADY",  this.WREADY,1,UVM_DEC);
		printer.print_field("BID",     this.BID,4,UVM_DEC);
		printer.print_field("BRESP",   this.BRESP,2,UVM_DEC);
		printer.print_field("BVALID",  this.BVALID,1,UVM_DEC);
		printer.print_field("BREADY",  this.BREADY,1,UVM_DEC);
		

	printer.print_field("ARID",    this.ARID ,4,UVM_DEC);
		printer.print_field("ARADDR",  this.ARADDR,32,UVM_DEC);
		printer.print_field("ARLEN",   this.ARLEN,4,UVM_DEC);
		printer.print_field("ARSIZE",  this.ARSIZE,3,UVM_DEC);
		printer.print_field("ARBURST", this.ARBURST,2,UVM_DEC);
		printer.print_field("ARVALID", this.ARVALID,1,UVM_DEC);
		printer.print_field("ARREADY", this.ARREADY,1,UVM_DEC);
		printer.print_field("RID ",    this.RID,4,UVM_DEC);
		printer.print_field("RRESP ",    this.RRESP,2,UVM_DEC);
		
		
		foreach(RDATA[i])
		printer.print_field($sformatf("RDATA[%0d]",i),   this.RDATA[i],32,UVM_DEC);
		
		
		printer.print_field("RLAST",   this.RLAST,1,UVM_DEC);
		printer.print_field("RVALID",  this.RVALID,1,UVM_DEC);
		printer.print_field("RREADY",  this.RREADY,1,UVM_DEC);


	endfunction

//-----------------------------------------------------------post_randomize()--------------------------------------------------------------
	function void axi_trans::post_randomize();

/*	wstart_address = AWADDR;
	rstart_address = ARADDR;
	
	wnumber_bytes = 2**AWSIZE;
	rnumber_bytes = 2**ARSIZE;

	wburst_length = AWLEN+1;
	rburst_length = ARLEN+1;

	waddress = new[wburst_length];
	WSTRB    = new[wburst_length];
	raddress = new[rburst_length];
	

	waligned_address = int'(wstart_address / wnumber_bytes) * wnumber_bytes;
	raligned_address = int'(rstart_address / rnumber_bytes) * rnumber_bytes;
*/	
	
	addr_cal();
	strobe_cal();
endfunction



//-----------------------------------------------------------addr_calculation()--------------------------------------------------------------

	function void axi_trans::addr_cal();
		int j;
	//burst =0
	wstart_address = AWADDR;
	rstart_address = ARADDR;
	
	wnumber_bytes = 2**AWSIZE;
	rnumber_bytes = 2**ARSIZE;

	wburst_length = AWLEN+1;
	rburst_length = ARLEN+1;

	waddress = new[wburst_length];
//	WSTRB    = new[wburst_length];
	raddress = new[rburst_length];
	

	waligned_address = int'(wstart_address / wnumber_bytes) * wnumber_bytes;
	raligned_address = int'(rstart_address / rnumber_bytes) * rnumber_bytes;
	

//--------------------------
	if (AWBURST == 0)
		begin	
			//$display("aw burst");			
			for(int i =0;i<wburst_length;i++ )
				begin
				waddress[i] = wstart_address;
				end
		end

	if (ARBURST == 0)
		begin
			//$display("ar burst");			
			for(int i =0;i<rburst_length;i++ )
				begin
				raddress[i] = rstart_address;
				end
		end


	// burst  = 1
	if (AWBURST == 1)
	begin
			//$display("aw burst 1");			
			for(int i =0;i<wburst_length;i++ )
				begin
					if (i == 0) 
						waddress[i] = wstart_address;
					else
						waddress[i] = waligned_address + (i)*wnumber_bytes;
				end
	end

	if (ARBURST ==1 )
	begin	
			//$display("ar burst 1");			
			for(int i =0;i<rburst_length;i++ )
				begin
					if (i == 0) 
						raddress[i] = rstart_address;
					else
						raddress[i] = raligned_address + (i)*rnumber_bytes;
				
				end
	end

// burst  = 2
	
	if (AWBURST == 2)
		begin
		
		//$display("aw burst 2");			
		 wwaligned_address = waligned_address;	
		w_wrap_boundary = int'(wstart_address/(wnumber_bytes*wburst_length))*(wnumber_bytes*wburst_length);
		j=0;
	
		for(int i =0;i<wburst_length;i++ )
			begin
				
				if (i == 0)
					begin 
						waddress[i] = wstart_address;
						//$display("awburst 2 waddress[%0d] = %0d",i,waddress[i]);
					end
				else
					begin
						waddress[i] = wwaligned_address + (j)*wnumber_bytes;
						//$display("awburst 2 waddress[%0d] = %0d",i,waddress[i]);
					end		
						
				if(waddress[i] == (w_wrap_boundary+wnumber_bytes*wburst_length))
					begin
				      		waddress[i] = w_wrap_boundary;
				      		wwaligned_address = w_wrap_boundary;
					  	j = 1;
						////$display("awburst 2 waddress[%0d] = %0d",i,waddress[i]);
					end
				else
					begin
						j++;
					end
				
				
			end
			//foreach(waddress[i])
			//$display("xxx awburst 2 waddress[%0d] = %0d",i,waddress[i]);
		end

	
	if (ARBURST == 2)
		begin
	
		//$display("ar burst 2");			
		r_wrap_boundary = int'(rstart_address/(rnumber_bytes*rburst_length))*(rnumber_bytes*rburst_length);
		j = 0;	
		
		for(int i =0;i<rburst_length;i++ )
			begin
				if (i == 0) 
					raddress[i] = rstart_address;
				else
					raddress[i] = raligned_address + (j)*rnumber_bytes;
					
				if(raddress[i] == (r_wrap_boundary+rnumber_bytes*rburst_length))
					begin
						raddress[i] = r_wrap_boundary;
				      		raligned_address = r_wrap_boundary;
					  	j=1;
				      
				      	end
				else
					begin
						j++;
					end
					
			end
	end

endfunction


//-----------------------------------------------------------strobe_calculation-------------------------------------------------------------

function void axi_trans::strobe_cal();
		wstart_address = AWADDR;
	rstart_address = ARADDR;
	
	wnumber_bytes = 2**AWSIZE;
	rnumber_bytes = 2**ARSIZE;

	wburst_length = AWLEN+1;
	rburst_length = ARLEN+1;

	
	WSTRB    = new[wburst_length];
	

	waligned_address = int'(wstart_address / wnumber_bytes) * wnumber_bytes;
	raligned_address = int'(rstart_address / rnumber_bytes) * rnumber_bytes;
	

	//--------------------------------
	foreach(waddress[i])
	begin
		if(i == 0)
			begin
				wlower_byte_lane = waddress[i] - int'(waddress[i]/data_bus_bytes)*data_bus_bytes;
				wupper_byte_lane = waligned_address + (wnumber_bytes-1) - int'(waddress[i]/data_bus_bytes)*data_bus_bytes;
				
				for(int j = wlower_byte_lane;j<=wupper_byte_lane;j++)
					begin
						WSTRB[i][j] =1;
					end		
			end
		else
			begin
				wlower_byte_lane = waddress[i] - int'(waddress[i]/data_bus_bytes)*data_bus_bytes;
				wupper_byte_lane = wlower_byte_lane + wnumber_bytes -1;
				
				for(int j = wlower_byte_lane;j<=wupper_byte_lane;j++)
						WSTRB[i][j] =1;		
			end
	end

	//foreach(WSTRB[i]) $display("the strobe value inside trans %0b ",WSTRB[i]);
endfunction 


