-------------------------------------------------------------------------------
-- Title       : HDMI Top Level
-- Project     : HDMI Interface
-------------------------------------------------------------------------------
-- File        : hdmi.vhd
-- Authors     : Joachim Schmidt
-- Company     : Hepia
-- Created     : 13.02.2018
-- Last update : 13.02.2018
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 Hepia, Geneve
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 13.02.2018   0.0      SCJ      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.hdmi_interface_pkg.all;

entity hdmi is

    generic (
        C_CHANNEL_NUMBER : integer     := 4;
        C_DATA_SIZE      : integer     := 16;
        C_PIXEL_SIZE     : integer     := 8;
        C_VGA_CONFIG     : t_VgaConfig := C_DEFAULT_VGACONFIG;
        C_RESOLUTION     : string      := "1024x768");

    port (
        ClkSys100MhzxC : in    std_logic;
        RstxR          : in    std_logic;
        -- Image generator
        PllLockedxSO   : out   std_logic;
        ClkVgaxCO      : out   std_logic;
        HCountxDO      : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDO      : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VidOnxSO       : out   std_logic;
        DataxDI        : in    std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
        -- HDMI
        HdmiTxRsclxSO  : out   std_logic;
        HdmiTxRsdaxSIO : inout std_logic;
        HdmiTxHpdxSI   : in    std_logic;
        HdmiTxCecxSIO  : inout std_logic;
        HdmiTxClkPxSO  : out   std_logic;
        HdmiTxClkNxSO  : out   std_logic;
        HdmiTxPxDO     : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
        HdmiTxNxDO     : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));

end entity hdmi;

