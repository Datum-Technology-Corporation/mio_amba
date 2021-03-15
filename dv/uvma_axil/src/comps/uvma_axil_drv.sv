// 
// Copyright 2021 Datum Technology Corporation
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
// License for the specific language governing permissions and limitations
// under the License.
// 


`ifndef __UVMA_AXIL_DRV_SV__
`define __UVMA_AXIL_DRV_SV__


/**
 * Component driving a AMBA Advanced eXtensible Interface virtual interface (uvma_axil_if).
 */
class uvma_axil_drv_c extends uvm_driver#(
   .REQ(uvma_axil_base_seq_item_c),
   .RSP(uvma_axil_base_mon_trn_c )
);
   
   // Objects
   uvma_axil_cfg_c    cfg;
   uvma_axil_cntxt_c  cntxt;
   
   // TLM
   uvm_analysis_port     #(uvma_axil_mstr_seq_item_c)  mstr_ap;
   uvm_analysis_port     #(uvma_axil_slv_seq_item_c )  slv_ap ;
   uvm_tlm_analysis_fifo #(uvma_axil_mon_trn_c      )  mon_trn_fifo;
   
   
   `uvm_component_utils_begin(uvma_axil_drv_c)
      `uvm_field_object(cfg  , UVM_DEFAULT)
      `uvm_field_object(cntxt, UVM_DEFAULT)
   `uvm_component_utils_end
   
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_axil_drv", uvm_component parent=null);
   
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
    * Drives the interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_mstr_req(uvma_axil_mstr_seq_item_c req);
   
   /**
    * Drives the interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_slv_req(uvma_axil_slv_seq_item_c req);
   
   /**
    * Drives the interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_slv_read_req(uvma_axil_slv_seq_item_c req);
   
   /**
    * Drives the interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_slv_write_req(uvma_axil_slv_seq_item_c req);
   
   /**
    * TODO Describe uvma_axil_drv_c::wait_for_rsp()
    */
   extern task wait_for_rsp(uvma_axil_mon_trn_c rsp);
   
   /**
    * TODO Describe uvma_axil_drv_c::process_mstr_rsp()
    */
   extern task process_mstr_resp(uvma_axil_slv_seq_item_c req, uvma_axil_mon_trn_c rsp);
   
   /**
    * Drives the interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_mstr_read_req(uvma_axil_mstr_seq_item_c req);
   
   /**
    * Drives the interface's (cntxt.vif) signals using req's contents.
    */
   extern task drv_mstr_write_req(uvma_axil_mstr_seq_item_c req);
   
   /**
    * TODO Describe uvma_axil_drv_c::drv_mstr_idle()
    */
   extern task drv_mstr_idle();
   
   /**
    * TODO Describe uvma_axil_drv_c::drv_slv_idle()
    */
   extern task drv_slv_idle(uvma_axil_access_type_enum access_type);
   
endclass : uvma_axil_drv_c


function uvma_axil_drv_c::new(string name="uvma_axil_drv", uvm_component parent=null);
   
   super.new(name, parent);
   
endfunction : new


function void uvma_axil_drv_c::build_phase(uvm_phase phase);
   
   super.build_phase(phase);
   
   void'(uvm_config_db#(uvma_axil_cfg_c)::get(this, "", "cfg", cfg));
   if (!cfg) begin
      `uvm_fatal("CFG", "Configuration handle is null")
   end
   uvm_config_db#(uvma_axil_cfg_c)::set(this, "*", "cfg", cfg);
   
   void'(uvm_config_db#(uvma_axil_cntxt_c)::get(this, "", "cntxt", cntxt));
   if (!cntxt) begin
      `uvm_fatal("CNTXT", "Context handle is null")
   end
   uvm_config_db#(uvma_axil_cntxt_c)::set(this, "*", "cntxt", cntxt);
   
   mstr_ap      = new("mstr_ap"     , this);
   slv_ap       = new("slv_ap"      , this);
   mon_trn_fifo = new("mon_trn_fifo", this);
   
endfunction : build_phase


