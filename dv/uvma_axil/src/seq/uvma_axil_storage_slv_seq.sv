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
class uvma_axil_storage_slv_seq_c extends uvma_axil_slv_base_seq_c;
   
   // Fields
   bit [(`UVMA_AXIL_DATA_MAX_SIZE-1):0]  mem[int unsigned];
   
   
   `uvm_object_utils_begin(uvma_axil_storage_slv_seq_c)
      `uvm_field_aa_int_int_unsigned(mem, UVM_DEFAULT)
   `uvm_object_utils_end
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_axil_storage_slv_seq");
   
   /**
    * TODO Describe uvma_axil_storage_slv_seq_c::do_response()
    */
   extern virtual task do_response(ref uvma_axil_mon_trn_c mon_req);
   
endclass : uvma_axil_storage_slv_seq_c


function uvma_axil_storage_slv_seq_c::new(string name="uvma_axil_storage_slv_seq");
   
   super.new(name);
   
endfunction : new


task uvma_axil_storage_slv_seq_c::do_response(ref uvma_axil_mon_trn_c mon_req);
   
   bit [(`UVMA_AXIL_ADDR_MAX_SIZE-1):0]     addr = 0;
   uvma_axil_slv_seq_item_c                 _req;
   
   if (mon_req.has_error) begin
      return;
   end
   
   for (int unsigned ii=0; ii<cfg.addr_bus_width; ii++) begin
      addr[ii] = mon_req.address[ii];
   end
   case (mon_req.access_type)
      UVMA_AXIL_ACCESS_READ: begin
         if (mem.exists(addr)) begin
            // The following code is currently incompatible with xsim (2020.2)
            // Temporary replacement below
            //`uvm_do_with(_req, {
            //   foreach (rdata[ii]) {
            //      if (ii < cfg.data_bus_width) {
            //         rdata[ii] == mem[addr][ii];
            //      }
            //   }
            //})
            `uvm_create(_req)
            if (_req.randomize()) begin
               foreach (_req.rdata[ii]) begin
                  if (ii < cfg.data_bus_width) begin
                     _req.rdata[ii] = 1'b0;
                  end
               end
               `uvm_send(_req)
            end
            else begin
               `uvm_fatal("AXIL_SEQ", $sformatf("Failed to randomize _req:\n%s", _req.sprint()))
            end
         end
         else begin
            `uvm_do_with(_req, {
               foreach (_req.rdata[ii]) {
                  if (ii < cfg.data_bus_width) {
                     _req.rdata[ii] == 1'b0;
                  }
               }
            })
         end
      end
      
      UVMA_AXIL_ACCESS_WRITE: begin
         mem[addr] = mon_req.data;
         `uvm_do(_req)
      end
      
      default: `uvm_fatal("AXIL_STORAGE_SLV_SEQ", $sformatf("Invalid access_type (%0d):\n%s", mon_req.access_type, mon_req.sprint()))
   endcase
   
endtask : do_response


`endif // __UVMA_AXIL_STORAGE_SLV_SEQ_SV__
