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
        selRSA: in std_logic_vector(6 downto 0);
        -- Señales de salida
        tx: out std_logic;
        SSEG_AN: out std_logic_vector(7 downto 0);
        SSEG_CA: out std_logic_vector(7 downto 0)
    );
end Principal;

architecture Behavioral of Principal is

    -- Reset internocxxxxxxx
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

    -- Señales para el cifrador de datos RSA 1024 bits
    signal rstEM: std_logic := '0'; -- reset de la exponenciación modular
    signal enEM: std_logic := '0'; -- habilitador de la exponenciación
    signal xEM: std_logic_vector(1023 downto 0) := (others => '0'); -- contenedor del valor a cifrar
    signal aEM: std_logic_vector(1023 downto 0) := (others => '0'); -- variable temporal del valor cifrado
    signal bEM: std_logic := '0'; -- estatus del módulo
    signal diEM: std_logic:= '0'; -- Indicador del bit de la clave secreta

    -- Constantes para el cifrador de datos RSA 1024 bits
    constant m: std_logic_vector(1023 downto 0) := X"00d36e0cf1e750ac8a2df4e108dcba391c57c97ced3642509300eaab1c1e8994b43efac40a39f74c5b9343819bd525464c095f794aaf493972087aa29f76c7f5de39b1702711b0581cc9e5c8d4e429b76d749bdb0919ccdc8dea9cc5b683b23755ca1cc34dd1c916f192a26df4ad5595bb5844d5c0a0832f265cd87293b8ce71"; -- Valor del módulo
    constant mp: std_logic_vector(15 downto 0) := X"cd6f"; -- Valor de -m^(-1)
    constant d: std_logic_vector(1023 downto 0) := X"0082e76f23728bda5957222f7d888ee376022363cc8299ab94ee2cd3994456e16da7dfec036ea835e0e8419cd128a8b8371d755511f6af6cc566dfbc9416a6d5a0c6c5ae76f88bcdd27d49e6bbc264595039bc9860d72620c5026b680f789cc7aae38cc50768ea3133edf7bf72068cde4c4027a41f1c569e5c7a28d0e8cb127f"; -- Clave secreta
    constant RmodM: std_logic_vector(1023 downto 0) := X"00cc2a6003cb9fbd36876c604d933910ca09cc35ad81f4be8fe4bf770f23ef826ffb515fa80880d5773f848ee7ba022638afc298da6c9da95bc3f9b585a0a43ac45cd3a0d7a625a5404da4970899a598e23fe09e03dbb9c8b3d0c55ab309e335730b484311c8474e6a01f147aac7b244de74e9fe7e41a816b1eebdb3b1eed19b";
    constant RRmodM: std_logic_vector(1023 downto 0) := X"003ff753e7775a3ba342166aa6379230ecf610c5db08cb681df91c92c45275baf42aee34e6c3ec0f09a170fbe8198ca8bc612c74aadbb693f402a3e2974aff483e59de9566555faa6afa4ecce51f3e03507b1b5d8fe8152eb230620277540633a51c9716f6a95f52b313c98541282fdf1b9ddb4293cc7a2758350ffde2ad4bb4";

    -- Máquina de estados
    type Estados is (LlenaParametros, LlenaImgEnt, ControlCNN, ActivaRSA, EsperaRSA, RegresaImg, Finaliza);
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

    Codifica: Codificador
        port map
        (
            -- Entradas
            clk => clk, codigoCeNN => codigo, 
            -- Salidas
            mensaje => xEM
        );

    SaMAL2RDJ: ExpMod
        generic map
        (
            widthWord => 16, sizeRAM => 64, widthAddr => 7, nBits => 1024
        )
        port map
        (
            -- Señales de este módulo
            clk => clk, rst => rstEM, en => enEM,
            -- Entradas
            x => xEM, N => m, np => mp, RmodN => RmodM, RRmodN => RRmodM, d => d,
            -- Salidas
            di => diEM, S => aEM, ban => bEM
        );

    ----------------------------------------------------------------------------------
    --                              Máquina de estados                              --
    ----------------------------------------------------------------------------------
    Maquina: process(clk, rst_Int, Edo, banPP, ban_RIE, ban_RIS, ban_CB, bEM)
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
                            Edo <= ActivaRSA;
                        else
                            Edo <= ControlCNN;
                        end if;

                    when ActivaRSA =>
                        Edo <= EsperaRSA;

                    when EsperaRSA =>
                        if(bEM = '1')then
                            Edo <= RegresaImg;
                        else
                            Edo <= EsperaRSA;
                        end if;

                    when RegresaImg =>
                        if(bEM = '1')then
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
    --                                Control RSA                                   --
    ----------------------------------------------------------------------------------
    enEM <= '1' when (Edo = ActivaRSA) else '0';
    
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
    --                                  Salida 7S                                   --
    ----------------------------------------------------------------------------------
    process(clk, Edo, selRSA)
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
                bin <= aEM(16*(to_integer(unsigned(selRSA))) + 15 downto 16*(to_integer(unsigned(selRSA))));
            else
                bin <= (others => '1');
            end if;
        end if;
    end process;

end Behavioral;
