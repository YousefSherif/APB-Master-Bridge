////////////////////////////////////////////////////////////////////////////////// 
// Create Date:  02/09/2022 05:17:28 PM
// Design Name:  APB_Master_Bridge_testbench
// Module Name:  APB_Master_Bridge_TB
// Project Name: AMBA BUS Assignment
// 
// Description:  Test cases of the APB Master including read and write transfers 
//               with wait states and without wait states, each case is teseted 
//               when transfer still high after transfer happens and when transfer
//               becomes low after a certain transfer
// 
// Team Members: 1- Mohamed Hosam Elden Abd Alhakim Abd Alhady
//               2- Fatma Ali Gamal Eldin Mohammed
//               3- Fatma Hazem Abdel Salam Mohamed
//               4- Tasneem Abo El-Esaad Abd El-Razik Abo El-Esaad 
//               5- Hadeer Muhammed Ali Abdo Saleh
//               6- Yousef Sherif Abdel Fadil
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
 
module APB_MASTER_TB ();

///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////Parameters and input/output signals///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
parameter DATA_WIDTH_TB = 'd32,  ADDRESS_WIDTH_TB = 'd32, STRB_WIDTH_TB = 'd4, SLAVES_NUM_TB = 'd8;

  reg                          PCLK_TB      ;      
  reg                          PRESETn_TB   ;    
  reg  [ADDRESS_WIDTH_TB-1:0]  IN_ADDR_TB   ;    
  reg  [DATA_WIDTH_TB-1:0]     IN_DATA_TB   ;    
  reg  [DATA_WIDTH_TB-1:0]     PRDATA_TB    ;     
  reg  [2:0]                   IN_PROT_TB   ;    
  reg                          IN_WRITE_TB  ;   
  reg  [STRB_WIDTH_TB-1:0]     IN_STRB_TB   ;    
  reg                          Transfer_TB  ;   
  reg                          PREADY_TB    ;     
  reg                          PSLVERR_TB   ;    
                             
 wire                          OUT_SLVERR_TB;  
 wire   [DATA_WIDTH_TB-1:0]    OUT_RDATA_TB ;  
 wire   [ADDRESS_WIDTH_TB-1:0] PADDR_TB     ;      
 wire   [DATA_WIDTH_TB-1:0]    PWDATA_TB    ;     
 wire                          PWRITE_TB    ;     
 wire                          PENABLE_TB   ;    
 wire   [2:0]                  PPROT_TB     ;      
 wire   [STRB_WIDTH_TB-1:0]    PSTRB_TB     ;      
 wire   [SLAVES_NUM_TB-1:0]    PSEL_TB      ;  

 
///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////Initial Block///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
initial
begin
	init();
	
	rst();
	
    $display("===================== Test write opteration with no waits=====================");
    write_no_wait('b01000000,'b00100000);
  
    $display("===================== Test write opteration with waits=====================");
    write_with_wait('b01000000,'b00100000);
  
  	$display("===================== Test read opteration with no waits=====================");
    read_no_wait('b01000000,'b00100000);
  
    $display("===================== Test read opteration with waits=====================");
    read_with_wait('b01000000,'b00100000);
	
  #20

$finish;
end

///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////Clock_Generator//////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
 always #5 PCLK_TB = ~ PCLK_TB;
 
 
 ///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////DUT instantiation/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
 APB_MASTER #(.DATA_WIDTH(DATA_WIDTH_TB),  .ADDRESS_WIDTH(ADDRESS_WIDTH_TB), .STRB_WIDTH(STRB_WIDTH_TB), .SLAVES_NUM(SLAVES_NUM_TB))
 DUT (
 .PCLK(PCLK_TB),
 .PRESETn(PRESETn_TB),
 .IN_ADDR(IN_ADDR_TB),
 .IN_DATA(IN_DATA_TB),
 .PRDATA(PRDATA_TB),
 .IN_WRITE(IN_WRITE_TB),
 .Transfer(Transfer_TB),
 .PREADY(PREADY_TB),
 .PSLVERR(PSLVERR_TB),
 .IN_PROT(IN_PROT_TB),
 .IN_STRB(IN_STRB_TB),
 
 .PPROT(PPROT_TB),
 .PSTRB(PSTRB_TB),
 .OUT_SLVERR(OUT_SLVERR_TB),
 .OUT_RDATA(OUT_RDATA_TB),
 .PADDR(PADDR_TB),
 .PWDATA(PWDATA_TB),
 .PWRITE(PWRITE_TB),
 .PENABLE(PENABLE_TB),
 .PSEL(PSEL_TB)
 );


