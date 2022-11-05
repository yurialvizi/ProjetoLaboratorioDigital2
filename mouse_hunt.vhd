library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mouse_hunt is
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
end entity mouse_hunt;

architecture rtl of mouse_hunt is

    component mouse_hunt_fd is
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
    end component;

    component mouse_hunt_uc is
        port (
            clock : in std_logic;
            reset : in std_logic;
            ligar : in std_logic;
            menor : in std_logic;
            s_recebido : in std_logic;
            r_recebido : in std_logic;
            tem_medida : in std_logic;
            tem_dado : in std_logic;
            limpa : out std_logic;
            medir : out std_logic;
            tem_presa : out std_logic;
            posicao : out std_logic;
            rato_solto : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    signal s_tem_dado, s_tem_medida, s_menor, s_s_recebido, s_r_recebido, s_limpa, s_medir, s_posicao : std_logic;

begin

    UC : mouse_hunt_uc
    port map(
        clock => clock,
        reset => reset,
        ligar => ligar,
        menor => s_menor,
        s_recebido => s_s_recebido,
        r_recebido => s_r_recebido,
        tem_medida => s_tem_medida,
        tem_dado  => s_tem_dado,
        limpa => s_limpa,
        medir => s_medir,
        tem_presa => tem_presa,
        posicao => s_posicao,
        rato_solto => rato_solto,
        db_estado => db_estado
    );

    FD : mouse_hunt_fd
    port map(
        clock => clock,
        reset => reset,
        dado_serial => dado_serial,
        echo => echo,
        limpa => s_limpa,
        medir => s_medir,
        posicao => s_posicao,
        menor => s_menor,
        s_recebido => s_s_recebido,
        r_recebido => s_r_recebido,
        tem_medida => s_tem_medida,
        tem_dado  => s_tem_dado,
        pwm => pwm,
        trigger => trigger,
        db_pwm => db_pwm,
        db_posicao => db_posicao,
        db_estado_interface => db_estado_interface,
        db_estado_receptor => db_estado_receptor
    );

end architecture rtl;