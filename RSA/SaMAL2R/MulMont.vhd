library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.componentes.all;

entity MulMont is
    Generic
    (
        widthWord : integer := 16; -- Radix o tamaño de palabra
        sizeRAM : integer := 8; -- Tamaño de la RAM
        widthAddr : integer := 4 -- Tamaño de la dirección de RAM
    );
    Port
    (   
        -- Señales de este módulo
        clk : in std_logic; -- Reloj: 100 MHz
        rst : in std_logic; -- Reinicio de este módulo
        en : in std_logic; -- Habilitador de este modulo
        -- Señales de entrada
        x : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor x de entrada
        y : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor y de entrada
        m : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor módulo m de entrada
        mp : in std_logic_vector(widthWord - 1 downto 0); -- Valor mp de entrada
        -- Señales de salida
        A : out std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor de salida, resultado
        ban : out std_logic -- Bandera de salida
    );
end MulMont;

architecture Behavioral of MulMont is

    -- Señales para los PE's
    --     Habilitadores
    signal enPE : std_logic_vector(sizeRAM - 1 downto 0) := (others => '0');
    --     Salidas
    signal aPE : std_logic_vector(sizeRAM * widthWord - 1 downto 0) := (others => '0');
    --     Reinicios
    signal rstPE : std_logic_vector(sizeRAM - 1 downto 0) := (others => '0');
    --     Valores de x
    signal xi : std_logic_vector(sizeRAM * widthWord downto 0) := (others => '0');
    --     Valores de u
    signal ui : std_logic_vector(sizeRAM * widthWord - 1 downto 0) := (others => '0');
    --     Valores de acarreo
    signal ci : std_logic_vector((sizeRAM - 1) * (widthWord + 1) - 1 downto 0) := (others => '0');
    --		Reloj
    signal clk_PE : std_logic_vector(sizeRAM - 1 downto 0) := (others => '0');

    -- Señales para Guardar el valor 
    signal enG : std_logic := '0';
    signal rstG : std_logic := '0';
    signal aG : std_logic_vector(sizeRAM * widthWord - 1 downto 0) := (others => '0');

    -- Contadores
    signal i : integer range 0 to sizeRAM := 0;

    -- Máquina de estados
    type Estados is (MM00, MM01, MM02, MM03, MM04, MM05);
    signal EdoPres, EdoFut : Estados;

