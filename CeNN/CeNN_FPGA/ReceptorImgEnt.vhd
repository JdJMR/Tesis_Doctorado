library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ReceptorImgEnt is
    generic
    (
        nBitsDatoRx: integer := 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
        nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
        nBitsMaxY: integer:= 9 -- Cantidad de bits para direccionar 256 bytes en Y(1 byte = 8bits)
    );
    port
    (
        -- Señales de entrada
        clk: in std_logic;
        rst: in std_logic;
        edo_rx: in std_logic;
        en: in std_logic;
        totalPixelX: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        totalPixelY: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        -- Señales de salida
        totalPixeles: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
        we: out std_logic;
        addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
        ban: out std_logic
    );
end ReceptorImgEnt;

architecture Behavioral of ReceptorImgEnt is

    signal cont: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal totalPixeles_t: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');

    -- Maquina de estados
    type Estados is (Espera, EsperaCero, EsperaUno, GuardaDato, AumentaContador, Comprueba, Finaliza);
    signal Edo: Estados;

begin

    Multiplicador: process(clk, totalPixelX, totalPixelY)
    begin
        if(rising_edge(clk))then
            totalPixeles_t <= unsigned(totalPixelX) * unsigned(totalPixelY);
        end if;
    end process;

    ----------------------------------------------------------------------------------
    --                             Máquina de estados                               --
    ----------------------------------------------------------------------------------
    Maquina: process(clk, en, rst, Edo, edo_rx, cont, totalPixeles_t)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                Edo <= Espera;
            else
                case Edo is
                    when Espera =>
                        if(en = '1')then
                            Edo <= EsperaCero;
                        else
                            Edo <= Espera;
                        end if;
                    when EsperaCero =>
                        if(edo_rx = '1')then
                            Edo <= EsperaCero;
                        else
                            Edo <= EsperaUno;
                        end if;
                    when EsperaUno =>
                        if(edo_rx = '1')then
                            Edo <= GuardaDato;
                        else
                            Edo <= EsperaUno;
                        end if;
                    when GuardaDato =>
                        Edo <= AumentaContador;
                    when AumentaContador =>
                        Edo <= Comprueba;
                    when Comprueba =>
                        if(cont >= totalPixeles_t)then
                            Edo <= Finaliza;
                        else
                            Edo <= EsperaCero;
                        end if;
                    when Finaliza =>
                        Edo <= Finaliza;
                end case;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    --                         Contador de datos recibidos                          --
    ----------------------------------------------------------------------------------
    Contador: process(clk, rst, Edo, cont)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                cont <= (others => '0');
            else
                if(Edo = AumentaContador)then
                    cont <= cont + 1;
                else
                    cont <= cont;
                end if;
            end if;
        end if;
    end process;
    ----------------------------------------------------------------------------------
    --                                   Salidas                                    --
    ----------------------------------------------------------------------------------
    we <= '1' when (Edo = GuardaDato) else '0';
    ban <= '1' when (Edo = Finaliza) else '0';
    totalPixeles <= std_logic_vector(totalPixeles_t);
    addr <= std_logic_vector(cont);
    
end Behavioral;
