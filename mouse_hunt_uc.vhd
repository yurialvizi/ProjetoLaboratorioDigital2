library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mouse_hunt_uc is
    port (
        clock : in std_logic;
        reset : in std_logic;
        menor : in std_logic;
        s_recebido : in std_logic;
        r_recebido : in std_logic;
        zera       : out std_logic;
        medir      : out std_logic;
        tem_presa  : out std_logic;
        posicao    : out std_logic;
        rato_solto : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0)
    );
end entity mouse_hunt_uc;

architecture rtl of mouse_hunt_uc is
    
    type tipo_estado is (inicial, hunt, prende, harbeas_corpus);
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
  process (Eatual, menor, s_recebido, r_recebido) 
  begin

    case Eatual is
      when inicial =>      Eprox <= hunt;

      when hunt =>      if menor='0' then Eprox <= hunt;
                        elsif menor='1' then Eprox <= prende;
                        end if;

      when prende =>    if s_recebido='0' then   Eprox <= prende;
                        elsif s_recebido ='1' then Eprox <= harbeas_corpus;
                        end if;

      when harbeas_corpus =>    if r_recebido='0' then Eprox <= harbeas_corpus;
                                elsif r_recebido='1' then Eprox <= inicial;
                                end if;
    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
       zera <= '1' when inicial, '0' when others;

  with Eatual select
      medir <= '1' when hunt, '0' when others;
	  
  with Eatual select
      tem_presa <= '1' when prende, '0' when others;

  with Eatual select
      posicao <= '1' when prende, '0' when others;

  with Eatual select
      rato_solto <= '1' when harbeas_corpus, '0' when others;
		
  -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,         -- 0
                     "0001" when hunt,            -- 1
                     "0010" when prende,          -- 2
                     "0011" when harbeas_corpus,  -- 3
					 "1111" when others;          -- F
    
end architecture rtl;