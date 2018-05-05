-------------------------------------------------------------------------------
-- Title       : mandelbrot_calculator_tb
-- Project     : MSE Mandelbrot
-------------------------------------------------------------------------------
-- File        : mandelbrot_calculator_tb.vhd
-- Authors     : Vivien Kaltenrieder
-- Company     : HES-SO
-- Created     : 28.05.2018
-- Last update : 28.05.2018
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: simulation stimulis for mandelbrot_calculator
-------------------------------------------------------------------------------
-- Copyright (c) 2018 HES-SO, Lausanne
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 28.03.2018   0.0      VKR      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity mandelbrot_calculator_tb is
generic (
    comma       : integer := 12; 
    max_iter    : integer := 100;
    SIZE        : integer := 16;
    ITER_SIZE   : integer := 7;
    X_ADD_SIZE  : integer := 10;
    Y_ADD_SIZE  : integer := 10);
end mandelbrot_calculator_tb;

architecture testbench of mandelbrot_calculator_tb is

  -- Input/output of the DUV
  signal clk_sti          : std_logic;
  signal rst_sti          : std_logic;
  signal ready_obs        : std_logic;
  signal start_sti        : std_logic;
  signal finished_obs     : std_logic;
  signal c_real_sti       : std_logic_vector(SIZE-1 downto 0);
  signal c_imaginary_sti  : std_logic_vector(SIZE-1 downto 0);
  signal z_real_obs       : std_logic_vector(SIZE-1 downto 0);
  signal z_imaginary_obs  : std_logic_vector(SIZE-1 downto 0);
  signal iterations_obs   : std_logic_vector(ITER_SIZE-1 downto 0);
  
  -- Singaux vides
  signal x_sti           : std_logic_vector(X_ADD_SIZE-1 downto 0);
  signal y_sti           : std_logic_vector(Y_ADD_SIZE-1 downto 0);
  signal x_obs           : std_logic_vector(X_ADD_SIZE-1 downto 0);
  signal y_obs           : std_logic_vector(Y_ADD_SIZE-1 downto 0);

  -- Internal singals
  signal sim_end_s : boolean := false; -- put true to end

  component mandelbrot_calculator is
  generic (
 
      comma       : integer := 12; 
      max_iter    : integer := 100;
      SIZE        : integer := 16;
      ITER_SIZE   : integer := 7;
      X_ADD_SIZE  : integer := 10;
      Y_ADD_SIZE  : integer := 10);

    port(
      clk_i         : in std_logic;
      rst_i         : in std_logic;
      ready_o       : out std_logic;
      start_i       : in std_logic;
      finished_o    : out std_logic;
      c_real_i      : in std_logic_vector(SIZE-1 downto 0);
      c_imaginary_i : in std_logic_vector(SIZE-1 downto 0);
      z_real_o      : out std_logic_vector(SIZE-1 downto 0);
      z_imaginary_o : out std_logic_vector(SIZE-1 downto 0);
      iterations_o  : out std_logic_vector(ITER_SIZE-1 downto 0);
      x_o           : out std_logic_vector(X_ADD_SIZE-1 downto 0);
      y_o           : out std_logic_vector(Y_ADD_SIZE-1 downto 0);
      x_i           : in std_logic_vector(X_ADD_SIZE-1 downto 0);
      y_i           : in std_logic_vector(Y_ADD_SIZE-1 downto 0)
    );
  end component;

begin
  duv : mandelbrot_calculator
  generic map (
    comma       => comma,
    max_iter    => max_iter,
    SIZE        => SIZE,
    ITER_SIZE   => ITER_SIZE,
    X_ADD_SIZE  => X_ADD_SIZE,
    Y_ADD_SIZE  => Y_ADD_SIZE
  )
  port map (
    clk_i         => clk_sti,
    rst_i         => rst_sti,
    ready_o       => ready_obs,
    start_i       => start_sti,
    finished_o    => finished_obs,
    c_real_i      => c_real_sti,
    c_imaginary_i => c_imaginary_sti,
    z_real_o      => z_real_obs,
    z_imaginary_o => z_imaginary_obs,
    iterations_o  => iterations_obs,
    x_i           => x_sti,
    y_i           => y_sti,
    x_o           => x_obs,
    y_o           => y_obs);

  ----------------------------------------------
  -----------  stimulus_proc           ---------
  ----------------------------------------------
  stimulus_proc : process is
  begin
    -- begin with a reset 20 ns
    start_sti <= '0';
    rst_sti <= '1';
    wait for 10 ns;

    -- Set the input values ---- should stop at 5
    c_real_sti <= "0000" & "100000000000";       -- 0.5  --> ~3.153320
    c_imaginary_sti <= "0000" & "000000000000";  -- 0    --> 0

    -- End of the reset
    wait for 20 ns;
    rst_sti <= '0';

    -- Start signal
    wait for 10 ns;
    start_sti <= '1';
    wait for 2 ns;
    start_sti <= '0';

    -- Let the process calcul the output (random value)
    wait for 400 ns;


    -- Set new input values ---- should stop at 29
    c_real_sti <= "0000" & "011000010100";      -- 0.3798828125     --> ~0.6
    c_imaginary_sti <= "0000" & "001100110011"; -- 0.199951171875   --> ~2.039

    -- Start signal
    start_sti <= '1';
    wait for 2 ns;
    start_sti <= '0';

    -- Let the process calcul the output (random value)
    wait for 300 ns;

    -- Say to the clock that he should stop
    sim_end_s <= true;

    wait; -- Stop the process
  end process; --stimulus_proc


  ----------------------------------------------
  ----------  clock_proc               ---------
  ----------------------------------------------
  clock_proc : process
  begin
    while sim_end_s = false loop
      clk_sti <= '1';
      wait for 1 ns;
      clk_sti <= '0';
    wait for 1 ns;
    end loop;
    wait; -- Stop the process
  end process; --clock_proc

end testbench;
