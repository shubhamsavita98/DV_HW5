module my_mem_tb_hw3;
  
  //Logics to drive stimulus
    logic clk, write, read;
    logic [7:0] data_in;
    logic [15:0] address;
    //logic to capture response
    logic [8:0] data_out;
 
  parameter SIZE=6;

  //Initialize the memory model
  my_mem uut(.clk(clk),
       .write(write),
       .read(read),
       .data_in(data_in),
       .address(address),
       .data_out(data_out)
       );
  
  // Starting clock ~ every 5ns
  always #5 clk=~clk;
  //error count
  int error_count=0; 
  
  //Checker for error counter using task
  task err_checker;
    input write, read;
    if(write == 1 && read == 1) begin
       error_count = error_count + 1;
      $display("==== Error count by checker: %0d ====", error_count);
    end
     else
       $display("No error increment from checker.\n");
  endtask
  
  initial begin
    
      typedef struct {
        
        //16 bits of address
        bit [15:0] addr_to_read;
        //9 bits of data
        bit [8:0] data_to_write;
        //expected data read
        bit [8:0] expected_data_read;
        //actual data read
        bit [8:0] actual_data_read;
      
      }my_mem_struct;
  
   
    my_mem_struct memst[6];
    
    //intializing clk,read and write7
    clk=0; read=0; write=0;
    
    //randomize addresses
    for(int i=0; i<SIZE; i++) begin
      memst[i].addr_to_read = $random; //storing random address
      #1 $display("Address [%0d] = %0d",i, memst[i].addr_to_read);
    end
    
    //randomize data
    for(int j=0; j<SIZE; j++) begin
      memst[j].data_to_write = $random; //storing random data
      #1 $display("Data [%0d] = %0d",j, memst[j].data_to_write);
    end
    
    //set write to 1 to start writing to memory
    write=1;

    for (int i = 0; i < SIZE; i++)
    begin
      @(posedge clk);
      address = memst[i].addr_to_read;
      #10;
      data_in = memst[i].data_to_write;
      #5;
    end
    
    //check the memst before shuffle
    $display("Data before shuffle:\n", memst);
    memst.shuffle();
    //check the memst before shuffle
    $display("Data after shuffle:\n", memst);

    @(negedge clk);
    write = 0;
    
    //data expected
    for(int i=0; i < SIZE; i++) begin
      memst[i].expected_data_read = memst[i].data_to_write;
    end
    
    @(posedge clk)
    read = 1;

    //compare data out with data read expected
    $display("********* Starting Test*********");
    // data read in reverse order
    for(int i=SIZE-1; i>=0; i--) begin
      $display("Previous data out: %0d", data_out);
      #10;
      address = memst[i].addr_to_read;
      #10;
      $display("Address: %0d", address);
      $display("Data expected %0d", memst[i].expected_data_read);
      $display("Current data out %0d", data_out);
      memst[i].actual_data_read = data_out; //adding data to queue
      if(data_out !== memst[i].expected_data_read) begin
        $display("Error!!");
        error_count = error_count + 1;
        
        //test to test the checker
        err_checker(read, write);
      end
      else begin
        $display("\ndata out %0d is equal to data expected.", data_out); 
        $display("\n Read Success! \n");
        err_checker(read, write);
      end
    end

    $display("Total Error Count: %0d\n", error_count);
    $display("*************** End Test *************");
    
    $display("\n********* Traversing Queue *********");
    //traverse actual_data_read queue
    for(int i=0; i<SIZE; i++) begin
      //data_read_queue.push_back(data_out);
      $display("\tactual_data_read[%0d]= %0d",i,memst[i].actual_data_read);
    end
    
    //assinging read and write to 1 for checker task
    read =1; write =1;
    err_checker(read, write);
    
    $finish;
  end
    //vcd file generation and waveform enablement
    initial begin
      $vcdplusmemon;
      $vcdpluson;
      $dumpfile("dump.vcd");
      $dumpvars;
    end
    
    //end of module
    endmodule
