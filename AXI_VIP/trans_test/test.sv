module top();

int array[1:100];

initial begin
	
	foreach(array[i])
		begin
		array[i] = i;
		$display("%0d",array[i]);
	
	end
	end
	while(array.size == 1)
	begin
		
	end
endmodule
