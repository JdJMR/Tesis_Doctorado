----------------------------------------------------------------------------------
--
-- Exponenciación Modular de 1024 bits
-- Algoritmo:
-- 0. Espera
-- 1. Lee el valor cifrado
-- 2. Activa la ExpMod
-- 3. Muestra el resultado.
--    Esperar hasta el reset
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.componentes.all;


entity Principal is
    Port
    (
        -- Módulo
        clk : in std_logic;                             -- Reloj principal (100 MHz)
        rst : in std_logic;                             -- Reinicio general
        en : in std_logic;                              -- Habilitador de exponenciación
        -- Entradas
        SelS : in std_logic_vector(4 downto 0);         -- Selector de direccionamiento para 7 Segmentos
        SelD: in std_logic;                             -- Selecciona si se muestra el valor de d(i)
        --SelX: in std_logic;                             -- Selecciona el valor de x (mensaje de entrada)
        -- Salidas
        di: out std_logic;                              -- Salida correspondiente del valor del exponente
        SSEG_CA : out std_logic_vector(7 downto 0);     -- Catodos del display de 7 segmentes
        SSEG_AN : out std_logic_vector(7 downto 0)      -- Anodos del display de 7 segmentos
    );
end Principal;

architecture Behavioral of Principal is

    -- Constantes globales
    constant widthWord : integer := 16;     -- Tamaño de palabra
    constant widthAddr : integer := 7;      -- Número de bits para sizeRAM
    constant sizeRAM : integer := 64;       -- Localidades de memoria
    constant nBits: integer:= 1024;         -- Cantidad de bits para el contador de n en ExpMod

    -- Constantes del valor cifrado
    constant x : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := X"0067408760e3e33a4ad7624b71fae2a5141ec503ccc2d14b8b6403f9a935969cec80548154a4bb7e2df59dd118b9fd0c548d62357a18895d2eef78e7077f74ef308f3643d62967f6db461f1be9ea5454d3fc4563e8696283e2cee242d2867c920f54d44e1c2b77f1758c1ae750ce1dfbc9fcb8248b3ae6a013b53a9892297a0b";
    constant x1: std_logic_vector(widthWord * sizeRAM - 1 downto 0):= X"00d36e0cf1e750ac8a2df4e108dcba391c57c97ced3642509300eaab1c1e8994b43efac40a39f74c5b9343819bd525464c095f794aaf493972087aa29f76c7f5de39b1702711b0581cc9e5c8d4e429b76d749bdb0919ccdc8dea9cc5b683b23755ca1cc34dd1c916f192a26df4ad5595bb5844d5c0a0832f265cd87293b8ce70";

    -- Constantes del módulo
    constant m: std_logic_vector(sizeRAM * widthWord - 1 downto 0) := X"00d36e0cf1e750ac8a2df4e108dcba391c57c97ced3642509300eaab1c1e8994b43efac40a39f74c5b9343819bd525464c095f794aaf493972087aa29f76c7f5de39b1702711b0581cc9e5c8d4e429b76d749bdb0919ccdc8dea9cc5b683b23755ca1cc34dd1c916f192a26df4ad5595bb5844d5c0a0832f265cd87293b8ce71";
    constant mp: std_logic_vector(widthWord - 1 downto 0) := X"cd6f";
    
    -- Constante de la clave secreta
    constant d: std_logic_vector(sizeRAM * widthWord - 1 downto 0) := X"0082e76f23728bda5957222f7d888ee376022363cc8299ab94ee2cd3994456e16da7dfec036ea835e0e8419cd128a8b8371d755511f6af6cc566dfbc9416a6d5a0c6c5ae76f88bcdd27d49e6bbc264595039bc9860d72620c5026b680f789cc7aae38cc50768ea3133edf7bf72068cde4c4027a41f1c569e5c7a28d0e8cb127f";

    -- Constantes relativa a R
    constant RmodM: std_logic_vector(sizeRAM * widthWord - 1 downto 0) := X"00cc2a6003cb9fbd36876c604d933910ca09cc35ad81f4be8fe4bf770f23ef826ffb515fa80880d5773f848ee7ba022638afc298da6c9da95bc3f9b585a0a43ac45cd3a0d7a625a5404da4970899a598e23fe09e03dbb9c8b3d0c55ab309e335730b484311c8474e6a01f147aac7b244de74e9fe7e41a816b1eebdb3b1eed19b";
    constant RRmodM: std_logic_vector(sizeRAM * widthWord - 1 downto 0) := X"003ff753e7775a3ba342166aa6379230ecf610c5db08cb681df91c92c45275baf42aee34e6c3ec0f09a170fbe8198ca8bc612c74aadbb693f402a3e2974aff483e59de9566555faa6afa4ecce51f3e03507b1b5d8fe8152eb230620277540633a51c9716f6a95f52b313c98541282fdf1b9ddb4293cc7a2758350ffde2ad4bb4";

    -- Señales para la exponenciación modular
    signal rstEM: std_logic := '0';
    signal enEM: std_logic := '0';
    signal xEM: std_logic_vector(sizeRAM * widthWord - 1 downto 0) := (others => '0');
    signal aEM: std_logic_vector(sizeRAM * widthWord - 1 downto 0) := (others => '0');
    signal bEM: std_logic := '0';
    signal diEM: std_logic:= '0';
    
    -- Señal que contiene el valor descifrado
    signal desc : std_logic_vector(sizeRAM * widthWord - 1 downto 0) := (others => '0');

    -- Señales para el muestreo en 7 segmentos
    signal bin : std_logic_vector(31 downto 0) := (others => '0');

    type Estados is (EdoEspera, EdoLeeX, EdoActivaExpMod, EdoEsperaExpMod, EdoLEDs);
    signal EdoPres, EdoFut : Estados;

