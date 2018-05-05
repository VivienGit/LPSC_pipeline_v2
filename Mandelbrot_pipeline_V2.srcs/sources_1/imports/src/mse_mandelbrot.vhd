-------------------------------------------------------------------------------
-- Title       : MSE Mandelbrot Top Level
-- Project     : MSE Mandelbrot
-------------------------------------------------------------------------------
-- File        : mse_mandelbrot.vhd
-- Authors     : Joachim Schmidt
-- Company     : Hepia
-- Created     : 26.02.2018
-- Last update : 26.02.2018
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 Hepia, Geneve
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 26.02.2018   0.0      SCJ      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.hdmi_interface_pkg.all;

entity mse_mandelbrot is

    generic (
        C_CHANNEL_NUMBER : integer := 4);

    port (
        ClkSys100MhzxC : in    std_logic;
        RstxR          : in    std_logic;
        -- HDMI
        HdmiTxRsclxSO  : out   std_logic;
        HdmiTxRsdaxSIO : inout std_logic;
        HdmiTxHpdxSI   : in    std_logic;
        HdmiTxCecxSIO  : inout std_logic;
        HdmiTxClkPxSO  : out   std_logic;
        HdmiTxClkNxSO  : out   std_logic;
        HdmiTxPxDO     : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
        HdmiTxNxDO     : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));

end entity mse_mandelbrot;