task uvma_axil_drv_c::run_phase(uvm_phase phase);
   
   super.run_phase(phase);
   
   forever begin
      wait (cfg.enabled && cfg.is_active);
      
      fork
         begin
            case (cntxt.reset_state)
               UVMA_AXIL_RESET_STATE_PRE_RESET : drv_pre_reset (phase);
               UVMA_AXIL_RESET_STATE_IN_RESET  : drv_in_reset  (phase);
               UVMA_AXIL_RESET_STATE_POST_RESET: drv_post_reset(phase);
               
               default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid reset_state: %0d", cntxt.reset_state))
            endcase
         end
         
         begin
            wait (!(cfg.enabled && cfg.is_active));
         end
      join_any
      disable fork;
   end
   
endtask : run_phase


task uvma_axil_drv_c::drv_pre_reset(uvm_phase phase);
   
   case (cfg.drv_mode)
      UVMA_AXIL_MODE_MSTR: @(cntxt.vif.dut_mstr_cb);
      UVMA_AXIL_MODE_SLV : @(cntxt.vif.dut_slv_cb );
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_mode: %0d", cfg.drv_mode))
   endcase
   
endtask : drv_pre_reset


task uvma_axil_drv_c::drv_in_reset(uvm_phase phase);
   
   case (cfg.drv_mode)
      UVMA_AXIL_MODE_MSTR: @(cntxt.vif.dut_mstr_cb);
      UVMA_AXIL_MODE_SLV : @(cntxt.vif.dut_slv_cb );
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_mode: %0d", cfg.drv_mode))
   endcase
   
endtask : drv_in_reset


task uvma_axil_drv_c::drv_post_reset(uvm_phase phase);
   
   uvma_axil_mstr_seq_item_c  mstr_req;
   uvma_axil_slv_seq_item_c   slv_req;
   uvma_axil_mstr_mon_trn_c   mstr_rsp;
   uvma_axil_slv_mon_trn_c    slv_rsp;
   
   case (cfg.drv_mode)
      UVMA_AXIL_MODE_MSTR: begin
         // 1. Get next req from sequence and drive it on the vif
         get_next_req(req);
         if (!$cast(mstr_req, req)) begin
            `uvm_fatal("AXIL_DRV", $sformatf("Could not cast 'req' (%s) to 'mstr_req' (%s)", $typename(req), $typename(mstr_req)))
         end
         drv_mstr_req(mstr_req);
         
         // 2. Wait for the monitor to send us the slv's rsp with the results of the req
         wait_for_rsp(slv_rsp);
         process_mstr_rsp(mstr_req, slv_rsp);
         
         // 3. Send port out to TLM and tell sequencer we're ready for the next sequence item
         mstr_ap.write(mstr_req);
         seq_item_port.item_done();
      end
      
      UVMA_AXIL_MODE_SLV: begin
         // 1. Wait for the monitor to send us the mstr's "rsp" with an access request
         wait_for_rsp(mstr_rsp);
         seq_item_port.put_response(mstr_rsp);
         
         // 2. Get next req from sequence to reply to mstr and drive it on the vif
         get_next_req(req);
         if (!$cast(slv_req, req)) begin
            `uvm_fatal("AXIL_DRV", $sformatf("Could not cast 'req' (%s) to 'slv_req' (%s)", $typename(req), $typename(slv_req)))
         end
         drv_slv_req(slv_req);
         
         // 3. Send out to TLM and tell sequencer we're ready for the next sequence item
         slv_ap.write(slv_req);
         seq_item_port.item_done();
      end
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_mode: %0d", cfg.drv_mode))
   endcase
   
endtask : drv_post_reset


