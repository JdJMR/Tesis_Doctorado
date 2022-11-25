---------------------------------------------------------------------------------------------
-- Exponenciación Modular
-- Entradas: 
-- Salida: S = x^d mod N
-- Algoritmo:
--   1. St = R mod N
--   2. xp = MulMont(x, R2, N)
--   3. xpp = MulMont(xp, xp, N)
--   4. For i = n-1 down to 1 do:
--         4.1. S0 = MulMont(St, St, N)
--         4.2. S1 = MulMont(S0, xpp, N)
--         4.3. St = S[d(i)]
--   5. End for
--   6. S0 = MulMont(St, xp, N)
--   6. St = MulMont(S0, 1, N)
--   7. Return St
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Pseudoalgoritmo:
-- 1.01: Espera habilitador
--       i = n
--
-- 2.01: St <- R mod m
--       Activa Montgomery: a = x, b = RRmodN
-- 2.02: Guarda xp <- Mont(x, R2 mod N)
-- 2.03: Reinicia Montgomery()
-- 2.04: Activa Montgomery: a = xp, b = xp
-- 2.05: Guarda xpp <- Mont(xp, xp, N)
-- 2.06: Reinicia Montgomery()
--
-- 3.01: i = i - 1
--
-- 4.01: Activa Montgomery: a = St, b = St
-- 4.02: Guarda S0 <- Montgomery(St, St)
-- 4.03: Reinicia Montgomery()
-- 4.04: Activa Montgomery: a = S0, b = xpp
-- 4.05: Guarda S1 <- Montgomery(S0, xp)
-- 4.06: Reinicia Montgomery()
-- 4.07: Guarda St
--
-- 5.01: ¿i = 1? Si: Ir a 6.01. No: Ir a 3.01
--
-- 6.01: Activa Montgomery: a = St, b = xp
-- 6.02: Guarda S0 <- Montgomery(St, xp)
-- 6.03: Reinicia Montgomery()
-- 6.04: Activa Montgomery: a = S0, b = 1
-- 6.05: Guarda St <- Montgomery(S0, 1, N)
-- 6.06: Reinicia Montgomery()
-- 6.07: Finaliza
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.componentes.all;

entity ExpMod is
    generic
    (
        widthWord : integer;    -- Tamaño de radix a manejar
		sizeRAM : integer;      -- Cantidad de localidades de RAM
		widthAddr : integer;    -- Tamaño de la RAM
		nBits: integer          -- Cantidad de bits para dirección el exponente
    );
    port
    (   
        -- Módulo 
        clk : in std_logic; -- Reloj general a 100 MHz
        rst : in std_logic; -- Reinicio de este módulo
        -- Entradas
        en : in std_logic; -- Habilitador de este módulo
        x : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Base 
		N : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Módulo
		np : in std_logic_vector(widthWord - 1 downto 0); -- Inverso multiplicativo de módulo
		RmodN : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- R mod m
		RRmodN : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- R^2 mod m
		d : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Exponente (clave secreta)
        -- Salidas
		di: out std_logic;								-- Valor d(i) del exponente
        S : out std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor calculado
		ban : out std_logic -- Indicador de estado de este Módulo
    );
end ExpMod;

architecture Behavioral of ExpMod is

	-- Constantes temporales
	constant ceros: std_logic_vector(sizeRAM * widthWord - 1 downto 0):= (others => '0');

	-- Señales temporales para este modulo
	signal S0 : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal S1 : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal St : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal xp : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal xpp : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');

	-- Señales para la Multiplicación Modular Montgomery
	signal enMM : std_logic := '0';
	signal xMM : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal yMM : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal AMM : std_logic_vector(widthWord * sizeRAM - 1 downto 0) := (others => '0');
	signal bMM : std_logic := '0';
	signal rstMM : std_logic := '0';

	-- Contador
	signal i: integer:= nBits;
	
	-- Máquina de estados para la multiplicación Montgomery
	type Estados is (EM11, EM21, EM22, EM23, EM24, EM25, EM26, EM31, EM41, EM42, EM43, EM44, EM45, EM46, EM47, EM51, EM61, EM62, EM63, EM64, EM65, EM66, EM67);
	signal Edo : Estados;

