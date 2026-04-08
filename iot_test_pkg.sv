// TEST Package

package iot_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "../env/iot_env.sv"
  `include "../sequences/ahb_sequences.sv"
  `include "iot_test_base.sv"

  //AHB Tests
  `include "ahb_tests/ahb_single_write_test.sv"
  `include "ahb_tests/ahb_single_read_test.sv"
  `include "ahb_tests/ahb_incr4_write_test.sv"
  `include "ahb_tests/ahb_incr4_read_test.sv"

endpackage