begin

    ---------------------------------------------------------------------------------------------
	-- Módulos externos                                                                        --
	---------------------------------------------------------------------------------------------
    
    CUi : CalcUi    
    generic map
    (
        widthWord => widthWord
    )
    port map
    (
        a0 => aPE(widthWord - 1 downto 0),
        xi => xi(widthWord - 1 downto 0), 
        y0 => y(widthWord - 1 downto 0), 
        mp => mp, 
        ui => ui(widthWord - 1 downto 0)
    );
    
    PE : for i in 0 to sizeRAM generate
        PEIS : if (i = 0) generate
            PE00 : PEI  
            generic map
            (
                widthWord => widthWord
            )
            port map
            (
                -- Señales para el módulo PEI
                clk => clk_PE(i),
                rst_in => rstPE(i),
                en_in => enPE(i),
                -- Señales de entrada
                A_in => aPE(widthWord - 1 downto 0),
                X_in => xi(widthWord - 1 downto 0),
                Y_in => y(widthWord - 1 downto 0),
                U_in => ui(widthWord - 1 downto 0),
                M_in => m(widthWord - 1 downto 0),
                -- Señales de salida
                X_out => xi(2 * widthWord - 1 downto widthWord),
                U_out => ui(2 * widthWord - 1 downto widthWord),
                C_out => ci(widthWord downto 0),
                en_out => enPE(i + 1),
                rst_out => rstPE(i + 1),
                clk_out => clk_PE(i + 1)
            );
        end generate;
        PEGSN : if(i > 0 and i < sizeRAM - 1) generate
            PEGN : PEG  
            generic map
            (
                widthWord => widthWord
            )
            port map
            (   
                -- Señales de este módulo
                clk => clk_PE(i),
                rst_in => rstPE(i),
                en_in => enPE(i),
                -- Señales de entrada
                C_in => ci((i * widthWord) + i - 1 downto ((i - 1) * widthWord) + i - 1),
                A_in => aPE((i + 1) * widthWord - 1 downto i * widthWord),
                X_in => xi((i + 1) * widthWord - 1 downto i * widthWord),
                Y_in => y((i + 1) * widthWord - 1 downto i * widthWord),
                U_in => ui((i + 1) * widthWord - 1 downto i * widthWord),
                M_in => m((i + 1) * widthWord - 1 downto i * widthWord),
                -- Señales de salida
                X_out => xi((i + 2) * widthWord - 1 downto (i + 1) * widthWord),
                U_out => ui((i + 2) * widthWord - 1 downto (i + 1) * widthWord),
                A_out => aPE(i * widthWord - 1 downto (i - 1) * widthWord),
                C_out => ci((i + 1) * widthWord + i  downto i * widthWord + i),
                en_out => enPE(i + 1),
                rst_out => rstPE(i + 1),
                clk_out => clk_PE(i + 1)
            );
        end generate;
        PEFS : if(i = sizeRAM - 1)generate
            PEFSN : PEF 
            generic map
            (
                widthWord => widthWord
            )
            port map
            (   
                -- Señales de este mñdulo
                clk => clk_PE(i),
                rst_in => rstPE(i),
                en_in => enPE(i),
                -- Señales de entrada
                C_in => ci((i * widthWord) + i - 1 downto ((i - 1) * widthWord + i - 1)),
                A_in => aPE((i + 1) * widthWord - 1 downto i * widthWord),
                X_in => xi((i + 1) * widthWord - 1 downto i * widthWord),
                Y_in => y((i + 1) * widthWord - 1 downto i * widthWord),
                U_in => ui((i + 1) * widthWord - 1 downto i * widthWord),
                M_in => m((i + 1) * widthWord - 1 downto i * widthWord),
                -- Señales de salida
                A_out => aPE(i * widthWord - 1 downto (i - 1) * widthWord),
                C_out => aPE((i + 1) * widthWord - 1 downto i * widthWord)
            );
        end generate;
    end generate;

    ---------------------------------------------------------------------------------------------
	-- MulMont                                                                                 --
	---------------------------------------------------------------------------------------------

    -- Máquina de estados
    Maquina : Process(EdoPres, en, i)
    begin
        case EdoPres is
            when MM00 => -- Estado de espera
                if(en = '1')then
                    EdoFut <= MM01;
                else
                    EdoFut <= MM00;
                end if;
            when MM01 => -- Activa los PE
                EdoFut <= MM02;
            when MM02 => -- Ciclo
                EdoFut <= MM03;
            when MM03 => -- Comprueba valor del contador. Aumenta el valor de contador
                if(i >= sizeRAM)then
                    EdoFut <= MM04;
                else
                    EdoFut <= MM01;
                end if;
            when MM04 => -- Comienza el guardado
                EdoFut <= MM05;
            when MM05 => -- Permanece en este estado
                EdoFut <= MM05;
        end case;
    end Process;

    -- Avance de la máquina de estados
    Avance : Process(clk, rst)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                EdoPres <= MM00;
            else
                EdoPres <= EdoFut;
            end if;
        end if;
    end Process;

    -- Contador i
    ContI : Process(clk, EdoPres, i)
    begin
        if(rising_edge(clk))then
            if(EdoPres = MM00)then
                i <= 0;
            elsif(EdoPres = MM02)then
                i <= i + 1;
            else
                i <= i;
            end if;
        end if;
    end Process;

    ProcesaXi: process(i, x, xi)
    begin
        if(i <= sizeRAM - 1)then
            xi(widthWord - 1 downto 0) <= x((i + 1) * widthWord - 1 downto i * widthWord);        
        else
            xi(widthWord - 1 downto 0) <= x(sizeRAM * widthWord - 1 downto (sizeRAM - 1) * widthWord);
        end if;
    end process;

    ActivaPE00 : process(EdoPres)
    begin
        if(EdoPres = MM01)then
            enPE(0) <= '1';
        else
            enPE(0) <= '0';
        end if;
    end process;
    
    -- Reinicio de los módulos PE
    rstPE(0) <= rst;
    
    -- Reloj del primer PE
    clk_PE(0) <= clk;

    ---------------------------------------------------------------------------------------------
	-- Salidas                                                                                 --
	---------------------------------------------------------------------------------------------
    
    ActivaBan : process(EdoPres)
    begin
        if(EdoPres = MM05)then
            ban <= '1';
        else
            ban <= '0';
        end if;
    end process;
    
    A <= aPE;
    
end Behavioral;
