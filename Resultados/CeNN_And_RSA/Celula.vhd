----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: Jos? de Jes?s Morales Romero
-- 
-- Design Name: C?lula
-- Module Name: C?lula - Behavioral
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.0

-- Description: M?dulo para la c?lula, utiliza las siguientes ecuaciones:
--      vxij(n + 1) = vxij(n) + h*[-vxij(n) + fij(n) + Iij]
-- Donde:
--      fij(n) = Sumatoria(A(i, j; k, l) * vykl(n))
--      Iij = Sumatoria(B(i, j; k, l) * vukl) + I
--      vyij = Satlins(vxij(n))
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library xil_defaultlib;
use xil_defaultlib.Componentes.all;

entity Celula is
    Generic
    (
        widthWord : integer := 16
    );
    Port
    (
        clk : in std_logic;
        rst : in std_logic;
        -- Entradas
        en : in std_logic;
        -- Plantilla A
        a11, a12, a13 : in std_logic_vector(widthWord - 1 downto 0);
        a21, a22, a23 : in std_logic_vector(widthWord - 1 downto 0);
        a31, a32, a33 : in std_logic_vector(widthWord - 1 downto 0);
        -- Plantilla B
        b11, b12, b13 : in std_logic_vector(widthWord - 1 downto 0);
        b21, b22, b23 : in std_logic_vector(widthWord - 1 downto 0);
        b31, b32, b33 : in std_logic_vector(widthWord - 1 downto 0);
        -- Entradas de las celulas vecinas  
        vu11, vu12, vu13 : in std_logic_vector(widthWord - 1 downto 0);
        vu21, vu22, vu23 : in std_logic_vector(widthWord - 1 downto 0);
        vu31, vu32, vu33 : in std_logic_vector(widthWord - 1 downto 0);
        -- Salidas de las celulas vecinas
        vy11, vy12, vy13 : in std_logic_vector(widthWord - 1 downto 0);
        vy21, vy23 : in std_logic_vector(widthWord - 1 downto 0);
        vy31, vy32, vy33 : in std_logic_vector(widthWord - 1 downto 0);
        -- Valor del bias
        Ikl : in std_logic_vector(widthWord - 1 downto 0);
        -- Salidas
        vy : out std_logic_vector(widthWord - 1 downto 0);
        ban : out std_logic
    );
end Celula;

architecture Behavioral of Celula is

    -- Constantes (tamaño de 18 bits)
    constant uno18 : signed(widthWord + 1 downto 0) := "00" & X"0200";
    constant nuno18 : signed(widthWord + 1 downto 0) := "11" & X"FE00";

    -- Señales temporales para Satlins
    signal ban_stl : std_logic := '0';
    signal vy_stl : std_logic_vector(widthWord - 1 downto 0) := (others => '0'); -- Salida de Satlins
    
    -- Señales temporales de estado
    signal preSuma : signed(2 * widthWord + 3 downto 0) := (others => '0');
    signal vx : signed(2 * widthWord + 3 downto 0) := (others => '0'); -- Estado
    signal hvx : signed(2 * widthWord + 3 downto 0) := (others => '0');
    
    -- Señal temporal de bandera de vy
    signal ban_t : std_logic := '0';

    -- Conversión de se?ales a signados de 18 bits
    signal a11_s, a12_s, a13_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal a21_s, a22_s, a23_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal a31_s, a32_s, a33_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal b11_s, b12_s, b13_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal b21_s, b22_s, b23_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal b31_s, b32_s, b33_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal Ikl_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal vu11_s, vu12_s, vu13_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal vu21_s, vu22_s, vu23_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal vu31_s, vu32_s, vu33_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal vy11_s, vy12_s, vy13_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal vy21_s, vy_s, vy23_s : signed(widthWord + 1 downto 0) := (others => '0');
    signal vy31_s, vy32_s, vy33_s : signed(widthWord + 1 downto 0) := (others => '0');

    -- Señales para el contador
    signal contador : unsigned(4 downto 0) := (others => '0');

    -- Señales temporales para el control del acumulador
    signal rst_mul : std_logic := '0'; 
    signal ce_mul : std_logic := '0';
    
    -- Señales para el acumulador
    signal a : signed(widthWord + 1 downto 0) := (others => '0'); -- De 18 bits
    signal b : signed(widthWord + 1 downto 0) := (others => '0'); -- De 18 bits
    signal suma1 : signed(2 * widthWord + 3 downto 0) := (others => '0'); -- De 36 bits
    signal suma2 : signed(2 * widthWord + 3 downto 0) := (others => '0'); -- De 36 bits
    signal c : signed(2 * widthWord + 3 downto 0) := (others => '0'); -- De 36 bits

    -- Acumuladores
    signal Iij : signed(2 * widthWord + 3 downto 0) := (others => '0'); -- De 36 bits
    signal Fij : signed(2 * widthWord + 3 downto 0) := (others => '0'); -- De 36 bits

