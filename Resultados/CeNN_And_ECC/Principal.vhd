library IEEE;
library xil_defaultlib;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use xil_defaultlib.Componentes.all;

entity Principal is
    port
    (
        -- Señales de entrada
        clk: in std_logic;
        rx: in std_logic;
        rst: in std_logic;
        selQ: in std_logic_vector(4 downto 0);
        -- Señales de salida
        tx: out std_logic;
        SSEG_AN: out std_logic_vector(7 downto 0);
        SSEG_CA: out std_logic_vector(7 downto 0)
    );
end Principal;

architecture Behavioral of Principal is

    -- Reset interno
    signal rst_Int: std_logic:= '0';

    -- Constantes
    constant nBitsPalabra : integer := 16; -- Cantidad de bits para los valores
    constant uno : std_logic_vector(nBitsPalabra - 1 downto 0) := X"0200"; -- Constante de valor 1  a 16 bits, 1 bit de signo, 6 de entero y resto de fracción
    constant nuno : std_logic_vector(nBitsPalabra - 1 downto 0) := X"FE00"; -- Constante de valor -1 a 16 bits, 1 bit de signo, 6 de entero y resto de fracción
    constant filas : integer := 8; -- Cantidad de Filas que tendrá la CNN
    constant columnas : integer := 8; -- Cantidad de Columnas que tendrá la CNN
    constant nBitsDatoRx: integer := 8; -- Cantidad de bits por palabra recibidos por el receptor RS232
    constant sizeRAM : integer := 65536; -- Cantidad de pixeles a guardar. Tamaño de la RAM
    constant nBitsMaxX: integer:= 8; -- Cantidad de bits para direccionar 256 bytes en X (1byte = 8bits)
    constant nBitsMaxY: integer:= 8; -- Cantidad de bits para direccionar 256 bytes en Y (1byte = 8bits)

    -- Señales para el receptor RS232
    signal edo_rx: std_logic:= '0';
    signal data_in: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');

    -- Señales para PilaParametros
    signal totalPixelX: std_logic_vector(nBitsMaxX - 1 downto 0):= (others => '0');
    signal totalPixelY: std_logic_vector(nBitsMaxY - 1 downto 0):= (others => '0');
    signal a11, a12, a13: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal a21, a22, a23: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal a31, a32, a33: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal b11, b12, b13: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal b21, b22, b23: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal b31, b32, b33: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal Ikl: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');
    signal banPP: std_logic:= '0';
    signal totalPixeles: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');

    -- Señales para la RAM de la imagen de entrada
    signal we_ImgEnt: std_logic:= '0';
    signal en_ImgEnt: std_logic:= '0';
    signal addr_re_ImgEnt: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal addr_we_ImgEnt: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal DI_ImgEnt: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal DO_ImgEnt: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');

    -- Señales para el Receptor de la imagen de entrada
    signal en_RIE: std_logic:= '0';
    signal we_RIE: std_logic:= '0';
    signal rst_RIE: std_logic:= '0';
    signal addr_RIE: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal DI_RIE: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal ban_RIE: std_logic:= '0';

    -- Señales para el control de bloques
    signal en_CB: std_logic:= '0';
    signal ban_CB: std_logic:= '0';
    signal addr_re_CB: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal addr_we_CB: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal we_CB: std_logic:= '0';
    signal DI_CB: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal codigo: std_logic_vector(63 downto 0):= (others => '0');
    signal estatusCodigo: std_logic:= '0';

    -- Sañales para la RAM de la imagen de salida
    signal we_ImgSal: std_logic:= '0';
    signal en_ImgSal: std_logic:= '0';
    signal addr_re_ImgSal: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal addr_we_ImgSal: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal DI_ImgSal: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal DO_ImgSal: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');

    -- Señales para siete segmentos
    signal bin: std_logic_vector(nBitsPalabra - 1 downto 0):= (others => '0');

    -- Señales para regresar imagen de salida
    signal en_RIS: std_logic:= '0';
    signal rst_RIS: std_logic:= '0';
    signal addr_RIS: std_logic_vector(nBitsMaxX + nBitsMaxY - 1 downto 0):= (others => '0');
    signal ban_RIS: std_logic:= '0';

    -- Señales para el transmisor RS232
    signal dato_tx: std_logic_vector(nBitsDatoRx - 1 downto 0):= (others => '0');
    signal en_tx: std_logic:= '0';
    signal edo_tx: std_logic:= '0';

    -- Señales temporales para la multiplicación escalar
    signal enMultEscalar, ce_ME: std_logic:= '0';
    signal QX, QZ: std_logic_vector(162 downto 0);
    signal kTemp: std_logic_vector(162 downto 0);

    -- Máquina de estados
    type Estados is (LlenaParametros, LlenaImgEnt, ControlCNN, ActivaECC, EsperaECC, RegresaImg, Finaliza);
    signal Edo: Estados;

