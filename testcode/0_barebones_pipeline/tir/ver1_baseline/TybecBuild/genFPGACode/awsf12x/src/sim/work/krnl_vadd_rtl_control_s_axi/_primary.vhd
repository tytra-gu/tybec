library verilog;
use verilog.vl_types.all;
entity krnl_vadd_rtl_control_s_axi is
    generic(
        C_S_AXI_ADDR_WIDTH: integer := 6;
        C_S_AXI_DATA_WIDTH: integer := 32
    );
    port(
        ACLK            : in     vl_logic;
        ARESET          : in     vl_logic;
        ACLK_EN         : in     vl_logic;
        AWADDR          : in     vl_logic_vector;
        AWVALID         : in     vl_logic;
        AWREADY         : out    vl_logic;
        WDATA           : in     vl_logic_vector;
        WSTRB           : in     vl_logic_vector;
        WVALID          : in     vl_logic;
        WREADY          : out    vl_logic;
        BRESP           : out    vl_logic_vector(1 downto 0);
        BVALID          : out    vl_logic;
        BREADY          : in     vl_logic;
        ARADDR          : in     vl_logic_vector;
        ARVALID         : in     vl_logic;
        ARREADY         : out    vl_logic;
        RDATA           : out    vl_logic_vector;
        RRESP           : out    vl_logic_vector(1 downto 0);
        RVALID          : out    vl_logic;
        RREADY          : in     vl_logic;
        interrupt       : out    vl_logic;
        ap_start        : out    vl_logic;
        ap_done         : in     vl_logic;
        ap_ready        : in     vl_logic;
        ap_idle         : in     vl_logic;
        a               : out    vl_logic_vector(63 downto 0);
        b               : out    vl_logic_vector(63 downto 0);
        c               : out    vl_logic_vector(63 downto 0);
        length_r        : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_S_AXI_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_S_AXI_DATA_WIDTH : constant is 1;
end krnl_vadd_rtl_control_s_axi;
