library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library xil_defaultlib;
use xil_defaultlib.componentes.all;

entity SieteSegmentos is
    port
    (
        -- Señales de entrada
        clk : in std_logic;
        bin : in std_logic_vector(15 downto 0);
        -- Señales de salida
        SSEG_CA : out std_logic_vector(7 downto 0);
        SSEG_AN : out std_logic_vector(7 downto 0)
    );
end SieteSegmentos;

architecture Behavioral of SieteSegmentos is

    signal seg : std_logic_vector(6 downto 0) := (others => '0');
    signal contador : unsigned(18 downto 0) := (others => '0');
    signal jbin : std_logic_vector(3 downto 0) := (others => '0');

begin

    SSeg : BinASieteSeg port map(bin => jbin, seg => seg);
    
    SSEG_CA <= '1' & seg;
    
    -- Contador
    ProcesoContador : process(clk, contador)
    begin
        if(rising_edge(clk))then
            contador <= contador + 1;
        end if;
    end process;

    with contador(18 downto 17) select
        SSEG_AN <=  "11111110" when "00",
                    "11111101" when "01",
                    "11111011" when "10",
                    "11110111" when "11",
                    "11111111" when others;

    with contador(18 downto 17) select
        jbin <= bin(3 downto 0) when "00",
                bin(7 downto 4) when "01",
                bin(11 downto 8) when "10",
                bin(15 downto 12) when "11",
                "0000" when others;

end Behavioral;