begin

    ----------------------------------------------------------------------------------
    --                                   Módulos                                    --
    ----------------------------------------------------------------------------------
    
    rxRS232: RS232Rx
        port map
        (
            clk => clk, rst => rst_Int, rx => rx, edo_rx => edo_rx, dato => data_in
        );

    Parametros: PilaParametros
        generic map
        (
            nBitsDatoRx => nBitsDatoRx, nBitsPalabra => nBitsPalabra, nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY
        )
        port map
        (
            -- Señales de entrada
            rst => rst_Int, clk => clk, edo_rx => edo_rx, data_in => data_in,
            -- Señales de salida
            totalPixelX => totalPixelX, totalPixelY => totalPixelY,
            a11 => a11, a12 => a12, a13 => a13, a21 => a21, a22 => a22, a23 => a23, a31 => a31, a32 => a32, a33 => a33,
            b11 => b11, b12 => b12, b13 => b13, b21 => b21, b22 => b22, b23 => b23, b31 => b31, b32 => b32, b33 => b33,
            Ikl => Ikl, ban => banPP
        );

    SieteSeg: SieteSegmentos
        port map
        (
            -- Señales de entrada
            clk => clk, bin => bin,
            -- Señales de salida
            SSEG_CA => SSEG_CA, SSEG_AN => SSEG_AN
        );

    RAM_ImgEnt: ModuloRAM 
        generic map
        (
            nBitsPalabra => nBitsDatoRx, widthAddr => nBitsMaxX + nBitsMaxY, sizeRAM => sizeRAM
        )
        port map
        (
            clk => clk, we => we_ImgEnt, en => en_ImgEnt, addr_re => addr_re_ImgEnt,
            addr_we => addr_we_ImgEnt, DI => DI_ImgEnt, DO => DO_ImgEnt
        );

    RecibeImgEnt: ReceptorImgEnt
        generic map
        (
            nBitsDatoRx => nBitsDatoRx, nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst_Int, edo_rx => edo_rx, en => en_RIE, totalPixelX => totalPixelX, totalPixelY => totalPixelY,
            -- Señales de salida
            totalPixeles => totalPixeles, we => we_RIE, addr => addr_RIE,
            ban => ban_RIE
        );

    CtrCNN: ControlDeBloques
        generic map
        (
            nBitsPalabra => nBitsPalabra, sizeRAM => sizeRAM, nBitsDatoRx => nBitsDatoRx, nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY,
            filas => filas, columnas => columnas
        )
        port map
        (
            -- Señales de entrada
            clk => clk, rst => rst_Int, en => en_CB, totalPixelX => totalPixelX, totalPixelY => totalPixelY, DO => DO_ImgEnt,
            -- Plantillas
            a11 => a11, a12 => a12, a13 => a13, a21 => a21, a22 => a22, a23 => a23, a31 => a31, a32 => a32, a33 => a33,
            b11 => b11, b12 => b12, b13 => b13, b21 => b21, b22 => b22, b23 => b23, b31 => b31, b32 => b32, b33 => b33,
            Ikl => Ikl,
            -- Señales de memoria
            addr_re => addr_re_CB, addr_we => addr_we_CB, we => we_CB, DI => DI_CB,
            -- Señales de salida
            codigo => codigo, estatusCodigo => estatusCodigo, ban => ban_CB
        );

    RAM_ImgSal: ModuloRAM
        generic map
        (
            nBitsPalabra => nBitsDatoRx, widthAddr => nBitsMaxX + nBitsMaxY, sizeRAM => sizeRAM
        )
        port map
        (
            clk => clk, we => we_ImgSal, en => en_ImgSal, addr_re => addr_re_ImgSal, addr_we => addr_we_ImgSal,
            DI => DI_ImgSal, DO => DO_ImgSal
        );

    RegresaImagen: RegresaImgSal
        generic map
        (
            nBitsDatoRx => nBitsDatoRx, nBitsMaxX => nBitsMaxX, nBitsMaxY => nBitsMaxY
        )
        port map
        (
            clk => clk, rst => rst_Int, en => en_RIS, dato_ent => DO_ImgSal, edo_tx => edo_tx, totalPixeles => totalPixeles,
            -- Señales de salida
            addr => addr_RIS, en_tx => en_tx, dato_tx => dato_tx, ban => ban_RIS
        );

    txRS232: RS232Tx
        port map
        (
            -- Señales de entrada
            clk => clk, en => en_tx, dato => dato_tx,
            -- Señales de salida
            tx => tx, edo_tx => edo_tx
        );

    ECC163: MultiplicacionEscalar
        port map
        (
            -- Entradas
            clk => clk, rst => rst, en => enMultEscalar, k => kTemp,
            -- Salida
            Estatus => ce_Me, QX => QX, QZ => QZ
        );

    ----------------------------------------------------------------------------------
    --                              Máquina de estados                              --
    ----------------------------------------------------------------------------------
    Maquina: process(clk, rst_Int, Edo, banPP, ban_RIE, ban_RIS, ban_CB)
    begin
        if(rising_edge(clk))then
            if(rst_Int = '1')then
                Edo <= LlenaParametros;
            else
                case Edo is
                    when LlenaParametros =>
                        if(banPP = '1')then
                            Edo <= LlenaImgEnt;
                        else
                            Edo <= LlenaParametros;
                        end if;
                    when LlenaImgEnt =>
                        if(ban_RIE = '1')then
                            Edo <= ControlCNN;
                        else
                            Edo <= LlenaImgEnt;
                        end if;
                    when ControlCNN =>
                        if(ban_CB = '1')then
                            Edo <= ActivaECC;
                        else
                            Edo <= ControlCNN;
                        end if;

                    when ActivaECC =>
                        Edo <= EsperaECC;

                    when EsperaECC =>
                        if(ce_ME = '1')then
                            Edo <= RegresaImg;
                        else
                            Edo <= EsperaECC;
                        end if;

                    when RegresaImg =>
                        if(ban_RIS = '1')then
                            Edo <= Finaliza;
                        else
                            Edo <= RegresaImg;
                        end if;
                    when Finaliza =>
                        Edo <= LlenaParametros;
                end case;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------
    --                                RAM de entrada                                --
    ----------------------------------------------------------------------------------
    we_ImgEnt <= we_RIE;
    en_ImgEnt <= '1';
    addr_re_ImgEnt <= addr_re_CB;
    addr_we_ImgEnt <= addr_RIE;
    DI_ImgEnt <= data_in;

    ----------------------------------------------------------------------------------
    --                                RAM de salida                                 --
    ----------------------------------------------------------------------------------
    we_ImgSal <= we_CB;
    en_ImgSal <= '1';
    addr_re_ImgSal <= addr_RIS;
    addr_we_ImgSal <= addr_we_CB;
    DI_ImgSal <= DI_CB;

    ----------------------------------------------------------------------------------
    --                                Llena Img Ent                                 --
    ----------------------------------------------------------------------------------
    en_RIE <= '1' when (Edo = LlenaImgEnt) else '0';

    ----------------------------------------------------------------------------------
    --                                Control CNN                                  --
    ----------------------------------------------------------------------------------
    en_CB <= '1' when (Edo = ControlCNN) else '0';
    
    ----------------------------------------------------------------------------------
    --                               Regresa Img Ent                                --
    ----------------------------------------------------------------------------------
    en_RIS <= '1' when (Edo = RegresaImg) else '0';
    
    ----------------------------------------------------------------------------------
    --                                Reset general                                 --
    ----------------------------------------------------------------------------------
    ReinicioInterno: process(clk, rst, Edo)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                rst_Int <= '1';
            else
                if(Edo = Finaliza)then
                    rst_Int <= '1';
                else
                    rst_Int <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------------
    --                                  ECC B-163                                   --
    ----------------------------------------------------------------------------------
    enMultEscalar <= '1' when Edo = ActivaECC else '0';
    kTemp <= X"00000000" & "000" & codigo & codigo;

    ----------------------------------------------------------------------------------
    --                                  Salida 7S                                   --
    ----------------------------------------------------------------------------------
    process(clk, Edo)
    begin
        if(rising_edge(clk))then
            if(Edo = LlenaParametros)then
                bin <= X"E001";
            elsif(Edo = LlenaImgEnt)then
                bin <= X"E002";
            elsif(Edo = ControlCNN)then
                bin <= X"E003";
            elsif(Edo = RegresaImg)then
                bin <= X"E004"; 
            elsif(Edo = Finaliza)then
                if(selQ = "00000")then
                    bin <= QX(15 downto 0);
                elsif(selQ = "00001")then
                    bin <= QX(31 downto 16);
                elsif(selQ = "00010")then
                    bin <= QX(47 downto 32);
                elsif(selQ = "00011")then
                    bin <= QX(63 downto 48);
                elsif(selQ = "00100")then
                    bin <= QX(79 downto 64);
                elsif(selQ = "00101")then
                    bin <= QX(95 downto 80);
                elsif(selQ = "00110")then
                    bin <= QX(111 downto 96);
                elsif(selQ = "00111")then
                    bin <= QX(127 downto 112);
                elsif(selQ = "01000")then
                    bin <= QX(143 downto 128);
                elsif(selQ = "01001")then
                    bin <= QX(159 downto 144);
                elsif(selQ = "01010")then
                    bin <= X"000" & '0' & QX(162 downto 160);
                elsif(selQ = "01011")then
                    bin <= QZ(15 downto 0);
                elsif(selQ = "01100")then
                    bin <= QZ(31 downto 16);
                elsif(selQ = "01101")then
                    bin <= QZ(47 downto 32);
                elsif(selQ = "0110")then
                    bin <= QZ(63 downto 48);
                elsif(selQ = "01111")then
                    bin <= QZ(79 downto 64);
                elsif(selQ = "10000")then
                    bin <= QZ(95 downto 80);
                elsif(selQ = "10001")then
                    bin <= QZ(111 downto 96);
                elsif(selQ = "10010")then
                    bin <= QZ(127 downto 112);
                elsif(selQ = "10011")then
                    bin <= QZ(143 downto 128);
                elsif(selQ = "10100")then
                    bin <= QZ(159 downto 144);
                elsif(selQ = "10101")then
                    bin <= X"000" & '0' & QZ(162 downto 160);
                else
                    bin <= (others => '0');
                end if;
            else
                bin <= (others => '1');
            end if;
        end if;
    end process;

end Behavioral;