task init();
 begin
	# 10
	PCLK_TB = 'b0;
	PRESETn_TB = 'b1;
	PSLVERR_TB = 'b0;
	Transfer_TB = 'b0;
	PREADY_TB = 'b0;
	IN_ADDR_TB = 'd58;
	IN_DATA_TB = 'd0;
	IN_PROT_TB = 3'b0;
	IN_STRB_TB = 'b0101;
	IN_WRITE_TB = 'b0;
	PRDATA_TB = 'b0;
	end 
endtask

task rst();
 begin
	PRESETn_TB = 'b1;	
	#10 	
	PRESETn_TB = 'b0;	
	#10 	
	PRESETn_TB = 'b1;	
	end 
endtask

///////////////////////////////////////////////////////////////////////////////////
///////////////////////Write operation with no waits///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
task write_no_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,
	 input reg  [SLAVES_NUM_TB-1:0]  SLAVE2
); 
begin
    #10
  Transfer_TB = 'b1;
	IN_ADDR_TB = 'hBAB84CD3;              //address = 1011_1010_1011_1000_0100_1100_1101_0011;
	IN_DATA_TB = 'd98;
	IN_WRITE_TB = 'b1;
	PREADY_TB = 'b0;
    #15
    $display("************First write operation test************");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("First Setup process done successfully");	
	else
       $display("First Setup process has an error");	
	#5
	
	PREADY_TB = 'b1;
	#10
	//Put the second transfer data
	IN_ADDR_TB = 'hB6B84CD3;           //address = 1011_0110_1011_1000_0100_1100_1101_0011;
	IN_DATA_TB = 'd90;
	PREADY_TB = 'b0;
	
	#5
    if (PENABLE_TB == 1'b0)
       $display("First write operation done successfully");	
	else
       $display("First write operation has an error");	
  
	#5
	$display("************Second write operation test************");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("Second Setup process done successfully");	
	else
       $display("Second Setup process has an error");	
	   
	PREADY_TB = 'b1;
	Transfer_TB = 'b0;
	#10
	PREADY_TB = 'b0;
	#5
    if (PENABLE_TB == 1'b0)
       $display("Second write operation done successfully");	
	else
       $display("Second write operation has an error");	
    
	  #15
	  $display("************No anthoer write operation needed test************");
	  if (PENABLE_TB == 1'b0)
       $display("Master return to idle state successsfully when no anthor wirte operation needed");	
	else
       $display("Master operation has an error");
end
endtask


///////////////////////////////////////////////////////////////////////////////////
//////////////////////////Write operation with waits///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
task write_with_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,
	 input reg  [SLAVES_NUM_TB-1:0]  SLAVE2
);
begin
  #10
  Transfer_TB = 'b1;
	IN_ADDR_TB = 'hBAB84CD3;              //address = 1011_1010_1011_1000_0100_1100_1101_0011;
	IN_DATA_TB = 'd98;
	IN_WRITE_TB = 'b1;
	PREADY_TB = 'b0;
    #15
    $display("************First write operation test************");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("First Setup process done successfully");	
	else
       $display("First Setup process has an error");	
	#25
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting");	
	else
       $display("An Error occur: Master didn't wait");	
       
	PREADY_TB = 'b1;
	#10
	//Put the second transfer data
	IN_ADDR_TB = 'hB6B84CD3;           //address = 1011_0110_1011_1000_0100_1100_1101_0011;
	IN_DATA_TB = 'd90;
	PREADY_TB = 'b0;
	
	#5
    if (PENABLE_TB == 1'b0)
       $display("First write operation done successfully");	
	else
       $display("First write operation has an error");	
  
	#5
	$display("************Second write operation test************");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("Second Setup process done successfully");	
	else
       $display("Second Setup process has an error");
	
	#20
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting");	
	else
       $display("An Error occur: Master didn't wait");	
       
	PREADY_TB = 'b1;
	Transfer_TB = 'b0;
	#10
	PREADY_TB = 'b0;
	#5
    if (PENABLE_TB == 1'b0)
       $display("Second write operation done successfully");	
	else
       $display("Second write operation has an error");	
    
	  #15
	  $display("************No anthoer write operation needed test************");
	  if (PENABLE_TB == 1'b0)
       $display("Master return to idle state successsfully when no anthor wirte operation needed");	
	else
       $display("Master operation has an error");
end
endtask

///////////////////////////////////////////////////////////////////////////////////
///////////////////////Read operation with no waits///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
task read_no_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,
	 input reg  [SLAVES_NUM_TB-1:0]  SLAVE2
);
begin
    #10
    Transfer_TB = 'b1;
	IN_ADDR_TB = 'hBAB84CD3;              //address = 1011_1010_1011_1000_0100_1100_1101_0011;
	IN_WRITE_TB = 'b0;
	PREADY_TB = 'b0;
    #15
    $display("************First read operation test************");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB)
       $display("First Setup process done successfully");	
	else
       $display("First Setup process has an error");	
	#5
	
	PREADY_TB = 'b1;
	PRDATA_TB = 'd98;
  #10
  //Put the second transfer data
	IN_ADDR_TB = 'hB6B84CD3;           //address = 1011_0110_1011_1000_0100_1100_1101_0011;
	PREADY_TB = 'b0;
	#5
	if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("First read operation done successfully");	
	else
       $display("First read operation has an error");	

	   
	$display("************Second read operation test************");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB)
       $display("Second Setup process done successfully");	
	else
       $display("Second Setup process has an error");		
	   
	#5
	PREADY_TB = 'b1;
	PRDATA_TB = 'd90;
	#5
	Transfer_TB = 'b0;
    #5
	PREADY_TB = 'b0;
	#5
    if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("Second read operation done successfully");	
	else
       $display("Second read operation has an error");	
   
	
	  #25
	  $display("************No anthoer read operation needed test************");
	  if (PENABLE_TB == 1'b0)
       $display("Master return to idle state successsfully when no anthor read operation needed");	
	else
       $display("Master operation has an error");
end
endtask



///////////////////////////////////////////////////////////////////////////////////
///////////////////////////Read operation with waits///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
task read_with_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,
	 input reg  [SLAVES_NUM_TB-1:0]  SLAVE2
);
begin
    #10
    Transfer_TB = 'b1;
	IN_ADDR_TB = 'hBAB84CD3;              //address = 1011_1010_1011_1000_0100_1100_1101_0011;
	IN_WRITE_TB = 'b0;
	PREADY_TB = 'b0;
    #15
    $display("************First read operation test************");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB)
       $display("First Setup process done successfully");	
	else
       $display("First Setup process has an error");		
	#25
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting");	
	else
       $display("An Error occur: Master didn't wait");	
	
	PREADY_TB = 'b1;
	PRDATA_TB = 'd98;
    #10
	//Put the second transfer data
	IN_ADDR_TB = 'hB6B84CD3;           //address = 1011_0110_1011_1000_0100_1100_1101_0011;
	PREADY_TB = 'b0;
	
	#5
	if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("First read operation done successfully");	
	else
       $display("First read operation has an error");
	
  
	$display("************Second read operation test************");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB)
       $display("Second Setup process done successfully");	
	else
       $display("Second Setup process has an error");
	   
	#25
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting");	
	else
       $display("An Error occur: Master didn't wait");	
	   
	PREADY_TB = 'b1;
	PRDATA_TB = 'd90;
	#5
	Transfer_TB = 'b0;
    #5
	PREADY_TB = 'b0;
	#5
    if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("Second read operation done successfully");	
	else
       $display("Second read operation has an error");	
  
	
	  #25
	  $display("************No anthoer read operation needed test************");
	  if (PENABLE_TB == 1'b0)
       $display("Master return to idle state successsfully when no anthor read operation needed");	
	else
       $display("Master operation has an error");
end
endtask
endmodule


