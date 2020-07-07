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


`ifndef __UVMA_APB_TDEFS_SV__
`define __UVMA_APB_TDEFS_SV__


typedef enum {
   UVMA_APB_MODE_MASTER,
   UVMA_APB_MODE_SLAVE
} uvma_apb_mode_enum;

typedef enum {
   UVMA_APB_RESET_STATE_PRE_RESET ,
   UVMA_APB_RESET_STATE_IN_RESET  ,
   UVMA_APB_RESET_STATE_POST_RESET
} uvma_apb_reset_state_enum;

typedef enum {
   UVMA_APB_DRV_IDLE_SAME  ,
   UVMA_APB_DRV_IDLE_ZEROS ,
   UVMA_APB_DRV_IDLE_RANDOM,
   UVMA_APB_DRV_IDLE_X     ,
   UVMA_APB_DRV_IDLE_Z
} uvma_apb_drv_idle_enum;


typedef enum bit {
   UVMA_APB_ACCESS_READ  = 0,
   UVMA_APB_ACCESS_WRITE = 1
} uvma_apb_access_type_enum;


`endif // __UVMA_APB_TDEFS_SV__
