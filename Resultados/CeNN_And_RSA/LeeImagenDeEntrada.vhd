library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;

entity LeeImagenDeEntrada is
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
end LeeImagenDeEntrada;

architecture Behavioral of LeeImagenDeEntrada is
    
    -- Constantes
     constant maxFil: std_logic_vector(3 downto 0):= conv_std_logic_vector(filas - 1, 4);
    constant maxCol: std_logic_vector(3 downto 0):= conv_std_logic_vector(columnas - 1, 4);
    
    -- Contadores
    signal contFil: unsigned(3 downto 0):= (others => '0');
    signal contCol: unsigned(3 downto 0):= (others => '1');
    signal cont: unsigned(5 downto 0):= (others => '1');
    
    -- Dirección
    signal addr_t1: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal addr_t2: unsigned(nBitsMaxX - 1 downto 0):= (others => '0');
    signal addr_t3: unsigned(nBitsMaxX + 3 downto 0):= (others => '0');
    signal addr_t4: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    
    -- Valores temporales
    signal vu11_t, vu12_t, vu13_t, vu14_t, vu15_t, vu16_t, vu17_t, vu18_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu21_t, vu22_t, vu23_t, vu24_t, vu25_t, vu26_t, vu27_t, vu28_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu31_t, vu32_t, vu33_t, vu34_t, vu35_t, vu36_t, vu37_t, vu38_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu41_t, vu42_t, vu43_t, vu44_t, vu45_t, vu46_t, vu47_t, vu48_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu51_t, vu52_t, vu53_t, vu54_t, vu55_t, vu56_t, vu57_t, vu58_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu61_t, vu62_t, vu63_t, vu64_t, vu65_t, vu66_t, vu67_t, vu68_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu71_t, vu72_t, vu73_t, vu74_t, vu75_t, vu76_t, vu77_t, vu78_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal vu81_t, vu82_t, vu83_t, vu84_t, vu85_t, vu86_t, vu87_t, vu88_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    
    -- Máquina de estados
    type Estados is (Espera, SumaCol, CompruebaCol, SumaFil, CompruebaFil, GuardaDo, Finaliza);
    signal EdoPres, EdoFut: Estados;
     
