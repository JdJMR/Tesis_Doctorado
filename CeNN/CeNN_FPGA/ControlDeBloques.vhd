----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: José de Jesús Morales Romero
-- 
-- Design Name: CNN_MxN
-- Module Name: CNN_MxN - Behavioral
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.0

-- Description: Diseño que crea una CNN de dimensiones M x N
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library xil_defaultlib;
use xil_defaultlib.Componentes.all;

entity ControlDeBloques is
    generic
    (
        nBitsPalabra: integer := 16; -- Cantidad de bits para los valores
        sizeRAM: integer := 65536; -- Cantidad de pixeles a guardar. Tamaño de la RAM
        nBitsDatoRx: integer := 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
        nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
        nBitsMaxY: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)
        filas: integer:= 8; -- Cantidad de Filas que tendrá la CNN
        columnas: integer:= 8 -- Cantidad de Columnas que tendrá la CNN
    );
    port
    (
        -- Señales de entrada
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad total de pixeles en X
        totalPixelY: in std_logic_vector(nBitsMaxY - 1 downto 0); -- Cantidad total de pixeles en Y
        DO: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        -- Plantilla A
        a11, a12, a13: in std_logic_vector(nBitsPalabra - 1 downto 0);
        a21, a22, a23: in std_logic_vector(nBitsPalabra - 1 downto 0);
        a31, a32, a33: in std_logic_vector(nBitsPalabra - 1 downto 0);
        -- Plantilla B
        b11, b12, b13: in std_logic_vector(nBitsPalabra - 1 downto 0);
        b21, b22, b23: in std_logic_vector(nBitsPalabra - 1 downto 0);
        b31, b32, b33: in std_logic_vector(nBitsPalabra - 1 downto 0);
        -- Bias
        Ikl: in std_logic_vector(nBitsPalabra - 1 downto 0);
        -- Señales para la memoria
		addr_re: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
		addr_we: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
		we: out std_logic;
		DI: out std_logic_vector(nBitsDatoRx - 1 downto 0);
        -- Señales de salida
        ban: out std_logic
    );
end ControlDeBloques;

