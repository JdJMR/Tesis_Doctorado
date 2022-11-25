library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;

entity EscribeImagenDeSalida is
    generic
    (
        nBitsDatoRx: integer := 8;
        nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
        nBitsMaxY: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)
        nBitsBloquesX: integer:= 6; -- Ancho de palabra para dirección el máximo de bloques en X
        nBitsBloquesY: integer:= 6; -- Ancho de palabra para dirección el máximo de bloques en X
        filas: integer:= 8;
        columnas: integer:= 8
    );
    port
    (
        -- Señales de entrada
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad máxima de pixeles en X
        puntCel: in std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0); -- Puntero al pixel inicial
        BloqueX: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Bloque en X actual
        BloqueY: in std_logic_vector(nBitsBloquesY - 1 downto 0); -- Bloque en Y actual
        totalBloquesX: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en X
        totalBloquesY: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en Y
        vy11, vy12, vy13, vy14, vy15, vy16, vy17, vy18: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy21, vy22, vy23, vy24, vy25, vy26, vy27, vy28: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy31, vy32, vy33, vy34, vy35, vy36, vy37, vy38: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy41, vy42, vy43, vy44, vy45, vy46, vy47, vy48: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy51, vy52, vy53, vy54, vy55, vy56, vy57, vy58: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy61, vy62, vy63, vy64, vy65, vy66, vy67, vy68: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy71, vy72, vy73, vy74, vy75, vy76, vy77, vy78: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        vy81, vy82, vy83, vy84, vy85, vy86, vy87, vy88: in std_logic_vector(nBitsDatoRx - 1 downto 0);
        -- Señales de salida
        addr: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0);
        DI: out std_logic_vector(nBitsDatoRx - 1 downto 0);
        we: out std_logic;
        ban: out std_logic
    );
end EscribeImagenDeSalida;

architecture Behavioral of EscribeImagenDeSalida is
    
    -- Constantes
    constant maxFil: std_logic_vector(3 downto 0):= conv_std_logic_vector(filas, 4);
    constant maxCol: std_logic_vector(3 downto 0):= conv_std_logic_vector(columnas, 4);
    
    -- Contadores
    signal contFil: unsigned(3 downto 0):= (others => '0');
    signal contCol: unsigned(3 downto 0):= (others => '1');
    signal cont: unsigned(5 downto 0):= (others => '1');
    
    -- Señales temporales
    signal DI_t: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    
    -- Dirección
    signal addr_t1: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal addr_t2: unsigned(nBitsMaxX - 1 downto 0):= (others => '0');
    signal addr_t3: unsigned(nBitsMaxX + 3 downto 0):= (others => '0');
    signal addr_t4: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    
    -- Máquina de estados
    type Estados is (Espera, SumaCol, CompFinCol, SumaFil, EscribeDi, NOP, CompFinFil, Finaliza);
    signal EdoPres, EdoFut: Estados;
    
