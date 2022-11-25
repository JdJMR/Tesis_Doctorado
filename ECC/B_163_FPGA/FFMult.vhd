----------------------------------------------------------------------------------
-- Company: CINVESTAV
-- Engineer: JOSE DE JESUS MORALES ROMERO
-- 
-- Create Date: 30.06.2022 12:53:09
-- Design Name: FFMULT
-- Module Name: FFMult - Behavioral
-- Project Name: ECC163
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: VIVADO 2020.2 
-- Description: REALIZA LA MULTIPLICACI�N EN CAMPOS FINITOS BINARIOS
-- 
-- Dependencies: FFSAdd.vhd
-- 
-- Revision: 1.0
-- Revision 0.01 - File Created
-- Additional Comments: NONE
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FFMult is
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
end FFMult;

architecture Behavioral of FFMult is

    -- Señales temporales
    signal ct: std_logic_vector(162 downto 0):= (others => '0');
    signal cont: integer:= 162;
    
    -- Señales para el sumador
    signal cls, cm1, Bi: std_logic_vector(162 downto 0):= (others => '1');
    
    -- Máquina de estados
    type Edos is (Idle, Reinicia, Oper1, Oper2, Count, Finaliza);
    signal Edo: Edos;
    
begin

    -- Máquina de estados
    process(clk, rst, en, cont, ct)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                Edo <= Idle;
                cont <= 162;
                ct <= (others => '0');
            else
                case Edo is
                    when Idle =>
                        ct <= ct;
                        cont <= 162;
                        if(en = '1')then
                            Edo <= Oper1;
                        else
                            Edo <= Idle;
                        end if;

                    when Reinicia =>
                        ct <= (others => '0');
                        Edo <= Oper1;
                        
                    when Oper1 =>
                        Edo <= Oper2;
                        ct <= ct;
                        
                    when Oper2 =>
                        ct <= (cls XOR (cm1 AND r)) XOR (Bi AND A);
                        Edo <= Count;
                        
                    when Count =>
                        if(cont = 0)then
                            Edo <= Finaliza;
                        else
                            cont <= cont - 1;
                            Edo <= Oper1;
                        end if;

                    when Finaliza =>
                        Edo <= Idle;
                end case;
            end if;
        end if;
    end process;

    -- Actualiza los valores
    process(clk, Edo, cont, cls, cm1, Bi)
    begin
        if(rising_edge(clk))then
            if(Edo = Oper1)then
                cls <= ct(162 downto 1) & '0';
                if(ct(162) = '0')then
                    cm1 <= (others => '0');
                else
                    cm1 <= (others => '1');
                end if;
                if(cont >= 0)then
                    if(B(cont) = '0')then
                        Bi <= (others => '0');
                    else
                        Bi <= (others => '1');
                    end if;
                else
                end if;
            else
                cls <= cls;
                cm1 <= cm1;
                Bi <= Bi;
            end if;
        end if;
    end process;

    ce <= '1' when Edo = Finaliza else '0';
    
    -- Regresa el resultado
    C <= ct;

end Behavioral;
