library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_7E2 is
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
end entity;

architecture rx_serial_7E2_arch of rx_serial_7E2 is

    component rx_serial_7E2_uc
        port ( 
        clock   : in  std_logic;
        reset   : in  std_logic;
        dado_serial : in  std_logic;
        tick    : in  std_logic;
        fim     : in  std_logic;
        zera    : out std_logic;
        conta   : out std_logic;
        carrega : out std_logic;
        desloca : out std_logic;
        pronto  : out std_logic;
		  tem_dado: out std_logic;
		  limpa   : out std_logic;
		  registra: out std_logic;
		  db_estado : out std_logic_vector(3 downto 0)
    );
    end component;

    component rx_serial_7E2_fd
        port (
            clock : in std_logic;
            -- deslocador
            dado_serial: in std_logic;
            carrega: in std_logic;
            desloca : in std_logic;
			reset: in std_logic;
            -- registrador
            limpa : in std_logic;
            registra : in std_logic;
            -- contador
            zera : in std_logic;
            conta : in std_logic;
            -- saídas
            paridade_ok : out std_logic;
            paridade_recebida : out std_logic;
            dado_recebido : out std_logic_vector (6 downto 0);
            fim : out std_logic
        );
    end component;

    component contador_m
        generic (
            constant M : integer;
            constant N : integer
        );
        port (
            clock : in std_logic;
            zera : in std_logic;
            conta : in std_logic;
            Q : out std_logic_vector (N - 1 downto 0);
            fim : out std_logic;
            meio : out std_logic
        );
    end component;
	 
	 component hex7seg is
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

    signal s_dado_serial, s_carrega, s_desloca, s_registra : std_logic;
    signal s_zera, s_conta, s_fim, s_tick, s_limpa, s_paridade_ok, s_tem_dado : std_logic;
	signal zero : std_logic := '0';

begin
    -- sinais reset e partida ativos em alto
    s_dado_serial <= dado_serial;

    U1_UC : rx_serial_7E2_uc
    port map(
        clock => clock,
        reset => reset,
		dado_serial => s_dado_serial,
        tick => s_tick,
        fim => s_fim,
        zera => s_zera,
        conta => s_conta,
        carrega => s_carrega,
        desloca => s_desloca,
		tem_dado => s_tem_dado,
		limpa  => s_limpa,
		registra => s_registra,
		db_estado => db_estado,
        pronto => pronto_rx
    );

    U2_FD : rx_serial_7E2_fd
    port map(
        clock => clock,
        -- deslocador
        dado_serial => s_dado_serial,
        carrega => s_carrega, 
        desloca => s_desloca,
		reset => reset,
        -- registrador
        limpa => s_limpa,
        registra => s_registra,
        -- contador
        zera => s_zera,
        conta => s_conta,
        -- saídas
        paridade_ok => s_paridade_ok,
        paridade_recebida => paridade_recebida,
        dado_recebido => dado_recebido,
        fim => s_fim
    );

    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    U3_TICK_115200 : contador_m
    generic map(
        M => 434, -- 115200 bauds
        N => 13
    )
    port map(
        clock => clock,
        zera => s_zera,
        conta => '1',
        Q => open,
        fim => open,
        meio => s_tick
    );

    -- saidas
	 	 
    paridade_ok <= '0' when s_tem_dado = '0' else
	                s_paridade_ok when s_tem_dado = '1';
	
    tem_dado <= s_tem_dado;
    

end architecture;