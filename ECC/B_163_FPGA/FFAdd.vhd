----------------------------------------------------------------------------------
-- Company: CINVESTAV
-- Engineer: JOSE DE JESUS MORALES ROMERO 
-- 
-- Create Date: 30.06.2022 10:58:57
-- Design Name: ECC163
-- Module Name: FFAdd - Behavioral
-- Project Name: ECC163
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: VIVADO 2020.20
-- Description: SUMADOR EN CAMPOS FINITOS BINARIOS
-- 
-- Dependencies: 
-- 
-- Revision: 1.0
-- Revision 0.01 - File Created
-- Additional Comments: NONE
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FFAdd is
    Port
    (
        -- Entradas
        A, B: in std_logic_vector(162 downto 0);
        -- Salidas
        C: out std_logic_vector(162 downto 0)
    );
end FFAdd;

architecture Behavioral of FFAdd is

begin
    C <= A XOR B;
end Behavioral;