architecture behavioural of hdmi is

    component clk_vga_hdmi_640x480
        port (
            ClkVgaxC       : out std_logic;
            ClkHdmixC      : out std_logic;
            reset          : in  std_logic;
            PllLockedxSO   : out std_logic;
            ClkSys100MhzxC : in  std_logic);
    end component;

    -- component clk_vga_640x480
    --     port(
    --         ClkVgaxC       : out std_logic;
    --         reset          : in  std_logic;
    --         PllLockedxSO   : out std_logic;
    --         ClkSys100MhzxC : in  std_logic);
    -- end component;

    -- component clk_hdmi_640x480
    --     port(
    --         ClkHdmixC      : out std_logic;
    --         reset          : in  std_logic;
    --         PllLockedxSO   : out std_logic;
    --         ClkSys100MhzxC : in  std_logic);
    -- end component;

    component clk_vga_hdmi_800x600
        port(
            ClkVgaxC       : out std_logic;
            ClkHdmixC      : out std_logic;
            reset          : in  std_logic;
            PllLockedxSO   : out std_logic;
            ClkSys100MhzxC : in  std_logic);
    end component;

    -- component clk_vga_1024x600
    --     port(
    --         ClkVgaxC       : out std_logic;
    --         reset          : in  std_logic;
    --         PllLockedxSO   : out std_logic;
    --         ClkSys100MhzxC : in  std_logic);
    -- end component;

    -- component clk_hdmi_1024x600
    --     port(
    --         ClkHdmixC      : out std_logic;
    --         reset          : in  std_logic;
    --         PllLockedxSO   : out std_logic;
    --         ClkSys100MhzxC : in  std_logic);
    -- end component;

    component clk_vga_hdmi_1024x600
        port(
            ClkVgaxC       : out std_logic;
            ClkHdmixC      : out std_logic;
            reset          : in  std_logic;
            PllLockedxSO   : out std_logic;
            ClkSys100MhzxC : in  std_logic);
    end component;

    component clk_vga_hdmi_1024x768
        port(
            ClkVgaxC       : out std_logic;
            ClkHdmixC      : out std_logic;
            reset          : in  std_logic;
            PllLockedxSO   : out std_logic;
            ClkSys100MhzxC : in  std_logic);
    end component;

    component vga is
        generic (
            C_DATA_SIZE  : integer;
            C_PIXEL_SIZE : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            ClkVgaxC     : in  std_logic;
            RstxR        : in  std_logic;
            PllLockedxSI : in  std_logic;
            VidOnxSO     : out std_logic;
            DataxDI      : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            HCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VgaxDO       : out t_Vga);
    end component vga;

    component vga_to_hdmi is
        generic (
            C_PIXEL_SIZE     : integer;
            C_CHANNEL_NUMBER : integer);
        port (
            ClkVgaxC       : in    std_logic;
            ClkHdmixC      : in    std_logic;
            RstxR          : in    std_logic;
            VgaxDI         : in    t_Vga;
            VidOnxSI       : in    std_logic;
            HdmiSourcexDIO : inout t_HdmiSource);
    end component vga_to_hdmi;

    signal ClkVgaxC       : std_logic                                           := '0';
    signal ClkHdmixC      : std_logic                                           := '0';
    -- signal ClkVgaBufGxC  : std_logic    := '0';
    -- signal ClkHdmiBufGxC : std_logic    := '0';
    signal PllLockedxS    : std_logic                                           := '0';
    signal VidOnxS        : std_logic                                           := '0';
    signal VgaxD          : t_Vga                                               := C_NO_VGA;
    signal HdmiSourcexD   : t_HdmiSource                                        := C_NO_HDMI_SOURCE;
    signal HdmiTxHpdxS    : std_logic                                           := '0';
    signal RstPllLockedxS : std_logic                                           := '0';
    signal DataxD         : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0) := (others => '0');
    signal HCountxD       : std_logic_vector((C_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal VCountxD       : std_logic_vector((C_DATA_SIZE - 1) downto 0)        := (others => '0');

begin  -- architecture behavioural

    -- Asynchronous statements

    assert ((C_VGA_CONFIG = C_640x480_VGACONFIG) and (C_RESOLUTION = "640x480"))
        or ((C_VGA_CONFIG = C_800x600_VGACONFIG) and (C_RESOLUTION = "800x600"))
        or ((C_VGA_CONFIG = C_1024x600_VGACONFIG) and (C_RESOLUTION = "1024x600"))
        or ((C_VGA_CONFIG = C_1024x768_VGACONFIG) and (C_RESOLUTION = "1024x768"))
        report "Not supported resolution!" severity failure;

    HdmiSourceOutxB : block is
    begin  -- block HdmiSourceOutxB
        HdmiTxRsclxAS : HdmiTxRsclxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS;
        HdmiTxRsdaxAS : HdmiTxRsdaxSIO                          <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS;
        HdmiTxHpdxAS  : HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS <= HdmiTxHpdxSI;
        HdmiTxCecxAS  : HdmiTxCecxSIO                           <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS;
        HdmiTxClkPxAS : HdmiTxClkPxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS;
        HdmiTxClkNxAS : HdmiTxClkNxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS;
        HdmiTxPxAS    : HdmiTxPxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD;
        HdmiTxNxAS    : HdmiTxNxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD;
    end block HdmiSourceOutxB;

    RstxB : block is
    begin  -- block RstxB
        RstPllLockedxAS : RstPllLockedxS <= not PllLockedxS;
    end block RstxB;

    ImageGenInOutxB : block is
    begin  -- block ImageGenInOutxB
        PllLockedxAS : PllLockedxSO <= PllLockedxS;
        ClkVgaxAS    : ClkVgaxCO    <= ClkVgaxC;
        HCountxAS    : HCountxDO    <= HCountxD;
        VCountxAS    : VCountxDO    <= VCountxD;
        VidOnxAS     : VidOnxSO     <= VidOnxS;
        DataxAS      : DataxD       <= DataxDI;
    end block ImageGenInOutxB;

    -- Synchronous statements

    -- Resolution 640x480
    -- ClkVgaxC  : 25.175  [MHz]
    -- ClkHdmixC : 125.875 [MHz]
    --
    -- Resolution 800x600
    -- ClkVgaxC  : 40      [MHz]
    -- ClkHdmixC : 200     [MHz]
    --
    -- Resolution 1024x600
    -- ClkVgaxC  : 51.2    [MHz]
    -- ClkHdmixC : 256     [MHz]
    --
    -- Resolution 1024x768
    -- ClkVgaxC  : 65      [MHz]
    -- ClkHdmixC : 325     [MHz]

    ClkVgaHdmi640x480xG : if C_RESOLUTION = "640x480" generate

        -- signal PllVgaLockedxS    : std_logic := '0';
        -- signal PllHdmiLockedxS   : std_logic := '0';
        -- signal ClkSysToClkVgaxS  : std_logic := '0';
        -- signal ClkSysToClkHdmixS : std_logic := '0';
        signal ClkSys100MhzBufgxC : std_logic := '0';

    begin

        BUFGClkSysToClkVgaHdmixI : BUFG
            port map (
                O => ClkSys100MhzBufgxC,  -- 1-bit output: Clock output.
                I => ClkSys100MhzxC);     -- 1-bit input: Clock input,

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkVgaxC____25.179______0.000______50.0______228.282____150.123
        -- ClkHdmixC___125.893______0.000______50.0______160.495____150.123
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        ClkVgaHdmi640x480xI : clk_vga_hdmi_640x480
            port map (
                ClkVgaxC       => ClkVgaxC,
                ClkHdmixC      => ClkHdmixC,
                reset          => RstxR,
                PllLockedxSO   => PllLockedxS,
                ClkSys100MhzxC => ClkSys100MhzBufgxC);

        -- PllLockedxAS : PllLockedxS <= PllVgaLockedxS and PllHdmiLockedxS;

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkVgaxC____25.173______0.000______50.0______319.783____246.739
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        -- ClkVga640x480xI : clk_vga_640x480
        --     port map (
        --         ClkVgaxC       => ClkVgaxC,
        --         reset          => RstxR,
        --         PllLockedxSO   => PllVgaLockedxS,
        --         ClkSys100MhzxC => ClkSysToClkVgaxS);

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkHdmixC___125.876______0.000______50.0______345.414____498.481
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        -- ClkHdmi640x480xI : clk_hdmi_640x480
        --     port map (
        --         ClkHdmixC      => ClkHdmixC,
        --         reset          => RstxR,
        --         PllLockedxSO   => PllHdmiLockedxS,
        --         ClkSys100MhzxC => ClkSysToClkHdmixS);

        -- BUFRClkSysToClkVgaxI : BUFR
        --     generic map (
        --         BUFR_DIVIDE => "BYPASS",
        --         SIM_DEVICE  => "7SERIES")
        --     port map (
        --         O   => ClkSysToClkVgaxS,  -- 1-bit output: Clock output
        --         CE  => '1',
        --         CLR => '0',
        --         I   => ClkSys100MhzxC);   -- 1-bit input: Clock input

        -- BUFGClkSysToClkHdmixI : BUFG
        --     port map (
        --         O => ClkSysToClkHdmixS,  -- 1-bit output: Clock output
        --         I => ClkSys100MhzxC);    -- 1-bit input: Clock input

    end generate ClkVgaHdmi640x480xG;

    ClkVgaHdmi800x600xG : if C_RESOLUTION = "800x600" generate

        signal ClkSys100MhzBufgxC : std_logic := '0';

    begin

        BUFGClkSysToClkVgaHdmixI : BUFG
            port map (
                O => ClkSys100MhzBufgxC,  -- 1-bit output: Clock output.
                I => ClkSys100MhzxC);     -- 1-bit input: Clock input,

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkVgaxC____40.000______0.000______50.0______159.371_____98.575
        -- ClkHdmixC___200.000______0.000______50.0______114.829_____98.575
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        ClkVgaHdmi800x600xI : clk_vga_hdmi_800x600
            port map (
                ClkVgaxC       => ClkVgaxC,
                ClkHdmixC      => ClkHdmixC,
                reset          => RstxR,
                PllLockedxSO   => PllLockedxS,
                ClkSys100MhzxC => ClkSys100MhzBufgxC);

    end generate ClkVgaHdmi800x600xG;

    ClkVgaHdmi1024x600xG : if C_RESOLUTION = "1024x600" generate

        -- signal PllVgaLockedxS    : std_logic := '0';
        -- signal PllHdmiLockedxS   : std_logic := '0';
        -- signal ClkSysToClkVgaxS  : std_logic := '0';
        -- signal ClkSysToClkHdmixS : std_logic := '0';
        signal ClkSys100MhzBufgxC : std_logic := '0';

    begin

        BUFGClkSysToClkVgaHdmixI : BUFG
            port map (
                O => ClkSys100MhzBufgxC,  -- 1-bit output: Clock output.
                I => ClkSys100MhzxC);     -- 1-bit input: Clock input,

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkVgaxC____51.250______0.000______50.0______147.936_____96.739
        -- ClkHdmixC___256.250______0.000______50.0______107.731_____96.739
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        ClkVgaHdmi1024x600xI : clk_vga_hdmi_1024x600
            port map (
                ClkVgaxC       => ClkVgaxC,
                ClkHdmixC      => ClkHdmixC,
                reset          => RstxR,
                PllLockedxSO   => PllLockedxS,
                ClkSys100MhzxC => ClkSys100MhzBufgxC);

        -- PllLockedxAS : PllLockedxS <= PllVgaLockedxS and PllHdmiLockedxS;

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkVgaxC____51.200______0.000______50.0______278.312____301.601
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        -- ClkVga1024x600xI : clk_vga_1024x600
        --     port map (
        --         ClkVgaxC       => ClkVgaxC,
        --         reset          => RstxR,
        --         PllLockedxSO   => PllVgaLockedxS,
        --         ClkSys100MhzxC => ClkSysToClkVgaxS);

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkHdmixC___256.000______0.000______50.0______220.657____301.601
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        -- ClkHdmi1024x600xI : clk_hdmi_1024x600
        --     port map (
        --         ClkHdmixC      => ClkHdmixC,
        --         reset          => RstxR,
        --         PllLockedxSO   => PllHdmiLockedxS,
        --         ClkSys100MhzxC => ClkSysToClkHdmixS);

        -- BUFRClkSysToClkVgaxI : BUFR
        --     generic map (
        --         BUFR_DIVIDE => "BYPASS",
        --         SIM_DEVICE  => "7SERIES")
        --     port map (
        --         O   => ClkSysToClkVgaxS,  -- 1-bit output: Clock output
        --         CE  => '1',
        --         CLR => '0',
        --         I   => ClkSys100MhzxC);   -- 1-bit input: Clock input

        -- BUFGClkSysToClkHdmixI : BUFG
        --     port map (
        --         O => ClkSysToClkHdmixS,  -- 1-bit output: Clock output
        --         I => ClkSys100MhzxC);    -- 1-bit input: Clock input

    end generate ClkVgaHdmi1024x600xG;

    ClkVgaHdmi1024x768xG : if C_RESOLUTION = "1024x768" generate

        signal ClkSys100MhzBufgxC : std_logic := '0';

    begin

        BUFGClkSysToClkVgaHdmixI : BUFG
            port map (
                O => ClkSys100MhzBufgxC,  -- 1-bit output: Clock output.
                I => ClkSys100MhzxC);     -- 1-bit input: Clock input,

        ------------------------------------------------------------------------------
        --  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
        --   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
        ------------------------------------------------------------------------------
        -- ClkVgaxC____65.000______0.000______50.0______142.278_____99.281
        -- ClkHdmixC___325.000______0.000______50.0______104.357_____99.281
        --
        ------------------------------------------------------------------------------
        -- Input Clock   Freq (MHz)    Input Jitter (UI)
        ------------------------------------------------------------------------------
        -- __primary_________100.000____________0.010

        ClkVgaHdmi1024x768xI : clk_vga_hdmi_1024x768
            port map (
                ClkVgaxC       => ClkVgaxC,
                ClkHdmixC      => ClkHdmixC,
                reset          => RstxR,
                PllLockedxSO   => PllLockedxS,
                ClkSys100MhzxC => ClkSys100MhzBufgxC);

    end generate ClkVgaHdmi1024x768xG;

    -- BUFGClkVgaxI : BUFG
    --     port map (
    --         O => ClkVgaBufGxC,          -- 1-bit output: Clock output
    --         I => ClkVgaxC);             -- 1-bit input: Clock input

    -- BUFGClkHdmixI : BUFG
    --     port map (
    --         O => ClkHdmiBufGxC,         -- 1-bit output: Clock output
    --         I => ClkHdmixC);            -- 1-bit input: Clock input

    VgaxI : entity work.vga
        generic map (
            C_DATA_SIZE  => C_DATA_SIZE,
            C_PIXEL_SIZE => C_PIXEL_SIZE,
            C_VGA_CONFIG => C_VGA_CONFIG)
        port map (
            ClkVgaxC     => ClkVgaxC,
            RstxR        => RstPllLockedxS,
            PllLockedxSI => PllLockedxS,
            VidOnxSO     => VidOnxS,
            DataxDI      => DataxD,
            HCountxDO    => HCountxD,
            VCountxDO    => VCountxD,
            VgaxDO       => VgaxD);

    VgaToHdmixI : entity work.vga_to_hdmi
        generic map (
            C_PIXEL_SIZE     => C_PIXEL_SIZE,
            C_CHANNEL_NUMBER => C_CHANNEL_NUMBER)
        port map (
            ClkVgaxC       => ClkVgaxC,
            ClkHdmixC      => ClkHdmixC,
            RstxR          => RstPllLockedxS,
            VgaxDI         => VgaxD,
            VidOnxSI       => VidOnxS,
            HdmiSourcexDIO => HdmiSourcexD);

end architecture behavioural;
