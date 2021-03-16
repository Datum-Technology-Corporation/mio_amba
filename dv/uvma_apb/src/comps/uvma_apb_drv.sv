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


`ifndef __UVMA_APB_DRV_SV__
`define __UVMA_APB_DRV_SV__


/**
 * Component driving a AMBA Advanced Peripheral Bus virtual interface (uvma_apb_if).
 * @note The req & rsp's roles are switched when this driver is in 'slv' mode.
 */
class uvma_apb_drv_c extends uvm_driver#(
   .REQ(uvma_apb_base_seq_item_c),
   .RSP(uvma_apb_mon_trn_c      )
);
   
   // Objects
   uvma_apb_cfg_c    cfg;
   uvma_apb_cntxt_c  cntxt;
   
   // TLM
   uvm_analysis_port     #(uvma_apb_mstr_seq_item_c)  mstr_ap;
   uvm_analysis_port     #(uvma_apb_slv_seq_item_c )  slv_ap ;
   uvm_tlm_analysis_fifo #(uvma_apb_mon_trn_c      )  mon_trn_fifo;
   
   
   `uvm_component_utils_begin(uvma_apb_drv_c)
      `uvm_field_object(cfg  , UVM_DEFAULT)
      `uvm_field_object(cntxt, UVM_DEFAULT)
   `uvm_component_utils_end
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_apb_drv", uvm_component parent=null);
   
   /**
    * 1. Ensures cfg & cntxt handles are not null.
    * 2. Builds ap.
    */
   extern virtual function void build_phase(uvm_phase phase);
   
   /**
    * Oversees driving, depending on the reset state, by calling drv_<pre|in|post>_reset() tasks.
    */
   extern virtual task run_phase(uvm_phase phase);
   
   /**
    * Called by run_phase() while agent is in pre-reset state.
    */
   extern task drv_pre_reset(uvm_phase phase);
   
   /**
    * Called by run_phase() while agent is in reset state.
    */
   extern task drv_in_reset(uvm_phase phase);
   
   /**
    * Called by run_phase() while agent is in post-reset state.
    */
   extern task drv_post_reset(uvm_phase phase);
   
   /**
    * TODO Describe uvma_apb_drv::get_next_req()
    */
   extern task get_next_req(ref uvma_apb_base_seq_item_c req);
   
   /**
    * Drives the virtual interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_mstr_req(uvma_apb_mstr_seq_item_c req);
   
   /**
    * Drives the virtual interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_slv_req(uvma_apb_slv_seq_item_c req);
   
   /**
    * TODO Describe uvma_apb_drv_c::wait_for_rsp()
    */
   extern task wait_for_rsp(uvma_apb_mon_trn_c rsp);
   
   /**
    * TODO Describe uvma_apb_drv_c::process_mstr_rsp()
    */
   extern task process_mstr_resp(uvma_apb_slv_seq_item_c req, uvma_apb_mon_trn_c rsp);
   
   /**
    * Drives the virtual interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_mstr_read_req(uvma_apb_mstr_seq_item_c req);
   
   /**
    * Drives the virtual interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_mstr_write_req(uvma_apb_mstr_seq_item_c req);
   
   /**
    * TODO Describe uvma_apb_drv_c::drv_mstr_idle()
    */
   extern task drv_mstr_idle();
   
   /**
    * TODO Describe uvma_apb_drv_c::drv_slv_idle()
    */
   extern task drv_slv_idle();
   
endclass : uvma_apb_drv_c


function uvma_apb_drv_c::new(string name="uvma_apb_drv", uvm_component parent=null);
   
   super.new(name, parent);
   
endfunction : new


function void uvma_apb_drv_c::build_phase(uvm_phase phase);
   
   super.build_phase(phase);
   
   void'(uvm_config_db#(uvma_apb_cfg_c)::get(this, "", "cfg", cfg));
   if (!cfg) begin
      `uvm_fatal("CFG", "Configuration handle is null")
   end
   uvm_config_db#(uvma_apb_cfg_c)::set(this, "*", "cfg", cfg);
   
   void'(uvm_config_db#(uvma_apb_cntxt_c)::get(this, "", "cntxt", cntxt));
   if (!cntxt) begin
      `uvm_fatal("CNTXT", "Context handle is null")
   end
   uvm_config_db#(uvma_apb_cntxt_c)::set(this, "*", "cntxt", cntxt);
   
   mstr_ap      = new("mstr_ap"     , this);
   slv_ap       = new("slv_ap"      , this);
   mon_trn_fifo = new("mon_trn_fifo", this);
   
