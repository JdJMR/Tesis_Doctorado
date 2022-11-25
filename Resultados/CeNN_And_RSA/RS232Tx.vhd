library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity RS232Tx is
	generic
	(
		nBitsDatoRx: integer:= 8
	);
	Port 
	( 
		-- Señales de entrada
		clk: in std_logic;
		en: in std_logic;
		dato: in std_logic_vector(nBitsDatoRx - 1 downto 0);
		-- Señales de salida
		tx: out std_logic;
		edo_tx: out std_logic
	);
end RS232Tx;

architecture Behavioral of RS232Tx is

	constant nBitsTiempo: integer:= 9;
	constant baudTx: std_logic_vector(nBitsTiempo - 1 downto 0):= "110000110";--10416 = (round(100MHz / 9600)) - 1
	signal contBaud: unsigned(nBitsTiempo - 1 downto 0):= (others => '0');
	constant bit_indice : natural := 9;
	signal contIndice: natural;
	signal dato_tx: std_logic_vector(nBitsDatoRx + 1 downto 0);
	signal txBit: std_logic:= '1';

	type Estados is (Espera, EnviaBit, CompruebaBits);
	signal Edo: Estados;

begin

	Maquina: process(clk, en, Edo)
	begin
		if(rising_edge(clk))then
			case Edo is
				when Espera => 
					if(en = '0')then
						Edo <= Espera;
					else
						Edo <= EnviaBit;
					end if;
				when EnviaBit =>
					if(contBaud >= unsigned(baudTx) - 1)then
						Edo <= CompruebaBits;
					else
						Edo <= EnviaBit;
					end if;
				when CompruebaBits =>
					if(contIndice >= bit_indice)then
						Edo <= Espera;
					else
						Edo <= EnviaBit;
					end if;
			end case;
		end if;
	end process;

	ContadorDeTiempo: process(clk, Edo, contBaud)
	begin
		if(rising_edge(clk))then
			if(Edo = EnviaBit)then
				contBaud <= contBaud + 1;
			else
				contBaud <= (others => '0');
			end if;
		end if;
	end process;

	ContadorDeIndice: process(clk, Edo, contIndice)
	begin
		if(rising_edge(clk))then
			if(Edo = Espera)then
				contIndice <= 0;
			elsif(Edo = CompruebaBits)then
				contIndice <= contIndice + 1;
			else
				contIndice <= contIndice;
			end if;
		end if;
	end process;

	--          Bit Stop
	--          |      Dato a enviar
	--          |      |     Bit Start
	--          |      |     |
	dato_tx <= '1' & dato & '0';

	EnviaBitTx: process(clk, Edo)
	begin
		if(rising_edge(clk))then
			if(Edo = Espera)then
				tx <= '1';
			else
				tx <= dato_tx(contIndice);
			end if;
		end if;
	end process;

	edo_tx <= '1' when (Edo = Espera) else '0';

end Behavioral;

