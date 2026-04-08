
class ahb_incr4_write_test extends iot_test_base;
  `uvm_component_utils(ahb_incr4_write_test)

  //iot_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);
    ahb_incr4_write_seq master_seq;
    phase.raise_objection(this);
    
#40000;

    // 2. Start the Master Sequence (The actual test scenario)
    master_seq = ahb_incr4_write_seq::type_id::create("master_seq");
    master_seq.start(env.master_agent_spi.sequencer);

    // Allow a little time for final response to complete
    #100;
    phase.drop_objection(this);
  endtask

endclass

