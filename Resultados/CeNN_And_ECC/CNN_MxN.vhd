----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: Jos� de Jes�s Morales Romero
-- 
-- Design Name: CNN_MxN
-- Module Name: CNN_MxN - Behavioral
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.0

-- Description: Dise�o que crea una CNN de dimensiones M x N
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.Componentes.all;

entity CNN_MxN is
	Generic
	(
		widthWord : integer := 16;
		filas : integer := 4;
		columnas : integer := 4
	);
	Port
	(
		-- Entradas
		clk : in std_logic;
		rst : in std_logic;
		en : in std_logic;
		-- Plantilla A
		a11, a12, a13 : in std_logic_vector(widthWord - 1 downto 0);
		a21, a22, a23 : in std_logic_vector(widthWord - 1 downto 0);
		a31, a32, a33 : in std_logic_vector(widthWord - 1 downto 0);
		-- Plantilla B
		b11, b12, b13 : in std_logic_vector(widthWord - 1 downto 0);
		b21, b22, b23 : in std_logic_vector(widthWord - 1 downto 0);
		b31, b32, b33 : in std_logic_vector(widthWord - 1 downto 0);
		-- Valor del bias
		Ikl : in std_logic_vector(widthWord - 1 downto 0);
		-- Entras de las celulas
		vu11, vu12, vu13, vu14, vu15, vu16, vu17, vu18 : in std_logic_vector(widthWord - 1 downto 0);
		vu21, vu22, vu23, vu24, vu25, vu26, vu27, vu28 : in std_logic_vector(widthWord - 1 downto 0);
		vu31, vu32, vu33, vu34, vu35, vu36, vu37, vu38 : in std_logic_vector(widthWord - 1 downto 0);
		vu41, vu42, vu43, vu44, vu45, vu46, vu47, vu48 : in std_logic_vector(widthWord - 1 downto 0);
		vu51, vu52, vu53, vu54, vu55, vu56, vu57, vu58 : in std_logic_vector(widthWord - 1 downto 0);
		vu61, vu62, vu63, vu64, vu65, vu66, vu67, vu68 : in std_logic_vector(widthWord - 1 downto 0);
		vu71, vu72, vu73, vu74, vu75, vu76, vu77, vu78 : in std_logic_vector(widthWord - 1 downto 0);
		vu81, vu82, vu83, vu84, vu85, vu86, vu87, vu88 : in std_logic_vector(widthWord - 1 downto 0);
		-- Salida de las celulas
		vy11, vy12, vy13, vy14, vy15, vy16, vy17, vy18 : out std_logic_vector(widthWord - 1 downto 0);
		vy21, vy22, vy23, vy24, vy25, vy26, vy27, vy28 : out std_logic_vector(widthWord - 1 downto 0);
		vy31, vy32, vy33, vy34, vy35, vy36, vy37, vy38 : out std_logic_vector(widthWord - 1 downto 0);
		vy41, vy42, vy43, vy44, vy45, vy46, vy47, vy48 : out std_logic_vector(widthWord - 1 downto 0);
		vy51, vy52, vy53, vy54, vy55, vy56, vy57, vy58 : out std_logic_vector(widthWord - 1 downto 0);
		vy61, vy62, vy63, vy64, vy65, vy66, vy67, vy68 : out std_logic_vector(widthWord - 1 downto 0);
		vy71, vy72, vy73, vy74, vy75, vy76, vy77, vy78 : out std_logic_vector(widthWord - 1 downto 0);
		vy81, vy82, vy83, vy84, vy85, vy86, vy87, vy88 : out std_logic_vector(widthWord - 1 downto 0);
		-- Banderas de estado
		ban : out std_logic := '0'
	);
end CNN_MxN;

architecture Behavioral of CNN_MxN is

	-- Célula de frontera
	constant CF : std_logic_vector(widthWord - 1 downto 0) := X"0000";
	
	-- Señales habilitadoras
	type enBan is array(filas downto 1, columnas downto 1) of std_logic;
	signal enCelula : enBan; 
	signal banCelula : enBan;
	
	-- RAM temporal
	type ram_v is array (filas downto 1, columnas downto 1) of std_logic_vector(widthWord - 1 downto 0);
	-- Señales temporales de salida
	signal vy : ram_v;
	-- Señales temporales de entrada
	signal vu : ram_v;
	
	-- Bandera temporal de salida
	signal ban1, ban2, ban3, ban4, ban5, ban6, ban7, ban8 : std_logic := '0';
	
