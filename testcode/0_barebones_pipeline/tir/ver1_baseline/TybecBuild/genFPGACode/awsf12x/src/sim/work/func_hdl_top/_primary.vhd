library verilog;
use verilog.vl_types.all;
entity func_hdl_top is
    generic(
        C_DATA_WIDTH    : integer := 512;
        C_NUM_CHANNELS  : integer := 2
    );
    port(
        aclk            : in     vl_logic;
        areset          : in     vl_logic;
        s_tvalid        : in     vl_logic_vector;
        s_tdata         : in     vl_logic_vector;
        s_tready        : out    vl_logic_vector;
        m_tvalid        : out    vl_logic;
        m_tdata         : out    vl_logic_vector;
        m_tready        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_NUM_CHANNELS : constant is 2;
end func_hdl_top;
