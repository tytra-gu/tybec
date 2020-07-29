library verilog;
use verilog.vl_types.all;
entity krnl_vadd_rtl_axi_write_master is
    generic(
        C_ADDR_WIDTH    : integer := 64;
        C_DATA_WIDTH    : integer := 32;
        C_MAX_LENGTH_WIDTH: integer := 32;
        C_BURST_LEN     : integer := 256;
        C_LOG_BURST_LEN : integer := 8
    );
    port(
        ctrl_start      : in     vl_logic;
        ctrl_offset     : in     vl_logic_vector;
        ctrl_length     : in     vl_logic_vector;
        ctrl_done       : out    vl_logic;
        s_tvalid        : in     vl_logic;
        s_tdata         : in     vl_logic_vector;
        s_tready        : out    vl_logic;
        aclk            : in     vl_logic;
        areset          : in     vl_logic;
        awaddr          : out    vl_logic_vector;
        awlen           : out    vl_logic_vector(7 downto 0);
        awsize          : out    vl_logic_vector(2 downto 0);
        awvalid         : out    vl_logic;
        awready         : in     vl_logic;
        wdata           : out    vl_logic_vector;
        wstrb           : out    vl_logic_vector;
        wlast           : out    vl_logic;
        wvalid          : out    vl_logic;
        wready          : in     vl_logic;
        bresp           : in     vl_logic_vector(1 downto 0);
        bvalid          : in     vl_logic;
        bready          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_ADDR_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_MAX_LENGTH_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_BURST_LEN : constant is 2;
    attribute mti_svvh_generic_type of C_LOG_BURST_LEN : constant is 2;
end krnl_vadd_rtl_axi_write_master;
