library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Componentes is

    component RS232Rx
        Port
        (	
            clk: in std_logic;
            rst: in std_logic;
            rx: in std_logic;
            edo_rx: out std_logic;
            dato: out std_logic_vector(7 downto 0)
        );
    end component;

    component PilaParametros
        Generic
        (
            nBitsDatoRx: integer := 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
            nBitsPalabra: integer := 16; -- Cantidad de bits para los valores
            nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
            nBitsMaxY: integer:= 9 -- Cantidad de bits para direccionar 256 bytes en Y(1 byte = 8bits)
        );
        Port
        (
            -- Entradas
            rst: in std_logic;
            clk: in std_logic;
            edo_rx: in std_logic;
            data_in: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            -- Salida
            totalPixelX: out std_logic_vector(nBitsMaxX - 1 downto 0);
            totalPixelY: out std_logic_vector(nBitsMaxY - 1 downto 0);	
            a11, a12, a13: out std_logic_vector(nBitsPalabra - 1 downto 0);
            a21, a22, a23: out std_logic_vector(nBitsPalabra - 1 downto 0);
            a31, a32, a33: out std_logic_vector(nBitsPalabra - 1 downto 0);
            b11, b12, b13: out std_logic_vector(nBitsPalabra - 1 downto 0);
            b21, b22, b23: out std_logic_vector(nBitsPalabra - 1 downto 0);
            b31, b32, b33: out std_logic_vector(nBitsPalabra - 1 downto 0);
            Ikl: out std_logic_vector(nBitsPalabra - 1 downto 0);
            -- Bandera de estado
            ban: out std_logic
        );
    end component;

    component SieteSegmentos
        port
        (
            -- Señales de entrada
            clk : in std_logic;
            bin : in std_logic_vector(15 downto 0);
            -- Señales de salida
            SSEG_CA : out std_logic_vector(7 downto 0);
            SSEG_AN : out std_logic_vector(7 downto 0)
        );
    end component;

    component BinASieteSeg
        port
        (
            bin : in std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    component ModuloRAM
        Generic
        (	
            nBitsPalabra: integer:= 8; -- Ancho de palabra
            widthAddr: integer:= 8; -- Ancho de dirección
            sizeRAM: integer := 256 -- Cantidad de palabras
        );
        Port
        (	
            clk: in std_logic;
            we: in std_logic;
            en: in std_logic;
            addr_re: in std_logic_vector(widthAddr - 1 downto 0);
            addr_we: in std_logic_vector(widthAddr - 1 downto 0);
            DI: in std_logic_vector(nBitsPalabra - 1 downto 0);
            DO: out std_logic_vector(nBitsPalabra - 1 downto 0)
        );
    end component;

    component ReceptorImgEnt
        generic
        (
            nBitsDatoRx: integer := 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
            nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
            nBitsMaxY: integer:= 9 -- Cantidad de bits para direccionar 256 bytes en Y(1 byte = 8bits)
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            edo_rx: in std_logic;
            en: in std_logic;
            totalPixelX: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            totalPixelY: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            -- Señales de salida
            totalPixeles: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            we: out std_logic;
            addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            ban: out std_logic
        );
    end component;

    component ControlDeBloques
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
            codigo: out std_logic_vector(63 downto 0);
            estatusCodigo: out std_logic;
            ban: out std_logic
        );
    end component;

    component CalculadorDeBloques
        generic
        (
            nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
            nBitsMaxY: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)
            nBitsBloquesX: integer:= 6; -- Número de bits para direccionar la cantidad máxima de bloques en Y
            nBitsBloquesY: integer:= 6 -- Número de bits para direccionar la cantidad máxima de bloques en Y
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad total de pixeles en X
            totalPixelY: in std_logic_vector(nBitsMaxY - 1 downto 0); -- Cantidad total de pixeles en Y
            -- Señales de salida
            totalBloquesX: out std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en X
            totalBloquesY: out std_logic_vector(nBitsBloquesY - 1 downto 0); -- Cantidad total de bloques en Y
            ban: out std_logic
        );
    end component;

    component CalculadorPunteroCelulaInicial
        generic
        (
            nBitsMaxX: integer:= 9;
            nBitsMaxY: integer:= 9;
            nBitsBloquesX: integer:= 6;
            nBitsBloquesY: integer:= 6
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad total de pixeles en X
            totalBloquesX: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en X
            totalBloquesY: in std_logic_vector(nBitsBloquesY - 1 downto 0); -- Cantidad total de bloques en Y
            -- Señales de salida
            puntCel: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0); -- Celula inicial del bloque actual
            BloqueX: out std_logic_vector(nBitsBloquesX - 1 downto 0); -- Bloque actual en X
            BloqueY: out std_logic_vector(nBitsBloquesY - 1 downto 0); -- Bloque actual en Y
            ban: out std_logic;
            banFin: out std_logic
        );
    end component;

    component LeeImagenDeEntrada
        generic
        (
            nBitsDatoRx: integer := 16;
            nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
            nBitsMaxY: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)
            filas: integer:= 8;
            columnas: integer:= 8
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            DO: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad total de pixeles en X
            puntCel: in std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            -- Señales de salida
            addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            vu11, vu12, vu13, vu14, vu15, vu16, vu17, vu18: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu21, vu22, vu23, vu24, vu25, vu26, vu27, vu28: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu31, vu32, vu33, vu34, vu35, vu36, vu37, vu38: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu41, vu42, vu43, vu44, vu45, vu46, vu47, vu48: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu51, vu52, vu53, vu54, vu55, vu56, vu57, vu58: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu61, vu62, vu63, vu64, vu65, vu66, vu67, vu68: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu71, vu72, vu73, vu74, vu75, vu76, vu77, vu78: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu81, vu82, vu83, vu84, vu85, vu86, vu87, vu88: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            ban: out std_logic
        );
    end component;

    component Conversor8A16Bits
        generic
        (
            nBitsPalabra: integer:= 16;
            nBitsDatoRx: integer:= 8
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            vu11_8b, vu12_8b, vu13_8b, vu14_8b, vu15_8b, vu16_8b, vu17_8b, vu18_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu21_8b, vu22_8b, vu23_8b, vu24_8b, vu25_8b, vu26_8b, vu27_8b, vu28_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu31_8b, vu32_8b, vu33_8b, vu34_8b, vu35_8b, vu36_8b, vu37_8b, vu38_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu41_8b, vu42_8b, vu43_8b, vu44_8b, vu45_8b, vu46_8b, vu47_8b, vu48_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu51_8b, vu52_8b, vu53_8b, vu54_8b, vu55_8b, vu56_8b, vu57_8b, vu58_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu61_8b, vu62_8b, vu63_8b, vu64_8b, vu65_8b, vu66_8b, vu67_8b, vu68_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu71_8b, vu72_8b, vu73_8b, vu74_8b, vu75_8b, vu76_8b, vu77_8b, vu78_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vu81_8b, vu82_8b, vu83_8b, vu84_8b, vu85_8b, vu86_8b, vu87_8b, vu88_8b: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            -- Señales de salida
            vu11, vu12, vu13, vu14, vu15, vu16, vu17, vu18: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu21, vu22, vu23, vu24, vu25, vu26, vu27, vu28: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu31, vu32, vu33, vu34, vu35, vu36, vu37, vu38: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu41, vu42, vu43, vu44, vu45, vu46, vu47, vu48: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu51, vu52, vu53, vu54, vu55, vu56, vu57, vu58: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu61, vu62, vu63, vu64, vu65, vu66, vu67, vu68: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu71, vu72, vu73, vu74, vu75, vu76, vu77, vu78: out std_logic_vector(nBitsPalabra - 1 downto 0);
            vu81, vu82, vu83, vu84, vu85, vu86, vu87, vu88: out std_logic_vector(nBitsPalabra - 1 downto 0);
            ban: out std_logic
        );
    end component;

    component CNN_MxN
        Generic
        (
            widthWord : integer := 16;
            filas : integer := 4;
            columnas : integer := 4
        );
        Port
        (
            -- Entradas
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            -- Plantilla A
            a11, a12, a13 : in std_logic_vector(widthWord - 1 downto 0);
            a21, a22, a23 : in std_logic_vector(widthWord - 1 downto 0);
            a31, a32, a33 : in std_logic_vector(widthWord - 1 downto 0);
            -- Plantilla B
            b11, b12, b13 : in std_logic_vector(widthWord - 1 downto 0);
            b21, b22, b23 : in std_logic_vector(widthWord - 1 downto 0);
            b31, b32, b33 : in std_logic_vector(widthWord - 1 downto 0);
            -- Valor del bias
            Ikl : in std_logic_vector(widthWord - 1 downto 0);
            -- Entras de las celulas
            vu11, vu12, vu13, vu14, vu15, vu16, vu17, vu18 : in std_logic_vector(widthWord - 1 downto 0);
            vu21, vu22, vu23, vu24, vu25, vu26, vu27, vu28 : in std_logic_vector(widthWord - 1 downto 0);
            vu31, vu32, vu33, vu34, vu35, vu36, vu37, vu38 : in std_logic_vector(widthWord - 1 downto 0);
            vu41, vu42, vu43, vu44, vu45, vu46, vu47, vu48 : in std_logic_vector(widthWord - 1 downto 0);
            vu51, vu52, vu53, vu54, vu55, vu56, vu57, vu58 : in std_logic_vector(widthWord - 1 downto 0);
            vu61, vu62, vu63, vu64, vu65, vu66, vu67, vu68 : in std_logic_vector(widthWord - 1 downto 0);
            vu71, vu72, vu73, vu74, vu75, vu76, vu77, vu78 : in std_logic_vector(widthWord - 1 downto 0);
            vu81, vu82, vu83, vu84, vu85, vu86, vu87, vu88 : in std_logic_vector(widthWord - 1 downto 0);
            -- Salida de las celulas
            vy11, vy12, vy13, vy14, vy15, vy16, vy17, vy18 : out std_logic_vector(widthWord - 1 downto 0);
            vy21, vy22, vy23, vy24, vy25, vy26, vy27, vy28 : out std_logic_vector(widthWord - 1 downto 0);
            vy31, vy32, vy33, vy34, vy35, vy36, vy37, vy38 : out std_logic_vector(widthWord - 1 downto 0);
            vy41, vy42, vy43, vy44, vy45, vy46, vy47, vy48 : out std_logic_vector(widthWord - 1 downto 0);
            vy51, vy52, vy53, vy54, vy55, vy56, vy57, vy58 : out std_logic_vector(widthWord - 1 downto 0);
            vy61, vy62, vy63, vy64, vy65, vy66, vy67, vy68 : out std_logic_vector(widthWord - 1 downto 0);
            vy71, vy72, vy73, vy74, vy75, vy76, vy77, vy78 : out std_logic_vector(widthWord - 1 downto 0);
            vy81, vy82, vy83, vy84, vy85, vy86, vy87, vy88 : out std_logic_vector(widthWord - 1 downto 0);
            -- Banderas de estado
            ban : out std_logic := '0'
        );
    end component;

    component Celula
        Generic
        (
            widthWord : integer := 16
        );
        Port
        (
            clk : in std_logic;
            rst : in std_logic;
            -- Entradas
            en : in std_logic;
            -- Plantilla A
            a11, a12, a13 : in std_logic_vector(widthWord - 1 downto 0);
            a21, a22, a23 : in std_logic_vector(widthWord - 1 downto 0);
            a31, a32, a33 : in std_logic_vector(widthWord - 1 downto 0);
            -- Plantilla B
            b11, b12, b13 : in std_logic_vector(widthWord - 1 downto 0);
            b21, b22, b23 : in std_logic_vector(widthWord - 1 downto 0);
            b31, b32, b33 : in std_logic_vector(widthWord - 1 downto 0);
            -- Entradas de las celulas vecinas  
            vu11, vu12, vu13 : in std_logic_vector(widthWord - 1 downto 0);
            vu21, vu22, vu23 : in std_logic_vector(widthWord - 1 downto 0);
            vu31, vu32, vu33 : in std_logic_vector(widthWord - 1 downto 0);
            -- Salidas de las celulas vecinas
            vy11, vy12, vy13 : in std_logic_vector(widthWord - 1 downto 0);
            vy21, vy23 : in std_logic_vector(widthWord - 1 downto 0);
            vy31, vy32, vy33 : in std_logic_vector(widthWord - 1 downto 0);
            -- Valor del bias
            Ikl : in std_logic_vector(widthWord - 1 downto 0);
            -- Salidas
            vy : out std_logic_vector(widthWord - 1 downto 0);
            ban : out std_logic
        );
    end component;

    component Satlins
        generic
        (
            widthWord : integer := 16
        );
        port
        (   
            -- Se?ales de entrada
            vx : in std_logic_vector(2 * widthWord + 3 downto 0);
            -- Se?ales de salida
            vy : out std_logic_vector(widthWord - 1 downto 0);
            ban : out std_logic
        );
    end component;

    component Conversor16A8Bits
        generic
        (
            nBitsPalabra: integer:= 16;
            nBitsDatoRx: integer:= 8
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            vy11_16b, vy12_16b, vy13_16b, vy14_16b, vy15_16b, vy16_16b, vy17_16b, vy18_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy21_16b, vy22_16b, vy23_16b, vy24_16b, vy25_16b, vy26_16b, vy27_16b, vy28_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy31_16b, vy32_16b, vy33_16b, vy34_16b, vy35_16b, vy36_16b, vy37_16b, vy38_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy41_16b, vy42_16b, vy43_16b, vy44_16b, vy45_16b, vy46_16b, vy47_16b, vy48_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy51_16b, vy52_16b, vy53_16b, vy54_16b, vy55_16b, vy56_16b, vy57_16b, vy58_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy61_16b, vy62_16b, vy63_16b, vy64_16b, vy65_16b, vy66_16b, vy67_16b, vy68_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy71_16b, vy72_16b, vy73_16b, vy74_16b, vy75_16b, vy76_16b, vy77_16b, vy78_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            vy81_16b, vy82_16b, vy83_16b, vy84_16b, vy85_16b, vy86_16b, vy87_16b, vy88_16b: in std_logic_vector(nBitsPalabra - 1 downto 0);
            -- Señales de salida
            vy11, vy12, vy13, vy14, vy15, vy16, vy17, vy18: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy21, vy22, vy23, vy24, vy25, vy26, vy27, vy28: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy31, vy32, vy33, vy34, vy35, vy36, vy37, vy38: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy41, vy42, vy43, vy44, vy45, vy46, vy47, vy48: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy51, vy52, vy53, vy54, vy55, vy56, vy57, vy58: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy61, vy62, vy63, vy64, vy65, vy66, vy67, vy68: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy71, vy72, vy73, vy74, vy75, vy76, vy77, vy78: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy81, vy82, vy83, vy84, vy85, vy86, vy87, vy88: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            ban: out std_logic
        );
    end component;

    component EscribeImagenDeSalida
        generic
        (
            nBitsDatoRx: integer := 8;
            nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
            nBitsMaxY: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)
            nBitsBloquesX: integer:= 6; -- Ancho de palabra para dirección el máximo de bloques en X
            nBitsBloquesY: integer:= 6; -- Ancho de palabra para dirección el máximo de bloques en X
            filas: integer:= 8;
            columnas: integer:= 8
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad máxima de pixeles en X
            puntCel: in std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0); -- Puntero al pixel inicial
            BloqueX: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Bloque en X actual
            BloqueY: in std_logic_vector(nBitsBloquesY - 1 downto 0); -- Bloque en Y actual
            totalBloquesX: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en X
            totalBloquesY: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en Y
            vy11, vy12, vy13, vy14, vy15, vy16, vy17, vy18: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy21, vy22, vy23, vy24, vy25, vy26, vy27, vy28: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy31, vy32, vy33, vy34, vy35, vy36, vy37, vy38: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy41, vy42, vy43, vy44, vy45, vy46, vy47, vy48: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy51, vy52, vy53, vy54, vy55, vy56, vy57, vy58: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy61, vy62, vy63, vy64, vy65, vy66, vy67, vy68: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy71, vy72, vy73, vy74, vy75, vy76, vy77, vy78: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            vy81, vy82, vy83, vy84, vy85, vy86, vy87, vy88: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            -- Señales de salida
            addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            DI: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            we: out std_logic;
            ban: out std_logic
        );
    end component;

    component RegresaImgSal
        generic
        (
            nBitsDatoRx: integer:= 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
            nBitsMaxX: integer:= 8;
            nBitsMaxY: integer:= 8
        );
        port
        (
            -- Señales de entrada
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            dato_ent: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            edo_tx: in std_logic; 
            totalPixeles: in std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            -- Señales de salida
            addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
            en_tx: out std_logic;
            dato_tx: out std_logic_vector(nBitsDatoRx - 1 downto 0);
            ban: out std_logic
        );
    end component;

    component RS232Tx
        generic
        (
            nBitsDatoRx: integer:= 8
        );
        Port 
        ( 
            -- Señales de entrada
            clk: in std_logic;
            en: in std_logic;
            dato: in std_logic_vector(nBitsDatoRx - 1 downto 0);
            -- Señales de salida
            tx: out std_logic;
            edo_tx: out std_logic
        );
    end component;

    component FFMult
        Port
        (
            -- Entradas
            clk, rst, en: in std_logic;
            A, B: in std_logic_vector(162 downto 0);
            r: in std_logic_vector(162 downto 0);
            -- Salidas
            ce: out std_logic;
            C: out std_logic_vector(162 downto 0)
        );
    end component;

    component MultiplicacionEscalar
        port
        (
            -- Entradas
            clk, rst, en: in std_logic;
            k: in std_logic_vector(162 downto 0);
            -- Salidas
            Estatus: out std_logic;
            QX, QZ: out std_logic_vector(162 downto 0)
        );
    end component;

    component FFAdd
        Port
        (
            -- Entradas
            A, B: in std_logic_vector(162 downto 0);
            -- Salidas
            C: out std_logic_vector(162 downto 0)
        );
    end component;

end Componentes;