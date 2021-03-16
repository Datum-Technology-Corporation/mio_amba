// 
// Copyright 2021 Datum Technology Corporation
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// 
// Licensed under the Solderpad Hardware License v 2.1 (the "License"); you may
// not use this file except in compliance with the License, or, at your option,
// the Apache License version 2.0. You may obtain a copy of the License at
// 
//     https://solderpad.org/licenses/SHL-2.1/
// 
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.
// 


`ifndef __UVMA_AXIL_STORAGE_SLV_SEQ_SV__
`define __UVMA_AXIL_STORAGE_SLV_SEQ_SV__


/**
 * 'slv' sequence that reads back '0 as data, unless the address has been
 * written to.
 */
class uvma_axil_storage_slv_seq_c extends uvma_axil_base_seq_c;
   
   // Fields
   int unsigned  mem[int unsigned];
   
   
   `uvm_object_utils_begin(uvma_axil_storage_slv_seq_c)
   `uvm_object_utils_end
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_axil_storage_slv_seq");
   
   /**
    * TODO Describe uvma_axil_storage_slv_seq_c::body()
    */
   extern virtual task body();
   
endclass : uvma_axil_storage_slv_seq_c


function uvma_axil_storage_slv_seq_c::new(string name="uvma_axil_storage_slv_seq");
   
   super.new(name);
   
endfunction : new


task uvma_axil_storage_slv_seq_c::body();
   
   int unsigned              addr = 0;
   uvma_axil_slv_seq_item_c  _req;
   
   forever begin
      get_response(rsp);
      if (rsp.has_error) continue;
      
      addr = rsp.address[(cfg.addr_bus_width-1):0];
      case (rsp.access_type)
         UVMA_AXIL_ACCESS_READ: begin
            if (mem.exists(addr)) begin
               `uvm_do_with(_req, {
                  rdata[(cfg.data_bus_width-1):0] == mem[addr];
               })
            end
            else begin
               `uvm_do_with(_req, {
                  rdata[(cfg.data_bus_width-1):0] == '0;
               })
            end
         end
         
         UVMA_AXIL_ACCESS_WRITE: begin
            mem[addr] = rsp.data[(cfg.data_bus_width-1):0];
            `uvm_do(_req)
         end
         
         default: `uvm_fatal("AXIL_STORAGE_SLV_SEQ", $sformatf("Invalid access_type (%0d):\n%s", rsp.access_type, rsp.sprint()))
      endcase
   end
   
endtask : body


`endif // __UVMA_AXIL_STORAGE_SLV_SEQ_SV__
