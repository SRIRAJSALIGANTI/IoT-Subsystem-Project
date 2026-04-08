// ahb_master_driver.sv
`ifndef AHB_MASTER_DRIVER_SV
`define AHB_MASTER_DRIVER_SV 


class ahb_master_driver extends uvm_driver #(ahb_seq_item);
  `uvm_component_utils(ahb_master_driver)

  virtual ahb_if.MASTER vif;

  // Pipeline Register Structure (Internal)
  typedef struct {
    bit          valid;
    logic [31:0] addr;
    logic [31:0] data;
    bit          write;
  } pipeline_reg_t;

  // Internal Synchronization variables (from your original code)
  local bit             req_pending;
  local logic    [31:0] req_addr;
  local logic    [31:0] req_data;
  local bit             req_write;
  local bit       [1:0] req_trans;
  local bit       [2:0] req_size;
  local bit       [2:0] req_burst;

  pipeline_reg_t        pipe_stage;

  event                 addr_phase_accepted;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    this.req_pending = 0;
    this.pipe_stage.valid = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ahb_if.MASTER)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction

  task run_phase(uvm_phase phase);
    // Fork the Reset, the Sequencer Pump, and the Pipeline Engine
    fork
      handle_reset();
      get_and_drive();  // Fetches from Sequencer
      pipeline_engine();  // Your original run() logic
    join
  endtask

  // -------------------------------------------------------
  // 1. Sequencer Fetching Logic
  // -------------------------------------------------------
  task get_and_drive();
    forever begin
      //       @ (negedge vif.hresetn); // Wait for reset release
      wait (!vif.hresetn);
      req_pending <= 0;
      pipe_stage.valid <= 0;

      // Wait for reset to release
      wait (vif.hresetn);

      forever begin
        seq_item_port.get_next_item(req);

        // Pass transaction info to internal registers
        req_addr    <= req.addr;
        req_data    <= req.data;
        req_write   <= req.write;
	req_trans   <= req.trans;
	req_size    <= req.size;
	req_burst   <= req.burst;
        req_pending <= 1;
        //`uvm_info("AHB_M_DRV",$sformatf("REQ_ADDR=%0h, REQ_DATA=%0h, REQ_WR=%0h, REQ.ADDR=%0h, REQ.DATA=%0h, REQ.WRITE=%0h", req_addr, req_data, req_write, req.addr, req.data, req.write),UVM_MEDIUM)

        // Wait for pipeline engine to accept the Address Phase
        @(addr_phase_accepted);

        req_pending <= 0;

        // We finish the item here (Address Phase Done). 
        // This allows Pipelining: The sequencer can send the next Address 
        // while the Driver Engine handles the Data Phase of this one.
        seq_item_port.item_done();
      end
    end
  endtask

  // -------------------------------------------------------
  // 2. Pipeline Engine (Adapted from your run logic)
  // -------------------------------------------------------
  task pipeline_engine();
    forever begin
      @(posedge vif.hclk);

      if (!vif.hresetn) continue;

      // HREADY CHECK
      if (vif.HREADY) begin

        // --- DATA PHASE (Previous Item) ---
        if (pipe_stage.valid) begin
          if (pipe_stage.write) begin
            vif.HWDATA <= pipe_stage.data;
            `uvm_info("AHB_M_DRV", $sformatf("Pipe_stage_data=%0h, vif.hwdata=%0h",
                                             pipe_stage.data, vif.HWDATA), UVM_HIGH)
          end else begin
            vif.HWDATA <= 32'hDEAD_DEAD;
            // Optionally capture HRDATA here if we want to send response back
          end
        end else begin
          `uvm_info("AHB_M_DRV", $sformatf("STAGE.VALID = %0b", pipe_stage.valid), UVM_HIGH)
          vif.HWDATA <= 32'hDEAD_BEEF;
        end

        // --- ADDRESS PHASE (New Item) ---
        if (req_pending) begin
          `uvm_info("AHB_M_DRV", "Req Pending -- 1", UVM_HIGH)
          vif.HADDR  <= req_addr;
          vif.HWRITE <= req_write;
          vif.HTRANS <= req_trans;  // NONSEQ
          vif.HSIZE  <= req_size;
          vif.HBURST <= req_burst;
          vif.HSEL   <= 1'b1;
          `uvm_info("AHB_M_DRV", $sformatf("REQ_ADDR=%0h, REQ_WR=%0h, VIF.HADDR=%0h, VIF.HWR=%0h",
                                           req_addr, req_write, vif.HADDR, vif.HWRITE), UVM_MEDIUM)

          // Update Pipeline Stage
          pipe_stage.valid <= 1;
          `uvm_info("AHB_M_DRV", "MADE STAGE VALID -- 1", UVM_HIGH)
          pipe_stage.addr  <= req_addr;
          pipe_stage.data  <= req_data;
          pipe_stage.write <= req_write;

          // Handshake back to get_and_drive task
          ->addr_phase_accepted;
        end else begin
       //   `uvm_info("AHB_M_DRV", "Req Pending -- 0", UVM_MEDIUM)
          // IDLE
          vif.HTRANS <= 2'b00;
          vif.HADDR  <= 32'h0;
          vif.HWRITE <= 0;
          @(posedge vif.hclk) pipe_stage.valid <= 0;
        end

      end else begin
        // STALL: Do nothing, hold signals
        `uvm_info("DRV", "Stalled by HREADY=0", UVM_LOW)
      end
    end
  endtask

  // -------------------------------------------------------
  // 3. Reset Handling
  // -------------------------------------------------------
  task handle_reset();
    forever begin
      wait (!vif.hresetn);
      vif.HADDR        <= 32'h0;
      vif.HWDATA       <= 0;
      vif.HWRITE       <= 0;
      vif.HTRANS       <= 0;
      vif.HSIZE        <= 0;
      vif.HBURST       <= 0;
      pipe_stage.valid <= 0;
      req_pending      <= 0;
      wait (vif.hresetn);
    end
  endtask

endclass

`endif
