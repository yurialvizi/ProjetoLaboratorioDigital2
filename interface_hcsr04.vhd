library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        medir     : in  std_logic;
        echo      : in  std_logic;
        trigger   : out std_logic;
        medida    : out std_logic_vector(11 downto 0);
        pronto    : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity interface_hcsr04;

architecture arch of interface_hcsr04 is
    
    component interface_hcsr04_uc
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            medir      : in  std_logic;
            echo       : in  std_logic;
            fim_medida : in  std_logic;
            timer      : in  std_logic;
            zera       : out std_logic;
            conta      : out std_logic;
            gera       : out std_logic;
            registra   : out std_logic;
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0) 
        );
    end component;

    component interface_hcsr04_fd
        port (
            clock   : in std_logic;
            gera    : in std_logic;
            zera    : in std_logic;
            echo    : in std_logic;
            conta   : in std_logic;
            registra : in std_logic;
            trigger : out std_logic;
            timer : out std_logic;
            fim_medida  : out std_logic;
            distancia   : out std_logic_vector(11 downto 0)
        );
    end component;


    signal s_conta, s_timer, s_fim_medida, s_zera, s_gera, s_registra : std_logic;

begin

    UC : interface_hcsr04_uc
        port map(
            clock      => clock,
            reset      => reset,
            medir      => medir,
            echo       => echo,
            timer      => s_timer,
            fim_medida => s_fim_medida,
            zera       => s_zera,
            conta      => s_conta,
            gera       => s_gera,
            registra   => s_registra,
            pronto     => pronto,
            db_estado  => db_estado
        );
    
    FD : interface_hcsr04_fd
        port map (
            clock => clock,
            gera => s_gera,
            zera => s_zera,
            echo => echo,
            conta => s_conta,
            registra => s_registra,
            trigger => trigger,
            timer => s_timer,
            fim_medida => s_fim_medida,
            distancia => medida
        );
    
    
end architecture arch;