task uvma_axil_drv_c::get_next_item(ref uvma_axil_base_seq_item_c req);
   
   seq_item_port.get_next_item(req);
   `uvml_hrtbt()
   
   // Copy cfg fields
   req.mode           = cfg.mode;
   req.addr_bus_width = cfg.addr_bus_width;
   req.data_bus_width = cfg.data_bus_width;
   
endtask : get_next_item


task uvma_axil_drv_c::drv_mstr_req(uvma_axil_mstr_seq_item_c req);
   
   case (req.access_type)
      UVMA_AXIL_ACCESS_READ: begin
         drv_mstr_read_req(req);
      end
      
      UVMA_AXIL_ACCESS_WRITE: begin
         drv_mstr_write_req(req);
      end
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid access_type: %0d", req.access_type))
   endcase
   
endtask : drv_mstr_req


task uvma_axil_drv_c::drv_mstr_read_req(uvma_axil_mstr_seq_item_c req);
   
   // Address and Data phase can happen simultaneously
   fork
      // Address Channel
      begin
         // Address Latency cycles
         repeat (req.addr_latency) begin
            @(cntxt.vif.drv_mstr_cb);
         end
         // Address phase
         cntxt.vif.drv_mstr_cb.arvalid <= 1'b1;
         cntxt.vif.drv_mstr_cb.araddr[(cfg.addr_bus_width-1):0] <= req.address[(cfg.addr_bus_width-1):0];
      end
      
      // Data Channel
      begin
         // Data Latency cycles
         repeat (req.data_latency) begin
            @(cntxt.vif.drv_mstr_cb);
         end
         cntxt.vif.drv_mstr_cb.rready <= 1'b1;
      end
   join
   
   // Wait for 'slv' ready
   while (cntxt.vif.drv_mstr_cb.arready !== 1'b1) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
   // Hold Cycles
   repeat (req.hold_duration) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
   // Readback
   cntxt.vif.drv_mstr_cb.arvalid <= 1'b0;
   drv_mstr_idle(UVMA_AXIL_ACCESS_READ);
   repeat (req.hold_duration) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
   // Tail
   cntxt.vif.drv_mstr_cb.rready <= 1'b0;
   repeat (req.tail_duration) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
endtask : drv_mstr_read_req


task uvma_axil_drv_c::drv_mstr_write_req(uvma_axil_mstr_seq_item_c req);
   
   // Address and Data phase can happen simultaneously
   fork
      // Address Channel
      begin
         // Latency cycles
         repeat (req.addr_latency) begin
            @(cntxt.vif.drv_mstr_cb);
         end
         // Address phase
         cntxt.vif.drv_mstr_cb.awvalid <= 1'b1;
         cntxt.vif.drv_mstr_cb.awaddr[(cfg.addr_bus_width-1):0] <= req.address[(cfg.addr_bus_width-1):0];
         
         // Wait for 'slv' ready
         while (cntxt.vif.drv_mstr_cb.awready !== 1'b1) begin
            @(cntxt.vif.drv_mstr_cb);
         end
      end
      
      // Data Channel
      begin
         // Latency cycles
         repeat (req.data_latency) begin
            @(cntxt.vif.drv_mstr_cb);
         end
         cntxt.vif.drv_mstr_cb.wvalid <= 1'b1;
         cntxt.vif.drv_mstr_cb.wdata[(cfg.addr_bus_width  -1):0] <= req.wdata [(cfg.addr_bus_width  -1):0];
         cntxt.vif.drv_mstr_cb.wstrb[(cfg.strobe_bus_width-1):0] <= req.strobe[(cfg.strobe_bus_width-1):0];
         
         // Wait for 'slv' ready
         while (cntxt.vif.drv_mstr_cb.wready !== 1'b1) begin
            @(cntxt.vif.drv_mstr_cb);
         end
      end
      
      // Response Channel
      begin
         // Latency cycles
         repeat (req.resp_latency) begin
            @(cntxt.vif.drv_mstr_cb);
         end
         cntxt.vif.drv_mstr_cb.bready <= 1'b1;
      end
   join
   
   // Hold Cycles
   repeat (req.hold_duration) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
   // Readback
   cntxt.vif.drv_mstr_cb.awvalid <= 1'b0;
   cntxt.vif.drv_mstr_cb.wvalid  <= 1'b0;
   drv_mstr_idle(UVMA_AXIL_ACCESS_WRITE);
   repeat (req.hold_duration) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
   // Tail
   cntxt.vif.drv_mstr_cb.bready <= 1'b0;
   repeat (req.tail_duration) begin
      @(cntxt.vif.drv_mstr_cb);
   end
   
endtask : drv_mstr_read_req


task uvma_axil_drv_c::drv_slv_req(uvma_axil_slv_seq_item_c req);
   
   case (req.access_type)
      UVMA_AXIL_ACCESS_READ: begin
         drv_slv_read_req(req);
      end
      
      UVMA_AXIL_ACCESS_WRITE: begin
         drv_slv_write_req(req);
      end
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid access_type: %0d", req.access_type))
   endcase
   
endtask : drv_slv_req


task uvma_axil_drv_c::drv_slv_read_req(uvma_axil_slv_seq_item_c req);
   
   // Latency cycles
   repeat (req.addr_latency) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Address phase
   cntxt.vif.drv_slv_cb.arready <= 1'b1;
   repeat (req.data_latency) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Read back phase
   while (cntxt.vif.drv_slv_cb.rready !== 1'b1) begin
      @(cntxt.vif.drv_slv_cb);
   end
   cntxt.vif.drv_slv_cb.rvalid <= 1'b1;
   cntxt.vif.drv_slv_cb.rresp  <= req.response;
   cntxt.vif.drv_slv_cb.rdata[(cfg.data_bus_width-1):0] <= req.data[(cfg.data_bus_width-1):0];
   
   // Hold cycles
   repeat (req.duration) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Idle
   repeat (req.tail_duration) begin
      @(cntxt.vif.drv_slv_cb.clk);
      drv_slv_idle(UVMA_AXIL_ACCESS_READ);
   end
   
endtask : drv_slv_read_req


task uvma_axil_drv_c::drv_slv_write_req(uvma_axil_slv_seq_item_c req);
   
   // Address and Data phase can happen simultaneously
   fork
      // Address Channel
      begin
         // Address Latency cycles
         repeat (req.addr_latency) begin
            @(cntxt.vif.drv_slv_cb);
         end
         
         // Address phase
         cntxt.vif.drv_slv_cb.awready <= 1'b1;
      end
      
      // Data Channel
      begin
         // Data Latency cycles
         repeat (req.data_latency) begin
            @(cntxt.vif.drv_slv_cb);
         end
         
         // Data phase
         while (cntxt.vif.drv_slv_cb.wvalid !== 1'b1) begin
            @(cntxt.vif.drv_slv_cb);
         end
         cntxt.vif.drv_slv_cb.wready <= 1'b1;
      end
   join
   
   // Wait for 'mstr' to be ready for the response
   while (cntxt.vif.drv_slv_cb.bready !== 1'b1) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Response latency
   repeat (slv_req.resp_latency) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Write back response and hold cycles
   cntxt.vif.drv_slv_cb.bvalid <= 1'b1;
   cntxt.vif.drv_slv_cb.bresp  <= req.response;
   repeat (slv_req.hold_duration) begin
      @(cntxt.vif.drv_slv_cb);
   end
   
   // Idle
   repeat (req.tail_duration) begin
      @(cntxt.vif.drv_slv_cb.clk);
      drv_slv_idle(UVMA_AXIL_ACCESS_WRITE);
   end
   
endtask : drv_slv_write_req


task uvma_axil_drv_c::wait_for_rsp(uvma_axil_mon_trn_c rsp);
   
   mon_trn_fifo.get(rsp);
   
endtask : wait_for_rsp


task uvma_axil_drv_c::process_mstr_rsp(uvma_axil_mstr_seq_item_c req, uvma_axil_mon_trn_c rsp);
   
   req.rdata     = rsp.rdata ;
   req.response  = rsp.response;
   req.has_error = |rsp.response;
   
endtask : process_mstr_resp


task uvma_axil_drv_c::drv_mstr_idle();
   
   case (access_type)
      UVMA_AXIL_ACCESS_READ: begin
         case (cfg.drv_idle)
            UVMA_AXIL_DRV_IDLE_SAME: // Do nothing;
            
            UVMA_AXIL_DRV_IDLE_ZEROS : cntxt.vif.araddr[(cfg.addr_bus_width-1):0] <= '0;
            UVMA_AXIL_DRV_IDLE_RANDOM: cntxt.vif.araddr[(cfg.addr_bus_width-1):0] <= $urandom();
            UVMA_AXIL_DRV_IDLE_X     : cntxt.vif.araddr[(cfg.addr_bus_width-1):0] <= 'X;
            UVMA_AXIL_DRV_IDLE_Z     : cntxt.vif.araddr[(cfg.addr_bus_width-1):0] <= 'Z;
            
            default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_idle: %0d", cfg.drv_idle))
         endcase
      end
      
      UVMA_AXIL_ACCESS_WRITE: begin
         case (cfg.drv_idle)
            UVMA_AXIL_DRV_IDLE_SAME: // Do nothing;
            
            UVMA_AXIL_DRV_IDLE_ZEROS: begin
               cntxt.vif.awaddr[(cfg.addr_bus_width  -1):0] <= '0;
               cntxt.vif.wdata [(cfg.data_bus_width  -1):0] <= '0;
               cntxt.vif.wstrb [(cfg.strobe_bus_width-1):0] <= '0;
            end
            
            UVMA_AXIL_DRV_IDLE_RANDOM: begin
               cntxt.vif.araddr[(cfg.addr_bus_width  -1):0] <= $urandom();
               cntxt.vif.wdata [(cfg.data_bus_width  -1):0] <= $urandom();
               cntxt.vif.wstrb [(cfg.strobe_bus_width-1):0] <= $urandom();
            end
            
            UVMA_AXIL_DRV_IDLE_X: begin
               cntxt.vif.araddr[(cfg.addr_bus_width  -1):0] <= 'X;
               cntxt.vif.wdata [(cfg.data_bus_width  -1):0] <= 'X;
               cntxt.vif.wstrb [(cfg.strobe_bus_width-1):0] <= 'X;
            end
            
            UVMA_AXIL_DRV_IDLE_Z: begin
               cntxt.vif.araddr[(cfg.addr_bus_width  -1):0] <= 'Z;
               cntxt.vif.wdata [(cfg.data_bus_width  -1):0] <= 'Z;
               cntxt.vif.wstrb [(cfg.strobe_bus_width-1):0] <= 'Z;
            end
            
            default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_idle: %0d", cfg.drv_idle))
         endcase
      end
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid access_type: %0d", access_type))
   endcase
   
endtask : drv_mstr_idle


task uvma_axil_drv_c::drv_slv_idle(uvma_axil_access_type_enum access_type);
   
   case (access_type)
      UVMA_AXIL_ACCESS_READ: begin
         cntxt.vif.arready <= '0;
         cntxt.vif.rvalid  <= '0;
         
         case (cfg.drv_idle)
            UVMA_AXIL_DRV_IDLE_SAME: // Do nothing;
            
            UVMA_AXIL_DRV_IDLE_ZEROS: begin
               cntxt.vif.rdata[(cfg.data_bus_width-1):0] <= '0;
               cntxt.vif.rresp <= '0;
            end
            
            UVMA_AXIL_DRV_IDLE_RANDOM: begin
               cntxt.vif.rdata[(cfg.data_bus_width-1):0] <= $urandom();
               cntxt.vif.rresp <= $urandom();
            end
            
            UVMA_AXIL_DRV_IDLE_X: begin
               cntxt.vif.rdata[(cfg.data_bus_width-1):0] <= 'X;
               cntxt.vif.rresp <= 'X;
            end
            
            UVMA_AXIL_DRV_IDLE_Z: begin
               cntxt.vif.rdata[(cfg.data_bus_width-1):0] <= 'Z;
               cntxt.vif.rresp <= 'Z;
            end
            
            default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_idle: %0d", cfg.drv_idle))
         endcase
      end
      
      UVMA_AXIL_ACCESS_WRITE: begin
         cntxt.vif.awready <= '0;
         cntxt.vif.wready  <= '0;
         cntxt.vif.bvalid  <= '0;
         
         case (cfg.drv_idle)
            UVMA_AXIL_DRV_IDLE_SAME  : ;// Do nothing;
            UVMA_AXIL_DRV_IDLE_ZEROS : cntxt.vif.bresp <= '0;
            UVMA_AXIL_DRV_IDLE_RANDOM: cntxt.vif.bresp <= $urandom();
            UVMA_AXIL_DRV_IDLE_X     : cntxt.vif.bresp <= 'X;
            UVMA_AXIL_DRV_IDLE_Z     : cntxt.vif.bresp <= 'Z;
            
            default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid drv_idle: %0d", cfg.drv_idle))
         endcase
      end
      
      default: `uvm_fatal("AXIL_DRV", $sformatf("Invalid access_type: %0d", access_type))
   endcase
   
endtask : drv_slv_idle


`endif // __UVMA_AXIL_DRV_SV__
