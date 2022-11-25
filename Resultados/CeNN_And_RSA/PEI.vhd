--------------------------------------------------------------------------------------------
--
-- Realiza las siguientes operaciones
-- 
-- 1. u = x. v = y. z = u * v. A1 = z(parte baja, 16 bits). C = z(parte alta, 16 bits)
-- 2. u = ui. v = m. z = u * v. A2 = z(parte baja, 16 bits). C = z(parte alta, 16 bits)
-- 3. A3 = A1 + A2 + A0 (18 bits)
-- 
--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PEI is
	Generic
	(	
		widthWord : integer := 16 -- Tamaño de radix a manejar
	);
	Port
	(	
		-- Señales de este módulo
		clk : in std_logic; -- Reloj: 100 MHz
		rst_in : in std_logic; -- Reset de este PE
		en_in : in std_logic; -- Habilitador de este PE
		-- Señales de entrada
		A_in : in std_logic_vector(widthWord - 1 downto 0); -- ai de entrada
		X_in : in std_logic_vector(widthWord - 1 downto 0); -- xi de entrada
		Y_in : in std_logic_vector(widthWord - 1 downto 0); -- yi de este PE
		U_in : in std_logic_vector(widthWord - 1 downto 0); -- ui para este PE
		M_in : in std_logic_vector(widthWord - 1 downto 0); -- mi de este PE
		-- Señales de salida
		X_out : out std_logic_vector(widthWord - 1 downto 0); -- Valor xi para el siguiente PE
		U_out : out std_logic_vector(widthWord - 1 downto 0); -- Valor ui para el siguiente PE
		C_out : out std_logic_vector(widthWord downto 0); -- Acarreo de salida
		en_out : out std_logic; -- Habilitador del siguiente PE
		rst_out : out std_logic; -- Reset para el siguiente PE
		clk_out : out std_logic
	);
end PEI;

architecture Behavioral of PEI is

	-- Señales temporales para el multiplicador
	signal u : unsigned(widthWord - 1 downto 0) := (others => '0');
	signal v : unsigned(widthWord - 1 downto 0) := (others => '0');
	signal w : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
	signal sumando : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
	signal a : unsigned(2 * widthWord - 1 downto 0) := (others => '0');

	-- Señales temporales de entrada
	signal xin : unsigned(widthWord - 1 downto 0) := (others => '0');
	signal uin : unsigned(widthWord - 1 downto 0) := (others => '0'); 
	signal ain : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
	signal yin : unsigned(widthWord - 1 downto 0) := (others => '0');
	signal mi : unsigned(widthWord - 1 downto 0) := (others => '0');

	-- Señales temporales del resultado
	signal A1 : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
	signal A2 : unsigned(2 * widthWord - 1 downto 0) := (others => '0');
	signal A3 : unsigned(2 * widthWord downto 0) := (others => '0');

	-- Señales de salida temporal
	signal xout : std_logic_vector(widthWord - 1 downto 0) := (others => '0');
	SIGNAL uout : std_logic_vector(widthWord - 1 downto 0) := (others => '0');
		
	-- Máquina de estados
	type Estados is (PEG00, PEG01, PEG02);
	signal EdoPres, EdoFut : Estados;
	
begin

	-- Conversión de tipo de señales
	ain <= resize(unsigned(A_in), 2 * widthWord );
	xin <= unsigned(X_in);
	yin <= unsigned(Y_in);
	uin <= unsigned(U_in);
	mi <= unsigned(M_in);
	
	-- Máquina de estados
	Maquina : Process(EdoPres, en_in)
	begin
		case EdoPres is
			when PEG00 => 
				if(en_in = '1')then
					EdoFut <= PEG01;
				else
					EdoFut <= PEG00;
				end if;
			when PEG01 => -- 
				EdoFut <= PEG02;
			when PEG02 => -- 
				EdoFut <= PEG00;
		end case;
	end process;

	Avance : Process(clk, rst_in)
	begin
		if(rising_edge(clk))then
			if(rst_in = '1')then
				EdoPres <= PEG00;
			else
				EdoPres <= EdoFut;
			end if;
		end if;
	end process;

	Multiplexor : process (EdoPres, mi, yin, uin, xin, ain)
	begin
		case EdoPres is
			when PEG01 => 
				v <= mi;
				u <= uin;
				sumando <= (others => '0');
			when others => 
				v <= yin;
				u <= xin;
				sumando <= ain;
		end case;
	end process;

	process(u, v, sumando, w)
	begin
		w <= u * v;
		a <= w + sumando;
	end process;

	GuardaA1 : Process(rst_in, clk, EdoPres, a, A1)
	begin
		if(falling_edge(clk))then
			if(rst_in = '1')then
				A1 <= (others => '0');
			else
				if(EdoPres = PEG00)then
					A1 <= a;
				else
					A1 <= A1;
				end if;
			end if;
		end if;
	end process;
	
	GuardaA2 : process(rst_in, clk, EdoPres, a, A2)
	begin
		if(rising_edge(clk))then
			if(rst_in = '1')then
				A2 <= (others => '0');
			else
				if(EdoPres = PEG01)then
					A2 <= a;
				else
					A2 <= A2;
				end if;
			end if;
		end if;
	end process;

	A3 <= resize(A1, 2 * widthWord + 1) + resize(A2, 2 * widthWord + 1);

	---------------------------------------------------------------------------------------------
	-- Salidas                                                                                 --
	---------------------------------------------------------------------------------------------
	X_out <= X_in;
	U_out <= U_in;
	rst_out <= rst_in;
	en_out <= en_in;
	C_out <= std_logic_vector(A3(2 * widthWord downto widthWord));
	clk_out <= clk;
	
end Behavioral;
