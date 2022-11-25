----------------------------------------------------------------------------------
-- Company: VLSI - SEES - DIE - CINVESTAV
-- Engineer: José de Jesús Morales Romero
-- 
-- Design Name: PilaParametros
-- Module Name: PilaParametros - arq_PilaParametros
-- Project Name: CNN
-- Target Devices: Artix 7 
-- Tool Versions: Vivado 2018
-- Revision: 1.2 (8/05/2019)

-- Description: Pila que almacena los parametros de la CNN
-- Revisión: 1.0: Creación del primer prototipo
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PilaParametros is
	Generic
	(
		nBitsDatoRx: integer := 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
		nBitsPalabra: integer := 16; -- Cantidad de bits para los valores
        nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
        nBitsMaxY: integer:= 9 -- Cantidad de bits para direccionar 256 bytes en Y(1 byte = 8bits)
	);
    Port
    (
    	-- Entradas
    	rst: in std_logic;
    	clk: in std_logic;
    	edo_rx: in std_logic;
    	data_in: in std_logic_vector(nBitsDatoRx - 1 downto 0);
    	-- Salida
    	totalPixelX: out std_logic_vector(nBitsMaxX - 1 downto 0);
        totalPixelY: out std_logic_vector(nBitsMaxY - 1 downto 0);	
    	a11, a12, a13: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	a21, a22, a23: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	a31, a32, a33: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	b11, b12, b13: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	b21, b22, b23: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	b31, b32, b33: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	Ikl: out std_logic_vector(nBitsPalabra - 1 downto 0);
    	-- Bandera de estado
    	ban: out std_logic
    );
end PilaParametros;

architecture arq_PilaParametros of PilaParametros is

	-- Señales temporales para los datos
	signal reg00, reg01, reg02, reg03, reg04, reg05, reg06, reg07 : std_logic_vector(nBitsDatoRx - 1 downto 0) := (others => '0');
	signal reg08, reg09, reg10, reg11, reg12, reg13, reg14, reg15 : std_logic_vector(nBitsDatoRx - 1 downto 0) := (others => '0');
	signal reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23 : std_logic_vector(nBitsDatoRx - 1 downto 0) := (others => '0');
	signal reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31 : std_logic_vector(nBitsDatoRx - 1 downto 0) := (others => '0');
    signal reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39 : std_logic_vector(nBitsDatoRx - 1 downto 0) := (others => '0');
    signal reg40: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
	
	-- Contadores
    signal cont : std_logic_vector(5 downto 0) := (others => '0');
    
    -- Máquina de estados
    type Estados is (EsperaCero, EsperaUno, GuardaDato, AumentaContador, Comprueba, Finaliza);
    signal Edo: Estados;
	
