library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
    port (
        clock : in std_logic;
        reset : in std_logic;
        posicao : in std_logic;
        pwm : out std_logic;
        db_pwm : out std_logic;
        db_posicao : out std_logic
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
            when '0' => s_posicao <= 75_000;  --  pulso de 1,5 ms
            when '1' => s_posicao <= 100_000; --  pulso de 2 ms
            when others => s_posicao <= 75_000;
        end case;
    end process;
    
    -- saidas
    pwm <= s_pwm;
    
    -- depuracoes
    db_posicao <= posicao;
    db_pwm <= s_pwm;

end rtl;