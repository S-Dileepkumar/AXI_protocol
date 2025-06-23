interface axi_if(input bit clk);

// the axi protocol has 5 channels
// 3 for write channels
// 2 for read channels

// Write address channel
logic [3:0]AWID;
logic [31:0]AWADDR;
logic [3:0]AWLEN;
logic [2:0]AWSIZE;
logic [1:0]AWBURST;
logic AWVALID;
logic AWREADY;

// WRITE DATA CHANNEL
logic [31:0]WDATA;
logic [3:0]WID;
logic [3:0]WSTRB;
logic WLAST;
logic WVALID;
logic WREADY;

// RESPONSE CHANNEL
logic [3:0]BID; 
logic [1:0]BRESP;
logic BVALID;
logic BREADY;
// READ ADDRESS CHANNEL
logic [3:0]ARID;
logic [31:0]ARADDR;
logic [3:0]ARLEN;
logic [2:0]ARSIZE;
logic [1:0]ARBURST;
logic ARVALID;
logic ARREADY;

// READ DATA CHANNEL
logic [31:0]RDATA;
logic [3:0]RID;
logic [1:0]RRESP;
logic RLAST;
logic RVALID;
logic RREADY;


clocking m_drv_cb@(posedge clk);
		
	default input #1;// output #1;
	
	output  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID;
	input   AWREADY;

	
	output  WDATA, WID , WSTRB, WLAST, WVALID;
	input   WREADY;

	input  	BID, BRESP, BVALID;
	output  BREADY;

	output  ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID;
	input   ARREADY;
	
	output  RREADY;
	input 	RDATA, RID, RRESP, RLAST,RVALID;

endclocking

clocking m_mon_cb@(posedge clk);
		
	default input #1;// output #1;
	
	input   AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID;
	input   AWREADY;

	
	input   WDATA, WID , WSTRB, WLAST, WVALID;
	input   WREADY;

	input   BID, BRESP, BVALID;
	input   BREADY;

	input   ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID;
	input   ARREADY;
	
	input   RREADY;
	input 	RDATA, RID, RRESP, RLAST,RVALID;

endclocking

clocking s_drv_cb@(posedge clk);
		
	default input #1;// output #1;
	
	input   AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID;
	output  AWREADY;

	
	input   WDATA, WID , WSTRB, WLAST, WVALID;
	output  WREADY;

	output   BID, BRESP, BVALID;
	input  BREADY;

	input   ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID;
	output  ARREADY;
	
	input   RREADY;
	output 	RDATA, RID, RRESP, RLAST,RVALID;

endclocking

clocking s_mon_cb@(posedge clk);
		
	default input #1;// output #1;
	
	input  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID;
	input   AWREADY;

	
	input  WDATA, WID , WSTRB, WLAST, WVALID;
	input   WREADY;

	input  BID, BRESP, BVALID;
	input   BREADY;

	input  ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID;
	input   ARREADY;
	
	input  RREADY;
	input 	RDATA, RID, RRESP, RLAST,RVALID;

endclocking