begin

    ---------------------------------------------------------------------------------------------
	-----  Módulos externos                                                                 -----
	---------------------------------------------------------------------------------------------
    ExpMontgomery : ExpMod 
    generic map
    (
        widthWord => widthWord, sizeRAM => sizeRAM, widthAddr => widthAddr, nBits => nBits
    )
    port map
    (
        -- Señales de este módulo
        clk => clk, rst => rstEM, en => enEM, 
        -- Entradas
        x => xEM, N => m, np => mp, RmodN => RmodM, RRmodN => RRmodM, d => d, 
        -- Salidas
        di => diEM, S => aEM, ban => bEM
    );

    SSegmentos : SieteSegmentos 
    port map
    (
        clk => clk, bin => bin, SSEG_CA => SSEG_CA, SSEG_AN => SSEG_AN
    );

    ---------------------------------------------------------------------------------------------
	-----  Principal                                                                        -----
	---------------------------------------------------------------------------------------------
    -- Máquina de estados
    Maquina : process(EdoPres, en, bEM)
    begin
        case EdoPres is
            when EdoEspera => -- Espera a que se activa la exponenciaci�n
                if(en = '1')then
                    EdoFut <= EdoLeeX;
                else
                    EdoFut <= EdoEspera;
                end if;
            when EdoLeeX => -- Lee el valor de x
                EdoFut <= EdoActivaExpMod;
            when EdoActivaExpMod => -- Actva la ExpMod y espera a que termine
                EdoFut <= EdoEsperaExpMod;
            when EdoEsperaExpMod => 
                if(bEM = '1')then
                    EdoFut <= EdoLEDs;
                else
                    EdoFut <= EdoEsperaExpMod;
                end if;
            when EdoLEDs => -- Muestra el resultado
                EdoFut <= EdoLEDs;
        end case;
    end process;

    -- Avance de la máquina de estados
    AvanceMaquina : process(clk, rst, EdoPres)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                EdoPres <= EdoEspera;
            else
                EdoPres <= EdoFut;
            end if;
        end if;
    end process;

    -- Guarda el valor descifrado
    GuardaDescifrado : process(clk, EdoPres)
    begin
        if(rising_edge(clk))then
            if(EdoPres = EdoLEDs)then
                desc <= aEM;
            else
                desc <= (others => '0');
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------------------------
	-----  SaML2R                                                                           -----
	---------------------------------------------------------------------------------------------
    -- Activa SaML2R
    ActivaEM : process(clk, EdoPres)
    begin
        if(rising_edge(clk))then
            if(EdoPres = EdoActivaExpMod)then
                enEM <= '1';
            else
                enEM <= '0';
            end if;
        end if;
    end process;

    -- Reinicia SaML2R
    ReiniciaEM : process(clk, EdoPres)
    begin
        if(rising_edge(clk))then
            if(EdoPres = EdoEspera or EdoPres = EdoLEDs)then
                rstEM <= '1';
            else
                rstEM <= '0';
            end if;
        end if;
    end process;

    -- xEM <= x; -- Activar para un valor normal de entrada de mensaje
    xEM <= x1; -- Activar para el valor N-1 de entrada de mensaje

    ---------------------------------------------------------------------------------------------
	-----  Salida                                                                           -----
	---------------------------------------------------------------------------------------------
    process(clk, SelD, diEM)
    begin
        if(rising_edge(clk))then
            if SelD = '1' then
                di <= diEM;
            else
                di <= '0';
            end if ;
        end if;
    end process;

	with SelS select
		bin <= 	desc(  31 downto   0) when "00000",
				desc(  63 downto  32) when "00001",
				desc(  95 downto  64) when "00010",
				desc( 127 downto  96) when "00011",
                desc( 159 downto 128) when "00100",
                desc( 191 downto 160) when "00101",
                desc( 223 downto 192) when "00110",
                desc( 255 downto 224) when "00111",
                desc( 287 downto 256) when "01000",
                desc( 319 downto 288) when "01001",
                desc( 351 downto 320) when "01010",
                desc( 383 downto 352) when "01011",
                desc( 415 downto 384) when "01100",
                desc( 447 downto 416) when "01101",
                desc( 479 downto 448) when "01110",
                desc( 511 downto 480) when "01111",
                desc( 543 downto 512) when "10000",
                desc( 575 downto 544) when "10001",
                desc( 607 downto 576) when "10010",
                desc( 639 downto 608) when "10011",
                desc( 671 downto 640) when "10100",
                desc( 703 downto 672) when "10101",
                desc( 735 downto 704) when "10110",
                desc( 767 downto 736) when "10111",
                desc( 799 downto 768) when "11000",
                desc( 831 downto 800) when "11001",
                desc( 863 downto 832) when "11010",
                desc( 895 downto 864) when "11011",
                desc( 927 downto 896) when "11100",
                desc( 959 downto 928) when "11101",
                desc( 991 downto 960) when "11110",
                desc(1023 downto 992) when "11111",
				X"FFFFFFFF" when others;

end Behavioral;