endfunction : build_phase


task uvma_apb_drv_c::run_phase(uvm_phase phase);
   
   super.run_phase(phase);
   
   forever begin
      wait (cfg.enabled && cfg.is_active);
      
      fork
         begin
            case (cntxt.reset_state)
               UVMA_APB_RESET_STATE_PRE_RESET : drv_pre_reset (phase);
               UVMA_APB_RESET_STATE_IN_RESET  : drv_in_reset  (phase);
               UVMA_APB_RESET_STATE_POST_RESET: drv_post_reset(phase);
               
               default: `uvm_fatal("APB_DRV", $sformatf("Invalid reset_state: %0d", cntxt.reset_state))
            endcase
         end
         
         begin
            wait (!(cfg.enabled && cfg.is_active));
         end
      join_any
      disable fork;
   end
   
endtask : run_phase


task uvma_apb_drv_c::drv_pre_reset(uvm_phase phase);
   
   case (cfg.drv_mode)
      UVMA_APB_MODE_MSTR: @(cntxt.vif.dut_mstr_cb);
      UVMA_APB_MODE_SLV : @(cntxt.vif.dut_slv_cb );
      
      default: `uvm_fatal("APB_DRV", $sformatf("Invalid drv_mode: %0d", cfg.drv_mode))
   endcase
   
endtask : drv_pre_reset


task uvma_apb_drv_c::drv_in_reset(uvm_phase phase);
   
   case (cfg.drv_mode)
      UVMA_APB_MODE_MSTR: @(cntxt.vif.dut_mstr_cb);
      UVMA_APB_MODE_SLV : @(cntxt.vif.dut_slv_cb );
      
      default: `uvm_fatal("APB_DRV", $sformatf("Invalid drv_mode: %0d", cfg.drv_mode))
   endcase
   
endtask : drv_in_reset


task uvma_apb_drv_c::drv_post_reset(uvm_phase phase);
   
   uvma_apb_mstr_seq_item_c  mstr_req;
   uvma_apb_slv_seq_item_c   slv_req;
   uvma_apb_mstr_mon_trn_c   mstr_rsp;
   uvma_apb_slv_mon_trn_c    slv_rsp;
   
   case (cfg.drv_mode)
      UVMA_APB_MODE_MSTR: begin
         // 1. Get next req from sequence and drive it on the vif
         get_next_req(req);
         if (!$cast(mstr_req, req)) begin
            `uvm_fatal("APB_DRV", $sformatf("Could not cast 'req' (%s) to 'mstr_req' (%s)", $typename(req), $typename(mstr_req)))
         end
         drv_mstr_req(mstr_req);
         
         // 2. Wait for the monitor to send us the slv's rsp with the results of the req
         wait_for_rsp(slv_rsp );
         process_mstr_rsp(mstr_req, slv_rsp);
         
         // 3. Send out to TLM and tell sequencer we're ready for the next sequence item
         mstr_ap.write(mstr_req);
         seq_item_port.item_done();
      end
      
      UVMA_APB_MODE_SLV: begin
         // 1. Wait for the monitor to send us the mstr's "rsp" with an access request
         wait_for_rsp(mstr_rsp);
         seq_item_port.put_response(mstr_rsp);
         
         // 2. Get next req from sequence to reply to mstr and drive it on the vif
         get_next_req(req);
         if (!$cast(slv_req, req)) begin
            `uvm_fatal("APB_DRV", $sformatf("Could not cast 'req' (%s) to 'slv_req' (%s)", $typename(req), $typename(slv_req)))
         end
         drv_slv_req (slv_req);
         
         // 3. Send out to TLM and tell sequencer we're ready for the next sequence item
         slv_ap.write(slv_req);
         seq_item_port.item_done();
      end
      
      default: `uvm_fatal("APB_DRV", $sformatf("Invalid drv_mode: %0d", cfg.drv_mode))
   endcase
   