architecture arq_ControlDeBloques of ControlDeBloques is

    -- Constantes 
    constant nBitsBloquesX: integer:= 6;
    constant nBitsBloquesY: integer:= 6;

    -- Señales para el calculador de bloques
    signal en_CB: std_logic:= '0';
    signal totalBloquesX: std_logic_vector(nBitsBloquesX - 1 downto 0):= (others => '0');
    signal totalBloquesY: std_logic_vector(nBitsBloquesY - 1 downto 0):= (others => '0');
    signal ban_CB: std_logic:= '0';

    -- Señales para el Calculador puntero celula inicial
    signal en_CPCI: std_logic:= '0';
    signal puntCel: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal BloqueX: std_logic_vector(nBitsBloquesX - 1 downto 0):= (others => '0');
    signal BloqueY: std_logic_vector(nBitsBloquesY - 1 downto 0):= (others => '0');
    signal ban_CPCI: std_logic:= '0';
    signal banFin: std_logic:= '0';

    -- Señales para Lee Imagen de Entrada
    signal en_LIE: std_logic:= '0';
    signal DO_LIE: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal addr_LIE: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal vu11_8b, vu12_8b, vu13_8b, vu14_8b, vu15_8b, vu16_8b, vu17_8b, vu18_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu21_8b, vu22_8b, vu23_8b, vu24_8b, vu25_8b, vu26_8b, vu27_8b, vu28_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu31_8b, vu32_8b, vu33_8b, vu34_8b, vu35_8b, vu36_8b, vu37_8b, vu38_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu41_8b, vu42_8b, vu43_8b, vu44_8b, vu45_8b, vu46_8b, vu47_8b, vu48_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu51_8b, vu52_8b, vu53_8b, vu54_8b, vu55_8b, vu56_8b, vu57_8b, vu58_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu61_8b, vu62_8b, vu63_8b, vu64_8b, vu65_8b, vu66_8b, vu67_8b, vu68_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu71_8b, vu72_8b, vu73_8b, vu74_8b, vu75_8b, vu76_8b, vu77_8b, vu78_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu81_8b, vu82_8b, vu83_8b, vu84_8b, vu85_8b, vu86_8b, vu87_8b, vu88_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal ban_LIE: std_logic:= '0';

    -- Señales para el conversor de 8 a 16 bits
    signal en_C8a16b: std_logic:= '0';
    signal vu11_16b, vu12_16b, vu13_16b, vu14_16b, vu15_16b, vu16_16b, vu17_16b, vu18_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu21_16b, vu22_16b, vu23_16b, vu24_16b, vu25_16b, vu26_16b, vu27_16b, vu28_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu31_16b, vu32_16b, vu33_16b, vu34_16b, vu35_16b, vu36_16b, vu37_16b, vu38_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu41_16b, vu42_16b, vu43_16b, vu44_16b, vu45_16b, vu46_16b, vu47_16b, vu48_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu51_16b, vu52_16b, vu53_16b, vu54_16b, vu55_16b, vu56_16b, vu57_16b, vu58_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu61_16b, vu62_16b, vu63_16b, vu64_16b, vu65_16b, vu66_16b, vu67_16b, vu68_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu71_16b, vu72_16b, vu73_16b, vu74_16b, vu75_16b, vu76_16b, vu77_16b, vu78_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu81_16b, vu82_16b, vu83_16b, vu84_16b, vu85_16b, vu86_16b, vu87_16b, vu88_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal ban_C8A16b: std_logic:= '0';

    -- Señales para la CNN
    signal en_CNN: std_logic:= '0';
    signal rst_CNN: std_logic:= '0';
    signal vy11_16b, vy12_16b, vy13_16b, vy14_16b, vy15_16b, vy16_16b, vy17_16b, vy18_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy21_16b, vy22_16b, vy23_16b, vy24_16b, vy25_16b, vy26_16b, vy27_16b, vy28_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy31_16b, vy32_16b, vy33_16b, vy34_16b, vy35_16b, vy36_16b, vy37_16b, vy38_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy41_16b, vy42_16b, vy43_16b, vy44_16b, vy45_16b, vy46_16b, vy47_16b, vy48_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy51_16b, vy52_16b, vy53_16b, vy54_16b, vy55_16b, vy56_16b, vy57_16b, vy58_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy61_16b, vy62_16b, vy63_16b, vy64_16b, vy65_16b, vy66_16b, vy67_16b, vy68_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy71_16b, vy72_16b, vy73_16b, vy74_16b, vy75_16b, vy76_16b, vy77_16b, vy78_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vy81_16b, vy82_16b, vy83_16b, vy84_16b, vy85_16b, vy86_16b, vy87_16b, vy88_16b: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal ban_CNN: std_logic:= '0';

    -- Señales para el conversor de 16 a 8 bits
    signal en_C16A8b: std_logic:= '0';
    signal vy11_8b, vy12_8b, vy13_8b, vy14_8b, vy15_8b, vy16_8b, vy17_8b, vy18_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy21_8b, vy22_8b, vy23_8b, vy24_8b, vy25_8b, vy26_8b, vy27_8b, vy28_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy31_8b, vy32_8b, vy33_8b, vy34_8b, vy35_8b, vy36_8b, vy37_8b, vy38_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy41_8b, vy42_8b, vy43_8b, vy44_8b, vy45_8b, vy46_8b, vy47_8b, vy48_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy51_8b, vy52_8b, vy53_8b, vy54_8b, vy55_8b, vy56_8b, vy57_8b, vy58_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy61_8b, vy62_8b, vy63_8b, vy64_8b, vy65_8b, vy66_8b, vy67_8b, vy68_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy71_8b, vy72_8b, vy73_8b, vy74_8b, vy75_8b, vy76_8b, vy77_8b, vy78_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vy81_8b, vy82_8b, vy83_8b, vy84_8b, vy85_8b, vy86_8b, vy87_8b, vy88_8b: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal ban_C16A8b: std_logic:= '0';
    
    -- Señales para Escribe Imagen de Salida
    signal en_EIS: std_logic:= '0';
    signal addr_EIS: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal DI_EIS: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal we_EIS: std_logic:= '0';
    signal ban_EIS: std_logic:= '0';

    -- Máquina de estados
    type Estados is (Espera, CalculaBloques, CalculaCelIni, LeeBloque, ConvierteA16Bits, ActivaCNN, ProcesaBloque, ConvierteA8Bits, GuardaBloque,
                    EsBloqueFinal, Finaliza);
    signal Edo: Estados;

