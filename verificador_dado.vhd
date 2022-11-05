library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity verificador_dado is
    port (
        dado_recebido : in std_logic_vector(6 downto 0);
        tecla_comparada : in std_logic_vector(6 downto 0);
        tecla_recebida : out std_logic
    );
end entity verificador_dado;

architecture rtl of verificador_dado is

begin
    
    tecla_recebida <= not((dado_recebido(6) xor tecla_comparada(6)) or
        (dado_recebido(5) xor tecla_comparada(5)) or
        (dado_recebido(4) xor tecla_comparada(4)) or
        (dado_recebido(3) xor tecla_comparada(3)) or
        (dado_recebido(2) xor tecla_comparada(2)) or
        (dado_recebido(1) xor tecla_comparada(1)) or
        (dado_recebido(0) xor tecla_comparada(0)));
    
end architecture rtl;