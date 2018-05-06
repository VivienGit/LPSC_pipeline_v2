-------------------------------------------------------------------------------
-- Title       : mandelbrot_calculator
-- Project     : MSE Mandelbrot
-------------------------------------------------------------------------------
-- File        : mandelbrot_calculator.vhd
-- Authors     : Vivien Kaltenrieder
-- Company     : HES-SO
-- Created     : 23.05.2018
-- Last update : 23.05.2018
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: mandelbrot_calculator
-------------------------------------------------------------------------------
-- Copyright (c) 2018 HES-SO, Lausanne
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 25.03.2018   0.0      VKR      Created
-- 02.03.2018   0.0      VKR      Sequential version
-- 07.03.2018   1.0      VKR      Combinatory version
-- 05.05.2018   2.0      VKR      Adding the buffer for the pipeline
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity mandelbrot_calculator is
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
      new_val_o     : out std_logic;
      finished_o    : out std_logic;
      start_i       : in std_logic;
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

end mandelbrot_calculator;

architecture Behavioral of mandelbrot_calculator is

-- Constante pour les tailles (multiplication etc)
  constant SIZE_BIG           : integer := 2*SIZE;
  constant SIZE_IN_BIG        : integer := comma+SIZE;
  constant COMMA_BIG          : integer := 2*comma;
  constant SIZE_RADIUS        : integer := 2*(SIZE-comma);
  constant EXTEND_COMMA       : std_logic_vector(comma-1 downto 0) := (others => '0');
  constant NB_PIPES           : integer := 3;

  -- For the pipeline -- L'indice pipe_coun d�finit qui est sur la sortie
  signal pipe_count_s         : integer := 0;           -- Pour savoir ou on est au niveau du pipeline

  type iterations_tab is array (NB_PIPES-1 downto 0) of std_logic_vector(ITER_SIZE-1 downto 0);
  signal iterations_s         : iterations_tab;
  
  type address_tab is array (NB_PIPES-1 downto 0) of std_logic_vector(X_ADD_SIZE-1 downto 0);
  signal x_address_s          : address_tab;
  signal y_address_s          : address_tab;
  
  type c_input_tab is array (NB_PIPES-1 downto 0) of std_logic_vector(SIZE-1 downto 0);
  signal c_real_s             : c_input_tab;
  signal c_imag_s             : c_input_tab;
  
  signal soft_reset_s         : boolean := false;
 
  signal x_o_s           : std_logic_vector(X_ADD_SIZE-1 downto 0);
  signal y_o_s           : std_logic_vector(Y_ADD_SIZE-1 downto 0);


  -- Stat machine states
  constant THREE_FREE_PIPES_STATE : std_logic_vector := "00";  -- Inital state
  constant TWO_FREE_PIPES_STATE   : std_logic_vector := "01";
  constant ONE_FREE_PIPE_STATE    : std_logic_vector := "10";
  constant PIPES_ARE_FULL_STATE   : std_logic_vector := "11";
  signal next_state_s, current_states : std_logic_vector (1 downto 0);

  -- Calculation signals
  signal one_is_finished_s    : boolean := false;
  signal z_real_s             : std_logic_vector(SIZE-1 downto 0);
  signal z_imag_s             : std_logic_vector(SIZE-1 downto 0);
  signal zn1_real_big_s       : std_logic_vector(SIZE_BIG-1 downto 0);
  signal zn1_imag_big_s       : std_logic_vector(SIZE_BIG-1 downto 0);

  signal z_real2_big_s        : std_logic_vector(SIZE_BIG-1 downto 0);
  signal zn1_real2_big_s      : std_logic_vector(SIZE_BIG-1 downto 0);    -- Le new c'est � gauche de la bascule !!!
  signal z_imag2_big_s        : std_logic_vector(SIZE_BIG-1 downto 0);
  signal zn1_imag2_big_s      : std_logic_vector(SIZE_BIG-1 downto 0);
  signal z_r2_i2_big_s        : std_logic_vector(SIZE_BIG-1 downto 0);
  signal zn1_r2_i2_big_s      : std_logic_vector(SIZE_BIG-1 downto 0);
  signal z_ri_big_s           : std_logic_vector(SIZE_BIG-1 downto 0);
  signal zn1_ri_big_s         : std_logic_vector(SIZE_BIG-1 downto 0);
  signal z_2ri_big_s          : std_logic_vector(SIZE_BIG-1 downto 0);
  signal zn1_2ri_big_s        : std_logic_vector(SIZE_BIG-1 downto 0);
