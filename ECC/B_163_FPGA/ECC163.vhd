----------------------------------------------------------------------------------
-- Company: CINVESTAV
-- Engineer: JOSE DE JESUS MORALES ROMERO ñ
-- 
-- Create Date: 30.06.2022 10:55:09
-- Design Name: ECC163
-- Module Name: ECC163 - Behavioral
-- Project Name: ECC163
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: VIVADO 2020.2
-- Description: CRIPTOGRAFIA DE CURVA ELIPTICA DE 163 BITS
-- 
-- Dependencies: MultiplicacionEscalar.vhd, SieteSegmentos.vhd
-- 
-- Revision:1.0
-- Revision 0.01 - File Created
-- Additional Comments: None
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.componentes.all;

entity ECC163 is
    Port
    (
        -- Entradas
        clk : in STD_LOGIC;
        rst: in std_logic;
        en: in std_logic;
        selK: in std_logic;
        SelS: in std_logic_vector(3 downto 0);
        -- Salidas
        LEDStatus: out std_logic_vector(15 downto 0);
        SSEG_AN: out std_logic_vector(7 downto 0);
        SSEG_CA: out std_logic_vector(7 downto 0)
    );
end ECC163;

architecture Behavioral of ECC163 is

    -- Constantes R
    constant k1: std_logic_vector(162 downto 0):= "000" & X"1234567890123456789012345678901234567890";
    constant k2: std_logic_vector(162 downto 0):= "001" & X"0987654321098765432109876543210987654321";

    -- Señales temporales para la multiplicación escalar
    signal en_MultEscalar, ce_ME: std_logic:= '0';
    signal QX, QZ: std_logic_vector(162 downto 0);
    signal kTemp: std_logic_vector(162 downto 0);

    -- Señales para mostrar el valor final
    signal bin: std_logic_vector(31 downto 0):= (others => '0');

    -- Maquina de estados principal
    type Estados is (Espera, Activa_ME, Espera_ME, Finaliza);
    signal Edo: Estados;

begin

    ----- Componentes externos -----
    MultEscalar: MultiplicacionEscalar
    port map
    (
        -- Entradas
        clk => clk, rst => rst, en => en_MultEscalar, k => kTemp,
        -- Salidas
        Estatus => ce_ME, QX => QX, QZ => QZ
    );

    SSegmentos: SieteSegmentos
    port map
    (
        -- Entradas
        clk => clk, bin => bin, SSEG_CA => SSEG_CA, SSEG_AN => SSEG_AN
    );

    ----- Máquina principal -----
    maquinaPrincipal: process(clk, rst, en, Edo, ce_ME)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                Edo <= Espera;
            else
                case Edo is
                    when Espera =>
                        if(en = '1')then
                            Edo <= Activa_ME;
                        else
                            Edo <= Espera;
                        end if;

                    when Activa_ME =>
                        Edo <= Espera_ME;

                    when Espera_ME =>
                        if(ce_ME = '1')then
                            Edo <= Finaliza;
                        else
                            Edo <= Espera_Me;
                        end if;

                    when Finaliza =>
                        Edo <= Finaliza;

                end case;
            end if;
        end if;
    end process;

    -- Actualiza el valor kTemp
    kTemp <= k1 when selK = '1' else k2;

    -- Activa el valor en_ME
    en_MultEscalar <= '1' when Edo = Activa_Me else '0';

    ----- Muesetra los valores -----
    process(clk, Edo)
    begin
        if(rising_edge(clk))then
            if(Edo = Finaliza)then
                if(SelS = "0000")then
                    bin <= QX( 31 downto   0);
                elsif(SelS = "0001")then
                    bin <= QX( 63 downto  32);
                elsif(SelS = "0010")then
                    bin <= QX( 95 downto  64);
                elsif(SelS = "0011")then
                    bin <= QX(127 downto  96);
                elsif(SelS = "0100")then
                    bin <= QX(159 downto 128);
                elsif(SelS = "0101")then
                    bin <= X"0000000" & '0' & QX(162 downto 160);
                elsif(SelS = "1000")then
                    bin <= QZ( 31 downto   0);
                elsif(SelS = "1001")then
                    bin <= QZ( 63 downto  32);
                elsif(SelS = "1010")then
                    bin <= QZ( 95 downto  64);
                elsif(SelS = "1011")then
                    bin <= QZ(127 downto  96);
                elsif(SelS = "1100")then
                    bin <= QZ(159 downto 128);
                elsif(SelS = "1101")then
                    bin <= X"0000000" & '0' & QZ(162 downto 160);
                else
                    bin <= (others => '0');
                end if;
            else
                bin <= (others => '0');
            end if;
        end if;
    end process;

    process(clk, Edo)
    begin
        if(rising_edge(clk))then
            if(Edo = Espera_ME)then
                LEDStatus <= X"FFFF";
            else
                LEDStatus <= X"0000";
            end if;
        end if;
    end process;
end Behavioral;
