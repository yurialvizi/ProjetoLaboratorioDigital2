------------------------------------------------------------------
-- Arquivo   : deslocador_n.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : deslocador  
--             > parametro N: numero de bits
--
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity deslocador_n is
    generic (
        constant N : integer := 4
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector (N-1 downto 0);
        saida          : out std_logic_vector (N-1 downto 0)
    );
end entity deslocador_n;

architecture deslocador_n_arch of deslocador_n is

    signal IQ: std_logic_vector (N-1 downto 0);

begin

    process (clock, reset, IQ)
    begin
        if reset='1' then IQ <= (others=>'1');
        elsif (clock'event and clock='1') then
            if carrega='1' then IQ <= dados;
            elsif desloca='1' then IQ <= entrada_serial & IQ(N-1 downto 1);
            else IQ <= IQ;
            end if;
        end if;
        saida <= IQ; 
    end process;
  
end architecture deslocador_n_arch;

