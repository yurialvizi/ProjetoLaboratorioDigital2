library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
    port (
        clock : in std_logic;
        reset : in std_logic;
        posicao : in std_logic_vector(2 downto 0);
        pwm : out std_logic;
        db_reset : out std_logic;
        db_pwm : out std_logic;
        db_posicao : out std_logic_vector(2 downto 0)
    );
end controle_servo;

architecture rtl of controle_servo is

    constant CONTAGEM_MAXIMA : integer := 1_000_000; -- valor para frequencia da saida de 50Hz 
    -- ou periodo de 20ms
    signal contagem : integer range 0 to CONTAGEM_MAXIMA - 1;
    signal posicao_pwm : integer range 0 to CONTAGEM_MAXIMA - 1;
    signal s_posicao : integer range 0 to CONTAGEM_MAXIMA - 1;
    signal s_pwm : std_logic;

begin

    process (clock, reset, s_posicao)
    begin
        -- inicia contagem e posicao
        if (reset = '1') then
            contagem <= 0;
            s_pwm <= '0';
            posicao_pwm <= s_posicao;
        elsif (rising_edge(clock)) then
            -- saida
            if (contagem < posicao_pwm) then
                s_pwm <= '1';
            else
                s_pwm <= '0';
            end if;
            -- atualiza contagem e posicao
            if (contagem = CONTAGEM_MAXIMA - 1) then
                contagem <= 0;
                posicao_pwm <= s_posicao;
            else
                contagem <= contagem + 1;
            end if;
        end if;
    end process;

    process (posicao)
    begin
        case posicao is
            when "000" => s_posicao <= 35_000; --  pulso de 0,70 ms
            when "001" => s_posicao <= 45_700; --  pulso de 0,914 ms
            when "010" => s_posicao <= 56_450; --  pulso de 1,129 ms
            when "011" => s_posicao <= 67_150; --  pulso de 1,343 ms
            when "100" => s_posicao <= 77_850; --  pulso de 1,557 ms
            when "101" => s_posicao <= 88_550; --  pulso de 1,771 ms
            when "110" => s_posicao <= 99_300; --  pulso de 1,986 ms
            when "111" => s_posicao <= 110_000; -- pulso de 2,1 ms
            when others => s_posicao <= 35_000;
        end case;
    end process;
    
    -- saidas
    pwm <= s_pwm;
    
    -- depuracoes
    db_posicao <= posicao;
    db_reset <= reset;
    db_pwm <= s_pwm;

end rtl;