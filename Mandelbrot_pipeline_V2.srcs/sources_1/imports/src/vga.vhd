-------------------------------------------------------------------------------
-- Title       : VGA Top Level
-- Project     : HDMI Interface
-------------------------------------------------------------------------------
-- File        : vga.vhd
-- Authors     : Joachim Schmidt
-- Company     : Hepia
-- Created     : 08.02.2018
-- Last update : 08.02.2018
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 Hepia, Geneve
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-02-08  0.0      SCJ       Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity vga is

    generic (
        C_DATA_SIZE  : integer     := 16;
        C_PIXEL_SIZE : integer     := 8;
        C_VGA_CONFIG : t_VgaConfig := C_DEFAULT_VGACONFIG);

    port (
        ClkVgaxC     : in  std_logic;
        RstxR        : in  std_logic;
        PllLockedxSI : in  std_logic;
        VidOnxSO     : out std_logic;
        DataxDI      : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
        HCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VgaxDO       : out t_Vga);

end entity vga;

architecture rtl of vga is

    component vga_controler is
        generic (
            C_DATA_SIZE  : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            ClkVgaxC     : in  std_logic;
            RstxRAN      : in  std_logic;
            PllLockedxSI : in  std_logic;
            VgaSyncxSO   : out t_VgaSync;
            HCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSO     : out std_logic);
    end component vga_controler;

    component vga_stripes is
        generic (
            C_DATA_SIZE  : integer;
            C_PIXEL_SIZE : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            HCountxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSI    : in  std_logic;
            DataxDI     : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            VgaPixelxDO : out t_VgaPixel;
            HCountxDO   : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO   : out std_logic_vector((C_DATA_SIZE - 1) downto 0));
    end component vga_stripes;

    signal RstxRN              : std_logic                                    := '1';
    signal VgaxD               : t_Vga                                        := C_NO_VGA;
    signal HCountCtrl2StripxD  : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VCountCtrl2StripxD  : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal HCountStrip2ImGenxD : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VCountStrip2ImGenxD : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VidOnxS             : std_logic                                    := '0';

    -- Debug signals

    -- signal DebugRedxD   : std_logic_vector((C_PIXEL_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugGreenxD : std_logic_vector((C_PIXEL_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugBluexD  : std_logic_vector((C_PIXEL_SIZE - 1) downto 0) := (others => '0');

    -- attribute mark_debug                 : string;
    -- attribute mark_debug of DebugRedxD   : signal is "true";
    -- attribute mark_debug of DebugGreenxD : signal is "true";
    -- attribute mark_debug of DebugBluexD  : signal is "true";

    -- attribute keep                 : string;
    -- attribute keep of DebugRedxD   : signal is "true";
    -- attribute keep of DebugGreenxD : signal is "true";
    -- attribute keep of DebugBluexD  : signal is "true";

begin  -- architecture rtl

    -- Asynchronous statements

    VgaSigOutxB : block is
    begin  -- block VgaSigOutxB
        VgaxAS    : VgaxDO    <= VgaxD;
        VidOnxAS  : VidOnxSO  <= VidOnxS;
        HCountxAS : HCountxDO <= HCountStrip2ImGenxD;
        VCountxAS : VCountxDO <= VCountCtrl2StripxD;
    end block VgaSigOutxB;

    RstxAS : RstxRN <= not RstxR;

    -- DebugSigxB : block is
    -- begin  -- block DebugSigxB
    --     DebugRedxAS   : DebugRedxD   <= VgaxD.VgaPixelxD.RedxD;
    --     DebugGreenxAS : DebugGreenxD <= VgaxD.VgaPixelxD.GreenxD;
    --     DebugBluexAS  : DebugBluexD  <= VgaxD.VgaPixelxD.BluexD;
    -- end block DebugSigxB;

    VgaStripesxI : entity work.vga_stripes
        generic map (
            C_DATA_SIZE  => C_DATA_SIZE,
            C_PIXEL_SIZE => C_PIXEL_SIZE,
            C_VGA_CONFIG => C_VGA_CONFIG)
        port map (
            HCountxDI   => HCountCtrl2StripxD,
            VCountxDI   => VCountCtrl2StripxD,
            VidOnxSI    => VidOnxS,
            DataxDI     => DataxDI,
            VgaPixelxDO => VgaxD.VgaPixelxD,
            HCountxDO   => HCountStrip2ImGenxD,
            VCountxDO   => VCountStrip2ImGenxD);

    -- Synchronous statements

    VgaControlerxI : entity work.vga_controler
        generic map (
            C_DATA_SIZE  => C_DATA_SIZE,
            C_VGA_CONFIG => C_VGA_CONFIG)
        port map (
            ClkVgaxC     => ClkVgaxC,
            RstxRAN      => RstxRN,
            PllLockedxSI => PllLockedxSI,
            VgaSyncxSO   => VgaxD.VgaSyncxS,
            HCountxDO    => HCountCtrl2StripxD,
            VCountxDO    => VCountCtrl2StripxD,
            VidOnxSO     => VidOnxS);

end architecture rtl;
