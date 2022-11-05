library ieee;
use ieee.std_logic_1164.all;

entity contador_cm is
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
        fim_medida  : out std_logic
    );
end entity contador_cm;

architecture arch of contador_cm is

    component contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
    end component;

    component contador_bcd_3digitos is 
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
    end component;

    component edge_detector is
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
    end component;

    signal s_tick, not_pulso : std_logic;
    
begin
    not_pulso <= not pulso;

    GERA_TICK : contador_m
        generic map (
           M => R,
           N => N
        )
        port map (
            clock => clock,
            zera  => reset,
            conta => pulso,
            Q     => open,
            fim   => open,
            meio  => s_tick
        );

    CONTA_CM : contador_bcd_3digitos
        port map (
            clock   => clock,
            zera    => reset,
            conta   => s_tick,
            digito0 => digito0,
            digito1 => digito1,
            digito2 => digito2,
            fim     => open
        );

    FIM_MED: edge_detector
    port map(  
        clock     => clock,
        signal_in => not_pulso,
        output    => fim_medida
    );
    
    
end architecture arch;