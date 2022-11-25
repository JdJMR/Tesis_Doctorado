----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: José de Jesús Morales Romero
-- 
-- Design Name: CNN_MxN
-- Module Name: Conversor8A16Bits - Behavioral
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.0
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Conversor8A16Bits is
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
end Conversor8A16Bits;

architecture Behavioral of Conversor8A16Bits is

    -- Constantes
    constant uno: signed(nBitsPalabra - 1 downto 0):= X"0200"; -- Valor de 1 en 16 bits
    constant nuno: signed(nBitsPalabra - 1 downto 0):= X"FE00"; -- Valor de -1 en 16 bits

    -- Contadores
    signal cont: unsigned(5 downto 0):= (others => '0');

    -- Registros temporales
    signal regEnt: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal regSal_t: signed(nBitsPalabra  - 1 downto 0):= (others => '0');
    signal regSal: signed(nBitsPalabra  - 1 downto 0):= (others => '0');
    signal div: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');

    -- Registros dememoria
    signal vu11_t, vu12_t, vu13_t, vu14_t, vu15_t, vu16_t, vu17_t, vu18_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu21_t, vu22_t, vu23_t, vu24_t, vu25_t, vu26_t, vu27_t, vu28_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu31_t, vu32_t, vu33_t, vu34_t, vu35_t, vu36_t, vu37_t, vu38_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu41_t, vu42_t, vu43_t, vu44_t, vu45_t, vu46_t, vu47_t, vu48_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu51_t, vu52_t, vu53_t, vu54_t, vu55_t, vu56_t, vu57_t, vu58_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu61_t, vu62_t, vu63_t, vu64_t, vu65_t, vu66_t, vu67_t, vu68_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu71_t, vu72_t, vu73_t, vu74_t, vu75_t, vu76_t, vu77_t, vu78_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');
    signal vu81_t, vu82_t, vu83_t, vu84_t, vu85_t, vu86_t, vu87_t, vu88_t: signed(nBitsPalabra - 1 downto 0):= (others => '0');