begin

    ----------------------------------------------------------------------------------
    ----------                         Este módulo                          ----------
    ----------------------------------------------------------------------------------
    Avance: process(clk, rst)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                EdoPres <= Espera;
            else
                EdoPres <= EdoFut;
            end if;
        end if;
    end process;
    
    Maquina: process(EdoPres, en, contCol, contFil)
    begin
        case EdoPres is
            when Espera =>
                if(en = '1')then
                    EdoFut <= SumaCol;
                else
                    EdoFut <= Espera;
                end if;
            when SumaCol =>
                EdoFut <= CompruebaCol;
            when CompruebaCol =>
                if(contCol > unsigned(maxCol))then
                    EdoFut <= SumaFil;
                else
                    EdoFut <= GuardaDo;
                end if;
            when SumaFil =>
                EdoFut <= CompruebaFil;
            when CompruebaFil =>
                if(contFil > unsigned(maxFil))then
                    EdoFut <= Finaliza;
                else
                    EdoFut <= GuardaDo;
                end if;
            when GuardaDo =>
                EdoFut <= SumaCol; 
            when Finaliza =>
                if(en = '1')then
                    EdoFut <= Finaliza;
                else
                    EdoFut <= Espera;
                end if;
        end case;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                         Contadores                           ----------
    ----------------------------------------------------------------------------------
    ContColumnas: process(clk, EdoPres, contCol)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Espera)then
                contCol <= (others => '1');
            elsif(EdoPres = SumaCol)then
                contCol <= contCol + 1;
            elsif(EdoPres = SumaFil)then
                contCol <= (others => '0');
            else
                contCol <= contCol;
            end if;
        end if;
    end process;
    
    ContFilas: process(clk, EdoPres, contFil)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Espera)then
                contFil <= (others => '0');
            elsif(EdoPres = SumaFil)then
                contFil <= contFil + 1;
            else
                contFil <= contFil;
            end if;
        end if;
    end process;
    
    Contador: process(clk, EdoPres, cont)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Espera)then
                cont <= (others => '1');
            elsif(EdoPres = SumaCol)then
                cont <= cont + 1;
            else
                cont <= cont;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                         Dirección                            ----------
    ----------------------------------------------------------------------------------
    addr_t1 <= unsigned(puntCel) + resize(contFil, nBitsMaxX + nBitsMaxY) + resize(contCol, nBitsMaxX + nBitsMaxY);
    addr_t2 <= unsigned(totalPixelX) - 1;
    addr_t3 <= addr_t2 * contFil;
    addr_t4 <= addr_t1 + resize(addr_t3, nBitsMaxX + nBitsMaxY);

    ----------------------------------------------------------------------------------
    ----------                         Guarda Do                            ----------
    ----------------------------------------------------------------------------------
    GuardaValDo: process(clk, EdoPres, cont, DO, 
                         vu11_t, vu12_t, vu13_t, vu14_t, vu15_t, vu16_t, vu17_t, vu18_t,
                         vu21_t, vu22_t, vu23_t, vu24_t, vu25_t, vu26_t, vu27_t, vu28_t,
                         vu31_t, vu32_t, vu33_t, vu34_t, vu35_t, vu36_t, vu37_t, vu38_t,
                         vu41_t, vu42_t, vu43_t, vu44_t, vu45_t, vu46_t, vu47_t, vu48_t,
                         vu51_t, vu52_t, vu53_t, vu54_t, vu55_t, vu56_t, vu57_t, vu58_t,
                         vu61_t, vu62_t, vu63_t, vu64_t, vu65_t, vu66_t, vu67_t, vu68_t,
                         vu71_t, vu72_t, vu73_t, vu74_t, vu75_t, vu76_t, vu77_t, vu78_t,
                         vu81_t, vu82_t, vu83_t, vu84_t, vu85_t, vu86_t, vu87_t, vu88_t)
    begin
        if(falling_edge(clk))then
            if(EdoPres = GuardaDo)then
                if   (cont = "000000")then vu11_t <= DO;
                elsif(cont = "000001")then vu12_t <= DO;
                elsif(cont = "000010")then vu13_t <= DO;
                elsif(cont = "000011")then vu14_t <= DO;
                elsif(cont = "000100")then vu15_t <= DO;
                elsif(cont = "000101")then vu16_t <= DO;
                elsif(cont = "000110")then vu17_t <= DO;
                elsif(cont = "000111")then vu18_t <= DO;
                elsif(cont = "001000")then vu21_t <= DO;
                elsif(cont = "001001")then vu22_t <= DO;
                elsif(cont = "001010")then vu23_t <= DO;
                elsif(cont = "001011")then vu24_t <= DO;
                elsif(cont = "001100")then vu25_t <= DO;
                elsif(cont = "001101")then vu26_t <= DO;
                elsif(cont = "001110")then vu27_t <= DO;
                elsif(cont = "001111")then vu28_t <= DO;
                elsif(cont = "010000")then vu31_t <= DO;
                elsif(cont = "010001")then vu32_t <= DO;
                elsif(cont = "010010")then vu33_t <= DO;
                elsif(cont = "010011")then vu34_t <= DO;
                elsif(cont = "010100")then vu35_t <= DO;
                elsif(cont = "010101")then vu36_t <= DO;
                elsif(cont = "010110")then vu37_t <= DO;
                elsif(cont = "010111")then vu38_t <= DO;
                elsif(cont = "011000")then vu41_t <= DO;
                elsif(cont = "011001")then vu42_t <= DO;
                elsif(cont = "011010")then vu43_t <= DO;
                elsif(cont = "011011")then vu44_t <= DO;
                elsif(cont = "011100")then vu45_t <= DO;
                elsif(cont = "011101")then vu46_t <= DO;
                elsif(cont = "011110")then vu47_t <= DO;
                elsif(cont = "011111")then vu48_t <= DO;
                elsif(cont = "100000")then vu51_t <= DO;
                elsif(cont = "100001")then vu52_t <= DO;
                elsif(cont = "100010")then vu53_t <= DO;
                elsif(cont = "100011")then vu54_t <= DO;
                elsif(cont = "100100")then vu55_t <= DO;
                elsif(cont = "100101")then vu56_t <= DO;
                elsif(cont = "100110")then vu57_t <= DO;
                elsif(cont = "100111")then vu58_t <= DO;
                elsif(cont = "101000")then vu61_t <= DO;
                elsif(cont = "101001")then vu62_t <= DO;
                elsif(cont = "101010")then vu63_t <= DO;
                elsif(cont = "101011")then vu64_t <= DO;
                elsif(cont = "101100")then vu65_t <= DO;
                elsif(cont = "101101")then vu66_t <= DO;
                elsif(cont = "101110")then vu67_t <= DO;
                elsif(cont = "101111")then vu68_t <= DO;
                elsif(cont = "110000")then vu71_t <= DO;
                elsif(cont = "110001")then vu72_t <= DO;
                elsif(cont = "110010")then vu73_t <= DO;
                elsif(cont = "110011")then vu74_t <= DO;
                elsif(cont = "110100")then vu75_t <= DO;
                elsif(cont = "110101")then vu76_t <= DO;
                elsif(cont = "110110")then vu77_t <= DO;
                elsif(cont = "110111")then vu78_t <= DO;
                elsif(cont = "111000")then vu81_t <= DO;
                elsif(cont = "111001")then vu82_t <= DO;
                elsif(cont = "111010")then vu83_t <= DO;
                elsif(cont = "111011")then vu84_t <= DO;
                elsif(cont = "111100")then vu85_t <= DO;
                elsif(cont = "111101")then vu86_t <= DO;
                elsif(cont = "111110")then vu87_t <= DO;                                
                else vu88_t <= DO;
                end if;
            else
                vu11_t <= vu11_t; vu12_t <= vu12_t; vu13_t <= vu13_t; vu14_t <= vu14_t; vu15_t <= vu15_t; vu16_t <= vu16_t; vu17_t <= vu17_t; vu18_t <= vu18_t;
                vu21_t <= vu21_t; vu22_t <= vu22_t; vu23_t <= vu23_t; vu24_t <= vu24_t; vu25_t <= vu25_t; vu26_t <= vu26_t; vu27_t <= vu27_t; vu28_t <= vu28_t;
                vu31_t <= vu31_t; vu32_t <= vu32_t; vu33_t <= vu33_t; vu34_t <= vu34_t; vu35_t <= vu35_t; vu36_t <= vu36_t; vu37_t <= vu37_t; vu38_t <= vu38_t;
                vu41_t <= vu41_t; vu42_t <= vu42_t; vu43_t <= vu43_t; vu44_t <= vu44_t; vu45_t <= vu45_t; vu46_t <= vu46_t; vu47_t <= vu47_t; vu48_t <= vu48_t;
                vu51_t <= vu51_t; vu52_t <= vu52_t; vu53_t <= vu53_t; vu54_t <= vu54_t; vu55_t <= vu55_t; vu56_t <= vu56_t; vu57_t <= vu57_t; vu58_t <= vu58_t;
                vu61_t <= vu61_t; vu62_t <= vu62_t; vu63_t <= vu63_t; vu64_t <= vu64_t; vu65_t <= vu65_t; vu66_t <= vu66_t; vu67_t <= vu67_t; vu68_t <= vu68_t;
                vu71_t <= vu71_t; vu72_t <= vu72_t; vu73_t <= vu73_t; vu74_t <= vu74_t; vu75_t <= vu75_t; vu76_t <= vu76_t; vu77_t <= vu77_t; vu78_t <= vu78_t;
                vu81_t <= vu81_t; vu82_t <= vu82_t; vu83_t <= vu83_t; vu84_t <= vu84_t; vu85_t <= vu85_t; vu86_t <= vu86_t; vu87_t <= vu87_t; vu88_t <= vu88_t;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                          Salida                              ----------
    ----------------------------------------------------------------------------------
    ban <= '1' when (EdoPres = Finaliza) else '0';
    addr <= std_logic_vector(addr_t4);
    
    vu11 <= vu11_t; vu12 <= vu12_t; vu13 <= vu13_t; vu14 <= vu14_t; vu15 <= vu15_t; vu16 <= vu16_t; vu17 <= vu17_t; vu18 <= vu18_t;
    vu21 <= vu21_t; vu22 <= vu22_t; vu23 <= vu23_t; vu24 <= vu24_t; vu25 <= vu25_t; vu26 <= vu26_t; vu27 <= vu27_t; vu28 <= vu28_t;
    vu31 <= vu31_t; vu32 <= vu32_t; vu33 <= vu33_t; vu34 <= vu34_t; vu35 <= vu35_t; vu36 <= vu36_t; vu37 <= vu37_t; vu38 <= vu38_t;
    vu41 <= vu41_t; vu42 <= vu42_t; vu43 <= vu43_t; vu44 <= vu44_t; vu45 <= vu45_t; vu46 <= vu46_t; vu47 <= vu47_t; vu48 <= vu48_t;
    vu51 <= vu51_t; vu52 <= vu52_t; vu53 <= vu53_t; vu54 <= vu54_t; vu55 <= vu55_t; vu56 <= vu56_t; vu57 <= vu57_t; vu58 <= vu58_t;
    vu61 <= vu61_t; vu62 <= vu62_t; vu63 <= vu63_t; vu64 <= vu64_t; vu65 <= vu65_t; vu66 <= vu66_t; vu67 <= vu67_t; vu68 <= vu68_t;
    vu71 <= vu71_t; vu72 <= vu72_t; vu73 <= vu73_t; vu74 <= vu74_t; vu75 <= vu75_t; vu76 <= vu76_t; vu77 <= vu77_t; vu78 <= vu78_t;
    vu81 <= vu81_t; vu82 <= vu82_t; vu83 <= vu83_t; vu84 <= vu84_t; vu85 <= vu85_t; vu86 <= vu86_t; vu87 <= vu87_t; vu88 <= vu88_t;
    
end Behavioral;
