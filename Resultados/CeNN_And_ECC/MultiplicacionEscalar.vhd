----------------------------------------------------------------------------------
-- Company: CINVESTAV
-- Engineer: JOSE DE JESUS MORALES ROMERO
-- 
-- Create Date: 01.07.2022 14:53:14
-- Design Name: MultiplicacionEscalar
-- Module Name: MultiplicacionEscalar - Behavioral
-- Project Name: ECC163
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: Vivado 2020.2 
-- Description: Realiza la multiplicación escalar
-- 
-- Dependencies: FFAdd, FFMul, FFSquarer
-- 
-- Revision: 1.0
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.componentes.all;

entity MultiplicacionEscalar is
    port
    (
        -- Entradas
        clk, rst, en: in std_logic;
        k: in std_logic_vector(162 downto 0);
        -- Salidas
        Estatus: out std_logic;
        QX, QZ: out std_logic_vector(162 downto 0)
    );
end MultiplicacionEscalar;

architecture Behavioral of MultiplicacionEscalar is

    -- Valores de la curva elíptica: B-163: y^2 + xy = x^3 + ax^2 + b
    -- con f(Z) = z^(163) + z^(7) + z^(6) + z^(3) + 1, a = 1, h = 2

    constant ECC_m: integer:= 163; -- Grado de la extensión del campo binario F(2^m)
    constant ECC_r: std_logic_vector(ECC_m - 1 downto 0):= "000" & X"0000000000000000000000000000000000000065";-- Polinomio de reducción de grado m f(z) = 2^m + r(z)
    constant ECC_S: std_logic_vector(ECC_m - 1 downto 0):= "000" & X"85E25BFE5C86226CDB12016F7553F9D0E693A268"; -- Semiña seleccionada
    constant ECC_B: std_logic_Vector(ECC_m - 1 downto 0):= "010" & X"0A601907B8C953CA1481EB10512F78744A3205FD"; -- Valor de b
    constant ECC_n: std_logic_vector(ECC_m - 1 downto 0):= "100" & X"0000000000000000000292FE77E70C12A4234C33";

    -- Señales temporales
    signal cont: integer:= 162;
    signal T0X, T0Z: std_logic_vector(162 downto 0):= (others => '0');
    constant T1X: std_logic_vector(162 downto 0):= (others => '0');
    constant T1Z: std_logic_vector(162 downto 0):= (others => '0');
    constant T2X: std_logic_vector(162 downto 0):= (others => '0');
    constant T2Z: std_logic_vector(162 downto 0):= (others => '0');

    -- Punto R
    constant RX: std_logic_vector(162 downto 0):= "000" & X"1234567890123456789012345678901234567890";
    constant RZ: std_logic_vector(162 downto 0):= "000" & X"1234567890123456789012345678901234567890";

    -- Punto P
    constant PX: std_logic_vector(162 downto 0):=   "011" & X"F0EBA16286A2D57EA0991168D4994637E8343E36";
    --constant PY: std_logic_vecto(m - 1 downto 0):= "000" & X"D51FBC6C71A0094FA2CDD545B11C5C0C797324F1";
    --constant PZ: std_logic_vector(162 downto 0):=   "000" & X"1234567890123456789012345678901234567890";
    --signal PX, PZ: std_logic_vector(162 downto 0):= (others => '0');

    -- Señales temporales para FFAdd
    signal OperSA, OperSB, OperSC: std_logic_vector(162 downto 0):= (others => '0');
    
    -- Señales temporales para FFMult
    signal OperMA, OperMB, OperMC: std_logic_vector(162 downto 0):= (others => '0');
    signal enFFMult, ceFFMult: std_logic:= '0';
    
    -- Definición de la máquina de estados principal
    type EdosPrincipal is (EP_Espera, EP_Guarda_T0, EP_Inicia_Bucle, EP_Activa_MD, EP_Espera_MD, EP_Guarda_T0_MD, EP_Activa_MA, EP_Espera_MA, EP_Guarda_T0_MA, EP_Aumenta_Cuenta, EP_Activa_MAF, EP_Espera_MAF, EP_Guarda_T0F, EP_Fin);

    -- Definición de la máquina de estados para la función MDouble
    type EdosMDouble is (EMD_Espera, EMD_Guarda_Temp, EMD_P1, EMD_Act_P2, EMD_Esp_P2, EMD_Guarda_P2, EMD_Act_P3, EMD_Esp_P3, EMD_Guarda_P3, EMD_Act_P4, EMD_Esp_P4, EMD_Guarda_P4, EMD_Act_P5, EMD_Esp_P5, EMD_Guarda_P5, EMD_Act_P6, EMD_Esp_P6, EMD_Guarda_P6, EMD_Act_P7, EMD_Esp_P7, EMD_Guarda_P7, EMD_P8, EMD_Fin);
    signal Estatus_MD: std_logic:= '0';
    signal En_MD: std_logic:= '0';
    signal MD_X, MD_Z, MD_T1: std_logic_vector(162 downto 0):= (others => '0');

    -- Definición de la máquina de estados para la función MAdd
    type EdosMAdd is (EMA_Espera, EMA_Guarda_T0TD, EMA_Inicia_Bucle, EMA_P1, EMA_Act_P2, EMA_Esp_P2, EMA_Guarda_P2, EMA_Act_P3, EMA_Esp_P3, EMA_Guarda_P3, EMA_Act_P4, EMA_Esp_P4, EMA_Guarda_P4, EMA_P5, EMA_Act_P6, EMA_Esp_P6, EMA_Guarda_P6, EMA_Act_P7, EMA_Esp_P7, EMA_Guarda_P7, EMA_P8, EMA_Fin);
    signal Estatus_MA: std_logic:= '0';
    signal En_MA: std_logic:= '0';
    signal MA_T1, MA_T2, MA_X1, MA_X2, MA_Z1, MA_Z2: std_logic_vector(162 downto 0):= (others => '0');

    -- Señales para las máquinas de estados
    signal EdosP: EdosPrincipal;
    signal EdosMD: EdosMDouble;
    signal EdosMA: EdosMAdd;

