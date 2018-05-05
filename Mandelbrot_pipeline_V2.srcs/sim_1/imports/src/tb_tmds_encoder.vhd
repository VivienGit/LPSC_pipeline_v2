-------------------------------------------------------------------------------
-- Title       : TMDS Encoder Testbench
-- Project     : HDMI Interface
-------------------------------------------------------------------------------
-- File        : tb_tmds_encoder.vhd
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
-- 13.02.2018    0.0     SCJ      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity tb_tmds_encoder is

end entity tb_tmds_encoder;

architecture testbench of tb_tmds_encoder is

    constant C_TMDS_DATA_SIZE         : integer := 8;
    constant C_TMDS_ENCODED_DATA_SIZE : integer := 10;
    constant C_CLOCK_PERIOD           : time    := 10 ns;

    component tmds_encoder is
        generic (
            C_TMDS_DATA_SIZE         : integer;
            C_TMDS_ENCODED_DATA_SIZE : integer);
        port (
            ClkxC              : in  std_logic;
            TmdsDataxDI        : in  std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0);
            ControlxDI         : in  std_logic_vector(1 downto 0);
            VidOnxSI           : in  std_logic;
            TmdsEncodedDataxDO : out std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0));
    end component tmds_encoder;

    signal ClkxC             : std_logic                                         := '1';
    signal TmdsDataxD        : std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0) := (others => '0');
    signal ControlxD         : std_logic_vector(1 downto 0)                      := (others => '0');
    signal VidOnxS           : std_logic                                         := '0';
    signal TmdsEncodedDataxD : std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0);

    -- component TMDS_encoder1 is
    --     port (
    --         clk     : in  std_logic;
    --         data    : in  std_logic_vector (7 downto 0);
    --         c       : in  std_logic_vector (1 downto 0);
    --         blank   : in  std_logic;
    --         encoded : out std_logic_vector (9 downto 0));
    -- end component TMDS_encoder1;

    -- signal BlankxS   : std_logic := '0';
    -- signal EncodedxD : std_logic_vector (9 downto 0);

    constant C_TMDS_DATA_0 : std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0) := "10101010";
    constant C_TMDS_DATA_1 : std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0) := "11000011";
    constant C_TMDS_DATA_2 : std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0) := "10000100";
    constant C_TMDS_DATA_3 : std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0) := "11111011";

    -- Divers
    signal TmdsDataRandomxD : integer := 0;

begin  -- architecture testbench

    -- Asynchronous statements

    ClkxAS   : ClkxC   <= not ClkxC after (C_CLOCK_PERIOD / 2);
    -- BlankxAS : BlankxS <= not VidOnxS;

    -- Synchronous statements

    TmdsEncoder1xI : entity work.tmds_encoder
        generic map (
            C_TMDS_DATA_SIZE         => C_TMDS_DATA_SIZE,
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkxC              => ClkxC,
            TmdsDataxDI        => TmdsDataxD,
            ControlxDI         => ControlxD,
            VidOnxSI           => VidOnxS,
            TmdsEncodedDataxDO => TmdsEncodedDataxD);

    -- TmdsEncoder2xI : entity work.TMDS_encoder1
    --     port map (
    --         clk     => ClkxC,
    --         data    => TmdsDataxD,
    --         c       => ControlxD,
    --         blank   => BlankxS,
    --         encoded => EncodedxD);

    TmdsDataRandomGenxP : process is
        variable Seed1xV     : positive := 1;
        variable Seed2xV     : positive := 1;
        variable RandxV      : real     := 0.0;
        variable RangeOfRand : real     := 255.0;
    begin  -- process TmdsDataRandomGenxP
        uniform(Seed1xV, Seed2xV, RandxV);
        TmdsDataRandomxD <= integer(RandxV * RangeOfRand);
        wait for C_CLOCK_PERIOD;
    end process TmdsDataRandomGenxP;

    -- MonitorTmdsRandomxP : process is
    -- begin  -- process MonitorTmdsRandomxP
    --     report "uniform = " & to_string(TmdsDataRandomxD) severity note;
    -- end process MonitorTmdsRandomxP;

    CtrlTmdsEncoderxP : process is
    begin  -- process CtrlTmdsEncoderxP
        -- Not VidOnxS
        TmdsDataxD <= (others => '0');
        VidOnxS    <= '0';
        ControlxD  <= "00";
        wait for C_CLOCK_PERIOD;
        ControlxD  <= "01";
        wait for C_CLOCK_PERIOD;
        ControlxD  <= "10";
        wait for C_CLOCK_PERIOD;
        ControlxD  <= "11";
        wait for 10 * C_CLOCK_PERIOD;
        -- VidOnxS
        VidOnxS    <= '1';
        ControlxD  <= "00";

        for i in 0 to 100 loop
            TmdsDataxD <= std_logic_vector(to_unsigned(TmdsDataRandomxD, C_TMDS_DATA_SIZE));
            wait for C_CLOCK_PERIOD;
            -- assert TmdsEncodedDataxD = EncodedxD report "Assertion violation." severity error;
            -- wait for C_CLOCK_PERIOD;
        end loop;  -- i

        wait;
    end process CtrlTmdsEncoderxP;

end architecture testbench;
