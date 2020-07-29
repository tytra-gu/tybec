library verilog;
use verilog.vl_types.all;
entity krnl_vadd_rtl_counter is
    generic(
        C_WIDTH         : integer := 4;
        C_INIT          : vl_logic_vector
    );
    port(
        clk             : in     vl_logic;
        clken           : in     vl_logic;
        rst             : in     vl_logic;
        load            : in     vl_logic;
        incr            : in     vl_logic;
        decr            : in     vl_logic;
        load_value      : in     vl_logic_vector;
        count           : out    vl_logic_vector;
        is_zero         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_INIT : constant is 4;
end krnl_vadd_rtl_counter;
