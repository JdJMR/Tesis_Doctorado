----------------------------------------------------------------------------------
-- Company: CINVESTAV
-- Engineer: JOSE DE JESUS MORALES ROMERO
-- 
-- Create Date: 06.07.2022 09:59:14
-- Design Name: CeNN_AND_RSA
-- Module Name: Codificador - Behavioral
-- Project Name: CeNN_RSA
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: VIVADO 2020.2
-- Description: Codificador de la imagen de salida, esta será utilizada para
-- el cifrado de datos
-- 
-- Dependencies: ModuloRAM.vhd
-- 
-- Revision: 1.0
-- Revision 0.01 - File Created
-- Additional Comments: None
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Codificador is
    port
    (
        -- Entradas
        clk: in std_logic;
        codigoCeNN: in std_logic_vector(63 downto 0);
        -- Salidas
        mensaje: out std_logic_vector(1023 downto 0)
    );
end Codificador;

architecture Behavioral of Codificador is

    -- Señales temporales
    signal temp: std_logic_vector(1023 downto 0):= (others => '0');

begin

    process(clk)
    begin
        if(rising_edge(clk))then
            mensaje <= temp(1023 downto 64) & codigoCeNN;
        end if;
    end process;

end Behavioral;
