// 
// Copyright 2020 Datum Technology Corporation
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// 
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may
// not use this file except in compliance with the License, or, at your option,
// the Apache License version 2.0. You may obtain a copy of the License at
// 
//     https://solderpad.org/licenses/SHL-2.1/
// 
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations under
// the License.
// 


`ifndef __UVMA_APB_MON_SV__
`define __UVMA_APB_MON_SV__


/**
 * Component sampling transactions from a AMBA Advanced Peripheral Bus virtual interface
 * (uvma_apb_if).
 */
class uvma_apb_mon_c extends uvm_monitor;
   
   // Objects
   uvma_apb_cfg_c    cfg;
   uvma_apb_cntxt_c  cntxt;
   
   // TLM
   uvm_analysis_port#(uvma_apb_mon_trn_c)  ap;
   
   
   `uvm_component_utils_begin(uvma_apb_mon_c)
      `uvm_field_object(cfg  , UVM_DEFAULT)
      `uvm_field_object(cntxt, UVM_DEFAULT)
   `uvm_component_utils_end
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_apb_mon", uvm_component parent=null);
   
   /**
    * 1. Ensures cfg & cntxt handles are not null.
    * 2. Builds ap.
    */
   extern virtual function void build_phase(uvm_phase phase);
   
   /**
    * Oversees monitoring, depending on the reset state, by calling mon_<pre|in|post>_reset() tasks.
    */
   extern virtual task run_phase(uvm_phase phase);
   
   /**
    * Updates the context's reset state.
    */
   extern virtual task observe_reset();
   
   /**
    * Called by run_phase() while agent is in pre-reset state.
    */
   extern virtual task mon_pre_reset(uvm_phase phase);
   
   /**
    * Called by run_phase() while agent is in reset state.
    */
   extern virtual task mon_in_reset(uvm_phase phase);
   
   /**
    * Called by run_phase() while agent is in post-reset state.
    */
   extern virtual task mon_post_reset(uvm_phase phase);
   
   /**
    * Creates trn by sampling the virtual interface's (cntxt.vif) signals.
    */
   extern virtual task sample_trn(output uvma_apb_mon_trn_c trn);
   
   /**
    * TODO Describe uvma_apb_mon_c::sample_signals()
    */
   extern virtual task sample_signals(output uvma_apb_mon_trn_c trn);
   
   /**
    * TODO Describe uvma_apb_mon_c::process_trn()
    */
   extern virtual function void process_trn(ref uvma_apb_mon_trn_c trn);
   
endclass : uvma_apb_mon_c


function uvma_apb_mon_c::new(string name="uvma_apb_mon", uvm_component parent=null);
   
   super.new(name, parent);
   
endfunction : new


function void uvma_apb_mon_c::build_phase(uvm_phase phase);
   
   super.build_phase(phase);
   
   void'(uvm_config_db#(uvma_apb_cfg_c)::get(this, "", "cfg", cfg));
   if (!cfg) begin
      `uvm_fatal("CFG", "Configuration handle is null")
   end
   
   void'(uvm_config_db#(uvma_apb_cntxt_c)::get(this, "", "cntxt", cntxt));
   if (!cntxt) begin
      `uvm_fatal("CNTXT", "Context handle is null")
   end
   
   ap = new("ap", this);
  
endfunction : build_phase


task uvma_apb_mon_c::run_phase(uvm_phase phase);
   
   super.run_phase(phase);
   
   fork
      observe_reset();
      
      begin
         forever begin
            wait (cfg.enabled) begin
               case (cntxt.reset_state)
                  UVMA_APB_RESET_STATE_PRE_RESET : mon_pre_reset (phase);
                  UVMA_APB_RESET_STATE_IN_RESET  : mon_in_reset  (phase);
                  UVMA_APB_RESET_STATE_POST_RESET: mon_post_reset(phase);
               endcase
            end
         end
      end
   join_none
   