endtask : drv_post_reset


task uvma_apb_drv_c::get_next_req(ref uvma_apb_base_seq_item_c req);
   
   seq_item_port.get_next_item(req);
   `uvml_hrtbt()
   
   // Copy cfg fields
   req.mode           = cfg.mode;
   req.addr_bus_width = cfg.addr_bus_width;
   req.data_bus_width = cfg.data_bus_width;
   req.sel_width      = cfg.sel_width;
   
endtask : get_next_req


task uvma_apb_drv_c::drv_mstr_req(uvma_apb_mstr_seq_item_c req);
   
   case (req.access_type)
      UVMA_APB_ACCESS_READ: begin
         drv_mstr_read_req(req);
      end
      
      UVMA_APB_ACCESS_WRITE: begin
         drv_mstr_write_req(req);
      end
      
      default: `uvm_fatal("APB_DRV", $sformatf("Invalid access_type: %0d", req.access_type))
   endcase
   
endtask : drv_mstr_req


task uvma_apb_drv_c::drv_slv_req(uvma_apb_slv_seq_item_c req);
   
   // Latency cycles
   @(cntxt.vif.drv_slv_cb);
   repeat (slv_req.latency) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Req data
   cntxt.vif.drv_slv_cb.pready  <= 1'b1;
   cntxt.vif.drv_slv_cb.pslverr <= req.slverr;
   cntxt.vif.drv_slv_cb.prdata[(cfg.data_bus_width-1):0] <= slv_req.data[(cfg.data_bus_width-1):0];
   
   // Hold cycles
   repeat (slv_req.hold_duration) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Idle
   @(cntxt.vif.drv_slv_cb.clk);
   drv_slv_idle();
   
endtask : drv_slv_req


task uvma_apb_drv_c::wait_for_rsp(uvma_apb_mon_trn_c rsp);
   
   mon_trn_fifo.get(rsp);
   
endtask : wait_for_rsp


task uvma_apb_drv_c::process_mstr_rsp(uvma_apb_mstr_seq_item_c req, uvma_apb_mon_trn_c rsp);
   
   req.rdata     = rsp.rdata ;
   req.has_error = rsp.slverr;
   
endtask : process_mstr_resp