begin

    ----- Componentes externos -----
    Suma: FFAdd port map(A => OperSA, B => OperSB, C => OperSC);

    Multiplica: FFMult 
    port map(
        -- Entradas
        clk => clk, rst => rst, en => enFFMult, A => OperMA, B => OperMB, r => ECC_R, 
        -- Salidas
        ce => ceFFMult, C => OperMC
        );

    ----- Máquina de estados principal -----
    MaquinaPrincipal: process(clk, rst, en, Estatus_MD, Estatus_MA, cont)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                EdosP <= EP_Espera;
            else
                case EdosP is
                    when EP_Espera =>
                        if(en = '1')then
                            EdosP <= EP_Guarda_T0;
                        else
                            EdosP <= EP_Espera;
                        end if;

                    when EP_Guarda_T0 =>
                        EdosP <= EP_Inicia_Bucle;

                    when EP_Inicia_Bucle =>
                        EdosP <= EP_Activa_MD;

                    when EP_Activa_MD =>
                        EdosP <= EP_Espera_MD;

                    when EP_Espera_MD =>
                        if(Estatus_MD = '1')then
                            EdosP <= EP_Guarda_T0_MD;
                        else
                            EdosP <= EP_Espera_MD;
                        end if;

                    when EP_Guarda_T0_MD =>
                        EdosP <= EP_Activa_MA;

                    when EP_Activa_MA =>
                        EdosP <= EP_Espera_MA;

                    when EP_Espera_MA =>
                        if(Estatus_MA = '1')then
                            EdosP <= EP_Guarda_T0_MA;
                        else
                            EdosP <= EP_Espera_MA;
                        end if;

                    when EP_Guarda_T0_MA =>
                        EdosP <= EP_Aumenta_Cuenta;

                    when EP_Aumenta_Cuenta =>
                        if(cont = 0)then
                            EdosP <= EP_Activa_MAF;
                        else
                            EdosP <= EP_Activa_MD;
                        end if;

                    when  EP_Activa_MAF =>
                        EdosP <= EP_Espera_MAF;

                    when EP_Espera_MAF =>
                        if(Estatus_MA = '1')then
                            EdosP <= EP_Guarda_T0F;
                        else
                            EdosP <= EP_Espera_MAF;
                        end if;

                    when EP_Guarda_T0F =>
                        EdosP <= EP_Fin;
                            
                    when EP_Fin =>
                        EdosP <= EP_Fin;

                end case;
            end if;
        end if;
    end process;

    -- Activa la máquina MDouble
    En_MD <= '1' when EdosP = EP_Activa_MD else '0';

    -- Activa la máquina MAdd
    En_MA <= '1' when EdosP = EP_Activa_MA or EdosP = EP_Activa_MAF else '0'; 

    -- Actualiza el valor de Estatus
    Estatus <= '1' when EdosP = EP_Fin else '0';

    -- Guarda el valor de T0
    process(clk, EdosP, T0X, T0Z)
    begin
        if(rising_edge(clk))then
            if(EdosP = EP_Guarda_T0)then
                T0X <= RX;
                T0Z <= RZ;
            elsif(EdosP = EP_Guarda_T0_MD)then
                T0X <= MD_X;
                T0Z <= MD_Z;
            elsif(EdosP = EP_Guarda_T0_MA)then
                T0X <= MA_X1;
                T0Z <= MA_Z1;
            elsif(EdosP = EP_Guarda_T0F)then
                T0X <= MA_X1;
                T0Z <= MA_Z1;
            else
                T0X <= T0X;
                T0Z <= T0Z;
            end if;
        end if;
    end process;

    ----- Máquina de estados MDouble -----
    maquinaMDouble: process(clk, EdosMD, en_MD, ceFFMult)
    begin
        if(rising_edge(clk))then
            case EdosMD is
                when EMD_Espera =>
                    if(en_MD = '1')then
                        EdosMD <= EMD_Guarda_Temp;
                    else
                        EdosMD <= EMD_Espera;
                    end if;

                when EMD_Guarda_Temp => 
                    EdosMD <= EMD_P1;

                when EMD_P1 =>
                    EdosMD <= EMD_Act_P2;

                when EMD_Act_P2 =>
                    EdosMD <= EMD_Esp_P2;

                when EMD_Esp_P2 =>
                    if(ceFFMult = '1')then
                        EdosMD <= EMD_Guarda_P2;
                    else
                        EdosMD <= EMD_Esp_P2;
                    end if;

                when EMD_Guarda_P2 =>
                    EdosMD <= EMD_Act_P3;

                when EMD_Act_P3 =>
                    EdosMD <= EMD_Esp_P3;

                when EMD_Esp_P3 =>
                    if(ceFFMult = '1')then
                        EdosMD <= EMD_Guarda_P3;
                    else
                        EdosMD <= EMD_Esp_P3;
                    end if;

                when EMD_Guarda_P3 =>
                    EdosMD <= EMD_Act_P4;

                when EMD_Act_P4 =>
                    EdosMD <= EMD_Esp_P4;

                when EMD_Esp_P4 =>
                    if(ceFFMult = '1')then
                        EdosMD <= EMD_Guarda_P4;
                    else
                        EdosMD <= EMD_Esp_P4;
                    end if;

                when EMD_Guarda_P4 =>
                    EdosMD <= EMD_Act_P5;

                when EMD_Act_P5 =>
                    EdosMD <= EMD_Esp_P5;

                when EMD_Esp_P5 =>
                    if(ceFFMult = '1')then
                        EdosMD <= EMD_Guarda_P5;
                    else
                        EdosMD <= EMD_Esp_P5;
                    end if;

                when EMD_Guarda_P5 =>
                    EdosMD <= EMD_Act_P6;

                when EMD_Act_P6 =>
                    EdosMD <= EMD_Esp_P6;

                when EMD_Esp_P6 =>
                    if(ceFFMult = '1')then
                        EdosMD <= EMD_Guarda_P6;
                    else
                        EdosMD <= EMD_Esp_P6;
                    end if;

                when EMD_Guarda_P6 =>
                    EdosMD <= EMD_Act_P7;

                when EMD_Act_P7 =>
                    EdosMD <= EMD_Esp_P7;

                when EMD_Esp_P7 =>
                    if(ceFFMult = '1')then
                        EdosMD <= EMD_Guarda_P7;
                    else
                        EdosMD <= EMD_Esp_P7;
                    end if;

                when EMD_Guarda_P7 =>
                    EdosMD <= EMD_P8;

                when EMD_P8 =>
                    EdosMD <= EMD_Fin;

                when EMD_Fin =>
                    EdosMD <= EMD_Espera;

            end case;
        end if;
    end process;

    -- Actualiza el valor MD_T1
    process(clk, EdosMD, MD_T1)
    begin
        if(rising_edge(clk))then
            if(EdosMD = EMD_Guarda_Temp)then
                MD_T1 <= ECC_B;
            elsif(EdosMD = EMD_Guarda_P4 or EdosMD = EMD_Guarda_P6)then
                MD_T1 <= OperMC;
            else
                MD_T1 <= MD_T1;
            end if;
        end if;
    end process;

    -- Actualiza el valor MD_X
    process(clk, EdosMD, MD_X)
    begin
        if(rising_edge(clk))then
            if(EdosMD = EMD_Guarda_Temp)then
                MD_X <= T0X;
            elsif(EdosMD = EMD_Guarda_P2 or EdosMD = EMD_Guarda_P7)then
                MD_X <= OperMC;
            elsif(EdosMD = EMD_P8)then
                MD_X <= OperSC;
            else
                MD_X <= MD_X;
            end if;
        end if;
    end process;

    -- Actualiza el valor de MD_Z
    process(clk, EdosMD, MD_Z)
    begin
        if(rising_edge(clk))then
            if(EdosMD = EMD_Guarda_Temp)then
                MD_Z <= T0Z;
            elsif(EdosMD = EMD_Guarda_P3 or EdosMD = EMD_Guarda_P5)then
                MD_Z <= OperMC;
            else
                MD_Z <= MD_Z;
            end if;
        end if;
    end process;

    -- Estatus de la máquina de estados de MDouble
    Estatus_MD <= '1' when EdosMD = EMD_Fin else '0';

    ----- Máquina de estados MAdd -----
    MaquinaMAdd: process(clk, EdosMA, en_MA, ceFFMult)
    begin
        if(rising_edge(clk))then
            case EdosMA is
                when EMA_Espera =>
                    if(en_MA = '1')then
                        EdosMA <= EMA_Guarda_T0TD;
                    else
                        EdosMA <= EMA_Espera;
                    end if;

                when EMA_Guarda_T0TD =>
                    EdosMA <= EMA_Inicia_Bucle;

                when EMA_Inicia_Bucle =>
                    EdosMA <= EMA_P1;

                when EMA_P1 =>
                    EdosMA <= EMA_Act_P2;

                when EMA_Act_P2 =>
                    EdosMA <= EMA_Esp_P2;

                when EMA_Esp_P2 => 
                    if(ceFFMult = '1')then
                        EdosMA <= EMA_Guarda_P2;
                    else
                        EdosMA <= EMA_Esp_P2;
                    end if;

                when EMA_Guarda_P2 =>
                    EdosMA <= EMA_Act_P3;

                when EMA_Act_P3 =>
                    EdosMA <= EMA_Esp_P3;

                when EMA_Esp_P3 =>
                    if(ceFFMult = '1')then
                        EdosMA <= EMA_Guarda_P3;
                    else
                        EdosMA <= EMA_Esp_P3;
                    end if;

                when EMA_Guarda_P3 =>
                    EdosMA <= EMA_Act_P4;

                when EMA_Act_P4 =>
                    EdosMA <= EMA_Esp_P4;

                when EMA_Esp_P4 =>
                    if(ceFFMult = '1')then
                        EdosMA <= EMA_Guarda_P4;
                    else
                        EdosMA <= EMA_Esp_P4;
                    end if;

                when EMA_Guarda_P4 =>
                    EdosMA <= EMA_P5;

                when EMA_P5 =>
                    EdosMA <= EMA_Act_P6;

                when EMA_Act_P6 =>
                    EdosMA <= EMA_Esp_P6;

                when EMA_Esp_P6 =>
                    if(ceFFMult = '1')then
                        EdosMA <= EMA_Guarda_P6;
                    else
                        EdosMA <= EMA_Esp_P6;
                    end if;

                when EMA_Guarda_P6 =>
                    EdosMA <= EMA_Act_P7;

                when EMA_Act_P7 =>
                    EdosMA <= EMA_Esp_P7;

                when EMA_Esp_P7 =>
                    if(ceFFMult = '1')then
                        EdosMA <= EMA_Guarda_P7;
                    else
                        EdosMA <= EMA_Esp_P7;
                    end if;

                when EMA_Guarda_P7 =>
                    EdosMA <= EMA_P8;

                when EMA_P8 =>
                    EdosMA <= EMA_Fin;

                when EMA_Fin =>
                    EdosMA <= EMA_Espera;

            end case;
        end if;
    end process;

    -- Actualiza el valor de MA_T1
    process(clk, EdosMA, MA_T1)
    begin
        if(rising_edge(clk))then
            if(EdosMA = EMA_Guarda_T0TD)then
                MA_T1 <= PX;
            else
                MA_T1 <= MA_T1;
            end if;
        end if;
    end process;

    -- Actualiza el valor de MA_T2
    process(clk, EdosMA, MA_T2)
    begin
        if(rising_edge(clk))then
            if(EdosMA = EMA_Guarda_P4)then
                MA_T2 <= OperMC;
            else
                MA_T2 <= MA_T2;
            end if;
        end if;
    end process;

    -- Actualiza el valor de MA_X1
    process(clk, EdosMA, MA_X1)
    begin
        if(rising_edge(clk))then
            if(EdosMA = EMA_Guarda_T0TD)then
                MA_X1 <= T0X;
            elsif(EdosMA = EMA_Guarda_P2 or EdosMA = EMA_Guarda_P7)then
                MA_X1 <= OperMC;
            elsif(EdosMA = EMA_P8)then
                MA_X1 <= OperSC;
            else
                MA_X1 <= MA_X1;
            end if;
        end if;
    end process;

    -- Actualiza el valor de MA_Z1
    process(clk, EdosMA, MA_Z1)
    begin
        if(rising_edge(clk))then
            if(EdosMA = EMA_Guarda_T0TD)then 
                MA_Z1 <= T0Z;
            elsif(EdosMA = EMA_Guarda_P3 or EdosMA = EMA_Guarda_P6)then
                MA_Z1 <= OperMC;
            elsif(EdosMA = EMA_P5)then
                MA_Z1 <= OperSC;
            else
                MA_Z1 <= MA_Z1;
            end if;
        end if;
    end process;

    -- Actualiza el valor de MA_X2 y MA_Z2
    process(clk, EdosMA, MA_X2, MA_Z2, cont)
    begin
        if(rising_edge(clk))then
            if(EdosMA = EMA_Guarda_T0TD)then
                if(cont >= 0)then
                    if(k(cont) = '0')then
                        MA_X2 <= T1X;
                        MA_Z2 <= T1Z;
                    else
                        MA_X2 <= T2X;
                        MA_Z2 <= T2Z;
                    end if;
                else
                    MA_X2 <= MA_X2;
                    MA_Z2 <= MA_Z2;
                end if;
            else
                MA_X2 <= MA_X2;
                MA_Z2 <= MA_Z2;
            end if;
        end if;
    end process;

    -- Estatus de la máquina MAdd
    Estatus_MA <= '1' when EdosMA = EMA_Fin else '0';

    ----- Contador -----
    process(clk, rst, EdosP, cont)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                cont <= 162;
            else
                if(EdosP = EP_Aumenta_Cuenta)then
                    cont <= cont - 1;
                else
                    cont <= cont;
                end if;
            end if;
        end if;
    end process;

    ----- Control del módulo multiplicación FFAdd (OperMA y OperMB) -----
    -- Activa el multiplicador
    enFFMult <= '1' when (EdosMD = EMD_Act_P2 or EdosMD = EMD_Act_P3 or EdosMD = EMD_Act_P4 or EdosMD = EMD_Act_P5 or EdosMD = EMD_Act_P6 or EdosMD = EMD_Act_P7 or EdosMA = EMA_Act_P2 or EdosMA = EMA_Act_P3 or EdosMA = EMA_Act_P4 or EdosMA = EMA_Act_P6 or EdosMA = EMA_Act_P7) else '0';

    -- Actualiza el valor de OperMA y OperMB
    process(clk, EdosMD, EdosMA, OperMA, OperMB)
    begin
        if(rising_edge(clk))then
            if(EdosMD = EMD_Act_P2)then
                OperMA <= MD_X;
                OperMB <= MD_X;
            elsif(EdosMD = EMD_Act_P3)then
                OperMA <= MD_Z;
                OperMB <= MD_Z;
            elsif(EdosMD = EMD_Act_P4)then
                OperMA <= MD_Z;
                OperMB <= MD_T1;
            elsif(EdosMD = EMD_Act_P5)then
                OperMA <= MD_Z;
                OperMB <= MD_X;
            elsif(EdosMD = EMD_Act_P6)then
                OperMA <= MD_T1;
                OperMB <= MD_T1;
            elsif(EdosMD = EMD_Act_P7)then
                OperMA <= MD_X;
                OperMB <= MD_X;
            elsif(EdosMA = EMA_Act_P2)then
                OperMA <= MA_X1;
                OperMB <= MA_Z2;
            elsif(EdosMA = EMA_Act_P3)then
                OperMA <= MA_Z1;
                OperMB <= MA_X2;
            elsif(EdosMA = EMA_Act_P4)then
                OperMA <= MA_X1;
                OperMB <= MA_Z1;
            elsif(EdosMA = EMA_Act_P6)then
                OperMA <= MA_Z1;
                OperMB <= MA_Z1;
            elsif(EdosMA = EMA_Act_P7)then
                OperMA <= MA_Z1;
                OperMB <= MA_T1;
            else
                OperMA <= OperMA;
                OperMB <= OperMB;
            end if;
        end if;
    end process;

    ----- Control del módulo suma ----- (OperSA, OperSB, OperSC)
    process(clk, EdosMA, EdosMD, OperSA, OperSB)
    begin
        if(rising_edge(clk))then
            if(EdosMD = EMD_P8)then
                OperSA <= MD_X;
                OperSB <= MD_T1;
            elsif(EdosMA = EMA_P5)then
                OperSA <= MA_Z1;
                OperSB <= MA_X1;
            elsif(EdosMA = EMA_P8)then
                OperSA <= MA_X1;
                OperSB <= MA_T2;
            else
                OperSA <= OperSA;
                OperSB <= OperSB;
            end if;
        end if;
    end process;

    ----- Salida Q -----
    QX <= MA_X1 when EdosMA = EMA_Fin else (others => '0');
    QZ <= MA_Z1 when EdosMA = EMA_Fin else (others => '0');
    
end Behavioral;
