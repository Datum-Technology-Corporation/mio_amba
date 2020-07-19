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
// License for the specific language governing permissions and limitations
// under the License.
// 


`ifndef __UVMA_APB_REG_ADAPTER_SV__
`define __UVMA_APB_REG_ADAPTER_SV__


/**
 * Object that converts between abstract register operations (UVM) and
 * Advanced Peripheral Bus operations.
 */
class uvma_apb_reg_adapter_c extends uvm_reg_adapter;
   
   `uvm_object_utils(uvma_apb_reg_adapter_c)
   
   
   /**
    * Default constructor
    */
   extern function new(string name="uvma_apb_reg_adapter");
   
   /**
    * Converts from UVM register operation to Advanced Peripheral Bus.
    */
   extern virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
   
   /**
    * Converts from Advanced Peripheral Bus to UVM register operation.
    */
   extern virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
   
endclass : uvma_apb_reg_adapter_c


function uvma_apb_reg_adapter_c::new(string name="uvma_apb_reg_adapter");
   
   super.new(name);
   
endfunction : new


function uvm_sequence_item uvma_apb_reg_adapter_c::reg2bus(const ref uvm_reg_bus_op rw);
   
   uvma_apb_seq_item_c  apb_trn = uvma_apb_seq_item_c::type_id::create("apb_trn");
   
   apb_trn.access_type = (rw.kind == UVM_READ) ? UVMA_APB_ACCESS_READ : UVMA_APB_ACCESS_WRITE;
   apb_trn.address     = rw.addr;
   apb_trn.data        = rw.data;
   
   return apb_trn;
   
endfunction : reg2bus


function void uvma_apb_reg_adapter_c::bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
   
   uvma_apb_seq_item_c  apb_trn;
   
   if (!$cast(apb_trn, bus_item)) begin
      `uvm_fatal("APB", $sformatf("Could not cast bus_item (%s) into apb_trn (%s)", $typename(bus_item), $typename(apb_trn)))
   end
   
   // TODO Implement uvma_apb_reg_adapter_c::bus2reg()
   //      Ex: rw.kind   = (apb_trn.access == UVMA_APB_ACCESS_READ) ? UVM_READ : UVM_WRITE;
   //          rw.addr   = apb_trn.addr;
   //          rw.data   = apb_trn.data;
   //          rw.status = UVM_IS_OK;
   
endfunction : bus2reg


`endif // __UVMA_APB_REG_ADAPTER_SV__
