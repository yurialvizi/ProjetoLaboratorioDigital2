library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_fd is
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
end entity interface_hcsr04_fd;

architecture arch of interface_hcsr04_fd is

    component gerador_pulso is
        generic (
            largura: integer:= 25
        );
        port(
            clock  : in  std_logic;
            reset  : in  std_logic;
            gera   : in  std_logic;
            para   : in  std_logic;
            pulso  : out std_logic;
            pronto : out std_logic
        );
    end component;

    component contador_cm is
    generic (
        constant R : integer;
        constant N : integer
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        pulso   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim_medida : out std_logic
    );
  end component;

  component registrador_n is
    generic (
       constant N: integer := 8 
    );
    port (
       clock  : in  std_logic;
       clear  : in  std_logic;
       enable : in  std_logic;
       D      : in  std_logic_vector (N-1 downto 0);
       Q      : out std_logic_vector (N-1 downto 0) 
    );
  end component;

  component contador_m is
        generic (
            constant M : integer := 50;
            constant N : integer := 6
        );
        port (
            clock : in std_logic;
            zera : in std_logic;
            conta : in std_logic;
            Q : out std_logic_vector (N - 1 downto 0);
            fim : out std_logic;
            meio : out std_logic
        );
    end component contador_m;

  signal s_distancia : std_logic_vector(11 downto 0);
    
begin

    PULSO : gerador_pulso
        generic map (
            largura => 500
        )
        port map (
            clock => clock,
            reset => zera,
            gera => gera,
            para => '0',
            pulso => trigger,
            pronto => open
        );

    MEDIDOR : contador_cm
        generic map (
            R => 2941,
            N => 12
        )
        port map (
            clock => clock,
            reset => zera,
            pulso => echo,
            digito0 => s_distancia(3 downto 0),
            digito1 => s_distancia(7 downto 4),
            digito2 => s_distancia(11 downto 8),
            fim_medida => fim_medida
        );

    REG : registrador_n
     generic map (
        N => 12
     )
     port map (
        clock => clock,
        clear => zera,
        enable => registra,
        D => s_distancia,
        Q => distancia
     );

    ECHO_PERDIDO : contador_m
    generic map(
        M => 5_000_000, -- 100 milisegundos
        N => 27
    )
    port map(
        clock => clock,
        zera => zera,
        conta => conta,
        Q => open,
        fim => timer,
        meio => open
    );
    
    
end architecture arch;