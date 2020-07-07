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


`ifndef __UVMA_APB_SEQ_ITEM_SV__
`define __UVMA_APB_SEQ_ITEM_SV__


/**
 * Object created by AMBA Advanced Peripheral Bus agent sequences extending uvma_apb_seq_base_c.
 */
class uvma_apb_seq_item_c extends uvml_trn_seq_item_c;
   
   // Master
   rand uvma_apb_access_type_enum             access_type;
   rand bit [(`UVMA_APB_PADDR_MAX_SIZE-1):0]  address    ;
   rand bit [(`UVMA_APB_DATA_MAX_SIZE -1):0]  data       ;
   rand bit [(`UVMA_APB_PSEL_MAX_SIZE -1):0]  slave_sel  ;
   
   // Slave - only used 
   rand bit                                   ready ;
   rand bit [(`UVMA_APB_DATA_MAX_SIZE -1):0]  rdata ;
   rand bit                                   slverr;
   
   // Metadata
   uvma_apb_mode_enum  mode;
   int unsigned        addr_bus_width; // Measured in bytes (B)
   int unsigned        data_bus_width; // Measured in bytes (B)
   int unsigned        sel_width     ; // Measured in bits  (b)
   
   
   `uvm_object_utils_begin(uvma_apb_mon_trn_c)
      `uvm_field_enum(uvma_apb_access_type_enum, access_type, UVM_DEFAULT              )
      `uvm_field_int (                           address    , UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int (                           data       , UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int (                           slave_sel  , UVM_DEFAULT + UVM_NOPRINT)
      
      `uvm_field_int(ready , UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int(rdata , UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int(slverr, UVM_DEFAULT + UVM_NOPRINT)
   `uvm_object_utils_end
   
   
   constraint default_cons {
      soft pslverr == 0;
   }
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_apb_seq_item");
   
   /**
    * TODO Describe uvma_apb_seq_item_c::do_print()
    */
   extern virtual function void do_print(uvm_printer printer);
   
endclass : uvma_apb_seq_item_c


function uvma_apb_seq_item_c::new(string name="uvma_apb_seq_item");
   
   super.new(name);
   
endfunction : new


function void uvma_apb_seq_item_c::do_print(uvm_printer printer);
   
   super.do_print(printer);
   
   case (mode)
      UVMA_APB_MODE_MASTER: begin
         printer.print_string("access_type", access_type);
         if (addr_bus_width != 0) begin
            printer.print_field("address", address, addr_bus_width);
         end
         if (data_bus_width != 0) begin
            printer.print_field("wdata", wdata, data_bus_width);
         end
         if (sel_width != 0) begin
            printer.print_field("slave_sel", slave_sel, sel_width);
         end
      end
      
      UVMA_APB_MODE_SLAVE: begin
         printer.print_field("ready", ready, $bits(ready));
         if (data_bus_width != 0) begin
            printer.print_field("rdata", rdata, data_bus_width);
         end
         printer.print_field("slverr", slverr, $bits(slverr));
      end
      
      default: `uvm_fatal("APB_SEQ_ITEM", $sformatf("Invlalid mode: %s", mode.name()))
   endcase
   
endfunction : do_print


`endif // __UVMA_APB_SEQ_ITEM_SV__
