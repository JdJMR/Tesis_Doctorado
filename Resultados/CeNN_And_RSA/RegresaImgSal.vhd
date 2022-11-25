library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegresaImgSal is
    generic
    (
        nBitsDatoRx: integer:= 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
        nBitsMaxX: integer:= 8;
        nBitsMaxY: integer:= 8
    );
    port
    (
        -- Señales de entrada
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        dato_ent: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        edo_tx: in std_logic; 
        totalPixeles: in std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
        -- Señales de salida
        addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
        en_tx: out std_logic;
        dato_tx: out std_logic_vector(nBitsDatoRx - 1 downto 0);
        ban: out std_logic
    );
end RegresaImgSal;

architecture Behavioral of RegresaImgSal is

    -- Contadores
    signal cont: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    
    -- Dato de fin de envio
    constant CR: std_logic_vector(7 downto 0) := X"0D";

    -- Máquina de estados
    type Estados is (Espera, LeeByte, ActivaTx, EnviaByte, AumentaContador, Comprueba, Finaliza);
    signal Edo: Estados;

begin

    ----------------------------------------------------------------------------------
    --                                RegresaImgSal                                 --
    ----------------------------------------------------------------------------------
    Maquina: process(clk, rst, en, Edo, edo_tx, cont, totalPixeles)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                Edo <= Espera;
            else
                case Edo is
                    when Espera =>
                        if(en = '1')then
                            Edo <= LeeByte;
                        else
                            Edo <= Espera;
                        end if;
                    when LeeByte =>
                        Edo <= ActivaTx;
                    when ActivaTx =>
                        Edo <= EnviaByte;
                    when EnviaByte =>
                        if(edo_tx = '1')then
                            Edo <= AumentaContador;
                        else
                            Edo <= EnviaByte;
                        end if;
                    when AumentaContador =>
                        Edo <= Comprueba;
                    when Comprueba => 
                        if(cont <= unsigned(totalPixeles))then
                            Edo <= LeeByte;
                        else
                            Edo <= Finaliza;
                        end if;
                    when Finaliza =>
                        Edo <= Finaliza;
                    when others => -- No se debe de dar esta condición
                        Edo <= Espera;
                end case;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    --                                  Contadores                                  --
    ----------------------------------------------------------------------------------
    Contador: process(clk, rst, Edo, cont)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                cont <= (others => '0');
            else
                if(Edo = Espera)then
                    cont <= (others => '0');
                elsif(Edo = AumentaContador)then
                    cont <= cont + 1;
                else
                    cont <= cont;
                end if;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    --                                    Salidas                                   --
    ----------------------------------------------------------------------------------
    Multiplexor: process(totalPixeles, cont, dato_ent)
    begin
        if(cont < unsigned(totalPixeles))then
            dato_tx <= dato_ent;
        else
            dato_tx <= CR;
        end if;
    end process;

    ban <= '1' when (Edo = Finaliza) else '0';

    addr <= std_logic_vector(cont);

    en_tx <= '1' when (Edo = ActivaTx) else '0';

end Behavioral;
