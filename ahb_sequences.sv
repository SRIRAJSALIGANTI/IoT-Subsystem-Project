`ifndef AHB_SEQUENCES_SV
`define AHB_SEQUENCES_SV 

// ---------------------------------------------------------
// 1. Base Sequence
// ---------------------------------------------------------
class ahb_base_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(ahb_base_seq)

  function new(string name = "ahb_base_seq");
    super.new(name);
  endfunction
endclass

// ---------------------------------------------------------
// 2. Single Write Sequence
// ---------------------------------------------------------
class ahb_single_write_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_single_write_seq)

  function new(string name = "ahb_single_write_seq");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;
    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    // Edit values here to control the transaction
    if (!req.randomize() with {
          // --- User Controls ---
          addr == 32'h00040000;  // Set your Address
          data == 32'hAABBCCDD;  // Set your Data

          // --- Protocol Rules ---
          write == 1;  // Write
          size == 3'b010;  // Word
          burst == 3'b000;  // SINGLE
          trans == 2'b10;  // NONSEQ
        })
      `uvm_error("SEQ", "Randomization failed");

    finish_item(req);
    `uvm_info("SEQ", $sformatf("Single Write: Addr=0x%h Data=0x%h", req.addr, req.data), UVM_MEDIUM)
  endtask
endclass

// ---------------------------------------------------------
// 3. Single read Sequence
// ---------------------------------------------------------
class ahb_single_read_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_single_read_seq)

  function new(string name = "ahb_single_read_seq");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;
    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    // Edit values here to control the transaction
    if (!req.randomize() with {
          // --- User Controls ---
          addr == 32'h00040000;  // Set your Address
          // --- Protocol Rules ---
          write == 0;  // Write
          size == 3'b010;  // Word
          burst == 3'b000;  // SINGLE
          trans == 2'b10;  // NONSEQ
        })
      `uvm_error("SEQ", "Randomization failed");

    finish_item(req);
    `uvm_info("SEQ", $sformatf("Single read: Addr=0x%h ", req.addr), UVM_MEDIUM)
  endtask
endclass

// ---------------------------------------------------------
// 4. incr4 burst write Sequence
// ---------------------------------------------------------
class ahb_incr4_write_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_incr4_write_seq)

  bit[31:0] start_addr;

  function new(string name = "ahb_incr4_write_seq");
    super.new(name);
  start_addr = 32'h00040000;  // Set your Address
  endfunction

  task body();
    ahb_seq_item req;

    for (int i=0; i<4; i++) begin 

    req = ahb_seq_item::type_id::create("req");

    start_item(req);


    // Edit values here to control the transaction
    if (!req.randomize() with {
          // --- User Controls ---
          addr == start_addr + (i*4);  // Set your Address
          // --- Protocol Rules ---
          write == 1;  // Write
          size == 3'b010;  // Word (4)
          burst == 3'b011;  // incr4
	  if(i==0)
            trans == 2'b10;
          else
            trans == 2'b11;
        
        })
      `uvm_error("SEQ", "Randomization failed");
    finish_item(req);
    `uvm_info("SEQ", $sformatf("Burst Write:Tranfer=%0d Addr=0x%h Data=0x%h", i, req.addr, req.data), UVM_MEDIUM)
    end
  endtask
endclass

// ---------------------------------------------------------
// 4. incr4 burst read Sequence
// ---------------------------------------------------------
class ahb_incr4_read_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_incr4_read_seq)

  bit[31:0] start_addr;

  function new(string name = "ahb_incr4_read_seq");
    super.new(name);
  start_addr = 32'h00040000;  // Set your Address
  endfunction

  task body();
    ahb_seq_item req;

    for (int i=0; i<4; i++) begin 

    req = ahb_seq_item::type_id::create("req");

    start_item(req);


    // Edit values here to control the transaction
    if (!req.randomize() with {
          // --- User Controls ---
          addr == start_addr + (i*4);  // Set your Address
          // --- Protocol Rules ---
          write == 0;  // Write
          size == 3'b010;  // Word (4)
          burst == 3'b011;  // incr4
	  if(i==0)
            trans == 2'b10;
          else
            trans == 2'b11;
        
        })
      `uvm_error("SEQ", "Randomization failed");
    finish_item(req);
    `uvm_info("SEQ", $sformatf("Burst read:Tranfer=%0d Addr=0x%h", i, req.addr), UVM_MEDIUM)
    end
  endtask
endclass


`endif
