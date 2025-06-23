// this test  is done to prove the correctness of the transactions

class trans;

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
rand bit [31:0]RDATA;
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

constraint c8{ AWADDR inside{[0:4096]}; ARADDR inside{[0:4096]};}

constraint c9{if((AWBURST || ARBURST) == (0 || 2))
			{ AWADDR % (2**AWSIZE) == 0}; 
			{ ARADDR % (2**ARSIZE) == 0};
	      }

constraint c10{(AWBURST == 2) -> (AWLEN inside{2,4,8,16});}

constraint c11{BRESP == 0;RRESP ==0;}

int wstart_address, rstart_address;
int wnumber_bytes , rnumber_bytes;
int data_bus_bytes = 4; 
int waligned_address,raligned_address;
int wburst_length , rburst_length;
int waddress[] ,raddress[];
int w_wrap_boundary, r_wrap_boundary;
int rlower_byte_lane , rupper_byte_lane;
int wlower_byte_lane , wupper_byte_lane;

bit [3:0]array;

function void post_randomize();

	wstart_address = AWADDR;
	rstart_address = ARADDR;
	
	wnumber_bytes = 2**AWSIZE;
	rnumber_bytes = 2**ARSIZE;

	wburst_length = AWLEN+1;
	rburst_length = ARLEN+1;

	waddress = new[wburst_length];
	WSTRB    =new[wburst_length];
	raddress = new[rburst_length];
	
//	waddress.size = wburst_legnth;
//	raddress.size = rburst_legnth;

	waligned_address = int'(wstart_address / wnumber_bytes) * wnumber_bytes;
	raligned_address = int'(rstart_address / rnumber_bytes) * rnumber_bytes;
	
//	$display("postrandomize \n wstart_address : %0d \n wnumber_bytes : %0d \n wburst_len: %0d \n waligned address:= %0d\n",wstart_address,wnumber_bytes,wburst_length,waligned_address);
	
//	$display("rstart_address : %0d \n rnumber_bytes : %0d \n rburst_len: %0d \n raligned address:= %0d\n",rstart_address,rnumber_bytes,rburst_length,raligned_address);
	
	addr_cal();
	strobe_cal();
endfunction

function void addr_cal();
	int j;
//burst =0
if (AWBURST == 0)
		begin				
//			$display("------------------------ read address-----------------");
			for(int i =0;i<wburst_length;i++ )
			begin
				waddress[i] = wstart_address;
//				$display(" AWBURST = %0d,waddress[%0d] : =  :%0d \n",AWBURST,i, waddress[i]);
			end
		end

if (ARBURST == 0)
		begin
//			$display("------------------------ read address-----------------");
			for(int i =0;i<rburst_length;i++ )
			begin
				raddress[i] = rstart_address;
//				$display(" ARBURST = %0d,raddress[%0d] : =  :%0d \n",ARBURST,i, raddress[i]);
			end
		end


// burst  = 1
	if (AWBURST == 1)
			for(int i =0;i<wburst_length;i++ )
			begin
				if (i == 0) waddress[i] = wstart_address;
				else
					waddress[i] = waligned_address + (i)*wnumber_bytes;
//				$display(" AWBURST = %0d,waddress[%0d] : =  :%0d \n",AWBURST,i, waddress[i]);
			end

	if (ARBURST ==1 )	
			for(int i =0;i<rburst_length;i++ )
			begin
				if (i == 0) raddress[i] = rstart_address;
				else
					raddress[i] = raligned_address + (i)*rnumber_bytes;
				
//				$display(" ARBURST = %0d,raddress[%0d] : =  :%0d \n",ARBURST,i, raddress[i]);
			end

// burst  = 2
	
	if (AWBURST == 2)
	begin
	int wwaligned_address = waligned_address;	
	w_wrap_boundary = int'(wstart_address/(wnumber_bytes*wburst_length))*(wnumber_bytes*wburst_length);
//	$display("the w_wrap_boundary %0d",w_wrap_boundary);	
	j=0;
	for(int i =0;i<wburst_length;i++ )
			begin
				
				if (i == 0)
					begin 
						waddress[i] = wstart_address;
					end
				else
					begin
						waddress[i] = wwaligned_address + (j)*wnumber_bytes;
					end		
						
				if(waddress[i] == (w_wrap_boundary+wnumber_bytes*wburst_length))
					begin

//					  $display("the if condition waddress %0d",waddress[i]); 
				      waddress[i] = w_wrap_boundary;
				      wwaligned_address = w_wrap_boundary;
					  j = 1;
				      $display("macthced and new waligned address = %0d ",wwaligned_address);
					end
				else
					begin
					$display("not macthced");
					j++;
					end
				
//				$display(" AWBURST = %0d,waddress[%0d] : =  :%0d \n",AWBURST,i, waddress[i]);
				
			end
	end

	
	if (ARBURST == 2)
	begin
	
	r_wrap_boundary = int'(rstart_address/(rnumber_bytes*rburst_length))*(rnumber_bytes*rburst_length);
//	$display("the r_wrap_boundary %0d",r_wrap_boundary);
	j = 0;	
	for(int i =0;i<rburst_length;i++ )
			begin
				if (i == 0) 
					raddress[i] = rstart_address;
				else
						raddress[i] = raligned_address + (j)*rnumber_bytes;
					
				if(raddress[i] == (r_wrap_boundary+rnumber_bytes*rburst_length))
				      begin
//						 $display("the if condition raddress %0d",raddress[i]); 
				      raddress[i] = r_wrap_boundary;
				      raligned_address = r_wrap_boundary;
					  j=1;
				      $display("macthced and new raligned address = %0d ",raligned_address);
				      
				      end
				else
					begin
//					$display("not macthced");
					j++;
					end
					
//				$display(" ARBURST = %0d,raddress[%0d] : =  :%0d \n",ARBURST,i, raddress[i]);
			end
	end

endfunction

function void strobe_cal();
	
	
	foreach(waddress[i])
	begin
	//	WSTRB[i] =0;
		if(i == 0)
			begin
			wlower_byte_lane = waddress[i] - int'(waddress[i]/data_bus_bytes)*data_bus_bytes;
			wupper_byte_lane = waligned_address + (wnumber_bytes-1) - int'(waddress[i]/data_bus_bytes)*data_bus_bytes;
	//		$display("align %0d\n,wnumber %0d\n, lss%0d",waligned_address,wnumber_bytes,int'(waddress[i]/data_bus_bytes)*data_bus_bytes);
				for(int j = wlower_byte_lane;j<=wupper_byte_lane;j++)
						begin
						WSTRB[i][j] =1;
						//$display("WSTRB[%0d][%0d]",WSTRB[i][j]);
						end		
			end
		else
			begin
			wlower_byte_lane = waddress[i] - int'(waddress[i]/data_bus_bytes)*data_bus_bytes;
			wupper_byte_lane = wlower_byte_lane + wnumber_bytes -1;
				for(int j = wlower_byte_lane;j<=wupper_byte_lane;j++)
						WSTRB[i][j] =1;		
			end
//		$display("upper_lane %0d\n lower_lane %0d\n strobe signal %b\n",wupper_byte_lane,wlower_byte_lane,WSTRB[i]);
	end
endfunction 



endclass



module top();

trans th;

initial 
	begin

	`ifdef VCS
	$fsdbDumpvars(0,top);
	`endif
	th = new();
	$display("displaying the assert randomize");
	repeat(3) begin
	assert(th.randomize with{AWBURST == 2;});
	$display("address = %0d		%p \n",th,th);
	$display("end of display");
	end
	end



endmodule
