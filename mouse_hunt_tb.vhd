library ieee;
use ieee.std_logic_1164.all;

entity mouse_hunt_tb is
end entity mouse_hunt_tb;

architecture rtl of mouse_hunt_tb is

    component mouse_hunt is
        port (
            clock : in std_logic;
            reset : in std_logic;
            ligar : in std_logic;
            dado_serial : in std_logic;
            echo : in std_logic;
            tem_presa : out std_logic;
            rato_solto : out std_logic;
            pwm : out std_logic;
            trigger : out std_logic;
            db_pwm : out std_logic;
            db_posicao : out std_logic;
            db_estado_interface : out std_logic_vector(3 downto 0);
            db_estado_receptor : out std_logic_vector(3 downto 0);
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    constant clockPeriod : time := 20 ns;
    constant bitPeriod   : time := 434*clockPeriod;
    
    procedure UART_WRITE_BYTE (
        Data_In : in  std_logic_vector(7 downto 0);
        signal Serial_Out : out std_logic ) is
    begin
  
        -- envia Start Bit
        Serial_Out <= '0';
        wait for bitPeriod;
  
        -- envia 8 bits seriais (dados + paridade)
        for ii in 0 to 7 loop
            Serial_Out <= Data_In(ii);
            wait for bitPeriod;
        end loop;  -- loop ii
  
        -- envia 2 Stop Bits
        Serial_Out <= '1';
        wait for 2*bitPeriod;
  
    end UART_WRITE_BYTE;

    signal clock_in : std_logic := '0';
    signal reset_in : std_logic := '0';
    signal ligar_in : std_logic := '0';
    signal echo_in : std_logic := '0';
    signal dado_serial_in : std_logic := '1';
    signal serialData        : std_logic_vector(7 downto 0) := "00000000";
    signal trigger_out : std_logic := '0';
    signal pwm_out : std_logic := '0';
    signal tem_presa_out : std_logic := '0';
    signal rato_solto_out : std_logic := '0';
    signal fim_posicao_out : std_logic := '0';
    signal db_estado_out : std_logic_vector (6 downto 0) := "0000000";



    signal keep_simulating : std_logic := '0';

    signal larguraPulso : time := 1 ns;

begin

    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

    dut : mouse_hunt
    port map(
        clock              => clock_in,
        reset              => reset_in,
        ligar              => ligar_in,
        dado_serial        => dado_serial_in,
        echo               => echo_in,
        tem_presa          => tem_presa_out,
        rato_solto         => rato_solto_out,
        trigger            => trigger_out,
        pwm                => pwm_out
    );

    stimulus : process is
    begin

        assert false report "Inicio das simulacoes" severity note;
        keep_simulating <= '1';

        ---- valores iniciais ----------------
        ligar_in <= '0';
        echo_in  <= '0';
        serialData <= "00000000";
        dado_serial_in <= '1';

        ---- inicio: reset ----------------
        -- wait for 2*clockPeriod;
        reset_in <= '1'; 
        wait for 2 us;
        reset_in <= '0';
        wait until falling_edge(clock_in);

         ---- ligar mouse hunt ----------------
        wait for 20 us;
        ligar_in <= '1';

        -- primeiro teste de captura
        assert false report "Teste 1: captura" severity note;
        larguraPulso <= 1176 us; -- 20 cm

        wait until falling_edge(trigger_out);

        wait for 400 us;

        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';

        wait until tem_presa_out = '1';

        wait for 400 us;

        serialData <= "01110011";
        UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>dado_serial_in);
        dado_serial_in <= '1';
        wait for bitPeriod;

        wait for 400 us;

        serialData <= "01110010";
        UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>dado_serial_in);
        dado_serial_in <= '1';
        wait for bitPeriod;
        
        wait for 2*clockPeriod;


        assert false report "Teste 2: distancia maior" severity note;
        larguraPulso <= 2352 us; -- 40 cm

        wait until falling_edge(trigger_out);
        wait for 400 us;

        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';



        assert false report "Teste 3: captura" severity note;
        larguraPulso <= 882 us; -- 15 cm

        wait until falling_edge(trigger_out);

        wait for 400 us;

        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';

        wait until tem_presa_out = '1';

        wait for 400 us;

        serialData <= "01110011";
        UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>dado_serial_in);
        dado_serial_in <= '1';
        wait for bitPeriod;

        wait for 400 us;

        serialData <= "01110010";
        UART_WRITE_BYTE ( Data_In=>serialData, Serial_Out=>dado_serial_in);
        dado_serial_in <= '1';
        wait for bitPeriod;
        
        wait for 2*clockPeriod;

        ligar_in <= '0';

        wait for 400 us;

        ---- final dos casos de teste da simulacao
        assert false report "Fim das simulacoes" severity note;
        keep_simulating <= '0';
        
        wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
    end process;
end architecture rtl;