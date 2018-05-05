----------------------------------------------------------------------------------
-- hepia / LPSCP / Pr. F. Vannel
--
-- Generateur de nombres complexes a fournir au calculateur de Mandelbrot
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity ComplexValueGenerator is
generic
  (SIZE        : integer :=  16;  -- Taille en bits de nombre au format virgule fixe
   COMMA       : integer :=  12;  -- Nombre de bits après la virgule
   X_SIZE      : integer := 300;  -- Taille en X (Nombre de pixel) de la fractale à afficher
   Y_SIZE      : integer := 200;  -- Taille en Y (Nombre de pixel) de la fractale à afficher
   SCREEN_RES  : integer := 10    -- Nombre de bit pour les vecteurs X et Y de la position du pixel
  );   
port
  (clk         : in  std_logic;
   reset       : in  std_logic;
   -- interface avec le module MandelbrotMiddleware
   next_value  : in  std_logic;
   c_real      : out std_logic_vector (SIZE-1 downto 0);
   c_imaginary : out std_logic_vector (SIZE-1 downto 0);
   X_screen    : out std_logic_vector (SCREEN_RES-1 downto 0);
   Y_screen    : out std_logic_vector (SCREEN_RES-1 downto 0)
   );
end ComplexValueGenerator;


architecture Behavioral of ComplexValueGenerator is


  -- signaux internes
  signal c_re_i, c_im_i           : std_logic_vector (SIZE-1 downto 0);
  signal c_re_min, c_im_min       : std_logic_vector (SIZE-1 downto 0);
  signal posx_i, posy_i           : std_logic_vector (SCREEN_RES-1 downto 0);

  
  -- constantes
  
  signal c_bot_left_RE : integer := -2;
  signal c_bot_left_IM : integer := -1;
  signal comma_padding : std_logic_vector (comma-1 downto 0) := (others=>'0');
  signal c_inc         : std_logic_vector (SIZE-1 downto 0);

begin

  -- fixe la valeur des signaux utilitaires ----------------------------------
  c_re_min <= conv_std_logic_vector(c_bot_left_RE, (SIZE-COMMA)) & comma_padding; -- -2.0 fixed point arithmetic
  c_im_min <= conv_std_logic_vector(c_bot_left_IM, (SIZE-COMMA)) & comma_padding; -- -1.0 fixed point arithmetic
  c_inc    <= "0000000000001100"; -- valeur virgule fixe selon regles 

  -- processus combinatoire --------------------------------------------------
  process (clk, reset)
  begin   
    if (reset = '1') then 
       c_re_i <= c_re_min;
       c_im_i <= c_im_min;
       posx_i <= (others => '0');
       posy_i <= (others => '0');
       
    elsif rising_edge(clk) then
    
      if next_value = '1' then

        -- balayage de l'espace complexe 
        c_re_i <= c_re_i   + c_inc;
        posx_i <= posx_i + 1;

        -- fin de ligne
        if posx_i = X_SIZE-1 then
          c_re_i  <= c_re_min;
          c_im_i  <= c_im_i + c_inc;
          posy_i  <= posy_i + 1;
          posx_i <= (others => '0');
          -- fin d'ecran
          if posy_i = Y_SIZE-1 then
            c_im_i <= c_im_min;
            posy_i <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;



  -- sorties pour le module calculateur de Mandelbrot ----------------------
  c_real      <= c_re_i;
  c_imaginary <= c_im_i;
  X_screen    <= posx_i;
  Y_screen    <= posy_i;

end Behavioral;

