-- ui = (a0 + xi*y0)mp mod b
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CalcUi is
    Generic
    (
        widthWord : integer := 16
    );
    Port
    (
        a0 : in std_logic_vector(widthWord - 1 downto 0);
        xi : in std_logic_vector(widthWord - 1 downto 0);
        y0 : in std_logic_vector(widthWord - 1 downto 0);
        mp : in std_logic_vector(widthWord - 1 downto 0);
        ui : out std_logic_vector(widthWord - 1 downto 0)
     );
end CalcUi;

architecture Behavioral of CalcUi is

    -- Señales temporales
    signal xy : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
    signal axy : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
    signal uiaxy : unsigned(2 * widthWord - 1 downto 0) := (others => '0');

begin

    xy <= unsigned(xi) * unsigned(y0);
    axy <= resize(unsigned(a0), 2 * widthWord - 1) + xy;
    uiaxy <= axy(widthWord - 1 downto 0) * unsigned(mp);
    ui <= std_logic_vector(uiaxy(widthWord - 1 downto 0));

end Behavioral;