begin

    Contador: process(clk, rst, en)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                cont <= (others => '0');
            else
                if(en = '1')then
                    if(cont < "111111")then
                        cont <= cont + 1;
                    else
                        cont <= "111111";
                    end if;
                    
                else
                    cont <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    MultiplexorEnt: process(clk, cont, regEnt)
    begin
        if(falling_edge(clk))then
            if   (cont = "000000")then regEnt <= vu11_8b;
            elsif(cont = "000001")then regEnt <= vu12_8b;
            elsif(cont = "000010")then regEnt <= vu13_8b;
            elsif(cont = "000011")then regEnt <= vu14_8b;
            elsif(cont = "000100")then regEnt <= vu15_8b;
            elsif(cont = "000101")then regEnt <= vu16_8b;
            elsif(cont = "000110")then regEnt <= vu17_8b;
            elsif(cont = "000111")then regEnt <= vu18_8b;
            elsif(cont = "001000")then regEnt <= vu21_8b;
            elsif(cont = "001001")then regEnt <= vu22_8b;
            elsif(cont = "001010")then regEnt <= vu23_8b;
            elsif(cont = "001011")then regEnt <= vu24_8b;
            elsif(cont = "001100")then regEnt <= vu25_8b;
            elsif(cont = "001101")then regEnt <= vu26_8b;
            elsif(cont = "001110")then regEnt <= vu27_8b;
            elsif(cont = "001111")then regEnt <= vu28_8b;
            elsif(cont = "010000")then regEnt <= vu31_8b;
            elsif(cont = "010001")then regEnt <= vu32_8b;
            elsif(cont = "010010")then regEnt <= vu33_8b;
            elsif(cont = "010011")then regEnt <= vu34_8b;
            elsif(cont = "010100")then regEnt <= vu35_8b;
            elsif(cont = "010101")then regEnt <= vu36_8b;
            elsif(cont = "010110")then regEnt <= vu37_8b;
            elsif(cont = "010111")then regEnt <= vu38_8b;
            elsif(cont = "011000")then regEnt <= vu41_8b;
            elsif(cont = "011001")then regEnt <= vu42_8b;
            elsif(cont = "011010")then regEnt <= vu43_8b;
            elsif(cont = "011011")then regEnt <= vu44_8b;
            elsif(cont = "011100")then regEnt <= vu45_8b;
            elsif(cont = "011101")then regEnt <= vu46_8b;
            elsif(cont = "011110")then regEnt <= vu47_8b;
            elsif(cont = "011111")then regEnt <= vu48_8b;
            elsif(cont = "100000")then regEnt <= vu51_8b;
            elsif(cont = "100001")then regEnt <= vu52_8b;
            elsif(cont = "100010")then regEnt <= vu53_8b;
            elsif(cont = "100011")then regEnt <= vu54_8b;
            elsif(cont = "100100")then regEnt <= vu55_8b;
            elsif(cont = "100101")then regEnt <= vu56_8b;
            elsif(cont = "100110")then regEnt <= vu57_8b;
            elsif(cont = "100111")then regEnt <= vu58_8b;
            elsif(cont = "101000")then regEnt <= vu61_8b;
            elsif(cont = "101001")then regEnt <= vu62_8b;
            elsif(cont = "101010")then regEnt <= vu63_8b;
            elsif(cont = "101011")then regEnt <= vu64_8b;
            elsif(cont = "101100")then regEnt <= vu65_8b;
            elsif(cont = "101101")then regEnt <= vu66_8b;
            elsif(cont = "101110")then regEnt <= vu67_8b;
            elsif(cont = "101111")then regEnt <= vu68_8b;
            elsif(cont = "110000")then regEnt <= vu71_8b;
            elsif(cont = "110001")then regEnt <= vu72_8b;
            elsif(cont = "110010")then regEnt <= vu73_8b;
            elsif(cont = "110011")then regEnt <= vu74_8b;
            elsif(cont = "110100")then regEnt <= vu75_8b;
            elsif(cont = "110101")then regEnt <= vu76_8b;
            elsif(cont = "110110")then regEnt <= vu77_8b;
            elsif(cont = "110111")then regEnt <= vu78_8b;
            elsif(cont = "111000")then regEnt <= vu81_8b;
            elsif(cont = "111001")then regEnt <= vu82_8b;
            elsif(cont = "111010")then regEnt <= vu83_8b;
            elsif(cont = "111011")then regEnt <= vu84_8b;
            elsif(cont = "111100")then regEnt <= vu85_8b;
            elsif(cont = "111101")then regEnt <= vu86_8b;
            elsif(cont = "111110")then regEnt <= vu87_8b;
            elsif(cont = "111111")then regEnt <= vu88_8b;         
            else
                regEnt <= regEnt;
            end if;
        end if;
    end process;

    -- División 2*reg/255 (se realiza con corrimientos, revisar algoritmos)
    div(9 downto 2) <= regEnt;
    div(1 downto 0) <= regEnt(7 downto 6);

    -- Resta 1 - div
    regSal_t <= uno - signed(div);

    Convierte: process(regEnt, regSal_t)
    begin
        if(regEnt = X"00")then
            regSal <= uno;
        elsif(regEnt = X"FF")then
            regSal <= nuno;
        else
            regSal <= regSal_t;
        end if;
    end process;

    MultiplexorSal: process(clk, cont, vu11_t, vu12_t, vu13_t, vu14_t, vu15_t, vu16_t, vu17_t, vu18_t,
                                       vu21_t, vu22_t, vu23_t, vu24_t, vu25_t, vu26_t, vu27_t, vu28_t,
                                       vu31_t, vu32_t, vu33_t, vu34_t, vu35_t, vu36_t, vu37_t, vu38_t,
                                       vu41_t, vu42_t, vu43_t, vu44_t, vu45_t, vu46_t, vu47_t, vu48_t,
                                       vu51_t, vu52_t, vu53_t, vu54_t, vu55_t, vu56_t, vu57_t, vu58_t,
                                       vu61_t, vu62_t, vu63_t, vu64_t, vu65_t, vu66_t, vu67_t, vu68_t,
                                       vu71_t, vu72_t, vu73_t, vu74_t, vu75_t, vu76_t, vu77_t, vu78_t,
                                       vu81_t, vu82_t, vu83_t, vu84_t, vu85_t, vu86_t, vu87_t, vu88_t)
    begin
        if(rising_edge(clk))then
            if   (cont = "000000")then vu11_t <= regSal;
            elsif(cont = "000001")then vu12_t <= regSal;
            elsif(cont = "000010")then vu13_t <= regSal;
            elsif(cont = "000011")then vu14_t <= regSal;
            elsif(cont = "000100")then vu15_t <= regSal;
            elsif(cont = "000101")then vu16_t <= regSal;
            elsif(cont = "000110")then vu17_t <= regSal;
            elsif(cont = "000111")then vu18_t <= regSal;
            elsif(cont = "001000")then vu21_t <= regSal;
            elsif(cont = "001001")then vu22_t <= regSal;
            elsif(cont = "001010")then vu23_t <= regSal;
            elsif(cont = "001011")then vu24_t <= regSal;
            elsif(cont = "001100")then vu25_t <= regSal;
            elsif(cont = "001101")then vu26_t <= regSal;
            elsif(cont = "001110")then vu27_t <= regSal;
            elsif(cont = "001111")then vu28_t <= regSal;
            elsif(cont = "010000")then vu31_t <= regSal;
            elsif(cont = "010001")then vu32_t <= regSal;
            elsif(cont = "010010")then vu33_t <= regSal;
            elsif(cont = "010011")then vu34_t <= regSal;
            elsif(cont = "010100")then vu35_t <= regSal;
            elsif(cont = "010101")then vu36_t <= regSal;
            elsif(cont = "010110")then vu37_t <= regSal;
            elsif(cont = "010111")then vu38_t <= regSal;
            elsif(cont = "011000")then vu41_t <= regSal;
            elsif(cont = "011001")then vu42_t <= regSal;
            elsif(cont = "011010")then vu43_t <= regSal;
            elsif(cont = "011011")then vu44_t <= regSal;
            elsif(cont = "011100")then vu45_t <= regSal;
            elsif(cont = "011101")then vu46_t <= regSal;
            elsif(cont = "011110")then vu47_t <= regSal;
            elsif(cont = "011111")then vu48_t <= regSal;
            elsif(cont = "100000")then vu51_t <= regSal;
            elsif(cont = "100001")then vu52_t <= regSal;
            elsif(cont = "100010")then vu53_t <= regSal;
            elsif(cont = "100011")then vu54_t <= regSal;
            elsif(cont = "100100")then vu55_t <= regSal;
            elsif(cont = "100101")then vu56_t <= regSal;
            elsif(cont = "100110")then vu57_t <= regSal;
            elsif(cont = "100111")then vu58_t <= regSal;
            elsif(cont = "101000")then vu61_t <= regSal;
            elsif(cont = "101001")then vu62_t <= regSal;
            elsif(cont = "101010")then vu63_t <= regSal;
            elsif(cont = "101011")then vu64_t <= regSal;
            elsif(cont = "101100")then vu65_t <= regSal;
            elsif(cont = "101101")then vu66_t <= regSal;
            elsif(cont = "101110")then vu67_t <= regSal;
            elsif(cont = "101111")then vu68_t <= regSal;
            elsif(cont = "110000")then vu71_t <= regSal;
            elsif(cont = "110001")then vu72_t <= regSal;
            elsif(cont = "110010")then vu73_t <= regSal;
            elsif(cont = "110011")then vu74_t <= regSal;
            elsif(cont = "110100")then vu75_t <= regSal;
            elsif(cont = "110101")then vu76_t <= regSal;
            elsif(cont = "110110")then vu77_t <= regSal;
            elsif(cont = "110111")then vu78_t <= regSal;
            elsif(cont = "111000")then vu81_t <= regSal;
            elsif(cont = "111001")then vu82_t <= regSal;
            elsif(cont = "111010")then vu83_t <= regSal;
            elsif(cont = "111011")then vu84_t <= regSal;
            elsif(cont = "111100")then vu85_t <= regSal;
            elsif(cont = "111101")then vu86_t <= regSal;
            elsif(cont = "111110")then vu87_t <= regSal;
            elsif(cont = "111111")then vu88_t <= regSal;         
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

    -- Salidas
    vu11 <= std_logic_vector(vu11_t); vu12 <= std_logic_vector(vu12_t); vu13 <= std_logic_vector(vu13_t); vu14 <= std_logic_vector(vu14_t); vu15 <= std_logic_vector(vu15_t); vu16 <= std_logic_vector(vu16_t); vu17 <= std_logic_vector(vu17_t); vu18 <= std_logic_vector(vu18_t);
    vu21 <= std_logic_vector(vu21_t); vu22 <= std_logic_vector(vu22_t); vu23 <= std_logic_vector(vu23_t); vu24 <= std_logic_vector(vu24_t); vu25 <= std_logic_vector(vu25_t); vu26 <= std_logic_vector(vu26_t); vu27 <= std_logic_vector(vu27_t); vu28 <= std_logic_vector(vu28_t);
    vu31 <= std_logic_vector(vu31_t); vu32 <= std_logic_vector(vu32_t); vu33 <= std_logic_vector(vu33_t); vu34 <= std_logic_vector(vu34_t); vu35 <= std_logic_vector(vu35_t); vu36 <= std_logic_vector(vu36_t); vu37 <= std_logic_vector(vu37_t); vu38 <= std_logic_vector(vu38_t);
    vu41 <= std_logic_vector(vu41_t); vu42 <= std_logic_vector(vu42_t); vu43 <= std_logic_vector(vu43_t); vu44 <= std_logic_vector(vu44_t); vu45 <= std_logic_vector(vu45_t); vu46 <= std_logic_vector(vu46_t); vu47 <= std_logic_vector(vu47_t); vu48 <= std_logic_vector(vu48_t);
    vu51 <= std_logic_vector(vu51_t); vu52 <= std_logic_vector(vu52_t); vu53 <= std_logic_vector(vu53_t); vu54 <= std_logic_vector(vu54_t); vu55 <= std_logic_vector(vu55_t); vu56 <= std_logic_vector(vu56_t); vu57 <= std_logic_vector(vu57_t); vu58 <= std_logic_vector(vu58_t);
    vu61 <= std_logic_vector(vu61_t); vu62 <= std_logic_vector(vu62_t); vu63 <= std_logic_vector(vu63_t); vu64 <= std_logic_vector(vu64_t); vu65 <= std_logic_vector(vu65_t); vu66 <= std_logic_vector(vu66_t); vu67 <= std_logic_vector(vu67_t); vu68 <= std_logic_vector(vu68_t);
    vu71 <= std_logic_vector(vu71_t); vu72 <= std_logic_vector(vu72_t); vu73 <= std_logic_vector(vu73_t); vu74 <= std_logic_vector(vu74_t); vu75 <= std_logic_vector(vu75_t); vu76 <= std_logic_vector(vu76_t); vu77 <= std_logic_vector(vu77_t); vu78 <= std_logic_vector(vu78_t);
    vu81 <= std_logic_vector(vu81_t); vu82 <= std_logic_vector(vu82_t); vu83 <= std_logic_vector(vu83_t); vu84 <= std_logic_vector(vu84_t); vu85 <= std_logic_vector(vu85_t); vu86 <= std_logic_vector(vu86_t); vu87 <= std_logic_vector(vu87_t); vu88 <= std_logic_vector(vu88_t);

    -- Bandera de salida
    Bandera: process(clk, cont)
    begin
        if(rising_edge(clk))then
            if(cont = "111111")then
                ban <= '1';
            else
                ban <= '0';
            end if;
        end if;
    end process;

end Behavioral;