begin

    ----------------------------------------------------------------------------------
    ----------                         Este módulo                          ----------
    ----------------------------------------------------------------------------------
    Avanza: process(clk, rst)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                EdoPres <= Espera;
            else
                EdoPres <= EdoFut;
            end if;
        end if;
    end process;
    
    Maquina: process(EdoPres, en, contCol, contFil)
    begin
        case EdoPres is
            when Espera =>
                if(en = '1')then
                    EdoFut <= SumaCol;
                else
                    EdoFut <= Espera;
                end if;
            when SumaCol =>
                EdoFut <= CompFinCol;
            when CompFinCol =>
                if(contCol >= "1000")then
                    EdoFut <= SumaFil;
                else
                    EdoFut <= EscribeDi;
                end if;
            when SumaFil =>
                EdoFut <= CompFinFil;
            when CompFinFil =>
                if(contFil >= "1000")then
                    EdoFut <= Finaliza;
                else
                    EdoFut <= EscribeDi;
                end if;
            when EscribeDi =>
                EdoFut <= NOP;
            when NOP =>
                EdoFut <= SumaCol;
            when Finaliza =>
                if(en = '1')then
                    EdoFut <= Finaliza;
                else
                    EdoFut <= Espera;
                end if;
        end case;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                         Contadores                           ----------
    ----------------------------------------------------------------------------------
    ContColumnas: process(clk, EdoPres, contCol)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Espera)then
                contCol <= (others => '1');
            elsif(EdoPres = SumaCol)then
                contCol <= contCol + 1;
            elsif(EdoPres = SumaFil)then
                contCol <= (others => '0');
            else
                contCol <= contCol;
            end if;
        end if;
    end process;
    
    ContFilas: process(clk, EdoPres, contFil)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Espera)then
                contFil <= (others => '0');
            elsif(EdoPres = SumaFil)then
                contFil <= contFil + 1;
            else
                contFil <= contFil;
            end if;
        end if;
    end process;
    
    Contador: process(clk, EdoPres, cont)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Espera)then
                cont <= (others => '1');
            elsif(EdoPres = SumaCol)then
                cont <= cont + 1;
            else
                cont <= cont;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                         Dirección                            ----------
    ----------------------------------------------------------------------------------
    addr_t1 <= unsigned(puntCel) + resize(contFil, nBitsMaxX + nBitsMaxY) + resize(contCol, nBitsMaxX + nBitsMaxY);
    addr_t2 <= unsigned(totalPixelX) - 1;
    addr_t3 <= addr_t2 * contFil;
    addr_t4 <= addr_t1 + resize(addr_t3, nBitsMaxX + nBitsMaxY);

    addr <= std_logic_vector(addr_t4);
    
    ----------------------------------------------------------------------------------
    ----------                          Escribe                             ----------
    ----------------------------------------------------------------------------------
    EscribeWe: process(clk, EdoPres, totalBloquesX, totalBloquesY, BloqueX, BloqueY, contCol, contFil)
    begin
        if(rising_edge(clk))then
            if(EdoPres = EscribeDi)then
                if(totalBloquesX = "000000" and totalBloquesY = "000000")then -- Total de bloques = 1
                    we <= '1';
                elsif(totalBloquesX > "000000" and totalBloquesY = "000000")then -- Bloques en X > 1 y Bloques en Y = 1
                    if(BloqueX = "000000")then -- Bloque 1 en X
                        if(contCol = unsigned(maxCol) - 1)then -- Â¿Ãšltima columna?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    elsif(BloqueX = totalBloquesX)then --Â¿Ãšltimo Bloque en X
                        if(contCol = "0000")then -- Â¿primer columna?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    else -- Bloque en X intermedio
                        if(contCol = "0000" or contCol = unsigned(maxCol) - 1)then -- ï¿½primer columna o ï¿½ltima?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    end if;
                elsif(totalBloquesX = "000000" and totalBloquesY > "000000")then -- Bloques en X = 1 y Bloques en Y > 1
                    if(BloqueY = "000000")then -- ï¿½Bloque 1 en Y?
                        if(contFil = unsigned(maxFil) - 1)then -- ï¿½ï¿½ltima fila?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    elsif(BloqueY = totalBloquesY)then -- ï¿½ï¿½ltimo Bloque en Y?
                        if(contFil = "0000")then -- ï¿½primera fila?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    else -- Bloque intermedio
                        if(contFil = "0000" or contFil = unsigned(maxFil) - 1)then -- ï¿½primer o ï¿½ltima fila?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    end if;
                else -- Bloques en X > 1 y Bloques en Y > 1
                    if(BloqueY = "000000" and BloqueX = "000000")then -- ï¿½Primer bloque?
                        if(contCol = unsigned(maxCol) - 1 or contFil = unsigned(maxFil) - 1)then -- ï¿½ï¿½ltima columna o ï¿½ltima fila?
                            we <= '0'; -- Si
                        else
                            we <= '1'; -- No
                        end if;
                    elsif(BloqueY = "000000" and BloqueX > "000000" and BloqueX < totalBloquesX)then -- ï¿½primer fila y columna intermedia?
                        if(contCol = "0000" or contCol = unsigned(maxCol) - 1 or contFil = unsigned(maxFil) - 1)then
                            we <= '0';
                        else
                            we <= '1';
                        end if;
                    elsif(BloqueY = "000000" and BloqueX = std_logic_vector(unsigned(totalBloquesX) - 1))then -- ï¿½primer fila y ï¿½ltima columna?
                        if(contCol = "0000" or contFil = unsigned(maxFil) - 1)then
                            we <= '0';
                        else
                            we <= '1';
                        end if;                    
                    elsif(BloqueY > "000000" and BloqueY < totalBloquesY and BloqueX = "000000")then -- ï¿½fila intermedia y primer columna?
                        if(contCol = unsigned(maxCol) - 1 or contFil = "0000" or contFil = unsigned(maxFil) - 1)then
                            we <= '0';
                        else
                            we <= '1';
                        end if;
                    elsif(BloqueY > "000000" and BloqueY < totalBloquesY and BloqueX = totalBloquesX)then -- ï¿½fila intermedia y ï¿½ltima columna?
                        if(contCol = "0000" or contFil = "0000" or contFil = unsigned(maxFil) - 1)then
                            we <= '0';
                        else
                            we <= '1';
                        end if;
                    elsif(BloqueY = totalBloquesY and BloqueX = "000000")then -- ï¿½ï¿½ltima fila y primer columna?
                        if(contCol = unsigned(maxCol) - 1 or contFil = "0000")then
                            we <= '0';
                        else
                            we <= '1';
                        end if;
                    elsif(BloqueY = totalBloquesY and BloqueX > "000000" and BloqueX < totalBloquesX)then -- ï¿½ï¿½ltima fila y columna intermdia?
                        if(contCol = "0000" or contCol = unsigned(maxCol) - 1 or contFil = "0000")then
                            we <= '0';
                        else
                            we <= '1';
                        end if;
                    elsif(BloqueY = totalBloquesY and BloqueX = totalBloquesX)then -- ï¿½ï¿½ltima fila y ï¿½ltima columna?
                        if(contCol = "0000" or contFil = "0000")then
                            we <= '0';
                        else
                            we <= '1';
                        end if; 
                    else -- Bloques centrales
                        if(contCol = "0000" or contCol = unsigned(maxCol) - 1 or contFil = "0000" or contFil = unsigned(maxFil) - 1)then
                            we <= '0';
                        else
                            we <= '1';
                        end if;
                    end if;
                end if;
            else
                we <= '0';
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                          Pasa Di                             ----------
    ----------------------------------------------------------------------------------
    PasaDi: process(clk, cont, vy11, vy12, vy13, vy14, vy15, vy16, vy17, vy18,
                               vy21, vy22, vy23, vy24, vy25, vy26, vy27, vy28,
                               vy31, vy32, vy33, vy34, vy35, vy36, vy37, vy38,
                               vy41, vy42, vy43, vy44, vy45, vy46, vy47, vy48,
                               vy51, vy52, vy53, vy54, vy55, vy56, vy57, vy58,
                               vy61, vy62, vy63, vy64, vy65, vy66, vy67, vy68,
                               vy71, vy72, vy73, vy74, vy75, vy76, vy77, vy78,
                               vy81, vy82, vy83, vy84, vy85, vy86, vy87, vy88)
    begin
        if(rising_edge(clk))then
            if   (cont = "000000")then DI_t <= vy11;
            elsif(cont = "000001")then DI_t <= vy12;
            elsif(cont = "000010")then DI_t <= vy13;
            elsif(cont = "000011")then DI_t <= vy14;
            elsif(cont = "000100")then DI_t <= vy15;
            elsif(cont = "000101")then DI_t <= vy16;
            elsif(cont = "000110")then DI_t <= vy17;
            elsif(cont = "000111")then DI_t <= vy18;
            elsif(cont = "001000")then DI_t <= vy21;
            elsif(cont = "001001")then DI_t <= vy22;
            elsif(cont = "001010")then DI_t <= vy23;
            elsif(cont = "001011")then DI_t <= vy24;
            elsif(cont = "001100")then DI_t <= vy25;
            elsif(cont = "001101")then DI_t <= vy26;
            elsif(cont = "001110")then DI_t <= vy27;
            elsif(cont = "001111")then DI_t <= vy28;
            elsif(cont = "010000")then DI_t <= vy31;
            elsif(cont = "010001")then DI_t <= vy32;
            elsif(cont = "010010")then DI_t <= vy33;
            elsif(cont = "010011")then DI_t <= vy34;
            elsif(cont = "010100")then DI_t <= vy35;
            elsif(cont = "010101")then DI_t <= vy36;
            elsif(cont = "010110")then DI_t <= vy37;
            elsif(cont = "010111")then DI_t <= vy38;
            elsif(cont = "011000")then DI_t <= vy41;
            elsif(cont = "011001")then DI_t <= vy42;
            elsif(cont = "011010")then DI_t <= vy43;
            elsif(cont = "011011")then DI_t <= vy44;
            elsif(cont = "011100")then DI_t <= vy45;
            elsif(cont = "011101")then DI_t <= vy46;
            elsif(cont = "011110")then DI_t <= vy47;
            elsif(cont = "011111")then DI_t <= vy48;
            elsif(cont = "100000")then DI_t <= vy51;
            elsif(cont = "100001")then DI_t <= vy52;
            elsif(cont = "100010")then DI_t <= vy53;
            elsif(cont = "100011")then DI_t <= vy54;
            elsif(cont = "100100")then DI_t <= vy55;
            elsif(cont = "100101")then DI_t <= vy56;
            elsif(cont = "100110")then DI_t <= vy57;
            elsif(cont = "100111")then DI_t <= vy58;
            elsif(cont = "101000")then DI_t <= vy61;
            elsif(cont = "101001")then DI_t <= vy62;
            elsif(cont = "101010")then DI_t <= vy63;
            elsif(cont = "101011")then DI_t <= vy64;
            elsif(cont = "101100")then DI_t <= vy65;
            elsif(cont = "101101")then DI_t <= vy66;
            elsif(cont = "101110")then DI_t <= vy67;
            elsif(cont = "101111")then DI_t <= vy68;
            elsif(cont = "110000")then DI_t <= vy71;
            elsif(cont = "110001")then DI_t <= vy72;
            elsif(cont = "110010")then DI_t <= vy73;
            elsif(cont = "110011")then DI_t <= vy74;
            elsif(cont = "110100")then DI_t <= vy75;
            elsif(cont = "110101")then DI_t <= vy76;
            elsif(cont = "110110")then DI_t <= vy77;
            elsif(cont = "110111")then DI_t <= vy78;
            elsif(cont = "111000")then DI_t <= vy81;
            elsif(cont = "111001")then DI_t <= vy82;
            elsif(cont = "111010")then DI_t <= vy83;
            elsif(cont = "111011")then DI_t <= vy84;
            elsif(cont = "111100")then DI_t <= vy85;
            elsif(cont = "111101")then DI_t <= vy86;
            elsif(cont = "111110")then DI_t <= vy87;
            elsif(cont = "111111")then DI_t <= vy88;
            else DI_t <= DI_t;
            end if;
        end if;
    end process;
    
    DI <= DI_t;
    
    ----------------------------------------------------------------------------------
    ----------                          Banderas                            ----------
    ----------------------------------------------------------------------------------
    Bandera: process(clk, EdoPres)
    begin
        if(rising_edge(clk))then
            if(EdoPres = Finaliza)then
                ban <= '1';
            else
                ban <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