begin

    ----------------------------------------------------------------------------------
    ----------                     Conversión de datos                      ----------
    ----------------------------------------------------------------------------------
    -- Plantilla A de Control
    a11_s <= resize(signed(a11), widthWord + 2); a12_s <= resize(signed(a12), widthWord + 2); a13_s <= resize(signed(a13), widthWord + 2);
    a21_s <= resize(signed(a21), widthWord + 2); a22_s <= resize(signed(a22), widthWord + 2); a23_s <= resize(signed(a23), widthWord + 2);
    a31_s <= resize(signed(a31), widthWord + 2); a32_s <= resize(signed(a32), widthWord + 2); a33_s <= resize(signed(a33), widthWord + 2);
    -- Plantilla B de Retroalimentaci?n
    b11_s <= resize(signed(b11), widthWord + 2); b12_s <= resize(signed(b12), widthWord + 2); b13_s <= resize(signed(b13), widthWord + 2);
    b21_s <= resize(signed(b21), widthWord + 2); b22_s <= resize(signed(b22), widthWord + 2); b23_s <= resize(signed(b23), widthWord + 2);
    b31_s <= resize(signed(b31), widthWord + 2); b32_s <= resize(signed(b32), widthWord + 2); b33_s <= resize(signed(b33), widthWord + 2);
    -- Bias
    Ikl_s <= resize(signed(Ikl), widthWord + 2);
    -- Entras celulas vecinas
    vu11_s <= resize(signed(vu11), widthWord + 2); vu12_s <= resize(signed(vu12), widthWord + 2); vu13_s <= resize(signed(vu13), widthWord + 2);
    vu21_s <= resize(signed(vu21), widthWord + 2); vu22_s <= resize(signed(vu22), widthWord + 2); vu23_s <= resize(signed(vu23), widthWord + 2);
    vu31_s <= resize(signed(vu31), widthWord + 2); vu32_s <= resize(signed(vu32), widthWord + 2); vu33_s <= resize(signed(vu33), widthWord + 2);
    -- Salidas celulas vecinas
    vy11_s <= resize(signed(vy11), widthWord + 2); vy12_s <= resize(signed(vy12), widthWord + 2);   vy13_s <= resize(signed(vy13), widthWord + 2);
    vy21_s <= resize(signed(vy21), widthWord + 2); vy_s   <= resize(signed(vy_stl), widthWord + 2); vy23_s <= resize(signed(vy23), widthWord + 2);
    vy31_s <= resize(signed(vy31), widthWord + 2); vy32_s <= resize(signed(vy32), widthWord + 2);   vy33_s <= resize(signed(vy33), widthWord + 2);

    ----------------------------------------------------------------------------------
    ----------                       Módulos Externos                       ----------
    ----------------------------------------------------------------------------------

    Stl : Satlins   generic map
                    (
                        widthWord => widthWord
                    )
                    port map
                    (
                        vx => std_logic_vector(vx), vy => vy_stl, ban => ban_stl
                    );

    ----------------------------------------------------------------------------------
    ----------                      Contador sin signo                      ----------
    ----------------------------------------------------------------------------------
    
    ContadorProceso : process(clk, contador, en)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
            	contador <= (others => '0');
            else
            	if(en = '1')then
            		if(contador = "11011")then
            			contador <= "01101";
            		else
            			contador <= contador + 1;
            		end if;
            	else
            		contador <= contador;
            	end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    ----------                          Multiplexor                         ----------
    ----------------------------------------------------------------------------------
    with contador select
    	a <= -- Bias
    		 Ikl_s when "00000",
    		 Ikl_s when "00001",
    		 -- Plantilla de retroalimentaci?n
    	     b11_s when "00010",
    	     b12_s when "00011",
    	     b13_s when "00100",
    	     b21_s when "00101",
    	     b22_s when "00110",
    	     b23_s when "00111",
    	     b31_s when "01000",
    	     b32_s when "01001",
    	     b33_s when "01010",
    	     -- Plantilla de control
    	     a11_s when "01110",
    	     a12_s when "01111",
    	     a13_s when "10000",
    	     a21_s when "10001",
    	     a22_s when "10010",
    	     a23_s when "10011",
    	     a31_s when "10100",
    	     a32_s when "10101",
    	     a33_s when "10110",
    	     -- Otros valores
    		 (others => '0') when others;
    		 
	with contador select
		b <= -- Bias
			 uno18  when "00000",
			 uno18  when "00001",
			 -- Plantilla de retroalimentaci?n
			 vu11_s when "00010",
			 vu12_s when "00011",
			 vu13_s when "00100",
			 vu21_s when "00101",
			 vu22_s when "00110",
			 vu23_s when "00111",
			 vu31_s when "01000",
			 vu32_s when "01001",
			 vu33_s when "01010",
			 -- Plantilla de control
			 vy11_s when "01110",
			 vy12_s when "01111",
			 vy13_s when "10000",
			 vy21_s when "10001",
			 vy_s   when "10010",
			 vy23_s when "10011",
			 vy31_s when "10100",
			 vy32_s when "10101",
			 vy33_s when "10110",
			 -- Otros valores
			 (others => '0') when others;

    ----------------------------------------------------------------------------------
    ----------                    Control del Acumulador                    ----------
    ----------------------------------------------------------------------------------
    
    CtrAcumulador : process(contador)
    begin
		if(contador = "00000")then
			ce_mul <= '0';
		else
			ce_mul <= '1';
		end if;
    end process;

	RstAcumulador : process(rst, contador)
	begin
		if(contador = "00000" or contador = "01101")then
			rst_mul <= '1';
		else
			rst_mul <= '0';
		end if;
	end process;
    ----------------------------------------------------------------------------------
    ----------                          Acumulador                          ----------
    ----------------------------------------------------------------------------------
    Acumula : process(suma1, rst_mul, suma2)
    begin
        if(rst_mul = '1')then
            suma1 <= (others => '0');
        else
            suma1 <= suma2;
        end if;
    end process;

    Multiplicacion : process(clk)
    begin
        if(rising_edge(clk))then
            if(ce_mul = '1')then
                c <= a * b;
                suma2 <= suma1 + c;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    ----------                          Sumadores                           ----------
    ----------------------------------------------------------------------------------

    SumadorIij : process(clk, contador, Iij, suma2)
    begin
        if(rising_edge(clk))then
            if(contador <= "00000")then
                Iij <= (others => '0');
            elsif(contador = "01100")then
                Iij <= suma2;
            else
                Iij <= Iij;
            end if;
        end if;
    end process;

    SumadorFij : process(clk, contador, Fij, suma2)
    begin
        if(rising_edge(clk))then
            if(contador <= "01001")then
                Fij <= (others => '0');
            elsif(contador = "11000")then
                Fij <= suma2;
            else
                Fij <= Fij;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                          Estado                              ----------
    ----------------------------------------------------------------------------------
    
    PreSumador : process(rst, Iij, Fij, vx)
    begin
		if(rst = '1')then
			preSuma <= (others => '0');
		else
			preSuma <= Iij + Fij - vx;
		end if;
    end process;
    
    -- Realiza la multiplicación de preSuma * 2^-8 = h * [-vx + Iij + Fij]
    hxPresuma : process(preSuma)
    begin
		if(preSuma(35) = '1')then
			hvx <= X"FF" & "1" & preSuma(34 downto 8); --hvx <= X"FF" & "11" & preSuma(34 downto 9); -- hvx <= X"FF" & "111" & preSuma(34 downto 10);     preSuma * 2^-10 = h * [-vx + Iij + Fij]
		else
            hvx <= X"00" & "0" & preSuma(34 downto 8); --hvx <= X"00" & "00" & preSuma(34 downto 9); -- hvx <= X"00" & "000" & preSuma(34 downto 10);     preSuma * 2^-10 = h * [-vx + Iij + Fij]
    	end if;
    end process;
    
    Estado : process(clk, rst, contador, vx)
    begin
    	if(rising_edge(clk))then
    		if(rst = '1')then
    			vx <= (others => '0');
    		else
    			if(contador = "00000")then
    				if(vu22(15) = '1')then
    					if(vu22(0) = '1')then
    						vx <= X"FFF" & signed(vu22(14 downto 0)) & X"FF" & "1";
    					else
    						vx <= X"FFF" & signed(vu22(14 downto 0)) & X"00" & "0";
    					end if;
    				else
    					if(vu22(0) = '1')then
    						vx <= X"000" & signed(vu22(14 downto 0)) & X"FF" & "1";
    					else
    						vx <= X"000" & signed(vu22(14 downto 0)) & X"00" & "0";
    					end if;
    				end if;
    			elsif(contador = "11010")then
    				vx <= vx + hvx;
    			else
    				vx <= vx;
    			end if;
    		end if;
    	end if;
    end process;
    
    ----------------------------------------------------------------------------------
    ----------                          Salidas                             ----------
    ----------------------------------------------------------------------------------
    vy <= std_logic_vector(vy_stl);
    
    Bandera : process(clk, contador, ban_t)
    begin
    	if(rising_edge(clk))then
    		if(contador = "00000")then
    			ban_t <= '0';
    		elsif(contador = "11011")then
    			ban_t <= ban_stl;
    		else
    			ban_t <= ban_t;
    		end if;
    	end if;
    end process;
    
    ban <= ban_t;
    
end Behavioral;
