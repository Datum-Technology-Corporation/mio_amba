// 
// Copyright 2020 Datum Technology Corporation
// 
// Licensed under the Solderpad Hardware License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     https://solderpad.org/licenses/
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 


`ifndef __UVMA_APB_IF_SV__
`define __UVMA_APB_IF_SV__


/**
 * Encapsulates all signals and clocking of AMBA Advanced Peripheral Bus interface. Used by
 * monitor (uvma_apb_mon_c) and driver (uvma_apb_drv_c).
 */
interface uvma_apb_if (
   input  clk    ,
   input  reset_n
);
   
   // Master-out signals
   wire [(`UVMA_APB_PADDR_MAX_SIZE-1):0]  paddr  ;
   wire [(`UVMA_APB_PSEL_MAX_SIZE -1):0]  psel   ;
   wire                                   penable;
   wire                                   pwrite ;
   wire [(`UVMA_APB_DATA_MAX_SIZE -1):0]  pwdata ;
   
   // Slave-out signals
   wire                                   pready ;
   wire [(`UVMA_APB_DATA_MAX_SIZE -1):0]  prdata ;
   wire                                   pslverr;
   
   
   /**
    * Used by DUT in 'master' mode.
    */
   clocking dut_master_cb @(posedge clk);
      input   pready ,
              prdata ,
              pslverr;
      output  paddr  ,
              psel   ,
              penable,
              pwrite ,
              pwdata ;
   endclocking : dut_master_cb
   
   /**
    * Used by DUT in 'slave' mode.
    */
   clocking dut_slave_cb @(posedge clk);
      output  pready ,
              prdata ,
              pslverr;
      input   paddr  ,
              psel   ,
              penable,
              pwrite ,
              pwdata ;
   endclocking : dut_slave_cb
   
   /**
    * Used by uvma_apb_drv_c.
    */
   clocking drv_master_cb @(posedge clk);
      output  pready ,
              prdata ,
              pslverr;
      input   paddr  ,
              psel   ,
              penable,
              pwrite ,
              pwdata ;
   endclocking : drv_master_cb
   
   /**
    * Used by uvma_apb_drv_c.
    */
   clocking drv_slave_cb @(posedge clk);
      output  pready ,
              prdata ,
              pslverr;
      input   paddr  ,
              psel   ,
              penable,
              pwrite ,
              pwdata ;
   endclocking : drv_slave_cb
   
   /**
    * Used by uvma_apb_mon_c.
    */
   clocking mon_cb @(posedge clk);
      input  paddr  ,
             psel   ,
             penable,
             pwrite ,
             pwdata ,
             pready ,
             prdata ,
             pslverr;
   endclocking : mon_cb
   
   
   modport dut_master_mp   (clocking dut_master_cb);
   modport dut_slave_mp    (clocking dut_slave_cb );
   modport active_master_mp(clocking drv_master_cb);
   modport active_slave_mp (clocking drv_slave_cb );
   modport passive_mp      (clocking mon_cb       );
   
endinterface : uvma_apb_if


`endif // __UVMA_APB_IF_SV__
