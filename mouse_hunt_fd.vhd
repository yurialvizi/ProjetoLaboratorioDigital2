library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mouse_hunt_fd is
    port (
        clock : in std_logic;
        reset : in std_logic;
        -- receptor
        dado_serial : in std_logic;
        -- interface
        echo : in std_logic;
        -- UC
        limpa : in std_logic;
        medir : in std_logic;
        posicao : in std_logic;
        menor : out std_logic;
        s_recebido : out std_logic;
        r_recebido : out std_logic;
        tem_medida : out std_logic;
        tem_dado : out std_logic;
        -- controle servo
        pwm : out std_logic;
        db_pwm : out std_logic;
        db_posicao : out std_logic;
        --interface
        trigger : out std_logic;
        -- depuracoes
        db_estado_interface : out std_logic_vector(3 downto 0);
        db_estado_receptor : out std_logic_vector(3 downto 0)
    );
end entity mouse_hunt_fd;

architecture rtl of mouse_hunt_fd is

    component controle_servo is
        port (
            clock : in std_logic;
            reset : in std_logic;
            posicao : in std_logic;
            pwm : out std_logic;
            db_pwm : out std_logic;
            db_posicao : out std_logic
        );
    end component;

    component interface_hcsr04 is
        port (
            clock : in std_logic;
            reset : in std_logic;
            medir : in std_logic;
            echo : in std_logic;
            trigger : out std_logic;
            medida : out std_logic_vector(11 downto 0);
            pronto : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component interface_hcsr04;

    component rx_serial_7E2 is
        port (
            clock : in std_logic;
            reset : in std_logic;
            dado_serial : in std_logic;
            dado_recebido : out std_logic_vector(6 downto 0);
            paridade_recebida : out std_logic;
            tem_dado : out std_logic;
            paridade_ok : out std_logic;
            pronto_rx : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    component comparador_85 is
        port (
            i_A3 : in std_logic;
            i_B3 : in std_logic;
            i_A2 : in std_logic;
            i_B2 : in std_logic;
            i_A1 : in std_logic;
            i_B1 : in std_logic;
            i_A0 : in std_logic;
            i_B0 : in std_logic;
            i_AGTB : in std_logic;
            i_ALTB : in std_logic;
            i_AEQB : in std_logic;
            o_AGTB : out std_logic;
            o_ALTB : out std_logic;
            o_AEQB : out std_logic
        );
    end component comparador_85;

    component verificador_dado is
        port (
            dado_recebido : in std_logic_vector(6 downto 0);
            tecla_comparada : in std_logic_vector(6 downto 0);
            tecla_recebida : out std_logic
        );
    end component;

    signal s_medida : std_logic_vector(11 downto 0);
    signal rx_reset : std_logic;
    signal s_aeqb_0, s_altb_0, s_agtb_0 : std_logic;
    signal s_aeqb_1, s_altb_1, s_agtb_1 : std_logic;
    signal s_aeqb_2, s_altb_2, s_agtb_2 : std_logic;
    signal s_dado_recebido : std_logic_vector(6 downto 0) := "0000000";

begin

    rx_reset <= reset or limpa;
    -- saidas
    menor <= s_altb_2;

    SERVO_CTRL : controle_servo
    port map(
        clock => clock,
        reset => reset,
        posicao => posicao,
        pwm => pwm,
        db_pwm => db_pwm,
        db_posicao => db_posicao
    );

    SENSOR : interface_hcsr04
    port map(
        clock => clock,
        reset => reset,
        medir => medir,
        echo => echo,
        trigger => trigger,
        medida => s_medida,
        pronto => tem_medida,
        db_estado => db_estado_interface
    );

    -- distancia de 30 cm
    -- 4 bits mais significativos
    COMPARADOR_2 : comparador_85
    port map(
        i_A3 => s_medida(11),
        i_B3 => '0',
        i_A2 => s_medida(10),
        i_B2 => '0',
        i_A1 => s_medida(9),
        i_B1 => '0',
        i_A0 => s_medida(8),
        i_B0 => '0',
        i_AGTB => s_agtb_1,
        i_ALTB => s_altb_1,
        i_AEQB => s_aeqb_1,
        o_AGTB => s_agtb_2,
        o_ALTB => s_altb_2,
        o_AEQB => s_aeqb_2
    );

    COMPARADOR_1 : comparador_85
    port map(
        i_A3 => s_medida(7),
        i_B3 => '0',
        i_A2 => s_medida(6),
        i_B2 => '0',
        i_A1 => s_medida(5),
        i_B1 => '1',
        i_A0 => s_medida(4),
        i_B0 => '1',
        i_AGTB => s_agtb_0,
        i_ALTB => s_altb_0,
        i_AEQB => s_aeqb_0,
        o_AGTB => s_agtb_1,
        o_ALTB => s_altb_1,
        o_AEQB => s_aeqb_1
    );

    COMPARADOR_0 : comparador_85
    port map(
        i_A3 => s_medida(3),
        i_B3 => '0',
        i_A2 => s_medida(2),
        i_B2 => '0',
        i_A1 => s_medida(1),
        i_B1 => '0',
        i_A0 => s_medida(0),
        i_B0 => '0',
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => s_agtb_0,
        o_ALTB => s_altb_0,
        o_AEQB => s_aeqb_0
    );

    RX : rx_serial_7E2
    port map(
        clock => clock,
        reset => rx_reset,
        dado_serial => dado_serial,
        dado_recebido => s_dado_recebido,
        paridade_recebida => open,
        tem_dado => tem_dado,
        paridade_ok => open,
        pronto_rx => open,
        db_estado => db_estado_receptor
    );

    TECLA_S : verificador_dado
    port map(
        dado_recebido => s_dado_recebido,
        tecla_comparada => "1110011",
        tecla_recebida => s_recebido
    );

    TECLA_R : verificador_dado
    port map(
        dado_recebido => s_dado_recebido,
        tecla_comparada => "1110010",
        tecla_recebida => r_recebido
    );
end architecture rtl;