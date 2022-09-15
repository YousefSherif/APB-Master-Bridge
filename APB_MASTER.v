////////////////////////////////////////////////////////////////////////////////// 
// Create Date:  02/09/2022 05:17:28 PM
// Design Name:  APB_Master_Bridge
// Module Name:  APB_Master_Bridge
// Project Name: AMBA BUS Assignment
// 
// Description:  The AHB-APB bridge is an AHB slave, providing an interface between
//               the high-speed AHB domain and the low-power APB domain. 
//               Read and write Transfers on the AHB are converted into corresponding
//               Transfers on the APB through a master interface.
// 
// Team Members: 1- Mohamed Hosam Elden Abd Alhakim Abd Alhady
//               2- Fatma Ali Gamal Eldin Mohammed
//               3- Fatma Hazem Abdel Salam Mohamed
//               4- Tasneem Abo El-Esaad Abd El-Razik Abo El-Esaad 
//               5- Hadeer Muhammed Ali Abdo Saleh
//               6- Yousef Sherif Abdel Fadil
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
//////////////// Module Difinition ///////////////////// 
////////////////////////////////////////////////////////
module APB_MASTER #(parameter DATA_WIDTH = 'd32,  ADDRESS_WIDTH = 'd32, STRB_WIDTH = 'd4, SLAVES_NUM = 'd8) (
input  wire                      PCLK       ,
input  wire                      PRESETn    ,
input  wire  [ADDRESS_WIDTH-1:0] IN_ADDR    ,
input  wire  [DATA_WIDTH-1:0]    IN_DATA    ,
input  wire  [DATA_WIDTH-1:0]    PRDATA     ,
input  wire  [2:0]               IN_PROT    ,
input  wire                      IN_WRITE   ,
input  wire  [STRB_WIDTH-1:0]    IN_STRB    ,
input  wire                      Transfer   ,
input  wire                      PREADY     ,
input  wire                      PSLVERR    ,

output reg                       OUT_SLVERR ,
output reg   [DATA_WIDTH-1:0]    OUT_RDATA  ,
output reg   [ADDRESS_WIDTH-1:0] PADDR      ,
output reg   [DATA_WIDTH-1:0]    PWDATA     ,
output reg                       PWRITE     ,
output reg                       PENABLE    ,
output reg   [2:0]               PPROT      ,
output reg   [STRB_WIDTH-1:0]    PSTRB      ,
output reg     [SLAVES_NUM-1:0]  PSEL
  ); 

  //////////////////////////////////////////////////////
 //////////////// Control Signals /////////////////////
//////////////////////////////////////////////////////
  reg  [1:0]  current_state , 
              next_state    ;

  //////////////////////////////////////////////////////
 ///////// States Encoded in Gray Encoding ////////////
//////////////////////////////////////////////////////
  localparam   [1:0]   IDLE     = 2'b00 ,
                       SETUP    = 2'b01 ,
                       ENABLE   = 2'b11 ;
  
  //////////////////////////////////////////////////////
 //////////////// State Transition ////////////////////
//////////////////////////////////////////////////////
  always @(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          current_state <= IDLE;          
        end
      else
        begin
          current_state <= next_state; 
        end 
    end

////////////////////////////////////////////////////////
///////////////// Next State Logic  /////////////////////
////////////////////////////////////////////////////////
  always@(*)
    begin
      case(current_state)            
            IDLE:   begin 
                      if(!Transfer)
                        begin
                          next_state = IDLE ;
                        end
                      else
                        begin
                          next_state = SETUP ; 
                        end
                    end
            SETUP:  begin
                      next_state = ENABLE ;
                    end
            ENABLE: begin
                      if(Transfer & !PSLVERR)
                        begin
                          if(PREADY)
                            begin
                              next_state = SETUP ;
                            end
                          else
                            begin
                              next_state = ENABLE ;
                            end
                        end
                      else 
                        begin
                         next_state = IDLE ;
                        end
                    end
            default: next_state = IDLE ; 
      endcase
    end

////////////////////////////////////////////////////////
////////////////// Address Decoding ///////////////////// 
////////////////////////////////////////////////////////
  always @(posedge PCLK, negedge PRESETn) 
    begin
      if (!PRESETn)
        begin
     	    PSEL = 'b0 ;
        end
      else if (next_state == IDLE)
        begin
          PSEL = 'b0 ;
        end
      else
        begin
     	    case(IN_ADDR[28:26])
            3'b000: begin 
                      PSEL = 'b0000_0001 ;
                    end
            3'b001: begin 
                      PSEL = 'b0000_0010 ;
                    end
            3'b010: begin 
                      PSEL = 'b0000_0100 ;
                    end
            3'b011: begin 
                      PSEL = 'b0000_1000 ;
                    end
            3'b100: begin 
                      PSEL = 'b0001_0000 ;
                    end
            3'b101: begin 
                      PSEL = 'b0010_0000 ;
                    end
            3'b110: begin 
                      PSEL = 'b0100_0000 ;
                    end
            3'b111: begin 
                      PSEL = 'b1000_0000 ;
                    end
            default:begin 
                      PSEL = 'b0000_0000 ;
                    end
          endcase
        end
    end

  /////////////////////////////////////////////////////
 ///////////////// OUTPUT LOGIC //////////////////////                                                
/////////////////////////////////////////////////////
 always @(posedge PCLK, negedge PRESETn)
   begin
     if(!PRESETn) 
       begin
         PENABLE    <= 1'b0 ;
         PADDR      <=  'b0 ;
         PWDATA     <=  'b0 ;
         PWRITE     <= 1'b0 ;
         OUT_RDATA  <=  'b0 ;
         PSTRB      <=  'b0 ;
         PPROT      <= 3'b0 ;
         OUT_SLVERR <= 1'b0 ;
       end
     else if(next_state == SETUP)
       begin
         PENABLE   <= 1'b0     ;
         PADDR     <= IN_ADDR  ;
         PWRITE    <= IN_WRITE ;
         PPROT     <= IN_PROT  ;
         if(IN_WRITE)
           begin
             PWDATA <= IN_DATA ;
             PSTRB  <= IN_STRB ;
           end
         else 
           begin
             PSTRB <= 'b0 ;
           end 
       end
     else if(next_state == ENABLE)
       begin
         PENABLE <= 1'b1;
         if(PREADY)
           OUT_SLVERR <= PSLVERR ;
           begin
             if(!IN_WRITE)
               begin
                 OUT_RDATA <= PRDATA ;
               end
           end
       end 
      else
        begin
          PENABLE <= 1'b0;
        end 

   end 

 endmodule

