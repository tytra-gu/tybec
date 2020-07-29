library verilog;
use verilog.vl_types.all;
entity krnl_vadd_rtl_axi_read_master is
    generic(
        C_ID_WIDTH      : integer := 1;
        C_ADDR_WIDTH    : integer := 64;
        C_DATA_WIDTH    : integer := 32;
        C_NUM_CHANNELS  : integer := 2;
        C_LENGTH_WIDTH  : integer := 32;
        C_BURST_LEN     : integer := 256;
        C_LOG_BURST_LEN : integer := 8;
        C_MAX_OUTSTANDING: integer := 3
    );
    port(
        aclk            : in     vl_logic;
        areset          : in     vl_logic;
        ctrl_start      : in     vl_logic;
        ctrl_done       : out    vl_logic;
        ctrl_offset     : in     vl_logic_vector;
        ctrl_length     : in     vl_logic_vector;
        ctrl_prog_full  : in     vl_logic_vector;
        arvalid         : out    vl_logic;
        arready         : in     vl_logic;
        araddr          : out    vl_logic_vector;
        arid            : out    vl_logic_vector;
        arlen           : out    vl_logic_vector(7 downto 0);
        arsize          : out    vl_logic_vector(2 downto 0);
        rvalid          : in     vl_logic;
        rready          : out    vl_logic;
        rdata           : in     vl_logic_vector;
        rlast           : in     vl_logic;
        rid             : in     vl_logic_vector;
        rresp           : in     vl_logic_vector(1 downto 0);
        m_tvalid        : out    vl_logic_vector;
        m_tready        : in     vl_logic_vector;
        m_tdata         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_ID_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_ADDR_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_NUM_CHANNELS : constant is 2;
    attribute mti_svvh_generic_type of C_LENGTH_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_BURST_LEN : constant is 2;
    attribute mti_svvh_generic_type of C_LOG_BURST_LEN : constant is 2;
    attribute mti_svvh_generic_type of C_MAX_OUTSTANDING : constant is 2;
end krnl_vadd_rtl_axi_read_master;
