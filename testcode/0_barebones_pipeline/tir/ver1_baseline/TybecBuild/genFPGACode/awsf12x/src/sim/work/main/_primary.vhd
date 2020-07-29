library verilog;
use verilog.vl_types.all;
entity main is
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
        vin1_stream_load: in     vl_logic_vector;
        vout_stream_store: out    vl_logic_vector;
        vin0_stream_load: in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STREAMW : constant is 1;
end main;