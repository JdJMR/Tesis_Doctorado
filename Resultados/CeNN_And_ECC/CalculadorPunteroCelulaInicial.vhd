----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: José de Jesús Morales Romero
-- 
-- Design Name: CNN
-- Module Name: CalculadorPunteroCelulaInicial - Behavioral
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.1
----------------------------------------------------------------------------------
-- Inicializa: ¿en = '1'? Si: Ir a SumaCol, No: Mantenerse en Inicializa. contCol <- unos's. contFil <- ceros's
-- SumaCol: contCol = contCol + 1, Ir a CompruebaCol 
-- CompruebaCol: ¿contCol > xBloques? Si: Ir a SumaFil, No: Ir a Calcula
-- SumaFil: contCol <- ceros's, contFil = contFil + 1. Ir a Calcula
-- Calcula: Guarda el valor de: punCel <= (xMax * conFil + conCol)*6
-- ActivaBan
-- EsperaEn: ¿en = '1'? Si: ir a SumaCol, No: Permanecer en EsperaEn
-- Finaliza
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CalculadorPunteroCelulaInicial is
	generic
	(
		nBitsMaxX: integer:= 9;
		nBitsMaxY: integer:= 9;
		nBitsBloquesX: integer:= 6;
		nBitsBloquesY: integer:= 6
	);
	port
	(
		-- Señales de entrada
		clk: in std_logic;
		rst: in std_logic;
		en: in std_logic;
		totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad total de pixeles en X
		totalBloquesX: in std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en X
		totalBloquesY: in std_logic_vector(nBitsBloquesY - 1 downto 0); -- Cantidad total de bloques en Y
		-- Señales de salida
		puntCel: out std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0); -- Celula inicial del bloque actual
		BloqueX: out std_logic_vector(nBitsBloquesX - 1 downto 0); -- Bloque actual en X
		BloqueY: out std_logic_vector(nBitsBloquesY - 1 downto 0); -- Bloque actual en Y
		ban: out std_logic;
		banFin: out std_logic
	);
end CalculadorPunteroCelulaInicial;

architecture Behavioral of CalculadorPunteroCelulaInicial is

	-- Contadores
	signal contFil: unsigned(nBitsBloquesX - 1 downto 0):= (others => '0');
	signal contCol: unsigned(nBitsBloquesY - 1 downto 0):= (others => '1');
	
	-- Puntero
	signal puntCel_t1: unsigned(nBitsMaxX + nBitsBloquesX - 1 downto 0):= (others => '0');
	signal puntCel_t2: unsigned(nBitsMaxX + nBitsBloquesX - 1 downto 0):= (others => '0');
	signal puntCel_t3: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
	signal puntCel_t4: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
	signal puntCel_t5: unsigned(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');

	-- Máquina de estados
	type Estados is (Inicializa, SumaCol, CompruebaCol, SumaFil, 
					 Calcula, ActivaBan, Finaliza, EsperaEn);
	signal EdoPres, EdoFut: Estados;
	
begin

	----------------------------------------------------------------------------------
    --                                   M�dulo                                     --
	----------------------------------------------------------------------------------
	Avanza: process(clk, rst)
	begin
		if(rising_edge(clk))then
			if(rst = '1')then
				EdoPres <= Inicializa;
			else
				EdoPres <= EdoFut;
			end if;
		end if;
	end process;
	
	Maquina: process(EdoPres, en, contCol, totalBloquesX)
	begin
		case EdoPres is
			when Inicializa =>
				if(en = '1')then
					EdoFut <= SumaCol;
				else
					EdoFut <= Inicializa;
				end if;
			when SumaCol =>
				EdoFut <= CompruebaCol;
			when CompruebaCol =>
			    if(contCol > unsigned(totalBloquesX))then
                    EdoFut <= SumaFil;
			    else
			        EdoFut <= Calcula;
			    end if;
			when SumaFil =>
			    EdoFut <= Calcula;
			when Calcula => 
			    EdoFut <= ActivaBan;
			when ActivaBan =>
			    EdoFut <= Finaliza;
			when Finaliza =>
			    EdoFut <= EsperaEn;
			when EsperaEn =>
			    if(en = '1')then
			        EdoFut <= SumaCol;
			    else
			        EdoFut <= EsperaEn;
			    end if;
		end case;
	end process;
	
	----------------------------------------------------------------------------------
    --                                 Contadores                                   --
	----------------------------------------------------------------------------------
	ContadorCol: process(clk, EdoPres, contCol)
	begin
		if(rising_edge(clk))then
			if(EdoPres = Inicializa)then
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
	
	ContadorFil: process(clk, EdoPres, contFil)
	begin
		if(rising_edge(clk))then
			if(EdoPres = Inicializa)then
				contFil <= (others => '0');
			elsif(EdoPres = SumaFil)then
				contFil <= contFil + 1;
			else
				contFil <= contFil;
			end if;
		end if;
	end process;

    ----------------------------------------------------------------------------------
    --                                  Calculador                                  --
	----------------------------------------------------------------------------------
	puntCel_t1 <= unsigned(totalPixelX) * contFil;
	puntCel_t2 <= puntCel_t1 + resize(contCol, nBitsMaxX + nBitsBloquesX);
	puntCel_t3 <= resize(puntCel_t2 & "00", nBitsMaxX + nBitsMaxY);
	puntCel_t4 <= resize(puntCel_t2 & '0', nBitsMaxX + nBitsMaxY);
	puntCel_t5 <= puntCel_t3 + puntCel_t4;
	
    ----------------------------------------------------------------------------------
    --                                   Salidas                                    --
	----------------------------------------------------------------------------------
	BanderaPuntero: process(clk, EdoPres)
	begin
        if(rising_edge(clk))then
            if(EdoPres = ActivaBan)then
                ban <= '1';
            else
                ban <= '0';
            end if;
        end if;
    end process;
	
	BanderaBloques: process(clk, EdoPres)
	begin
        if(rising_edge(clk))then
            if(contCol >= unsigned(totalBloquesX) and contFil >= unsigned(totalBloquesY))then
                banFin <= '1';
            else
                banFin <= '0';
            end if;
        end if;
	end process;
	
	puntCel <= std_logic_vector(puntCel_t5);
	BloqueX <= std_logic_vector(contCol);
	BloqueY <= std_logic_vector(contFil);
	
end Behavioral;
