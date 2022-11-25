----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: Jos? de Jes?s Morales Romero
-- 
-- Design Name: Satlins
-- Module Name: Satlins - Behavioral
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.1 (18/02/2019)

-- Description: M?dulo de la funci?n Satlins(x) = 0.5 * (|v(t) + 1| - |v(t) - 1|)
-- Revisi?n: 1.1: Modificaci?n del ancho de la palabra de 18 a 16 bits
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Satlins is
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
end Satlins;

architecture Behavioral of Satlins is

    -- Se?ales temporales
    signal vx_t : signed(2 * widthWord + 3 downto 0) := (others => '0');

    -- Constantes
    constant masUno : signed(2 * widthWord + 3 downto 0) := X"000040000";
    constant menosUno : signed(2 * widthWord + 3 downto 0) :=   X"FFFFC0000";
    constant uno16 : std_logic_vector(widthWord - 1 downto 0) := X"0200";
    constant nuno16 : std_logic_vector(widthWord - 1 downto 0) := X"FE00";

begin

    vx_t <= signed(vx);

    process(vx_t, vx)
    begin
        if(vx_t < masUno)then
            if(vx_t > menosUno)then
                vy <= vx(2 * widthWord + 3) & vx(23 downto 9);
                ban <= '0';
            else
                vy <= nuno16;
                ban <= '1';
            end if;
        else
            vy <= uno16;
            ban <= '1';
        end if;
    end process;

end Behavioral;
