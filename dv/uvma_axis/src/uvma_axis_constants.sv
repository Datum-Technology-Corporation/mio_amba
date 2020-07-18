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


`ifndef __UVMA_AXIS_CONSTANTS_SV__
`define __UVMA_AXIS_CONSTANTS_SV__


const int unsigned  uvma_axis_default_data_bus_width  = 256; // Measured in bytes (B)
const int unsigned  uvma_axis_default_tid_width       =   8; // Measured in bits  (b)
const int unsigned  uvma_axis_default_tdest_width     =   4; // Measured in bits  (b)
const int unsigned  uvma_axis_default_tuser_width     = 256; // Measured in bits  (b)

const int unsigned  uvma_axis_max_payload_size  = 32_768; // Measured in bytes (B)
const int unsigned  uvma_axis_min_payload_size  =      8; // Measured in bytes (B)

const int unsigned  uvma_axis_logging_num_data_bytes                       =   8; // Number of bytes logged at start and end of payload by transaction loggers
const int unsigned  uvma_axis_cycle_throttle_seq_default_pct_bus_usage     =  90;
const int unsigned  uvma_axis_mstr_rand_traffic_seq_default_num_pkts       = 100;
const int unsigned  uvma_axis_mstr_rand_traffic_seq_default_pct_bus_usage  = 100;


`endif // __UVMA_AXIS_CONSTANTS_SV__