modport M_DRV_MP(clocking m_drv_cb);
modport M_MON_MP(clocking m_mon_cb);
modport S_DRV_MP(clocking s_drv_cb);
modport S_MON_MP(clocking s_mon_cb);

		property AWVALID_;
      		@(posedge clk) $rose(AWVALID) |-> $stable(AWID) && $stable (AWLEN) && $stable (AWBURST) && $stable (AWSIZE) && (AWADDR) until AWREADY[->1];
      	endproperty
      
     	property VALID_;
     		@(posedge clk) $rose(WVALID) |-> $stable(WID) && $stable(WDATA) && $stable (WSTRB) && $stable(WLAST) until WREADY[->1];
     	endproperty
  
 
   	property ARVALID_;
   		@(posedge clk) $rose(ARVALID) |-> $stable(ARID) && $stable (ARLEN) && $stable (ARBURST) && $stable (ARSIZE) && (ARADDR) until ARREADY[->1];
   	endproperty


   	A_1: assert property (AWVALID_);
   	A_2: assert property (VALID_);
   	A_3: assert property (ARVALID_);

	c_1: cover property (AWVALID_);
   	c_2: cover property (VALID_);
   	c_3: cover property (ARVALID_);

 	property BVALID_;
    		@(posedge clk) $rose(BVALID) |-> $stable(BID) && $stable (BRESP) until BREADY[->1];
    endproperty
 
      
   	property RVALID_;
   		@(posedge clk) $rose(RVALID) |-> $stable(RID) && $stable (RDATA) && $stable (RLAST)  && (RRESP) until RREADY[->1];
   	endproperty

   	A_4: assert property (BVALID_);
   	A_5: assert property (RVALID_);

	c_4: cover property (BVALID_);
   	c_5: cover property (RVALID_);


   	property AWVALID_AWREADY;
   		@(posedge clk) AWVALID && !AWREADY |=> AWVALID;
   	endproperty 
   
   	property WVALID_WREADY;
   		@(posedge clk) WVALID && !WREADY |=> WVALID;
   	endproperty 
   
   	property ARVALID_ARREADY;
   		@(posedge clk) ARVALID && !ARREADY |=> ARVALID;
   	endproperty 


   	A_6: assert property (AWVALID_AWREADY);
   	A_7: assert property (WVALID_WREADY);
   	A_8: assert property (ARVALID_ARREADY);

	c_6: cover property (AWVALID_AWREADY);
   	c_7: cover property (WVALID_WREADY);
   	c_8: cover property (ARVALID_ARREADY);

   	property BVALID_BREADY;
   		@(posedge clk) BVALID && !BREADY |=> BVALID;
   	endproperty 


   	property RVALID_RREADY;
   		@(posedge clk) RVALID && !RREADY |=> RVALID;
   	endproperty 

   	A_9: assert property (BVALID_BREADY);
   	A_10: assert property (RVALID_RREADY);

	c_9: cover property (BVALID_BREADY);
   	c_10: cover property (RVALID_RREADY);
	
	//wrapping type unaligned address not happen
	property R_wrap_type;
		@(posedge clk) (ARBURST==2)|->(ARSIZE==1) |-> ARADDR%2==0;
	endproperty

	property R_wrap_type1;
 		@(posedge clk)  (ARBURST==2)|->(ARSIZE==2) |-> ARADDR%4==0;
	endproperty

	property W_wrap_type;
		@(posedge clk)  (AWBURST==2)|->(AWSIZE==1) |-> AWADDR%2==0;
	endproperty 

	property W_wrap_type1;
 		@(posedge clk) (AWBURST==2)|-> (AWSIZE==2) |-> AWADDR%4==0;
	endproperty

	A_11: assert property (R_wrap_type);
	A_12: assert property (R_wrap_type1);
	A_13: assert property (W_wrap_type);
	A_14: assert property (W_wrap_type1);

	c_11: cover property (R_wrap_type);
	c_12: cover property (R_wrap_type1);
	c_13: cover property (W_wrap_type);
	c_14: cover property (W_wrap_type1);

	property ar_size;
		@(posedge clk) AWVALID |-> (AWSIZE<3);
	endproperty

	property aw_size;
		@(posedge clk) ARVALID |-> (ARSIZE<3);
	endproperty

	A_15: assert property (ar_size);
	A_16: assert property (aw_size);

	c_15: cover property (ar_size);
	c_16: cover property (aw_size);


	property W_burst_type_wrap;
 		@(posedge clk) (AWBURST==2)|-> ((AWLEN==2)||(AWLEN==4)||(AWLEN==8)||(AWLEN==16));
	endproperty

	property R_burst_type_wrap;
		@(posedge clk) (ARBURST==2)|-> ((ARLEN==2)||(ARLEN==4)||(ARLEN==8)||(ARLEN==16));
	endproperty

	A_17: assert property (R_burst_type_wrap);
	A_18: assert property (W_burst_type_wrap);

	c_17: cover property (R_burst_type_wrap);
	c_18: cover property (W_burst_type_wrap);


	property WBURST_;
 		@(posedge clk) AWVALID |-> (AWBURST!==3);
	endproperty

	property RBURST_;
 		@(posedge clk) ARVALID |-> (ARBURST!==3);
	endproperty

	A_19: assert property (WBURST_);
	A_20: assert property (RBURST_);

	c_19: cover property (WBURST_);
	c_20: cover property (RBURST_);

	property WLAST_;
		@(posedge clk) WLAST |-> (WVALID)&&(!WREADY) |=> WVALID;
	endproperty

	property RLAST_;
		@(posedge clk) RLAST |-> (RVALID)&&(!RREADY) |=> RVALID;
	endproperty

	A_21: assert property (WLAST_);
	A_22: assert property (RLAST_);

	c_21: cover property (WLAST_);
	c_22: cover property (RLAST_);

endinterface