--  signal zn1_real_new_s       : std_logic_vector(SIZE_BIG-1 downto 0);
--  signal zn1_imag_new_s       : std_logic_vector(SIZE_BIG-1 downto 0);

  signal radius_big_s         : std_logic_vector(SIZE_BIG downto 0);    -- No minus 1, we extend
  signal radius_s             : std_logic_vector(SIZE_RADIUS downto 0); -- same

begin
  -- The values will only be considere if finished is set
  z_real_o        <= z_real_s;
  z_imaginary_o   <= z_imag_s;
  
  -- Output address
  x_o     <= x_o_s;
  y_o     <= y_o_s;

  ----------------------------------------------
  --             calc_proc             ---------
  ----------------------------------------------
  calc_proc : process (z_real_s, z_imag_s, z_real2_big_s, z_imag2_big_s, radius_big_s, radius_s, z_r2_i2_big_s, z_2ri_big_s, c_imaginary_i, c_real_i)
  begin
    one_is_finished_s <= false;

    -- Calcul the squared of the input values
    zn1_real2_big_s   <= std_logic_vector(signed(z_real_s)*signed(z_real_s));
    zn1_imag2_big_s   <= std_logic_vector(signed(z_imag_s)*signed(z_imag_s));

    -- Calcul the radius to test if we need to stop
    radius_big_s    <= std_logic_vector(signed(z_real2_big_s(SIZE_BIG-1) & z_real2_big_s)+signed(z_imag2_big_s(SIZE_BIG-1) & z_imag2_big_s));
    radius_s        <= std_logic_vector(radius_big_s(SIZE_BIG downto COMMA_BIG));

    ----------------- Calcul the real part      --------------------
    -- Substraction of the squared inputs
    zn1_r2_i2_big_s   <= std_logic_vector(signed(z_real2_big_s)-signed(z_imag2_big_s));
    -- New value of the output (next value of the input)
    zn1_real_big_s  <= std_logic_vector(signed(std_logic_vector'(c_real_s(pipe_count_s) & EXTEND_COMMA)) + signed(z_r2_i2_big_s));

    ----------------- Calcul the imaginary part  --------------
    -- Multiplication of the two inputs and multiplication by 2
    zn1_ri_big_s    <= std_logic_vector(signed(z_real_s)*signed(z_imag_s));
    zn1_2ri_big_s   <= z_ri_big_s(SIZE_BIG-2 downto 0) & '0';
    -- New value of the output (next value of the input)
    zn1_imag_big_s  <= std_logic_vector(signed(std_logic_vector'(c_imag_s(pipe_count_s) & EXTEND_COMMA)) + signed(z_2ri_big_s));

    -- Condition to detect if the one before was the one to go out 
    if signed(radius_s) >= 4 AND unsigned(iterations_s(0)) >= max_iter then
        one_is_finished_s <= true;       
    end if;

  end process; -- calc_proc

    ----------------------------------------------
     --       Output Buffer and synch           --
    ----------------------------------------------
    buffer_proc : process (clk_i, rst_i, soft_reset_s, zn1_real_big_s, zn1_imag_big_s, zn1_real2_big_s,
                           zn1_imag2_big_s, zn1_r2_i2_big_s, zn1_ri_big_s, zn1_2ri_big_s)
    begin
        if (rst_i = '1') then
            iterations_s      <= (others => (others => '0')); -- Start the calculation
            z_real_s          <= (others => '0');
            z_imag_s          <= (others => '0');
            z_real2_big_s     <= (others => '0');
            z_imag2_big_s     <= (others => '0');
            z_r2_i2_big_s     <= (others => '0');
            z_ri_big_s        <= (others => '0');
            z_2ri_big_s       <= (others => '0');
            pipe_count_s      <= 0;
        elsif Rising_Edge(clk_i) then
            -- Incrementing the iterations
            if soft_reset_s then
                iterations_s(pipe_count_s) <= (others => '0');
                z_real_s          <= (others => '0');
                z_imag_s         <= (others => '0');
            else            
                if pipe_count_s = 0 then
                  iterations_s(0) <= std_logic_vector(unsigned(iterations_s(0)) + 1);
                elsif pipe_count_s = 1 then
                  iterations_s(1) <= std_logic_vector(unsigned(iterations_s(1)) + 1);
                else
                  iterations_s(2) <= std_logic_vector(unsigned(iterations_s(2)) + 1);
                end if;
            end if;

            z_real_s          <= zn1_real_big_s(SIZE_IN_BIG-1 downto comma);
            z_imag_s          <= zn1_imag_big_s(SIZE_IN_BIG-1 downto comma);
            z_real2_big_s     <= zn1_real2_big_s;
            z_imag2_big_s     <= zn1_imag2_big_s;
            z_r2_i2_big_s     <= zn1_r2_i2_big_s;
            z_ri_big_s        <= zn1_ri_big_s;
            z_2ri_big_s       <= zn1_2ri_big_s;
            
            -- The pipe is alays running
            if pipe_count_s >= 2 then
                pipe_count_s <= 0;
            else
                pipe_count_s <= pipe_count_s + 1;
            end if;
        end if;
    end process; -- buffer_proc

    ----------------------------------------------
    --           State machine                  --
    ----------------------------------------------
    state_machine : process (current_states, start_i)
    begin
        next_state_s <= THREE_FREE_PIPES_STATE;
        finished_o    <= '0';
        new_val_o     <= '0';
        soft_reset_s  <= false;
        x_o_s         <= (others => '0');
        y_o_s         <= (others => '0');

        -- State machine
        case current_states is
            when THREE_FREE_PIPES_STATE =>
              new_val_o <= '1';
              if start_i = '1' then
                  x_address_s(pipe_count_s) <= x_i;
                  y_address_s(pipe_count_s) <= y_i;
                  soft_reset_s    <= true;
                  next_state_s    <= TWO_FREE_PIPES_STATE;                                  
              else
                  next_state_s <= THREE_FREE_PIPES_STATE;
              end if;
            when TWO_FREE_PIPES_STATE  =>
                new_val_o <= '1';
                if start_i = '1' then
                    x_address_s(pipe_count_s) <= x_i;
                    y_address_s(pipe_count_s) <= y_i;
                    soft_reset_s   <= true;
                    next_state_s  <= ONE_FREE_PIPE_STATE;
                elsif one_is_finished_s then
                    x_o_s           <= x_address_s(pipe_count_s);
                    y_o_s           <= y_address_s(pipe_count_s);
                    finished_o    <= '1';
                    next_state_s  <= THREE_FREE_PIPES_STATE;
                else
                    next_state_s <= TWO_FREE_PIPES_STATE;
                end if;
            when ONE_FREE_PIPE_STATE  =>
                new_val_o <= '1';
                if start_i = '1' then
                    x_address_s(pipe_count_s) <= x_i;
                    y_address_s(pipe_count_s) <= y_i;
                    soft_reset_s   <= true;
                    next_state_s  <= PIPES_ARE_FULL_STATE;
                elsif one_is_finished_s then
                    x_o_s           <= x_address_s(pipe_count_s);
                    y_o_s           <= y_address_s(pipe_count_s);
                    finished_o    <= '1';
                    next_state_s  <= TWO_FREE_PIPES_STATE;
                else
                    next_state_s <= ONE_FREE_PIPE_STATE;
                end if;
            when PIPES_ARE_FULL_STATE  =>
                if one_is_finished_s then
                    x_o_s           <= x_address_s(pipe_count_s);
                    y_o_s           <= y_address_s(pipe_count_s);
                    finished_o    <= '1';
                    next_state_s  <= TWO_FREE_PIPES_STATE;
                else
                    next_state_s <= TWO_FREE_PIPES_STATE;
                end if;
            when others =>
              next_state_s <= THREE_FREE_PIPES_STATE;
        end case;

    end process; -- state_machine

    ----------------------------------------------
    --           synch state machine            --
    ----------------------------------------------
  	 synch_proc : process (clk_i, rst_i)
     begin
        if (rst_i = '1') then
          current_states <= THREE_FREE_PIPES_STATE;
        elsif Rising_Edge(clk_i) then
          current_states <= next_state_s;
        end if;
    end process; -- synch_proc

end Behavioral;
