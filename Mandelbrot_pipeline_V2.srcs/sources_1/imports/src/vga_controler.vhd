-------------------------------------------------------------------------------
-- Title       : VGA Controler
-- Project     : HDMI Interface
-------------------------------------------------------------------------------
-- File        : vga_controler.vhd
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
-- 08.02.20188   0.0     SCJ      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity vga_controler is

    generic (
        C_DATA_SIZE  : integer     := 16;
        C_VGA_CONFIG : t_VgaConfig := C_DEFAULT_VGACONFIG);

    port (
        ClkVgaxC     : in  std_logic;   -- Clock = 51.2 MHz
        RstxRAN      : in  std_logic;
        PllLockedxSI : in  std_logic;
        VgaSyncxSO   : out t_VgaSync;
        HCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VidOnxSO     : out std_logic);

end entity vga_controler;

architecture behavioural of vga_controler is

    signal VgaConfigxD : t_VgaConfig                                  := C_VGA_CONFIG;
    signal VgaSyncxS   : t_VgaSync                                    := C_SET_VGASYNC;
    signal HCountxD    : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VCountxD    : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VidOnxS     : std_logic                                    := '0';

    -- Debug signals

    -- signal DebugHSyncxS : std_logic := '0';
    -- signal DebugVSyncxS : std_logic := '0';

    -- attribute mark_debug                 : string;
    -- attribute mark_debug of HCountxD     : signal is "true";
    -- attribute mark_debug of VCountxD     : signal is "true";
    -- attribute mark_debug of VidOnxS      : signal is "true";
    -- attribute mark_debug of DebugHSyncxS : signal is "true";
    -- attribute mark_debug of DebugVSyncxS : signal is "true";

    -- attribute keep                 : string;
    -- attribute keep of HCountxD     : signal is "true";
    -- attribute keep of VCountxD     : signal is "true";
    -- attribute keep of VidOnxS      : signal is "true";
    -- attribute keep of DebugHSyncxS : signal is "true";
    -- attribute keep of DebugVSyncxS : signal is "true";

begin  -- architecture behavioural

    -- Asynchronous statements
    VgaSigOutxB : block is
    begin  -- block VgaSigOutxB
        HSyncxAS  : VgaSyncxSO.HSyncxS <= VgaSyncxS.HSyncxS;
        VSyncxAS  : VgaSyncxSO.VSyncxS <= VgaSyncxS.VSyncxS;
        HCountxAS : HCountxDO          <= HCountxD;
        VCountxAS : VCountxDO          <= VCountxD;
        VidOnxAS  : VidOnxSO           <= VidOnxS;
    end block VgaSigOutxB;

    -- DebugSigxB : block is
    -- begin  -- block DebugSigxB
    --     DebugHSyncxAS : DebugHSyncxS <= VgaSyncxS.HSyncxS;
    --     DebugVSyncxAS : DebugVSyncxS <= VgaSyncxS.VSyncxS;
    -- end block DebugSigxB;

    -- Synchronous statements

    -- purpose: HCount and VCount process
    -- type   : combinational
    -- inputs : all
    -- outputs: 
    HVCountxP : process (all) is
    begin  -- process HVCountxP
        if RstxRAN = '0' or PllLockedxSI = '0' then
            VgaSyncxS.HSyncxS <= '0';
            VgaSyncxS.VSyncxS <= '0';
            VidOnxS           <= '0';
            HCountxD          <= std_logic_vector(to_unsigned(0, C_DATA_SIZE));
            VCountxD          <= std_logic_vector(to_unsigned(0, C_DATA_SIZE));
        elsif rising_edge(ClkVgaxC) then
            HCountxD          <= HCountxD;
            VCountxD          <= VCountxD;
            VidOnxS           <= VidOnxS;
            VgaSyncxS.HSyncxS <= VgaSyncxS.HSyncxS;
            VgaSyncxS.VSyncxS <= VgaSyncxS.VSyncxS;

            -- Set/reset VidOnxS
            if unsigned(HCountxD) = (VgaConfigxD.HActivexD - 1) then
                VidOnxS <= '0';
            elsif (unsigned(HCountxD) = (VgaConfigxD.HLenxD - 1)) and
                ((unsigned(VCountxD) < (VgaConfigxD.VActivexD - 1)) or
                 (unsigned(VCountxD) = (VgaConfigxD.VLenxD - 1))) then
                VidOnxS <= '1';
            end if;

            -- Set/reset HSyncxS
            if unsigned(HCountxD) = (VgaConfigxD.HActivexD + VgaConfigxD.HFrontPorchxD - 1) then
                VgaSyncxS.HSyncxS <= '1';
            elsif unsigned(HCountxD) = (VgaConfigxD.HActivexD + VgaConfigxD.HFrontPorchxD +
                                        VgaConfigxD.HSyncLenxD - 1) then
                VgaSyncxS.HSyncxS <= '0';
            end if;

            -- Reset HCountxD or increment HCountxD
            if unsigned(HCountxD) = (VgaConfigxD.HLenxD - 1) then
                HCountxD <= std_logic_vector(to_unsigned(0, C_DATA_SIZE));

                -- Set/reset VSyncxS
                if unsigned(VCountxD) = (VgaConfigxD.VActivexD + VgaConfigxD.VBackPorchxD - 1) then
                    VgaSyncxS.VSyncxS <= '1';
                elsif unsigned(VCountxD) = (VgaConfigxD.VActivexD + VgaConfigxD.VBackPorchxD +
                                            VgaConfigxD.VSyncLenxD - 1) then
                    VgaSyncxS.VSyncxS <= '0';
                end if;

                -- Reset VCountxD or increment VCountxD
                if unsigned(VCountxD) = (VgaConfigxD.VLenxD - 1) then
                    VCountxD <= std_logic_vector(to_unsigned(0, C_DATA_SIZE));
                else
                    VCountxD <= std_logic_vector(unsigned(VCountxD) + 1);
                end if;
            else
                HCountxD <= std_logic_vector(unsigned(HCountxD) + 1);
            end if;
        end if;
    end process HVCountxP;

end architecture behavioural;