begin

	---------------------------------------------------------------------------------------------
	-----  Módulos externos                                                                 -----
	---------------------------------------------------------------------------------------------
	Montgomery: MulMont
	generic map
	(
		widthWord => widthWord, sizeRAM => sizeRAM, widthAddr => widthAddr
	)
	port map
	(
		-- Señales de este módulo
		clk => clk, rst => rstMM, en => enMM,
		-- Señales de entrada
		x => xMM, y => yMM, m => N, mp => np,
		-- Señales de salida
		A => AMM, ban => bMM
	);
    
	---------------------------------------------------------------------------------------------
	-----  ExpMont                                                                        -----
	---------------------------------------------------------------------------------------------
	Maquina: process(clk, rst, en, Edo, bMM)
	begin
		if(rising_edge(clk))then
			if(rst = '1')then
				Edo <= EM11;
			else
				case Edo is
					when EM11 =>				-- Espera Idle
						if(en = '1')then
							Edo <= EM21;
						else
							Edo <= EM11;
						end if;
					when EM21 =>				-- St = RmodN
						if(bMM = '1')then		-- Activa MulMont(x, R2, N)
							Edo <= EM22;
						else
							Edo <= EM21;
						end if;
					when EM22 =>				-- Guarda xp = MulMont(x, R2, N)
						Edo <= EM23;
					when EM23 =>				-- Reinicia MulMont()
						Edo <= EM24;
					when EM24 =>				-- Activa MulMont(xp, xp, N)
						if(bMM = '1')then
							Edo <= EM25;
						else
							Edo <= EM24;
						end if;
					when EM25 =>				-- Guarda xpp = MulMont(xp, xp, N)
						Edo <= EM26;
					when EM26 => 				-- Reinicia MulMont()
						Edo <= EM31;
					when EM31 =>				-- i = i - 1
						Edo <= EM41;
					when EM41 =>				-- Activa MulMont(St, St, N)
						if(bMM = '1')then
							Edo <= EM42;
						else
							Edo <= EM41;
						end if;
					when EM42 =>				-- Guarda S0 = MulMont(St, St, N)
						Edo <= EM43;
					when EM43 =>				-- Reinicia MulMont()
						Edo <= EM44;
					when EM44 =>				-- Activa MulMont(S1, xpp)
						if(bMM = '1')then
							Edo <= EM45;
						else
							Edo <= EM44;
						end if;
					when EM45 =>				-- Guarda S1 = MulMont(S1, xp, N)
						Edo <= EM46;
					when EM46 =>				-- Reinicia MulMont()
						Edo <= EM47;
					when EM47 =>				-- Guarda St
						Edo <= EM51;
					when EM51 =>				-- ¿i == 1?
						if(i = 1)then			--    Si: Ir a EM61
							Edo <= EM61;
						else					--    No: Ir a EM31
							Edo <= EM31;
						end if;
					when EM61 =>				-- Activa MulMont(St, xp, N)
						if(bMM = '1')then
							Edo <= EM62;
						else
							Edo <= EM61;
						end if;
					when EM62 =>				-- Guarda S0 = MulMont(St, xp, N)
						Edo <= EM63;
					when EM63 =>				-- Reinicia MulMont()
						Edo <= EM64;
					when EM64 =>				-- Activa MulMont(S0, 1, N)
						if(bMM = '1')then
							Edo <= EM65;
						else
							Edo <= EM64;
						end if;
					when EM65 => 				-- Guarda St = MulMont(S0, 1, N)
						Edo <= EM66;
					when EM66 =>				-- Reinicia MontMul()
						Edo <= EM67;
					when EM67 =>				-- Finaliza
						Edo <= EM67;
				end case;
			end if;
		end if;
	end process;

	----------------------------------------------------------------------------------
    --                                   Contador                                   --
    ----------------------------------------------------------------------------------
    Contador: process(clk, Edo, i)
    begin
        if(rising_edge(clk))then
            if(Edo = EM11)then
                i <= nBits;
            elsif(Edo = EM31)then
                i <= i - 1;
            else
                i <= i;
            end if;
        end if;
	end process;
	
	----------------------------------------------------------------------------------
    --                                  Montgomery                                  --
    ----------------------------------------------------------------------------------
    ActivaMontgomery: process(clk, Edo)
    begin
        if(rising_edge(clk))then
            if(Edo = EM21 or Edo = EM24 or Edo = EM41 or Edo = EM44 or Edo = EM61 or Edo = EM64)then
                enMM <= '1';
            else
                enMM <= '0';
            end if;
        end if;
    end process;
    
    ReiniciaMontgomery: process(Edo)
    begin
		if(Edo = EM23 or Edo = EM26 or Edo = EM43 or Edo = EM46 or Edo = EM63 or Edo = EM66)then
			rstMM <= '1';
		else
			rstMM <= '0';
		end if;	
    end process;
    
    MultiplexorMontgomery: process(Edo, x, RRmodN, xp, S0, S1, St, xpp)
    begin
        if(Edo = EM11 or Edo = EM21)then
            xMM <= x;
			yMM <= RRmodN;
		elsif(Edo = EM24 or Edo = EM25)then
			xMM <= xp;
			yMM <= xp;
        elsif(Edo = EM41 or Edo = EM42)then
            xMM <= St;
            yMM <= St;
        elsif(Edo = EM44 or Edo = EM45)then
            xMM <= S0;
			yMM <= xpp;
		elsif(Edo = EM61 or Edo = EM62)then
			xMM <= St;
			yMM <= xp;
		elsif(Edo = EM64 or Edo = EM65)then
			xMM <= S0;
			yMM <= ceros(sizeRAM * widthWord - 1 downto 1) & '1';
        else
            xMM <= (others => '0');
            yMM <= (others => '0');
        end if;
    end process;
	
	----------------------------------------------------------------------------------
    --                              Salidas Temporales                              --
    ----------------------------------------------------------------------------------
    GuardaXp: process(clk, Edo, xp, AMM)
    begin
        if(rising_edge(clk))then
            if(Edo = EM22)then
                xp <= AMM;
            else
                xp <= xp;
            end if;
        end if;
	end process;

	GuardaXpp: process(clk, Edo, xpp, AMM)
	begin
		if(rising_edge(clk))then
			if(Edo = EM25)then
				xpp <= AMM;
			else
				xpp <= xpp;
			end if;
		end if;
	end process;

	GuardaSt: process(clk, Edo, RmodN, St, S0, S1, AMM)
	begin
		if(rising_edge(clk))then
			if(Edo = EM21)then
				St <= RmodN;
			elsif(Edo = EM47)then
				if(d(i) = '0')then
					St <= S0;
				else
					St <= S1;
				end if;
			elsif(Edo = EM65)then
				St <= AMM;
			else
				St <= St;
			end if;
		end if;
	end process;

	GuardaS0: process(clk, Edo, AMM, S0)
	begin
		if(rising_edge(clk))then
			if(Edo = EM42 or Edo = EM62)then
				S0 <= AMM;
			else
				S0 <= S0;
			end if;
		end if;
	end process;

	GuardaS1: process(clk, Edo, S1, AMM)
	begin
		if(rising_edge(clk))then
			if(Edo = EM45)then
				S1 <= AMM;
			else
				S1 <= S1;
			end if;
		end if;
	end process;

	----------------------------------------------------------------------------------
    --                                    Salidas                                   --
    ----------------------------------------------------------------------------------
	process(clk, i, d)
	begin
		if(i = nBits)then
			di <= '0';
		else
			di <= d(i);
		end if;
	end process;
	
    S <= St;
    ban <= '1' when (Edo = EM67) else '0';
	
end Behavioral;
