library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Componentes is

    component ExpMod
    generic
    (
        widthWord : integer; -- Tamaño de radix a manejar
		sizeRAM : integer; -- Cantidad de localidades de RAM
		widthAddr : integer; -- Tamaño de la RAM
		nBits: integer
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
        di: out std_logic;											-- Valor d(i) del exponente
        S : out std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor calculado
		ban : out std_logic -- Indicador de estado de este Módulo
    );
    end component;

    component SieteSegmentos
        port
        (
            -- Señales de entrada
            clk : in std_logic;
            bin : in std_logic_vector(31 downto 0);
            -- Señales de salida
            SSEG_CA : out std_logic_vector(7 downto 0);
            SSEG_AN : out std_logic_vector(7 downto 0)
        );
    end component;

    component BinASieteSeg
        port
        (
            bin : in std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    component MulMont
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
            en : in std_logic; -- Habilitador de este módulo
            -- Señales de entrada
            x : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor x de entrada
            y : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor y de entrada
            m : in std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor módulo m de entrada
            mp : in std_logic_vector(widthWord - 1 downto 0); -- Valor mp de entrada
            -- Señales de salida
            A : out std_logic_vector(sizeRAM * widthWord - 1 downto 0); -- Valor de salida, resultado
            ban : out std_logic -- Bandera de salida
        );
    end component;

    component PEI
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
    end component;

    component PEG
        Generic
        (	
            widthWord : integer := 16 -- Tamaño de radix a manejar
        );
        Port
        (	
            -- Señales de este módulo
            clk : in std_logic; -- Reloj: 100 MHz.
            rst_in : in std_logic; -- Reinicio de este PE
            en_in : in std_logic; -- Habilitador de este PE
            -- Señales de entrada
            C_in : in std_logic_vector(widthWord downto 0); -- Acarreo de entrada
            A_in : in std_logic_vector(widthWord - 1 downto 0); -- ai de entrada
            X_in : in std_logic_vector(widthWord - 1 downto 0); -- xi de entrada
            Y_in : in std_logic_vector(widthWord - 1 downto 0); -- yi de este PE
            U_in : in std_logic_vector(widthWord - 1 downto 0); -- ui para este PE
            M_in : in std_logic_vector(widthWord - 1 downto 0); -- mi de este PE
            -- Señales de salida
            X_out : out std_logic_vector(widthWord - 1 downto 0); -- Valor xi para el siguiente PE
            U_out : out std_logic_vector(widthWord - 1 downto 0); -- Valor ui para el siguiente PE
            A_out : out std_logic_vector(widthWord - 1 downto 0); -- Valor ai de salida de este PE
            C_out : out std_logic_vector(widthWord downto 0); -- Acarreo de salida
            en_out : out std_logic; -- Habilitador del siguiente PE
            rst_out : out std_logic; -- Reinicio para el siguiente PE
            clk_out : out std_logic
        );
    end component;

    component PEF
        generic
        (	
            widthWord : integer := 16 -- Tamaño de radix a manejar
        );
        port
        (	
            -- Señales de este módulo
            clk : in std_logic; -- Reloj: 100 MHz
            rst_in : in std_logic; -- Reinicio de este PE
            en_in : in std_logic; -- Habilitador de este PE
            -- Señales de entrada
            C_in : in std_logic_vector(widthWord downto 0); -- Acarreo de entrada
            A_in : in std_logic_vector(widthWord - 1 downto 0); -- ai de entrada
            X_in : in std_logic_vector(widthWord - 1 downto 0); -- xi de entrada
            Y_in : in std_logic_vector(widthWord - 1 downto 0); -- yi de este PE
            U_in : in std_logic_vector(widthWord - 1 downto 0); -- ui para este PE
            M_in : in std_logic_vector(widthWord - 1 downto 0); -- mi de este PE
            -- Señales de salida
            A_out : out std_logic_vector(widthWord - 1 downto 0); -- Valor ai de salida de este PE
            C_out : out std_logic_vector(widthWord - 1 downto 0) -- Acarreo de salida
        );
    end component;

    component CalcUi
        Generic
        (
            widthWord : integer := 16
        );
        Port
        (
            a0 : in std_logic_vector(widthWord - 1 downto 0);
            xi : in std_logic_vector(widthWord - 1 downto 0);
            y0 : in std_logic_vector(widthWord - 1 downto 0);
            mp : in std_logic_vector(widthWord - 1 downto 0);
            ui : out std_logic_vector(widthWord - 1 downto 0)
        );
    end component;

end Componentes;