begin

    ----------------------------------------------------------------------------------
    --                                   Módulos                                    --
    ----------------------------------------------------------------------------------
    CalBloques: CalculadorDeBloques
        generic map
        (
            nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY, nBitsBloquesX => nBitsBloquesX, nBitsBloquesY => nBitsBloquesY
        )
        port map
        (
            -- Señales de estrada
            clk => clk, rst => rst, en => en_CB, totalPixelX => totalPixelX, totalPixelY => totalPixelY,
            -- Señales de salida
            totalBloquesX => totalBloquesX, totalBloquesY => totalBloquesY, ban => ban_CB
        );

    CalPuntero: CalculadorPunteroCelulaInicial
        generic map
        (
            nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY, nBitsBloquesX => nBitsBloquesY
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst, en => en_CPCI, totalPixelX => totalPixelX, totalBloquesX => totalBloquesX, totalBloquesY => totalBloquesY,
            -- Señales de salida
            puntCel => puntCel, BloqueX => BloqueX, BloqueY => BloqueY, ban => ban_CPCI, banFin => banFin
        );

    LeeImgEnt: LeeImagenDeEntrada
        generic map
        (
            nBitsDatoRx => nBitsDatoRx, nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY, filas => filas, columnas => columnas
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst, en => en_LIE, DO => DO_LIE, totalPixelX => totalPixelX, puntCel => puntCel,
            -- Señales de salida
            addr => addr_LIE, 
            vu11 => vu11_8b, vu12 => vu12_8b, vu13 => vu13_8b, vu14 => vu14_8b, vu15 => vu15_8b, vu16 => vu16_8b, vu17 => vu17_8b, vu18 => vu18_8b,
            vu21 => vu21_8b, vu22 => vu22_8b, vu23 => vu23_8b, vu24 => vu24_8b, vu25 => vu25_8b, vu26 => vu26_8b, vu27 => vu27_8b, vu28 => vu28_8b,
            vu31 => vu31_8b, vu32 => vu32_8b, vu33 => vu33_8b, vu34 => vu34_8b, vu35 => vu35_8b, vu36 => vu36_8b, vu37 => vu37_8b, vu38 => vu38_8b,
            vu41 => vu41_8b, vu42 => vu42_8b, vu43 => vu43_8b, vu44 => vu44_8b, vu45 => vu45_8b, vu46 => vu46_8b, vu47 => vu47_8b, vu48 => vu48_8b,
            vu51 => vu51_8b, vu52 => vu52_8b, vu53 => vu53_8b, vu54 => vu54_8b, vu55 => vu55_8b, vu56 => vu56_8b, vu57 => vu57_8b, vu58 => vu58_8b,
            vu61 => vu61_8b, vu62 => vu62_8b, vu63 => vu63_8b, vu64 => vu64_8b, vu65 => vu65_8b, vu66 => vu66_8b, vu67 => vu67_8b, vu68 => vu68_8b,
            vu71 => vu71_8b, vu72 => vu72_8b, vu73 => vu73_8b, vu74 => vu74_8b, vu75 => vu75_8b, vu76 => vu76_8b, vu77 => vu77_8b, vu78 => vu78_8b,
            vu81 => vu81_8b, vu82 => vu82_8b, vu83 => vu83_8b, vu84 => vu84_8b, vu85 => vu85_8b, vu86 => vu86_8b, vu87 => vu87_8b, vu88 => vu88_8b,
            ban => ban_LIE
        );

    ConvA16b: Conversor8A16Bits
        generic map
        (
            nBitsPalabra => nBitsPalabra, nBitsDatoRx => nBitsDatoRx
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst, en => en_C8a16b, 
            vu11_8b => vu11_8b, vu12_8b => vu12_8b, vu13_8b => vu13_8b, vu14_8b => vu14_8b, vu15_8b => vu15_8b, vu16_8b => vu16_8b, vu17_8b => vu17_8b, vu18_8b => vu18_8b,
            vu21_8b => vu21_8b, vu22_8b => vu22_8b, vu23_8b => vu23_8b, vu24_8b => vu24_8b, vu25_8b => vu25_8b, vu26_8b => vu26_8b, vu27_8b => vu27_8b, vu28_8b => vu28_8b,
            vu31_8b => vu31_8b, vu32_8b => vu32_8b, vu33_8b => vu33_8b, vu34_8b => vu34_8b, vu35_8b => vu35_8b, vu36_8b => vu36_8b, vu37_8b => vu37_8b, vu38_8b => vu38_8b,
            vu41_8b => vu41_8b, vu42_8b => vu42_8b, vu43_8b => vu43_8b, vu44_8b => vu44_8b, vu45_8b => vu45_8b, vu46_8b => vu46_8b, vu47_8b => vu47_8b, vu48_8b => vu48_8b,
            vu51_8b => vu51_8b, vu52_8b => vu52_8b, vu53_8b => vu53_8b, vu54_8b => vu54_8b, vu55_8b => vu55_8b, vu56_8b => vu56_8b, vu57_8b => vu57_8b, vu58_8b => vu58_8b,
            vu61_8b => vu61_8b, vu62_8b => vu62_8b, vu63_8b => vu63_8b, vu64_8b => vu64_8b, vu65_8b => vu65_8b, vu66_8b => vu66_8b, vu67_8b => vu67_8b, vu68_8b => vu68_8b,
            vu71_8b => vu71_8b, vu72_8b => vu72_8b, vu73_8b => vu73_8b, vu74_8b => vu74_8b, vu75_8b => vu75_8b, vu76_8b => vu76_8b, vu77_8b => vu77_8b, vu78_8b => vu78_8b,
            vu81_8b => vu81_8b, vu82_8b => vu82_8b, vu83_8b => vu83_8b, vu84_8b => vu84_8b, vu85_8b => vu85_8b, vu86_8b => vu86_8b, vu87_8b => vu87_8b, vu88_8b => vu88_8b,
            -- Señale de salida
            vu11 => vu11_16b, vu12 => vu12_16b, vu13 => vu13_16b, vu14 => vu14_16b, vu15 => vu15_16b, vu16 => vu16_16b, vu17 => vu17_16b, vu18 => vu18_16b,
            vu21 => vu21_16b, vu22 => vu22_16b, vu23 => vu23_16b, vu24 => vu24_16b, vu25 => vu25_16b, vu26 => vu26_16b, vu27 => vu27_16b, vu28 => vu28_16b,
            vu31 => vu31_16b, vu32 => vu32_16b, vu33 => vu33_16b, vu34 => vu34_16b, vu35 => vu35_16b, vu36 => vu36_16b, vu37 => vu37_16b, vu38 => vu38_16b,
            vu41 => vu41_16b, vu42 => vu42_16b, vu43 => vu43_16b, vu44 => vu44_16b, vu45 => vu45_16b, vu46 => vu46_16b, vu47 => vu47_16b, vu48 => vu48_16b,
            vu51 => vu51_16b, vu52 => vu52_16b, vu53 => vu53_16b, vu54 => vu54_16b, vu55 => vu55_16b, vu56 => vu56_16b, vu57 => vu57_16b, vu58 => vu58_16b,
            vu61 => vu61_16b, vu62 => vu62_16b, vu63 => vu63_16b, vu64 => vu64_16b, vu65 => vu65_16b, vu66 => vu66_16b, vu67 => vu67_16b, vu68 => vu68_16b,
            vu71 => vu71_16b, vu72 => vu72_16b, vu73 => vu73_16b, vu74 => vu74_16b, vu75 => vu75_16b, vu76 => vu76_16b, vu77 => vu77_16b, vu78 => vu78_16b,
            vu81 => vu81_16b, vu82 => vu82_16b, vu83 => vu83_16b, vu84 => vu84_16b, vu85 => vu85_16b, vu86 => vu86_16b, vu87 => vu87_16b, vu88 => vu88_16b,
            ban => ban_C8A16b
        );

    CNN: CNN_MxN
        generic map
        (
            widthWord => nBitsPalabra, filas => filas, columnas => columnas
        )
        port map
        (
            -- Entradas
            clk => clk, rst => rst_CNN, en => en_CNN,
            -- Plantillas
            a11 => a11, a12 => a12, a13 => a13, a21 => a21, a22 => a22, a23 => a23, a31 => a31, a32 => a32, a33 => a33,
            b11 => b11, b12 => b12, b13 => b13, b21 => b21, b22 => b22, b23 => b23, b31 => b31, b32 => b32, b33 => b33,
            Ikl => Ikl,
            -- Entras de las celulas
            vu11 => vu11_16b, vu12 => vu12_16b, vu13 => vu13_16b, vu14 => vu14_16b, vu15 => vu15_16b, vu16 => vu16_16b, vu17 => vu17_16b, vu18 => vu18_16b,
            vu21 => vu21_16b, vu22 => vu22_16b, vu23 => vu23_16b, vu24 => vu24_16b, vu25 => vu25_16b, vu26 => vu26_16b, vu27 => vu27_16b, vu28 => vu28_16b,
            vu31 => vu31_16b, vu32 => vu32_16b, vu33 => vu33_16b, vu34 => vu34_16b, vu35 => vu35_16b, vu36 => vu36_16b, vu37 => vu37_16b, vu38 => vu38_16b,
            vu41 => vu41_16b, vu42 => vu42_16b, vu43 => vu43_16b, vu44 => vu44_16b, vu45 => vu45_16b, vu46 => vu46_16b, vu47 => vu47_16b, vu48 => vu48_16b,
            vu51 => vu51_16b, vu52 => vu52_16b, vu53 => vu53_16b, vu54 => vu54_16b, vu55 => vu55_16b, vu56 => vu56_16b, vu57 => vu57_16b, vu58 => vu58_16b,
            vu61 => vu61_16b, vu62 => vu62_16b, vu63 => vu63_16b, vu64 => vu64_16b, vu65 => vu65_16b, vu66 => vu66_16b, vu67 => vu67_16b, vu68 => vu68_16b,
            vu71 => vu71_16b, vu72 => vu72_16b, vu73 => vu73_16b, vu74 => vu74_16b, vu75 => vu75_16b, vu76 => vu76_16b, vu77 => vu77_16b, vu78 => vu78_16b,
            vu81 => vu81_16b, vu82 => vu82_16b, vu83 => vu83_16b, vu84 => vu84_16b, vu85 => vu85_16b, vu86 => vu86_16b, vu87 => vu87_16b, vu88 => vu88_16b,
            -- Salida de las celulas
            vy11 => vy11_16b, vy12 => vy12_16b, vy13 => vy13_16b, vy14 => vy14_16b, vy15 => vy15_16b, vy16 => vy16_16b, vy17 => vy17_16b, vy18 => vy18_16b,
            vy21 => vy21_16b, vy22 => vy22_16b, vy23 => vy23_16b, vy24 => vy24_16b, vy25 => vy25_16b, vy26 => vy26_16b, vy27 => vy27_16b, vy28 => vy28_16b,
            vy31 => vy31_16b, vy32 => vy32_16b, vy33 => vy33_16b, vy34 => vy34_16b, vy35 => vy35_16b, vy36 => vy36_16b, vy37 => vy37_16b, vy38 => vy38_16b,
            vy41 => vy41_16b, vy42 => vy42_16b, vy43 => vy43_16b, vy44 => vy44_16b, vy45 => vy45_16b, vy46 => vy46_16b, vy47 => vy47_16b, vy48 => vy48_16b,
            vy51 => vy51_16b, vy52 => vy52_16b, vy53 => vy53_16b, vy54 => vy54_16b, vy55 => vy55_16b, vy56 => vy56_16b, vy57 => vy57_16b, vy58 => vy58_16b,
            vy61 => vy61_16b, vy62 => vy62_16b, vy63 => vy63_16b, vy64 => vy64_16b, vy65 => vy65_16b, vy66 => vy66_16b, vy67 => vy67_16b, vy68 => vy68_16b,
            vy71 => vy71_16b, vy72 => vy72_16b, vy73 => vy73_16b, vy74 => vy74_16b, vy75 => vy75_16b, vy76 => vy76_16b, vy77 => vy77_16b, vy78 => vy78_16b,
            vy81 => vy81_16b, vy82 => vy82_16b, vy83 => vy83_16b, vy84 => vy84_16b, vy85 => vy85_16b, vy86 => vy86_16b, vy87 => vy87_16b, vy88 => vy88_16b,
            -- Bandera
            ban => ban_CNN
        );
    
    ConvA8b: Conversor16A8Bits
        generic map
        (
            nBitsPalabra => nBitsPalabra, nBitsDatoRx => nBitsDatoRx
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst, en => en_C16A8b,
            vy11_16b => vy11_16b, vy12_16b => vy12_16b, vy13_16b => vy13_16b, vy14_16b => vy14_16b, vy15_16b => vy15_16b, vy16_16b => vy16_16b, vy17_16b => vy17_16b, vy18_16b => vy18_16b,
            vy21_16b => vy21_16b, vy22_16b => vy22_16b, vy23_16b => vy23_16b, vy24_16b => vy24_16b, vy25_16b => vy25_16b, vy26_16b => vy26_16b, vy27_16b => vy27_16b, vy28_16b => vy28_16b,
            vy31_16b => vy31_16b, vy32_16b => vy32_16b, vy33_16b => vy33_16b, vy34_16b => vy34_16b, vy35_16b => vy35_16b, vy36_16b => vy36_16b, vy37_16b => vy37_16b, vy38_16b => vy38_16b,
            vy41_16b => vy41_16b, vy42_16b => vy42_16b, vy43_16b => vy43_16b, vy44_16b => vy44_16b, vy45_16b => vy45_16b, vy46_16b => vy46_16b, vy47_16b => vy47_16b, vy48_16b => vy48_16b,
            vy51_16b => vy51_16b, vy52_16b => vy52_16b, vy53_16b => vy53_16b, vy54_16b => vy54_16b, vy55_16b => vy55_16b, vy56_16b => vy56_16b, vy57_16b => vy57_16b, vy58_16b => vy58_16b,
            vy61_16b => vy61_16b, vy62_16b => vy62_16b, vy63_16b => vy63_16b, vy64_16b => vy64_16b, vy65_16b => vy65_16b, vy66_16b => vy66_16b, vy67_16b => vy67_16b, vy68_16b => vy68_16b,
            vy71_16b => vy71_16b, vy72_16b => vy72_16b, vy73_16b => vy73_16b, vy74_16b => vy74_16b, vy75_16b => vy75_16b, vy76_16b => vy76_16b, vy77_16b => vy77_16b, vy78_16b => vy78_16b,
            vy81_16b => vy81_16b, vy82_16b => vy82_16b, vy83_16b => vy83_16b, vy84_16b => vy84_16b, vy85_16b => vy85_16b, vy86_16b => vy86_16b, vy87_16b => vy87_16b, vy88_16b => vy88_16b,
            -- Señales de salida
            vy11 => vy11_8b, vy12 => vy12_8b, vy13 => vy13_8b, vy14 => vy14_8b, vy15 => vy15_8b, vy16 => vy16_8b, vy17 => vy17_8b, vy18 => vy18_8b,
            vy21 => vy21_8b, vy22 => vy22_8b, vy23 => vy23_8b, vy24 => vy24_8b, vy25 => vy25_8b, vy26 => vy26_8b, vy27 => vy27_8b, vy28 => vy28_8b,
            vy31 => vy31_8b, vy32 => vy32_8b, vy33 => vy33_8b, vy34 => vy34_8b, vy35 => vy35_8b, vy36 => vy36_8b, vy37 => vy37_8b, vy38 => vy38_8b,
            vy41 => vy41_8b, vy42 => vy42_8b, vy43 => vy43_8b, vy44 => vy44_8b, vy45 => vy45_8b, vy46 => vy46_8b, vy47 => vy47_8b, vy48 => vy48_8b,
            vy51 => vy51_8b, vy52 => vy52_8b, vy53 => vy53_8b, vy54 => vy54_8b, vy55 => vy55_8b, vy56 => vy56_8b, vy57 => vy57_8b, vy58 => vy58_8b,
            vy61 => vy61_8b, vy62 => vy62_8b, vy63 => vy63_8b, vy64 => vy64_8b, vy65 => vy65_8b, vy66 => vy66_8b, vy67 => vy67_8b, vy68 => vy68_8b,
            vy71 => vy71_8b, vy72 => vy72_8b, vy73 => vy73_8b, vy74 => vy74_8b, vy75 => vy75_8b, vy76 => vy76_8b, vy77 => vy77_8b, vy78 => vy78_8b,
            vy81 => vy81_8b, vy82 => vy82_8b, vy83 => vy83_8b, vy84 => vy84_8b, vy85 => vy85_8b, vy86 => vy86_8b, vy87 => vy87_8b, vy88 => vy88_8b,
            ban => ban_C16A8b
        );
    
    EscImgSal: EscribeImagenDeSalida
        generic map
        (
            nBitsDatoRx => nBitsDatoRx, nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY, nBitsBloquesX => nBitsBloquesX, nBitsBloquesY => nBitsBloquesY,
            filas => filas, columnas => columnas
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst, en => en_EIS, totalPixelX => totalPixelX, puntCel => puntCel, BloqueX => BloqueX, BloqueY => BloqueY, 
            totalBloquesX => totalBloquesX, totalBloquesY => totalBloquesY,
            vy11 => vy11_8b, vy12 => vy12_8b, vy13 => vy13_8b, vy14 => vy14_8b, vy15 => vy15_8b, vy16 => vy16_8b, vy17 => vy17_8b, vy18 => vy18_8b,
            vy21 => vy21_8b, vy22 => vy22_8b, vy23 => vy23_8b, vy24 => vy24_8b, vy25 => vy25_8b, vy26 => vy26_8b, vy27 => vy27_8b, vy28 => vy28_8b,
            vy31 => vy31_8b, vy32 => vy32_8b, vy33 => vy33_8b, vy34 => vy34_8b, vy35 => vy35_8b, vy36 => vy36_8b, vy37 => vy37_8b, vy38 => vy38_8b,
            vy41 => vy41_8b, vy42 => vy42_8b, vy43 => vy43_8b, vy44 => vy44_8b, vy45 => vy45_8b, vy46 => vy46_8b, vy47 => vy47_8b, vy48 => vy48_8b,
            vy51 => vy51_8b, vy52 => vy52_8b, vy53 => vy53_8b, vy54 => vy54_8b, vy55 => vy55_8b, vy56 => vy56_8b, vy57 => vy57_8b, vy58 => vy58_8b,
            vy61 => vy61_8b, vy62 => vy62_8b, vy63 => vy63_8b, vy64 => vy64_8b, vy65 => vy65_8b, vy66 => vy66_8b, vy67 => vy67_8b, vy68 => vy68_8b,
            vy71 => vy71_8b, vy72 => vy72_8b, vy73 => vy73_8b, vy74 => vy74_8b, vy75 => vy75_8b, vy76 => vy76_8b, vy77 => vy77_8b, vy78 => vy78_8b,
            vy81 => vy81_8b, vy82 => vy82_8b, vy83 => vy83_8b, vy84 => vy84_8b, vy85 => vy85_8b, vy86 => vy86_8b, vy87 => vy87_8b, vy88 => vy88_8b,
            -- Señales de salida
            addr => addr_EIS, DI => DI_EIS, we => we_EIS, ban => ban_EIS
        );
    ----------------------------------------------------------------------------------
    --                              Máquina de estados                              --
    ----------------------------------------------------------------------------------
    Maquina: process(clk, rst, Edo, en, ban_CB, ban_CPCI, ban_LIE, ban_EIS, ban_C8A16b, ban_CNN, ban_C16A8b, banFin)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                Edo <= Espera;
            else
                case Edo is
                    when Espera =>
                        if(en = '1')then
                            Edo <= CalculaBloques;
                        else
                            Edo <= Espera;
                        end if;
                    when CalculaBloques =>
                        if(ban_CB = '1')then
                            Edo <= CalculaCelIni;
                        else
                            Edo <= CalculaBloques;
                        end if;
                    when CalculaCelIni =>
                        if(ban_CPCI = '1')then
                            Edo <= LeeBloque;
                        else
                            Edo <= CalculaCelIni;
                        end if;
                    when LeeBloque =>
                        if(ban_LIE = '1')then
                            Edo <= ConvierteA16Bits;
                        else
                            Edo <= LeeBloque;
                        end if;
                    when ConvierteA16Bits =>
                        if(ban_C8A16b = '1')then
                            Edo <= ActivaCNN;
                        else
                            Edo <= ConvierteA16Bits;
                        end if;
                    when ActivaCNN =>
                        Edo <= ProcesaBloque;
                    when ProcesaBloque =>
                        if(ban_CNN = '1')then
                            Edo <= ConvierteA8Bits;
                        else
                            Edo <= ProcesaBloque;
                        end if;
                    when ConvierteA8Bits =>
                        if(ban_C16A8b = '1')then
                            Edo <= GuardaBloque;
                        else
                            Edo <= ConvierteA8Bits;
                        end if;
                    when GuardaBloque =>
                        if(ban_EIS = '1')then
                            Edo <= EsBloqueFinal;
                        else
                            Edo <= GuardaBloque;
                        end if;
                    when EsBloqueFinal =>
                        if(banFin = '1')then
                            Edo <= Finaliza;
                        else
                            Edo <= CalculaCelIni;
                        end if;
                    when Finaliza =>
                        Edo <= Finaliza;
                    when others =>
                        Edo <= Espera;
                end case;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    --                             Calculador de bloques                            --
    ----------------------------------------------------------------------------------
    en_CB <= '1' when (Edo = CalculaBloques) else '0';
    
    ----------------------------------------------------------------------------------
    --                             Calculador de puntero                            --
    ----------------------------------------------------------------------------------
    en_CPCI <= '1' when (Edo = CalculaCelIni) else '0';
    
    ----------------------------------------------------------------------------------
    --                                   Lee Bloque                                 --
    ----------------------------------------------------------------------------------
    en_LIE <= '1' when (Edo = LeeBloque) else '0';
    DO_LIE <= DO;

    ----------------------------------------------------------------------------------
    --                               Convierte a 16 bits                            --
    ----------------------------------------------------------------------------------
    en_C8a16b <= '1' when (Edo = ConvierteA16Bits) else '0';
    
    ----------------------------------------------------------------------------------
    --                                       CNN                                    --
    ----------------------------------------------------------------------------------
    en_CNN <= '1' when ((Edo = ProcesaBloque) or (Edo = ActivaCNN)) else '0';

    ReinicioCNN: process(clk, rst, Edo)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                rst_CNN <= '1';
            else
                if(Edo = EsBloqueFinal)then
                    rst_CNN <= '1';
                else
                    rst_CNN <= '0';
                end if;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    --                               Convierte a 8 bits                             --
    ----------------------------------------------------------------------------------
    en_C16A8b <= '1' when (Edo = ConvierteA8Bits) else '0';

    ----------------------------------------------------------------------------------
    --                                   Memorias                                   --
    ----------------------------------------------------------------------------------
    addr_re <= addr_LIE;
    addr_we <= addr_EIS;
    DI <= DI_EIS;
    we <= we_EIS;
    
    ----------------------------------------------------------------------------------
    --                                  Guarda Bloque                               --
    ----------------------------------------------------------------------------------
    en_EIS <= '1' when (Edo = GuardaBloque) else '0';
    
    ----------------------------------------------------------------------------------
    --                                   Salidas                                    --
    ----------------------------------------------------------------------------------
    ban <= '1' when (Edo = Finaliza) else '0';
            
end arq_ControlDeBloques;