task uvma_apb_drv_c::drv_mstr_read_req(uvma_apb_mstr_seq_item_c req);
   
   // Setup phase
   @(cntxt.vif.drv_mstr_cb.clk);
   cntxt.vif.drv_mstr_cb.pwrite <= 0;
   cntxt.vif.drv_mstr_cb.paddr [(cfg.addr_bus_width-1):0] <= req.address[(cfg.addr_bus_width-1):0];
   cntxt.vif.drv_mstr_cb.psel  [(cfg.sel_width     -1):0] <= req.slv_sel[(cfg.sel_width     -1):0];
   
   // Access phase
   @(cntxt.vif.drv_mstr_cb.clk);
   cntxt.vif.drv_mstr_cb.penable <= 1;
   do begin
      @(cntxt.vif.drv_mstr_cb.clk);
   end while (cntxt.vif.drv_mstr_cb.pready !== 1'b1);
   
   // Finish up
   @(cntxt.vif.drv_mstr_cb.clk);
   cntxt.vif.drv_mstr_cb.penable <= 0;
   drv_mstr_idle();
   
endtask : drv_mstr_read_req


task uvma_apb_drv_c::drv_mstr_write_req(uvma_apb_mstr_seq_item_c req);
   
   // Setup phase
   @(cntxt.vif.drv_mstr_cb.clk);
   cntxt.vif.drv_mstr_cb.pwrite <= 1;
   cntxt.vif.drv_mstr_cb.paddr [(cfg.addr_bus_width-1):0] <= req.address[(cfg.addr_bus_width-1):0];
   cntxt.vif.drv_mstr_cb.psel  [(cfg.sel_width     -1):0] <= req.slv_sel[(cfg.sel_width     -1):0];
   cntxt.vif.drv_mstr_cb.pwdata[(cfg.data_bus_width-1):0] <= req.wdata  [(cfg.data_bus_width-1):0];
   
   // Access phase
   @(cntxt.vif.drv_mstr_cb.clk);
   cntxt.vif.drv_mstr_cb.penable <= 1;
   do begin
      @(cntxt.vif.drv_mstr_cb.clk);
   end while (cntxt.vif.drv_mstr_cb.pready !== 1'b1);
   
   // Finish up
   @(cntxt.vif.drv_mstr_cb.clk);
   drv_mstr_idle();
   cntxt.vif.drv_mstr_cb.penable <= 0;
   
endtask : drv_mstr_read_req


task uvma_apb_drv_c::drv_mstr_idle();
   
   case (cfg.drv_idle)
      UVMA_APB_DRV_IDLE_SAME: // Do nothing;
      
      UVMA_APB_DRV_IDLE_ZEROS: begin
         cntxt.vif.drv_mstr_cb.paddr [(cfg.addr_bus_width-1):0] <= '0;
         cntxt.vif.drv_mstr_cb.psel  [(cfg.sel_width     -1):0] <= '0;
         cntxt.vif.drv_mstr_cb.pwdata[(cfg.data_bus_width-1):0] <= '0;
      end
      
      UVMA_APB_DRV_IDLE_RANDOM: begin
         cntxt.vif.drv_mstr_cb.paddr [(cfg.addr_bus_width-1):0] <= $urandom();
         cntxt.vif.drv_mstr_cb.psel  [(cfg.sel_width     -1):0] <= $urandom();
         cntxt.vif.drv_mstr_cb.pwdata[(cfg.data_bus_width-1):0] <= $urandom();
      end
      
      UVMA_APB_DRV_IDLE_X: begin
         cntxt.vif.drv_mstr_cb.paddr [(cfg.addr_bus_width-1):0] <= 'X;
         cntxt.vif.drv_mstr_cb.psel  [(cfg.sel_width     -1):0] <= 'X;
         cntxt.vif.drv_mstr_cb.pwdata[(cfg.data_bus_width-1):0] <= 'X;
      end
      
      UVMA_APB_DRV_IDLE_Z: begin
         cntxt.vif.drv_mstr_cb.paddr [(cfg.addr_bus_width-1):0] <= 'Z;
         cntxt.vif.drv_mstr_cb.psel  [(cfg.sel_width     -1):0] <= 'Z;
         cntxt.vif.drv_mstr_cb.pwdata[(cfg.data_bus_width-1):0] <= 'Z;
      end
      
      default: `uvm_fatal("APB_DRV", $sformatf("Invalid drv_idle: %0d", cfg.drv_idle))
   endcase
   
endtask : drv_mstr_idle


task uvma_apb_drv_c::drv_slv_idle();
   
   case (cfg.drv_idle)
      UVMA_APB_DRV_IDLE_SAME: // Do nothing;
      
      UVMA_APB_DRV_IDLE_ZEROS: begin
         cntxt.vif.prdata[(cfg.data_bus_width-1):0] <= '0;
         cntxt.vif.pslverr <= 0;
      end
      
      UVMA_APB_DRV_IDLE_RANDOM: begin
         cntxt.vif.prdata[(cfg.data_bus_width-1):0] <= $urandom();
         cntxt.vif.pslverr <= $urandom_range(0,1);
      end
      
      UVMA_APB_DRV_IDLE_X: begin
         cntxt.vif.prdata[(cfg.data_bus_width-1):0] <= 'X;
         cntxt.vif.pslverr <= 'X;
      end
      
      UVMA_APB_DRV_IDLE_Z: begin
         cntxt.vif.prdata[(cfg.data_bus_width-1):0] <= 'Z;
         cntxt.vif.pslverr <= 'Z;
      end
      
      default: `uvm_fatal("APB_DRV", $sformatf("Invalid drv_idle: %0d", cfg.drv_idle))
   endcase
   
endtask : drv_slv_idle


`endif // __UVMA_APB_DRV_SV__
