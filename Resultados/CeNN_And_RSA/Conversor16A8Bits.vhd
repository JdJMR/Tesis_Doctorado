library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Conversor16A8Bits is
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
end Conversor16A8Bits;

architecture Behavioral of Conversor16A8Bits is

    -- Constantes
    constant uno: std_logic_vector(nBitsPalabra - 1 downto 0):= X"0200";
    constant nuno: std_logic_vector(nBitsPalabra - 1 downto 0):= X"FE00";
    -- Contadores
    signal cont: unsigned(2 downto 0):= (others => '0');

begin

    Contador: process(clk, rst, cont, en)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                cont <= (others => '0');
            else
                if(en = '1')then
                    if(cont <= "100")then
                        cont <= cont + 1;
                    else
                        cont <= cont;
                    end if;
                else
                    cont <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    process(vy11_16b) begin if(vy11_16b = uno)then vy11 <= X"00"; elsif(vy11_16b = nuno)then vy11 <= X"FF"; else vy11 <= vy11_16b(15 downto 8); end if; end process;
    process(vy12_16b) begin if(vy12_16b = uno)then vy12 <= X"00"; elsif(vy12_16b = nuno)then vy12 <= X"FF"; else vy12 <= vy12_16b(15 downto 8); end if; end process;
    process(vy13_16b) begin if(vy13_16b = uno)then vy13 <= X"00"; elsif(vy13_16b = nuno)then vy13 <= X"FF"; else vy13 <= vy13_16b(15 downto 8); end if; end process;
    process(vy14_16b) begin if(vy14_16b = uno)then vy14 <= X"00"; elsif(vy14_16b = nuno)then vy14 <= X"FF"; else vy14 <= vy14_16b(15 downto 8); end if; end process;
    process(vy15_16b) begin if(vy15_16b = uno)then vy15 <= X"00"; elsif(vy15_16b = nuno)then vy15 <= X"FF"; else vy15 <= vy15_16b(15 downto 8); end if; end process;
    process(vy16_16b) begin if(vy16_16b = uno)then vy16 <= X"00"; elsif(vy16_16b = nuno)then vy16 <= X"FF"; else vy16 <= vy16_16b(15 downto 8); end if; end process;
    process(vy17_16b) begin if(vy17_16b = uno)then vy17 <= X"00"; elsif(vy17_16b = nuno)then vy17 <= X"FF"; else vy17 <= vy17_16b(15 downto 8); end if; end process;
    process(vy18_16b) begin if(vy18_16b = uno)then vy18 <= X"00"; elsif(vy18_16b = nuno)then vy18 <= X"FF"; else vy18 <= vy18_16b(15 downto 8); end if; end process;
    
    process(vy21_16b) begin if(vy21_16b = uno)then vy21 <= X"00"; elsif(vy21_16b = nuno)then vy21 <= X"FF"; else vy21 <= vy21_16b(15 downto 8); end if; end process;
    process(vy22_16b) begin if(vy22_16b = uno)then vy22 <= X"00"; elsif(vy22_16b = nuno)then vy22 <= X"FF"; else vy22 <= vy22_16b(15 downto 8); end if; end process;
    process(vy23_16b) begin if(vy23_16b = uno)then vy23 <= X"00"; elsif(vy23_16b = nuno)then vy23 <= X"FF"; else vy23 <= vy23_16b(15 downto 8); end if; end process;
    process(vy24_16b) begin if(vy24_16b = uno)then vy24 <= X"00"; elsif(vy24_16b = nuno)then vy24 <= X"FF"; else vy24 <= vy24_16b(15 downto 8); end if; end process;
    process(vy25_16b) begin if(vy25_16b = uno)then vy25 <= X"00"; elsif(vy25_16b = nuno)then vy25 <= X"FF"; else vy25 <= vy25_16b(15 downto 8); end if; end process;
    process(vy26_16b) begin if(vy26_16b = uno)then vy26 <= X"00"; elsif(vy26_16b = nuno)then vy26 <= X"FF"; else vy26 <= vy26_16b(15 downto 8); end if; end process;
    process(vy27_16b) begin if(vy27_16b = uno)then vy27 <= X"00"; elsif(vy27_16b = nuno)then vy27 <= X"FF"; else vy27 <= vy27_16b(15 downto 8); end if; end process;
    process(vy28_16b) begin if(vy28_16b = uno)then vy28 <= X"00"; elsif(vy28_16b = nuno)then vy28 <= X"FF"; else vy28 <= vy28_16b(15 downto 8); end if; end process;

    process(vy31_16b) begin if(vy31_16b = uno)then vy31 <= X"00"; elsif(vy31_16b = nuno)then vy31 <= X"FF"; else vy31 <= vy31_16b(15 downto 8); end if; end process;
    process(vy32_16b) begin if(vy32_16b = uno)then vy32 <= X"00"; elsif(vy32_16b = nuno)then vy32 <= X"FF"; else vy32 <= vy32_16b(15 downto 8); end if; end process;
    process(vy33_16b) begin if(vy33_16b = uno)then vy33 <= X"00"; elsif(vy33_16b = nuno)then vy33 <= X"FF"; else vy33 <= vy33_16b(15 downto 8); end if; end process;
    process(vy34_16b) begin if(vy34_16b = uno)then vy34 <= X"00"; elsif(vy34_16b = nuno)then vy34 <= X"FF"; else vy34 <= vy34_16b(15 downto 8); end if; end process;
    process(vy35_16b) begin if(vy35_16b = uno)then vy35 <= X"00"; elsif(vy35_16b = nuno)then vy35 <= X"FF"; else vy35 <= vy35_16b(15 downto 8); end if; end process;
    process(vy36_16b) begin if(vy36_16b = uno)then vy36 <= X"00"; elsif(vy36_16b = nuno)then vy36 <= X"FF"; else vy36 <= vy36_16b(15 downto 8); end if; end process;
    process(vy37_16b) begin if(vy37_16b = uno)then vy37 <= X"00"; elsif(vy37_16b = nuno)then vy37 <= X"FF"; else vy37 <= vy37_16b(15 downto 8); end if; end process;
    process(vy38_16b) begin if(vy38_16b = uno)then vy38 <= X"00"; elsif(vy38_16b = nuno)then vy38 <= X"FF"; else vy38 <= vy38_16b(15 downto 8); end if; end process;

    process(vy41_16b) begin if(vy41_16b = uno)then vy41 <= X"00"; elsif(vy41_16b = nuno)then vy41 <= X"FF"; else vy41 <= vy41_16b(15 downto 8); end if; end process;
    process(vy42_16b) begin if(vy42_16b = uno)then vy42 <= X"00"; elsif(vy42_16b = nuno)then vy42 <= X"FF"; else vy42 <= vy42_16b(15 downto 8); end if; end process;
    process(vy43_16b) begin if(vy43_16b = uno)then vy43 <= X"00"; elsif(vy43_16b = nuno)then vy43 <= X"FF"; else vy43 <= vy43_16b(15 downto 8); end if; end process;
    process(vy44_16b) begin if(vy44_16b = uno)then vy44 <= X"00"; elsif(vy44_16b = nuno)then vy44 <= X"FF"; else vy44 <= vy44_16b(15 downto 8); end if; end process;
    process(vy45_16b) begin if(vy45_16b = uno)then vy45 <= X"00"; elsif(vy45_16b = nuno)then vy45 <= X"FF"; else vy45 <= vy45_16b(15 downto 8); end if; end process;
    process(vy46_16b) begin if(vy46_16b = uno)then vy46 <= X"00"; elsif(vy46_16b = nuno)then vy46 <= X"FF"; else vy46 <= vy46_16b(15 downto 8); end if; end process;
    process(vy47_16b) begin if(vy47_16b = uno)then vy47 <= X"00"; elsif(vy47_16b = nuno)then vy47 <= X"FF"; else vy47 <= vy47_16b(15 downto 8); end if; end process;
    process(vy48_16b) begin if(vy48_16b = uno)then vy48 <= X"00"; elsif(vy48_16b = nuno)then vy48 <= X"FF"; else vy48 <= vy48_16b(15 downto 8); end if; end process;

    process(vy51_16b) begin if(vy51_16b = uno)then vy51 <= X"00"; elsif(vy51_16b = nuno)then vy51 <= X"FF"; else vy51 <= vy51_16b(15 downto 8); end if; end process;
    process(vy52_16b) begin if(vy52_16b = uno)then vy52 <= X"00"; elsif(vy52_16b = nuno)then vy52 <= X"FF"; else vy52 <= vy52_16b(15 downto 8); end if; end process;
    process(vy53_16b) begin if(vy53_16b = uno)then vy53 <= X"00"; elsif(vy53_16b = nuno)then vy53 <= X"FF"; else vy53 <= vy53_16b(15 downto 8); end if; end process;
    process(vy54_16b) begin if(vy54_16b = uno)then vy54 <= X"00"; elsif(vy54_16b = nuno)then vy54 <= X"FF"; else vy54 <= vy54_16b(15 downto 8); end if; end process;
    process(vy55_16b) begin if(vy55_16b = uno)then vy55 <= X"00"; elsif(vy55_16b = nuno)then vy55 <= X"FF"; else vy55 <= vy55_16b(15 downto 8); end if; end process;
    process(vy56_16b) begin if(vy56_16b = uno)then vy56 <= X"00"; elsif(vy56_16b = nuno)then vy56 <= X"FF"; else vy56 <= vy56_16b(15 downto 8); end if; end process;
    process(vy57_16b) begin if(vy57_16b = uno)then vy57 <= X"00"; elsif(vy57_16b = nuno)then vy57 <= X"FF"; else vy57 <= vy57_16b(15 downto 8); end if; end process;
    process(vy58_16b) begin if(vy58_16b = uno)then vy58 <= X"00"; elsif(vy58_16b = nuno)then vy58 <= X"FF"; else vy58 <= vy58_16b(15 downto 8); end if; end process;
    
    process(vy61_16b) begin if(vy61_16b = uno)then vy61 <= X"00"; elsif(vy61_16b = nuno)then vy61 <= X"FF"; else vy61 <= vy61_16b(15 downto 8); end if; end process;
    process(vy62_16b) begin if(vy62_16b = uno)then vy62 <= X"00"; elsif(vy62_16b = nuno)then vy62 <= X"FF"; else vy62 <= vy62_16b(15 downto 8); end if; end process;
    process(vy63_16b) begin if(vy63_16b = uno)then vy63 <= X"00"; elsif(vy63_16b = nuno)then vy63 <= X"FF"; else vy63 <= vy63_16b(15 downto 8); end if; end process;
    process(vy64_16b) begin if(vy64_16b = uno)then vy64 <= X"00"; elsif(vy64_16b = nuno)then vy64 <= X"FF"; else vy64 <= vy64_16b(15 downto 8); end if; end process;
    process(vy65_16b) begin if(vy65_16b = uno)then vy65 <= X"00"; elsif(vy65_16b = nuno)then vy65 <= X"FF"; else vy65 <= vy65_16b(15 downto 8); end if; end process;
    process(vy66_16b) begin if(vy66_16b = uno)then vy66 <= X"00"; elsif(vy66_16b = nuno)then vy66 <= X"FF"; else vy66 <= vy66_16b(15 downto 8); end if; end process;
    process(vy67_16b) begin if(vy67_16b = uno)then vy67 <= X"00"; elsif(vy67_16b = nuno)then vy67 <= X"FF"; else vy67 <= vy67_16b(15 downto 8); end if; end process;
    process(vy68_16b) begin if(vy68_16b = uno)then vy68 <= X"00"; elsif(vy68_16b = nuno)then vy68 <= X"FF"; else vy68 <= vy68_16b(15 downto 8); end if; end process;

    process(vy71_16b) begin if(vy71_16b = uno)then vy71 <= X"00"; elsif(vy71_16b = nuno)then vy71 <= X"FF"; else vy71 <= vy71_16b(15 downto 8); end if; end process;
    process(vy72_16b) begin if(vy72_16b = uno)then vy72 <= X"00"; elsif(vy72_16b = nuno)then vy72 <= X"FF"; else vy72 <= vy72_16b(15 downto 8); end if; end process;
    process(vy73_16b) begin if(vy73_16b = uno)then vy73 <= X"00"; elsif(vy73_16b = nuno)then vy73 <= X"FF"; else vy73 <= vy73_16b(15 downto 8); end if; end process;
    process(vy74_16b) begin if(vy74_16b = uno)then vy74 <= X"00"; elsif(vy74_16b = nuno)then vy74 <= X"FF"; else vy74 <= vy74_16b(15 downto 8); end if; end process;
    process(vy75_16b) begin if(vy75_16b = uno)then vy75 <= X"00"; elsif(vy75_16b = nuno)then vy75 <= X"FF"; else vy75 <= vy75_16b(15 downto 8); end if; end process;
    process(vy76_16b) begin if(vy76_16b = uno)then vy76 <= X"00"; elsif(vy76_16b = nuno)then vy76 <= X"FF"; else vy76 <= vy76_16b(15 downto 8); end if; end process;
    process(vy77_16b) begin if(vy77_16b = uno)then vy77 <= X"00"; elsif(vy77_16b = nuno)then vy77 <= X"FF"; else vy77 <= vy77_16b(15 downto 8); end if; end process;
    process(vy78_16b) begin if(vy78_16b = uno)then vy78 <= X"00"; elsif(vy78_16b = nuno)then vy78 <= X"FF"; else vy78 <= vy78_16b(15 downto 8); end if; end process;
    
    process(vy81_16b) begin if(vy81_16b = uno)then vy81 <= X"00"; elsif(vy81_16b = nuno)then vy81 <= X"FF"; else vy81 <= vy81_16b(15 downto 8); end if; end process;
    process(vy82_16b) begin if(vy82_16b = uno)then vy82 <= X"00"; elsif(vy82_16b = nuno)then vy82 <= X"FF"; else vy82 <= vy82_16b(15 downto 8); end if; end process;
    process(vy83_16b) begin if(vy83_16b = uno)then vy83 <= X"00"; elsif(vy83_16b = nuno)then vy83 <= X"FF"; else vy83 <= vy83_16b(15 downto 8); end if; end process;
    process(vy84_16b) begin if(vy84_16b = uno)then vy84 <= X"00"; elsif(vy84_16b = nuno)then vy84 <= X"FF"; else vy84 <= vy84_16b(15 downto 8); end if; end process;
    process(vy85_16b) begin if(vy85_16b = uno)then vy85 <= X"00"; elsif(vy85_16b = nuno)then vy85 <= X"FF"; else vy85 <= vy85_16b(15 downto 8); end if; end process;
    process(vy86_16b) begin if(vy86_16b = uno)then vy86 <= X"00"; elsif(vy86_16b = nuno)then vy86 <= X"FF"; else vy86 <= vy86_16b(15 downto 8); end if; end process;
    process(vy87_16b) begin if(vy87_16b = uno)then vy87 <= X"00"; elsif(vy87_16b = nuno)then vy87 <= X"FF"; else vy87 <= vy87_16b(15 downto 8); end if; end process;
    process(vy88_16b) begin if(vy88_16b = uno)then vy88 <= X"00"; elsif(vy88_16b = nuno)then vy88 <= X"FF"; else vy88 <= vy88_16b(15 downto 8); end if; end process;
    
    Bandera: process(clk, cont)
    begin
        if(falling_edge(clk))then
            if(cont >= "100")then
                ban <= '1';
            else
                ban <= '0';
            end if;
        end if;
    end process;
    
    end Behavioral;
