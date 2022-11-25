library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;

entity CalculadorDeBloques is
	generic
	(
		nBitsMaxX: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
		nBitsMaxY: integer:= 9; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)
		nBitsBloquesX: integer:= 6; -- Número de bits para direccionar la cantidad máxima de bloques en Y
		nBitsBloquesY: integer:= 6 -- Número de bits para direccionar la cantidad máxima de bloques en Y
	);
	port
	(
		-- Señales de entrada
		clk: in std_logic;
		rst: in std_logic;
		en: in std_logic;
		totalPixelX: in std_logic_vector(nBitsMaxX - 1 downto 0); -- Cantidad total de pixeles en X
        totalPixelY: in std_logic_vector(nBitsMaxY - 1 downto 0); -- Cantidad total de pixeles en Y
        -- Señales de salida
		totalBloquesX: out std_logic_vector(nBitsBloquesX - 1 downto 0); -- Cantidad total de bloques en X
		totalBloquesY: out std_logic_vector(nBitsBloquesY - 1 downto 0); -- Cantidad total de bloques en Y
		ban: out std_logic
	);
end CalculadorDeBloques;

architecture Behavioral of CalculadorDeBloques is

	-- Constantes
	constant seisX: std_logic_vector(nBitsMaxX - 1 downto 0):= conv_std_logic_vector(6, nBitsMaxX);
	constant seisY: std_logic_vector(nBitsMaxY - 1 downto 0):= conv_std_logic_vector(6, nBitsMaxY);
	constant dosX: std_logic_vector(nBitsMaxX - 1 downto 0):= conv_std_logic_vector(2, nBitsMaxX);
	constant dosY: std_logic_vector(nBitsMaxY - 1 downto 0):= conv_std_logic_vector(2, nBitsMaxY);

	-- Valores máximos
	signal xMax_t: unsigned(nBitsMaxX - 1 downto 0) := (others => '0');
	signal yMax_t: unsigned(nBitsMaxY - 1 downto 0) := (others => '0');

	-- Contadores
	signal contX: unsigned(nBitsMaxX - 1 downto 0) := (others => '0');
	signal contY: unsigned(nBitsMaxY - 1 downto 0) := (others => '0');
	signal contBloqueX: unsigned(nBitsBloquesX - 1 downto 0):= (others => '1');
	signal contBloqueY: unsigned(nBitsBloquesY - 1 downto 0):= (others => '1');
	
begin

	xMax_t <= unsigned(totalPixelX) - unsigned(dosX);

	ContadorX: process(clk, rst, en, contX, contBloqueX)
	begin
        if(rising_edge(clk))then
            if(rst = '1')then
                contX <= (others => '0');
                contBloqueX <= (others => '1');
            else
                if(en = '1')then
                    if(contX >= xMax_t)then
                        contX <= contX;
                        contBloqueX <= contBloqueX;
                    else
                        contX <= contX + unsigned(seisX);
                        contBloqueX <= contBloqueX + 1;
                    end if;
                else
                    contX <= contX;
                    contBloqueX <= contBloqueX;
                end if;
            end if;
		end if;
	end process;

	yMax_t <= unsigned(totalPixelY) - unsigned(dosY);

	ContadorY: process(clk, rst, en, contY)
	begin	
        if(rising_edge(clk))then
            if(rst = '1')then
                contY <= (others => '0');
                contBloqueY <= (others => '1');
            else
                if(en = '1')then
                    if(contY >= yMax_t)then
                        contY <= contY;
                        contBloqueY <= contBloqueY;
                    else
                        contY <= contY + unsigned(seisY);
                        contBloqueY <= contBloqueY + 1;
                    end if;
                else
                    contY <= contY;
                    contBloqueY <= contBloqueY;
                end if;
			end if;
		end if;
	end process;

	Bandera: process(clk, en, contX, contY)
	begin
		if(rising_edge(clk))then
			if(en = '1')then
				if(contX >= xMax_t and contY >= yMax_t)then
					ban <= '1';
				else
					ban <= '0';
				end if;
			else
				ban <= '0';
			end if;
		end if;
	end process;

	totalBloquesX <= std_logic_vector(contBloqueX);
	totalBloquesY <= std_logic_vector(contBloqueY);
	
end Behavioral;
