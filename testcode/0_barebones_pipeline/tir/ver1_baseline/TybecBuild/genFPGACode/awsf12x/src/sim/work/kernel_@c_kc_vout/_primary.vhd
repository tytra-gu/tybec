library verilog;
use verilog.vl_types.all;
entity kernel_C_kc_vout is
    generic(
        STREAMW         : integer := 32
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        iready          : out    vl_logic;
        ivalid          : in     vl_logic;
        ovalid          : out    vl_logic;
        oready          : in     vl_logic;
        out1_s0         : out    vl_logic_vector;
        in1_s0          : in     vl_logic_vector;
        in2_s0          : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STREAMW : constant is 1;
end kernel_C_kc_vout;
