----------------------------------------------------------------------------------
-- Company: CINVESTAV
-- Engineer: JOSE DE JESUS MORALES ROMERO
-- 
-- Create Date: 30.06.2022 11:02:54
-- Design Name: ECC163
-- Module Name: Componentes - Behavioral
-- Project Name: ECC163
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: VIVADO 2020.2
-- Description: Archivos de componentes
-- 
-- Dependencies: None 
-- 
-- Revision: 1.0
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Componentes is 

    component FFAdd
        Port
        (
            -- Entradas
            A, B: in std_logic_vector(162 downto 0);
            -- Salidas
            C: out std_logic_vector(162 downto 0)
        );
    end component;
    
    component FFSquarer
        Port
        (
        -- Entradas
        A: in std_logic_vector(162 downto 0);
        -- Salidas
        C: out std_logic_vector(325 downto 0)
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

    component BinASieteSeg
        port
        (
            bin : in std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    component SieteSegmentos
        port
        (
            -- Señales de entrada
            clk : in std_logic;
            bin : in std_logic_vector(31 downto 0);
            -- Señales de salida
            SSEG_CA : out std_logic_vector(7 downto 0);
            SSEG_AN : out std_logic_vector(7 downto 0)
        );
    end component;
    
end Componentes;
