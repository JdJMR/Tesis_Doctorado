------------------------------------------------------------------------------
-- Diseñador: José de Jesus Morales Romero
-- VLSI-SEES-CINVESTAV-IPN
-- Memoria RAM
-- Versión: 1.1
-- Descripción: RAM de dos modulos
-- Baja latencia
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ModuloRAM is
	Generic
    (	
        nBitsPalabra: integer:= 8; -- Ancho de palabra
		widthAddr: integer:= 8; -- Ancho de dirección
        sizeRAM: integer := 256 -- Cantidad de palabras
	);
	Port
    (	
        clk: in std_logic;
		we: in std_logic;
		en: in std_logic;
		addr_re: in std_logic_vector(widthAddr - 1 downto 0);
		addr_we: in std_logic_vector(widthAddr - 1 downto 0);
		DI: in std_logic_vector(nBitsPalabra - 1 downto 0);
		DO: out std_logic_vector(nBitsPalabra - 1 downto 0)
	);
end ModuloRAM;

architecture arq_moduloRAM of ModuloRAM is

	--Definición de la memoria
	type ram_t is array (0 to sizeRAM-1) of std_logic_vector(nBitsPalabra-1 downto 0);
	-- Crea la RAM
    signal RAM: ram_t;

begin

	LecturaEscritura: process(clk)
	begin
		if(clk'event and clk='1')then
			if(en = '1')then
				if(we = '1')then
					RAM(conv_integer(addr_we)) <= DI;
				end if;
				DO <= RAM(conv_integer(addr_re));
			end if;
		end if;
	end process;

end arq_moduloRAM;
