class master_sequence extends uvm_sequence#(axi_trans);
	`uvm_object_utils(master_sequence);
	
	extern function new(string name = "master_sequence");
endclass

	function master_sequence::new(string name = "master_sequence");
		super.new(name);
	endfunction
	
//------------------------------------------------------

class m_subseq_0 extends master_sequence;
	`uvm_object_utils(m_subseq_0);
	
	extern function new(string name = "m_subseq_0");
	extern task body();
endclass

	function m_subseq_0::new(string name = "m_subseq_0");
		super.new(name);
	endfunction

	task m_subseq_0::body();
		repeat(30)
		begin
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {AWBURST == 0; ARBURST == 0;});
		finish_item(req);
		end
	endtask

//----------------------------------------------------------------------


class m_subseq_1 extends master_sequence;
	`uvm_object_utils(m_subseq_1);
	
	extern function new(string name = "m_subseq_1");
	extern task body();
endclass

	function m_subseq_1::new(string name = "m_subseq_1");
		super.new(name);
	endfunction

	task m_subseq_1::body();
		repeat(30)
		begin
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {AWBURST == 1; ARBURST == 1;});
		finish_item(req);
		end
	endtask

//----------------------------------------------------------------------


class m_subseq_2 extends master_sequence;
	`uvm_object_utils(m_subseq_2);
	
	extern function new(string name = "m_subseq_2");
	extern task body();
endclass

	function m_subseq_2::new(string name = "m_subseq_2");
		super.new(name);
	endfunction

	task m_subseq_2::body();
		repeat(30)
		begin
		req = axi_trans::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {AWBURST == 2; ARBURST == 2;});
		finish_item(req);
		end
	endtask

//----------------------------------------------------------------------