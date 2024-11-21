
`define WIDTH 4
`define IMEM_SIZE 16
`define INST_INC 4'b0000
`define INST_ACC 4'b0001

`define STAGE_LEN 2
`define STAGE_FETCH    2'h0
`define STAGE_EXECUTE1 2'h1
`define STAGE_EXECUTE0 2'h2
`define STAGE_COMMIT   2'h3


module control (
                input [`WIDTH-1:0]      inst,
                input [`STAGE_LEN-1:0]  stage,
                output [`STAGE_LEN-1:0] next_stage
);

  // FSM for stage update
  case (stage)
    `STAGE_FETCH:
       case (inst)
         `INST_INC: assign next_stage = `STAGE_EXECUTE0;
         `INST_ACC: assign next_stage = `STAGE_EXECUTE1;
         default:   assign next_stage = `STAGE_COMMIT;
       endcase // case (inst)

    `STAGE_EXECUTE1:
      assign next_stage = `STAGE_EXECUTE0;

    `STAGE_EXECUTE0:
      assign next_stage = `STAGE_COMMIT;

    `STAGE_COMMIT:
      assign next_stage = `STAGE_FETCH;
  endcase
endmodule

module tiny_cpu (
  input clk,
  input rst,

  output commit,

  // These outputs just avoid yosys optimize away registers
  output [`WIDTH-1:0] pc,
  output [`WIDTH-1:0] R1,
  output [`WIDTH-1:0] R2
);
  // STEP: microarchitectural state
  reg [`STAGE_LEN-1:0] stage;
  wire [`STAGE_LEN-1:0] next_stage;

  // STEP: update pc
  reg [`WIDTH-1:0] pc;
  always @(posedge clk)
    if (rst) pc <= 0;
    else     pc <= (stage==`STAGE_COMMIT)? pc + 1 : pc;


  // STEP: read instruction
  reg [`WIDTH-1:0] imem [`IMEM_SIZE-1:0];
  always @(posedge clk)
    if (rst) begin
      integer i;
      for (i=0; i<`IMEM_SIZE; i=i+1) imem[i] <= 0;
    end
  wire [`WIDTH-1:0] inst = imem[pc];

  // control logic
  control ctrl(inst, stage, next_stage);

  // STEP: execute the instruction
  reg [`WIDTH-1:0] R1, R2;
  always @(posedge clk)
    if (rst) begin
      stage <= `STAGE_FETCH;
      R1 <= 0;
      R2 <= 0;
    end else begin
      if (stage == `STAGE_COMMIT) begin
         // TODO: split this out to actually use EXECUTE 0 & 1 stages
         case (inst)
           `INST_INC: R1 <= R1 + 1;
           `INST_ACC: R2 <= R2 + R1;
         endcase
      end
      stage <= next_stage;
    end


  // STEP: generate commit output
  assign commit = stage==`STAGE_COMMIT;

endmodule

module top
(
  a_i,
  b_i,
  s_o,
  c_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] s_o;
  output c_o;

  bsg_adder_ripple_carry
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .s_o(s_o),
    .c_o(c_o)
  );


endmodule

module bsg_adder_ripple_carry
(
  a_i,
  b_i,
  s_o,
  c_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] s_o;
  output c_o;
  wire [15:0] s_o;
  wire c_o;
  assign { c_o, s_o } = a_i + b_i;

endmodule

