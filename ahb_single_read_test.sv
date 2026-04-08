class ahb_single_read_test extends iot_test_base;
  `uvm_component_utils(ahb_single_read_test)

  //iot_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction




  task run_phase(uvm_phase phase);
    ahb_single_read_seq master_seq;
    ahb_single_write_seq master_seq1;
    phase.raise_objection(this);
    
#40000;

    // 2. Start the Master Sequence (The actual test scenario)
    master_seq = ahb_single_read_seq::type_id::create("master_seq");
    master_seq1 = ahb_single_write_seq::type_id::create("master_seq1");

    master_seq1.start(env.master_agent_spi.sequencer);
    #10;
    master_seq.start(env.master_agent_spi.sequencer);

    // Allow a little time for final response to complete
    #100;
    phase.drop_objection(this);
  endtask

endclass