begin

    ----------------------------------------------------------------------------------
    --                             Máquina de estados                               --
    ----------------------------------------------------------------------------------
    Maquina: process(clk, Edo, rst, edo_rx, cont)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                Edo <= EsperaCero;
            else
                case Edo is
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
                        if(cont > "100111")then
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
    --                              Contador de registros                           --
    ----------------------------------------------------------------------------------
    Contador : process(clk, rst, Edo, cont)
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
    --                               Guarda Parametros                              --
    ----------------------------------------------------------------------------------
    Guarda : process(clk, Edo, cont)
    begin
        if(rising_edge(clk))then
            if(Edo = GuardaDato)then
                if   (cont = "000000")then reg00 <= data_in;
                elsif(cont = "000001")then reg01 <= data_in;
                elsif(cont = "000010")then reg02 <= data_in;
                elsif(cont = "000011")then reg03 <= data_in;
                elsif(cont = "000100")then reg04 <= data_in;
                elsif(cont = "000101")then reg05 <= data_in;
                elsif(cont = "000110")then reg06 <= data_in;
                elsif(cont = "000111")then reg07 <= data_in;
                elsif(cont = "001000")then reg08 <= data_in;
                elsif(cont = "001001")then reg09 <= data_in;
                elsif(cont = "001010")then reg10 <= data_in;
                elsif(cont = "001011")then reg11 <= data_in;
                elsif(cont = "001100")then reg12 <= data_in;
                elsif(cont = "001101")then reg13 <= data_in;
                elsif(cont = "001110")then reg14 <= data_in;
                elsif(cont = "001111")then reg15 <= data_in;
                elsif(cont = "010000")then reg16 <= data_in;
                elsif(cont = "010001")then reg17 <= data_in;
                elsif(cont = "010010")then reg18 <= data_in;
                elsif(cont = "010011")then reg19 <= data_in;
                elsif(cont = "010100")then reg20 <= data_in;
                elsif(cont = "010101")then reg21 <= data_in;
                elsif(cont = "010110")then reg22 <= data_in;
                elsif(cont = "010111")then reg23 <= data_in;
                elsif(cont = "011000")then reg24 <= data_in;
                elsif(cont = "011001")then reg25 <= data_in;
                elsif(cont = "011010")then reg26 <= data_in;
                elsif(cont = "011011")then reg27 <= data_in;
                elsif(cont = "011100")then reg28 <= data_in;
                elsif(cont = "011101")then reg29 <= data_in;
                elsif(cont = "011110")then reg30 <= data_in;
                elsif(cont = "011111")then reg31 <= data_in;
                elsif(cont = "100000")then reg32 <= data_in;
                elsif(cont = "100001")then reg33 <= data_in;
                elsif(cont = "100010")then reg34 <= data_in;
                elsif(cont = "100011")then reg35 <= data_in;
                elsif(cont = "100100")then reg36 <= data_in;
                elsif(cont = "100101")then reg37 <= data_in;
                elsif(cont = "100110")then reg38 <= data_in;
                elsif(cont = "100111")then reg39 <= data_in;
                else
                    reg00 <= reg00; reg01 <= reg01; reg02 <= reg02; reg03 <= reg03; reg04 <= reg04; reg05 <= reg05; reg06 <= reg06;
                    reg07 <= reg07; reg08 <= reg08; reg09 <= reg09; reg10 <= reg10; reg11 <= reg11; reg12 <= reg12; reg13 <= reg13;
                    reg14 <= reg14; reg15 <= reg15; reg16 <= reg16; reg17 <= reg17; reg18 <= reg18; reg19 <= reg19; reg20 <= reg20;
                    reg21 <= reg21; reg22 <= reg22; reg23 <= reg23; reg24 <= reg24; reg25 <= reg25; reg26 <= reg26; reg27 <= reg27;
                    reg28 <= reg28; reg29 <= reg29; reg30 <= reg30; reg31 <= reg31; reg32 <= reg32; reg33 <= reg33; reg34 <= reg34;
                    reg35 <= reg35; reg36 <= reg36; reg37 <= reg37; reg38 <= reg38; reg39 <= reg39;
                end if;
            else
                reg00 <= reg00; reg01 <= reg01; reg02 <= reg02; reg03 <= reg03; reg04 <= reg04; reg05 <= reg05; reg06 <= reg06;
                reg07 <= reg07; reg08 <= reg08; reg09 <= reg09; reg10 <= reg10; reg11 <= reg11; reg12 <= reg12; reg13 <= reg13;
                reg14 <= reg14; reg15 <= reg15; reg16 <= reg16; reg17 <= reg17; reg18 <= reg18; reg19 <= reg19; reg20 <= reg20;
                reg21 <= reg21; reg22 <= reg22; reg23 <= reg23; reg24 <= reg24; reg25 <= reg25; reg26 <= reg26; reg27 <= reg27;
                reg28 <= reg28; reg29 <= reg29; reg30 <= reg30; reg31 <= reg31; reg32 <= reg32; reg33 <= reg33; reg34 <= reg34;
                reg35 <= reg35; reg36 <= reg36; reg37 <= reg37; reg38 <= reg38; reg39 <= reg39;
            end if;
    	end if;
    end process;

    ----------------------------------------------------------------------------------
    --                                 Paramétros                                   --
    ----------------------------------------------------------------------------------  
    -- Cantidad de pixeles en X en binario
    totalPixelX <= reg00;
    -- Cantidad de pixeles en Y en binario
    totalPixelY <= reg01;

    -- Plantilla A
    a11 <= reg02 & reg03;
    a12 <= reg04 & reg05;
    a13 <= reg06 & reg07;
    a21 <= reg08 & reg09;
    a22 <= reg10 & reg11;
    a23 <= reg12 & reg13;
    a31 <= reg14 & reg15;
    a32 <= reg16 & reg17;
    a33 <= reg18 & reg19;
    
    -- Plantilla B
    b11 <= reg20 & reg21;
    b12 <= reg22 & reg23;
    b13 <= reg24 & reg25;
    b21 <= reg26 & reg27;
    b22 <= reg28 & reg29;
    b23 <= reg30 & reg31;
    b31 <= reg32 & reg33;
    b32 <= reg34 & reg35;
    b33 <= reg36 & reg37;
    
    -- Bias
    Ikl <= reg38 & reg39;
       
    ----------------------------------------------------------------------------------
    --                                   Salidas                                    --
    ----------------------------------------------------------------------------------
    ban <= '1' when (Edo = Finaliza) else '0';
	
end arq_PilaParametros;