begin

	----------------------------------------------------------------------------------
    ----------                       Módulos Externos                       ----------
    ----------------------------------------------------------------------------------
    
    Ci : for i in 1 to filas generate
    	Cj : for j in 1 to columnas generate
    		Ci1j1 : if(i = 1 and j = 1)generate
    			C11 : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
    						-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => CF, vu12 => CF,        vu13 => CF,
							vu21 => CF, vu22 => vu(i, j),  vu23 => vu(i, j+1),
							vu31 => CF, vu32 => vu(i+1,j), vu33 => vu(i+1, j+1),
							-- Salida de las celulas vecinas
							vy11 => CF, vy12 => CF,        vy13 => CF,
							vy21 => CF,                    vy23 => vy(i, j+1),
							vy31 => CF, vy32 => vy(i+1,j), vy33 => vy(i+1, j+1),
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Ci1jm : if(i = 1 and j > 1 and j < columnas)generate
    			C1m : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => CF,          vu12 => CF,        vu13 => CF,
							vu21 => vu(i,j-1),   vu22 => vu(i,j),   vu23 => vu(i,j+1),
							vu31 => vu(i+1,j-1), vu32 => vu(i+1,j), vu33 => vu(i+1,j+1),
							-- Salida de las celulas vecinas
							vy11 => CF,          vy12 => CF,        vy13 => CF,
							vy21 => vy(i,j-1),                      vy23 => vy(i,j+1),
							vy31 => vy(i+1,j-1), vy32 => vy(i+1,j), vy33 => vy(i+1,j+1),
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Ci1jc : if(i = 1 and j = columnas)generate
    			C1c : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => CF,          vu12 => CF,        vu13 => CF,
							vu21 => vu(i,j-1),   vu22 => vu(i,j),   vu23 => CF,
							vu31 => vu(i+1,j-1), vu32 => vu(i+1,j), vu33 => CF,
							-- Salida de las celulas vecinas
							vy11 => CF,          vy12 => CF,        vy13 => CF,
							vy21 => vy(i,j-1),                      vy23 => CF,
							vy31 => vy(i+1,j-1), vy32 => vy(i+1,j), vy33 => CF,
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Cinj1 : if(i > 1 and i < filas and j = 1)generate
    			Cn1 : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => CF, vu12 => vu(i-1,j), vu13 => vu(i-1,j+1),
							vu21 => CF, vu22 => vu(i,j),   vu23 => vu(i,j+1),
							vu31 => CF, vu32 => vu(i+1,j), vu33 => vu(i+1,j+1),
							-- Salida de las celulas vecinas
							vy11 => CF, vy12 => vy(i-1,j), vy13 => vy(i-1,j+1),
							vy21 => CF,                    vy23 => vy(i,j+1),
							vy31 => CF, vy32 => vy(i+1,j), vy33 => vy(i+1,j+1),
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Cinjm : if(i > 1 and i < filas and j > 1 and j < columnas)generate
    			Cij : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => vu(i-1,j-1), vu12 => vu(i-1,j), vu13 => vu(i-1,j+1),
							vu21 => vu(i,j-1),   vu22 => vu(i,j),   vu23 => vu(i,j+1),
							vu31 => vu(i+1,j-1), vu32 => vu(i+1,j), vu33 => vu(i+1,j+1),
							-- Salida de las celulas vecinas
							vy11 => vy(i-1,j-1), vy12 => vy(i-1,j), vy13 => vy(i-1,j+1),
							vy21 => vy(i,j-1),                      vy23 => vy(i,j+1),
							vy31 => vy(i+1,j-1), vy32 => vy(i+1,j), vy33 => vy(i+1,j+1),
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Cinjc : if(i > 1 and i < filas and j = columnas)generate
    			Cnc : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					) 
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => vu(i-1,j-1), vu12 => vu(i-1,j), vu13 => CF,
							vu21 => vu(i,j-1),   vu22 => vu(i,j),   vu23 => CF,
							vu31 => vu(i+1,j-1), vu32 => vu(i+1,j), vu33 => CF,
							-- Salida de las celulas vecinas
							vy11 => vy(i-1,j-1), vy12 => vy(i-1,j), vy13 => CF,
							vy21 => vy(i,j-1),                      vy23 => CF,
							vy31 => vy(i+1,j-1), vy32 => vy(i+1,j), vy33 => CF,
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Cifj1 : if(i = filas and j = 1)generate
    			Cf1 : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => CF, vu12 => vu(i-1,j), vu13 => vu(i-1,j+1),
							vu21 => CF, vu22 => vu(i,j),   vu23 => vu(i,j+1),
							vu31 => CF, vu32 => CF,        vu33 => CF,
							-- Salida de las celulas vecinas
							vy11 => CF, vy12 => vy(i-1,j), vy13 => vy(i-1,j+1),
							vy21 => CF,                    vy23 => vy(i,j+1),
							vy31 => CF, vy32 => CF,        vy33 => CF,
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Cifjm : if(i = filas and j > 1 and j < columnas)generate
    			Cfm : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => vu(i-1,j-1), vu12 => vu(i-1,j), vu13 => vu(i-1,j+1),
							vu21 => vu(i,j-1),   vu22 => vu(i,j),   vu23 => vu(i,j+1),
							vu31 => CF,          vu32 => CF,        vu33 => CF,
							-- Salida de las celulas vecinas
							vy11 => vy(i-1,j-1), vy12 => vy(i-1,j), vy13 => vy(i-1,j+1),
							vy21 => vy(i,j-1),                      vy23 => vy(i,j+1),
							vy31 => CF,          vy32 => CF,        vy33 => CF,
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    		Cifjc : if(i = filas and j = columnas)generate
    			Cfc : Celula
    					Generic map
    					(
    						widthWord => widthWord
    					)
    					Port map
    					(
    						clk => clk, rst => rst, en => enCelula(i,j),
							-- Plantilla A
							a11 => a11, a12 => a12, a13 => a13,
							a21 => a21, a22 => a22, a23 => a23,
							a31 => a31, a32 => a32, a33 => a33,
							-- Plantilla B
							b11 => b11, b12 => b12, b13 => b13,
							b21 => b21, b22 => b22, b23 => b23,
							b31 => b31, b32 => b32, b33 => b33,
							-- Entradas de las celulas vecinas
							vu11 => vu(i-1,j-1), vu12 => vu(i-1,j), vu13 => CF,
							vu21 => vu(i,j-1),   vu22 => vu(i,j),   vu23 => CF,
							vu31 => CF,          vu32 => CF,        vu33 => CF,
							-- Salida de las celulas vecinas
							vy11 => vy(i-1,j-1), vy12 => vy(i-1,j), vy13 => CF,
							vy21 => vy(i,j-1),                      vy23 => CF,
							vy31 => CF,          vy32 => CF,        vy33 => CF,
							-- Valor del bias
							Ikl => Ikl,
							-- Salidas
							vy => vy(i,j), ban => banCelula(i,j)
    					);
    		end generate;
    		
    	end generate;
    end generate;
    
	----------------------------------------------------------------------------------
	----------                         Este Módulo                          ----------
	----------------------------------------------------------------------------------
	
	-- Habilitadores
	EnableProcess : process(en, banCelula)
	begin
		if(en = '1')then
			for i in 1 to filas loop
				for j in 1 to columnas loop
					enCelula(i,j) <= not banCelula(i,j);
				end loop;
			end loop;
		else
			for i in 1 to filas loop
				for j in 1 to columnas loop
					enCelula(i,j) <= '0';
				end loop;
			end loop;
		end if;
	end process;
	
	-- Entradas
	vu(1,1) <= vu11;  vu(1,2) <= vu12; vu(1,3) <= vu13; vu(1,4) <= vu14; vu(1,5) <= vu15; vu(1,6) <= vu16; vu(1,7) <= vu17; vu(1,8) <= vu18;
	vu(2,1) <= vu21;  vu(2,2) <= vu22; vu(2,3) <= vu23; vu(2,4) <= vu24; vu(2,5) <= vu25; vu(2,6) <= vu26; vu(2,7) <= vu27; vu(2,8) <= vu28;
	vu(3,1) <= vu31;  vu(3,2) <= vu32; vu(3,3) <= vu33; vu(3,4) <= vu34; vu(3,5) <= vu35; vu(3,6) <= vu36; vu(3,7) <= vu37; vu(3,8) <= vu38;
	vu(4,1) <= vu41;  vu(4,2) <= vu42; vu(4,3) <= vu43; vu(4,4) <= vu44; vu(4,5) <= vu45; vu(4,6) <= vu46; vu(4,7) <= vu47; vu(4,8) <= vu48;
	vu(5,1) <= vu51;  vu(5,2) <= vu52; vu(5,3) <= vu53; vu(5,4) <= vu54; vu(5,5) <= vu55; vu(5,6) <= vu56; vu(5,7) <= vu57; vu(5,8) <= vu58;
	vu(6,1) <= vu61;  vu(6,2) <= vu62; vu(6,3) <= vu63; vu(6,4) <= vu64; vu(6,5) <= vu65; vu(6,6) <= vu66; vu(6,7) <= vu67; vu(6,8) <= vu68;
	vu(7,1) <= vu71;  vu(7,2) <= vu72; vu(7,3) <= vu73; vu(7,4) <= vu74; vu(7,5) <= vu75; vu(7,6) <= vu76; vu(7,7) <= vu77; vu(7,8) <= vu78;
	vu(8,1) <= vu81;  vu(8,2) <= vu82; vu(8,3) <= vu83; vu(8,4) <= vu84; vu(8,5) <= vu85; vu(8,6) <= vu86; vu(8,7) <= vu87; vu(8,8) <= vu88;
	
	-- Salidas
	vy11 <= vy(1,1); vy12 <= vy(1,2); vy13 <= vy(1,3); vy14 <= vy(1,4); vy15 <= vy(1,5); vy16 <= vy(1,6); vy17 <= vy(1,7); vy18 <= vy(1,8);
	vy21 <= vy(2,1); vy22 <= vy(2,2); vy23 <= vy(2,3); vy24 <= vy(2,4); vy25 <= vy(2,5); vy26 <= vy(2,6); vy27 <= vy(2,7); vy28 <= vy(2,8); 
	vy31 <= vy(3,1); vy32 <= vy(3,2); vy33 <= vy(3,3); vy34 <= vy(3,4); vy35 <= vy(3,5); vy36 <= vy(3,6); vy37 <= vy(3,7); vy38 <= vy(3,8);
	vy41 <= vy(4,1); vy42 <= vy(4,2); vy43 <= vy(4,3); vy44 <= vy(4,4); vy45 <= vy(4,5); vy46 <= vy(4,6); vy47 <= vy(4,7); vy48 <= vy(4,8);
	vy51 <= vy(5,1); vy52 <= vy(5,2); vy53 <= vy(5,3); vy54 <= vy(5,4); vy55 <= vy(5,5); vy56 <= vy(5,6); vy57 <= vy(5,7); vy58 <= vy(5,8);
	vy61 <= vy(6,1); vy62 <= vy(6,2); vy63 <= vy(6,3); vy64 <= vy(6,4); vy65 <= vy(6,5); vy66 <= vy(6,6); vy67 <= vy(6,7); vy68 <= vy(6,8);
	vy71 <= vy(7,1); vy72 <= vy(7,2); vy73 <= vy(7,3); vy74 <= vy(7,4); vy75 <= vy(7,5); vy76 <= vy(7,6); vy77 <= vy(7,7); vy78 <= vy(7,8);
	vy81 <= vy(8,1); vy82 <= vy(8,2); vy83 <= vy(8,3); vy84 <= vy(8,4); vy85 <= vy(8,5); vy86 <= vy(8,6); vy87 <= vy(8,7); vy88 <= vy(8,8);
	
	-- Banderas
	ban1 <= banCelula(1,1) and banCelula(1,2) and banCelula(1,3) and banCelula(1,4) and banCelula(1,5) and banCelula(1,6) and banCelula(1,7) and banCelula(1,8);
	ban2 <= banCelula(2,1) and banCelula(2,2) and banCelula(2,3) and banCelula(2,4) and banCelula(2,5) and banCelula(2,6) and banCelula(2,7) and banCelula(2,8);
	ban3 <= banCelula(3,1) and banCelula(3,2) and banCelula(3,3) and banCelula(3,4) and banCelula(3,5) and banCelula(3,6) and banCelula(3,7) and banCelula(3,8);
	ban4 <= banCelula(4,1) and banCelula(4,2) and banCelula(4,3) and banCelula(4,4) and banCelula(4,5) and banCelula(4,6) and banCelula(4,7) and banCelula(4,8);
	ban5 <= banCelula(5,1) and banCelula(5,2) and banCelula(5,3) and banCelula(5,4) and banCelula(5,5) and banCelula(5,6) and banCelula(5,7) and banCelula(5,8);
	ban6 <= banCelula(6,1) and banCelula(6,2) and banCelula(6,3) and banCelula(6,4) and banCelula(6,5) and banCelula(6,6) and banCelula(6,7) and banCelula(6,8);
	ban7 <= banCelula(7,1) and banCelula(7,2) and banCelula(7,3) and banCelula(7,4) and banCelula(7,5) and banCelula(7,6) and banCelula(7,7) and banCelula(7,8);
	ban8 <= banCelula(8,1) and banCelula(8,2) and banCelula(8,3) and banCelula(8,4) and banCelula(8,5) and banCelula(8,6) and banCelula(8,7) and banCelula(8,8);
	
	ban <= ban1 and ban2 and ban3 and ban4 and ban5 and ban6 and ban7 and ban8;

					

end Behavioral;
	