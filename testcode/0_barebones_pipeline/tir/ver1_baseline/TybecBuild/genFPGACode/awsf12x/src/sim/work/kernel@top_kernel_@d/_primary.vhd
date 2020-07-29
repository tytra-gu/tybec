library verilog;
use verilog.vl_types.all;
entity kernelTop_kernel_D is
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
        kd_vin_s0       : in     vl_logic_vector;
        kd_vout_s0      : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STREAMW : constant is 1;
end kernelTop_kernel_D;