architecture rtl of mse_mandelbrot is

    ---------------------------------------------------------------------------
    -- Resolution configuration
    ---------------------------------------------------------------------------
    -- Possible resolutions
    --
    -- 1024x768
    -- 1024x600
    -- 800x600
    -- 640x480

    -- constant C_VGA_CONFIG : t_VgaConfig := C_1024x768_VGACONFIG;
    constant C_VGA_CONFIG : t_VgaConfig := C_1024x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_800x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_640x480_VGACONFIG;

    -- constant C_RESOLUTION : string := "1024x768";
    constant C_RESOLUTION : string := "1024x600";
    -- constant C_RESOLUTION : string := "800x600";
    -- constant C_RESOLUTION : string := "640x480";
    -------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------

    constant C_DATA_SIZE                        : integer := 16;
    constant C_PIXEL_SIZE                       : integer := 8;
    constant C_COMMA                            : integer := 12;
    constant C_ITER_SIZE                        : integer := 7;
    constant C_MAX_ITER                         : integer := 100;
    constant C_X_SIZE                           : integer := 1024;
    constant C_Y_SIZE                           : integer := 600;
    constant C_SCREEN_RES                       : integer := 10;
    constant C_BRAM_VIDEO_MEMORY_ADDR_SIZE      : integer := 20;
    constant C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE : integer := 10;
    constant C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE  : integer := 10;
    constant C_BRAM_VIDEO_MEMORY_DATA_SIZE      : integer := 9;

    component hdmi is
        generic (
            C_CHANNEL_NUMBER : integer;
            C_DATA_SIZE      : integer;
            C_PIXEL_SIZE     : integer;
            C_VGA_CONFIG     : t_VgaConfig;
            C_RESOLUTION     : string);
        port (
            ClkSys100MhzxC : in    std_logic;
            RstxR          : in    std_logic;
            PllLockedxSO   : out   std_logic;
            ClkVgaxCO      : out   std_logic;
            HCountxDO      : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO      : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSO       : out   std_logic;
            DataxDI        : in    std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            HdmiTxRsclxSO  : out   std_logic;
            HdmiTxRsdaxSIO : inout std_logic;
            HdmiTxHpdxSI   : in    std_logic;
            HdmiTxCecxSIO  : inout std_logic;
            HdmiTxClkPxSO  : out   std_logic;
            HdmiTxClkNxSO  : out   std_logic;
            HdmiTxPxDO     : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
            HdmiTxNxDO     : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));
    end component hdmi;

    component image_generator is
        generic (
            C_DATA_SIZE  : integer;
            C_PIXEL_SIZE : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            ClkVgaxC     : in  std_logic;
            RstxRA       : in  std_logic;
            PllLockedxSI : in  std_logic;
            HCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSI     : in  std_logic;
            DataxDO      : out std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0));
    end component image_generator;
    
    component ComplexValueGenerator is
        generic
            (SIZE        : integer;  -- Taille en bits de nombre au format virgule fixe
             COMMA       : integer;  -- Nombre de bits aprÃ¨s la virgule
             X_SIZE      : integer;  -- Taille en X (Nombre de pixel) de la fractale Ã  afficher
             Y_SIZE      : integer;  -- Taille en Y (Nombre de pixel) de la fractale Ã  afficher
             SCREEN_RES  : integer);    -- Nombre de bit pour les vecteurs X et Y de la position du pixel
        port
            (clk         : in  std_logic;
             reset       : in  std_logic;
             -- interface avec le module MandelbrotMiddleware
             next_value  : in  std_logic;
             c_real      : out std_logic_vector (SIZE-1 downto 0);
             c_imaginary : out std_logic_vector (SIZE-1 downto 0);
             X_screen    : out std_logic_vector (SCREEN_RES-1 downto 0);
             Y_screen    : out std_logic_vector (SCREEN_RES-1 downto 0));
    end component ComplexValueGenerator;
    
    component mandelbrot_calculator is
        generic (
            comma       : integer; 
            max_iter    : integer;
            SIZE        : integer;
            ITER_SIZE   : integer;
            X_ADD_SIZE  : integer;
            Y_ADD_SIZE  : integer);
    
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
            y_i           : in std_logic_vector(Y_ADD_SIZE-1 downto 0));
    end component mandelbrot_calculator;
    
    COMPONENT blk_mem_bram
      PORT (
        clka              : IN STD_LOGIC;
        wea               : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra             : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
        dina              : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        douta             : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        clkb              : IN STD_LOGIC;
        web               : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb             : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
        dinb              : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        doutb             : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
      );
    END COMPONENT;

    -- Pll Locked
    signal PllLockedxS    : std_logic                                           := '0';
    signal RstPllLockedxS : std_logic                                           := '0';
    -- Clocks
    signal ClkVgaxC       : std_logic                                           := '0';
    -- VGA
    signal HCountxD       : std_logic_vector((C_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal VCountxD       : std_logic_vector((C_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal VidOnxS        : std_logic                                           := '0';
    -- Others
    signal DataxD         : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0) := (others => '0');
    signal HdmiSourcexD   : t_HdmiSource                                        := C_NO_HDMI_SOURCE;
    
    -- Complex Value
    signal c_real_s       : std_logic_vector (C_DATA_SIZE-1 downto 0);
    signal c_imaginary_s  : std_logic_vector (C_DATA_SIZE-1 downto 0);
    signal X_screen_s     : std_logic_vector (C_SCREEN_RES-1 downto 0);
    signal Y_screen_s     : std_logic_vector (C_SCREEN_RES-1 downto 0);
    
    signal finished_s     : std_logic;
    
    signal ready_s        : std_logic;
    signal start_s        : std_logic;
    signal z_real_s       : std_logic_vector(C_DATA_SIZE-1 downto 0);
    signal z_imaginary_s  : std_logic_vector(C_DATA_SIZE-1 downto 0);
    signal iterations_s   : std_logic_vector(C_ITER_SIZE-1 downto 0);
    signal calc_add_x_s   : std_logic_vector(C_SCREEN_RES-1 downto 0);
    signal calc_add_y_s   : std_logic_vector(C_SCREEN_RES-1 downto 0);
    
    
    signal web_s          : std_logic_vector(0 downto 0);    
    signal wea_s          : std_logic_vector(0 downto 0);
    signal d_out_bram_s   : std_logic_vector(C_ITER_SIZE-1 downto 0);
    signal addrb_s        : std_logic_vector(C_BRAM_VIDEO_MEMORY_ADDR_SIZE-1 downto 0);
    signal addwa_s        : std_logic_vector(C_BRAM_VIDEO_MEMORY_ADDR_SIZE-1 downto 0);


    -- Debug signals

    -- attribute mark_debug                               : string;
    -- attribute mark_debug of HCountxD                   : signal is "true";
    -- attribute mark_debug of VCountxD                   : signal is "true";
    -- attribute mark_debug of DataImGen2BramMVxD         : signal is "true";
    -- attribute mark_debug of DataBramMV2HdmixD          : signal is "true";
    -- attribute mark_debug of BramVideoMemoryWriteAddrxD : signal is "true";
    -- attribute mark_debug of BramVideoMemoryReadAddrxD  : signal is "true";
    -- attribute mark_debug of BramVideoMemoryWriteDataxD : signal is "true";
    -- attribute mark_debug of BramVideoMemoryReadDataxD  : signal is "true";

    -- attribute keep                               : string;
    -- attribute keep of HCountxD                   : signal is "true";
    -- attribute keep of VCountxD                   : signal is "true";
    -- attribute keep of DataImGen2BramMVxD         : signal is "true";
    -- attribute keep of DataBramMV2HdmixD          : signal is "true";
    -- attribute keep of BramVideoMemoryWriteAddrxD : signal is "true";
    -- attribute keep of BramVideoMemoryReadAddrxD  : signal is "true";
    -- attribute keep of BramVideoMemoryWriteDataxD : signal is "true";
    -- attribute keep of BramVideoMemoryReadDataxD  : signal is "true";

begin  -- architecture rtl

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

    ---------------------------------------------------------------------------
    -- HDMI Interface
    ---------------------------------------------------------------------------
    DataxD(((C_PIXEL_SIZE * 3) - 1) downto 0) <= d_out_bram_s((C_ITER_SIZE - 1) downto 0) & '0' & 
                                                 d_out_bram_s((C_ITER_SIZE - 1) downto 0) & '0' & 
                                                 d_out_bram_s((C_ITER_SIZE - 1) downto 0) & '0';
    HdmixI : entity work.hdmi
        generic map (
            C_CHANNEL_NUMBER => C_CHANNEL_NUMBER,
            C_DATA_SIZE      => C_DATA_SIZE,
            C_PIXEL_SIZE     => C_PIXEL_SIZE,
            C_VGA_CONFIG     => C_VGA_CONFIG,
            C_RESOLUTION     => C_RESOLUTION)
        port map (
            ClkSys100MhzxC => ClkSys100MhzxC,
            RstxR          => RstxR,
            PllLockedxSO   => PllLockedxS,
            ClkVgaxCO      => ClkVgaxC,
            HCountxDO      => HCountxD,
            VCountxDO      => VCountxD,
            VidOnxSO       => VidOnxS,
            DataxDI        => DataxD,
            HdmiTxRsclxSO  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS,
            HdmiTxRsdaxSIO => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS,
            HdmiTxHpdxSI   => HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS,
            HdmiTxCecxSIO  => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS,
            HdmiTxClkPxSO  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS,
            HdmiTxClkNxSO  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS,
            HdmiTxPxDO     => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD,
            HdmiTxNxDO     => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD);


    RstPllLockedxB : block is
    begin  -- block RstPllLockedxB

        RstPllLockedxAS : RstPllLockedxS <= not PllLockedxS;

    end block RstPllLockedxB;

 /*   ImageGeneratorxB : block is
    begin  -- block ImageGeneratorxB

        ---------------------------------------------------------------------------
        -- Image generator example
        ---------------------------------------------------------------------------
        ImageGeneratorxI : entity work.image_generator
            generic map (
                C_DATA_SIZE  => C_DATA_SIZE,
                C_PIXEL_SIZE => C_PIXEL_SIZE,
                C_VGA_CONFIG => C_VGA_CONFIG)
            port map (
                ClkVgaxC     => ClkVgaxC,
                RstxRA       => RstPllLockedxS,
                PllLockedxSI => PllLockedxS,
                HCountxDI    => HCountxD,
                VCountxDI    => VCountxD,
                VidOnxSI     => VidOnxS,
                DataxDO      => DataxD);

    end block ImageGeneratorxB; */
    
    ComplexeValueGeneratorxB : block is
    begin  -- block ComplexeValueGeneratorxB
   
     ---------------------------------------------------------------------------
     -- Value Generator
     ---------------------------------------------------------------------------
    ComplexeValueGeneratorxI : ComplexValueGenerator
       generic map (
           SIZE         => C_DATA_SIZE,
           COMMA        => C_COMMA,
           X_SIZE       => C_X_SIZE,
           Y_SIZE       => C_Y_SIZE,
           SCREEN_RES   => C_SCREEN_RES)
       port map (
           clk          => ClkSys100MhzxC,
           reset        => RstxR,
           next_value   => finished_s,
           c_real       => c_real_s,
           c_imaginary  => c_imaginary_s,
           X_screen     => X_screen_s,
           Y_screen     => Y_screen_s);

    end block ComplexeValueGeneratorxB;
    
    mandelbrot_calculatorxB : block is
    begin  -- block ComplexeValueGeneratorxB
   
     ---------------------------------------------------------------------------
     -- Value Generator
     ---------------------------------------------------------------------------
    mandelbrot_calculatorxI : entity work.mandelbrot_calculator
    generic map (
        comma       => C_COMMA,
        max_iter    => C_MAX_ITER,
        SIZE        => C_DATA_SIZE,
        ITER_SIZE   => C_ITER_SIZE,
        X_ADD_SIZE  => C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE,
        Y_ADD_SIZE  => C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE)

    port map(
        clk_i         => ClkSys100MhzxC,
        rst_i         => RstxR,
        ready_o       => ready_s,
        start_i       => ready_s,
        finished_o    => finished_s,
        c_real_i      => c_real_s,
        c_imaginary_i => c_imaginary_s,
        z_real_o      => z_real_s,
        z_imaginary_o => z_imaginary_s,
        iterations_o  => iterations_s,
        x_o           => calc_add_x_s, --> pour la BRAM en adress
        y_o           => calc_add_y_s,  --> pour la BRAM en adress
        x_i           => X_screen_s,
        y_i           => Y_screen_s);
  end block mandelbrot_calculatorxB; 
  
  addrb_s <= VCountxD(C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE - 1 downto 0) & HCountxD(C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE - 1 downto 0);
  addwa_s <= Y_screen_s & X_screen_s;
  
  blk_mem_bramxB : block is
  begin  -- block ComplexeValueGeneratorxB
  web_s(0) <= '0';
  wea_s(0) <= finished_s;
  blk_mem_bramxI : blk_mem_bram
    PORT MAP (
      clka  => ClkSys100MhzxC,
      wea   => wea_s,
      addra => addwa_s,
      dina  => iterations_s,
      douta => open,
      clkb  => ClkVgaxC,
      web   => web_s,
      addrb => addrb_s,
      dinb  => (others => '0'),
      doutb => d_out_bram_s
    ); 
  end block blk_mem_bramxB; 

end architecture rtl;
