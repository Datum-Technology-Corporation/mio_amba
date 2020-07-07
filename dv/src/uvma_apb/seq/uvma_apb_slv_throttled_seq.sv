// 
// Copyright 2020 OpenHW Group
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


`ifndef __UVMA_APB_SLV_THROTTLED_SEQ_SV__
`define __UVMA_APB_SLV_THROTTLED_SEQ_SV__


/**
 * TODO Describe uvma_apb_slv_throttled_seq_c
 */
class uvma_apb_slv_throttled_seq_c extends uvma_apb_slv_base_seq_c;
   
   // Fields
   rand int unsigned  pct_ready;
   rand int unsigned  min_latency;
   rand int unsigned  max_latency;
   
   // Control
   bit  active = 1;
   
   
   `uvm_object_utils_begin(uvma_apb_slv_throttled_seq_c)
      `uvm_field_int(pct_ready  , UVM_DEFAULT + UVM_DEC)
      `uvm_field_int(min_latency, UVM_DEFAULT + UVM_DEC)
      `uvm_field_int(max_latency, UVM_DEFAULT + UVM_DEC)
   `uvm_object_utils_end
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_apb_slv_throttled_seq");
   
   /**
    * TODO Describe uvma_apb_slv_throttled_seq_c::body()
    */
   extern virtual task body();
   
endclass : uvma_apb_slv_throttled_seq_c


function uvma_apb_slv_throttled_seq_c::new(string name="uvma_apb_slv_throttled_seq");
   
   super.new(name);
   
endfunction : new


task uvma_apb_slv_throttled_seq_c::body();
   
   int unsigned  delay;
   
   while (active) begin
      // 
      
      delay = $urandom_range(min_latency, max_latency);
      repeat (delay) begin
         @(cntxt.vif.drv_slv_cb);
      end
   end
   
endtask : body


`endif // __UVMA_APB_SLV_THROTTLED_SEQ_SV__
