------------------------------------------------------------------
-- Arquivo   : tx_serial_uc.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : unidade de controle do circuito da experiencia 2 
--             > implementa superamostragem (tick)
--             > 
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7E2_uc is 
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
end entity;

architecture rx_serial_uc_arch of rx_serial_7E2_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, armazenamento, final, dado_presente);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (dado_serial, tick, fim, Eatual) 
  begin

    case Eatual is

      when inicial =>      if dado_serial='1' then Eprox <= inicial;
                           else                Eprox <= preparacao;
                           end if;

      when preparacao =>   Eprox <= espera;

      when espera =>       if tick='1' then   Eprox <= recepcao;
                           elsif fim ='0' and tick='0' then Eprox <= espera;
                           elsif fim ='1' and tick='0' then Eprox <= armazenamento;
                           end if;

      when recepcao =>    Eprox <= espera;

      when armazenamento => Eprox <= final;
	  
      when final =>        Eprox <= dado_presente;

      when dado_presente => if dado_serial='1' then Eprox <= dado_presente;
                            else                Eprox <= preparacao;
                            end if;

      when others =>       Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      carrega <= '1' when preparacao, '0' when others;

  with Eatual select
      zera <= '1' when preparacao, '0' when others;
	  
  with Eatual select
      limpa <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;

  with Eatual select
      registra <= '1' when armazenamento, '0' when others;
	  
  with Eatual select
      pronto <= '1' when final, '0' when others;
	  
  with Eatual select
      tem_dado <= '1' when dado_presente, '0' when others;
		
  -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,       -- 0
                     "0001" when preparacao,    -- 1
                     "0010" when espera,        -- 2
                     "0011" when recepcao,      -- 3
                     "0100" when armazenamento, -- 4
                     "0101" when final,         -- 5
                     "0110" when dado_presente, -- 6
					 "1111" when others;        -- F

end architecture rx_serial_uc_arch;