endtask : run_phase


task uvma_apb_mon_c::observe_reset();
   
   forever begin
      wait (cfg.enabled) begin
         wait (cntxt.vif.reset_n === 0);
         cntxt.reset_state = UVMA_APB_RESET_STATE_IN_RESET;
         wait (cntxt.vif.reset_n === 1);
         cntxt.reset_state = UVMA_APB_RESET_STATE_POST_RESET;
      end
   end
   
endtask : observe_reset


task uvma_apb_mon_c::mon_pre_reset(uvm_phase phase);
   
   @(cntxt.vif.mon_cb);
   
endtask : mon_pre_reset


task uvma_apb_mon_c::mon_in_reset(uvm_phase phase);
   
   @(cntxt.vif.mon_cb);
   
endtask : mon_in_reset


task uvma_apb_mon_c::mon_post_reset(uvm_phase phase);
   
   uvma_apb_mon_trn_c  trn;
   
   sample_trn (trn);
   process_trn(trn);
   ap.write   (trn);
   
   `uvml_hrtbt()
   
endtask : mon_post_reset


task uvma_apb_mon_c::sample_trn(output uvma_apb_mon_trn_c trn);
   
   bit  sampled_trn = 0;
   
   trn = uvma_apb_mon_trn_c::type_id::create("trn");
   
   do begin
      @(cntxt.vif.mon_cb);
      
      if (cntxt.vif.reset_n === 1) begin
         case (cfg.mode)
            // Only sample when a data transfer is starting
            UVMA_APB_MODE_MASTER: begin
               if ((cntxt.vif.mon_cb.penable === 1) && (cntxt.vif.mon_cb.pready === 1)) begin
                  sample_signals(trn);
                  sampled_trn = 1;
               end
            end
            
            UVMA_APB_MODE_SLAVE: begin
               // Sample both when tready is asserted/deasserted and when a data
               // transfer begins
               if (
                  ((cntxt.vif.mon_cb.penable === 1) && (cntxt.vif.mon_cb.pready === 1)) ||
                  (cntxt.vif.mon_cb.pready !== cntxt.ton)
               ) begin
                  sample_signals(trn);
                  sampled_trn = 1;
                  cntxt.ton = cntxt.vif.mon_cb.tready;
               end
            end
            
            default: `uvm_fatal("APB_MON", $sformatf("Invalid cfg.mode: %s", cfg.mode.name()))
         endcase
      end
   end while (!sampled_trn);
   
endtask : sample_trn


task uvma_apb_mon_c::sample_signals(output uvma_apb_mon_trn_c trn);
   
   // Create transaction and fill in metadata
   trn = uvma_apb_mon_trn_c::type_id::create("trn");
   trn.addr_bus_width    = cfg.addr_bus_width     ;
   trn.data_bus_width    = cfg.data_bus_width   ;
   trn.sel_width         = cfg.sel_width   ;
   trn.timestamp_start   = $realtime();
   trn.timestamp_end     = $realtime();
   
   // Sample bus signals
   trn.paddr   = cntxt.vif.mon_cb.paddr  ;
   trn.psel    = cntxt.vif.mon_cb.psel   ;
   trn.penable = cntxt.vif.mon_cb.penable;
   trn.pwrite  = cntxt.vif.mon_cb.pwrite ;
   trn.pwdata  = cntxt.vif.mon_cb.pwdata ;
   trn.pready  = cntxt.vif.mon_cb.pready ;
   trn.prdata  = cntxt.vif.mon_cb.prdata ;
   trn.pslverr = cntxt.vif.mon_cb.pslverr;
   
endtask : sample_signals


function void uvma_apb_mon_c::process_trn(ref uvma_apb_mon_trn_c trn);
   
   // TODO Implement uvma_apb_mon_c::process_trn()
   
endfunction : process_trn


`endif // __UVMA_APB_MON_SV__
