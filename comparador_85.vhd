-------------------------------------------------------------------
-- Arquivo   : comparador_85.vhd
-- Projeto   : Experiencia 02 - Um Fluxo de Dados Simples
-------------------------------------------------------------------
-- Descricao : comparador binario de 4 bits 
--             similar ao CI 7485
--             baseado em descricao criada por Edson Gomi (11/2017)
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     02/01/2021  1.0     Edson Midorikawa  criacao
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity comparador_85 is
  port (
    i_A3   : in  std_logic;
    i_B3   : in  std_logic;
    i_A2   : in  std_logic;
    i_B2   : in  std_logic;
    i_A1   : in  std_logic;
    i_B1   : in  std_logic;
    i_A0   : in  std_logic;
    i_B0   : in  std_logic;
    i_AGTB : in  std_logic;
    i_ALTB : in  std_logic;
    i_AEQB : in  std_logic;
    o_AGTB : out std_logic;
    o_ALTB : out std_logic;
    o_AEQB : out std_logic
  );
end entity comparador_85;

architecture dataflow of comparador_85 is
  signal agtb : std_logic; -- fio igual a 1 quando A > B, sem considerar possível cascateamento
  signal aeqb : std_logic; -- fio igual a 1 qunado A = B, sem considerar possível cascateamento
  signal altb : std_logic; -- fio igual a 1 qunado A < B, sem considerar possível cascateamento
begin
  -- equacoes dos sinais: pagina 462, capitulo 6 do livro-texto
  -- Wakerly, J.F. Digital Design - Principles and Practice, 4th Edition
  -- veja tambem datasheet do CI SN7485 (Function Table) 
  agtb <= (i_A3 and not(i_B3)) or -- começa a testar condições em que A > B, compara primeiro os bits mais significativos
          (not(i_A3 xor i_B3) and i_A2 and not(i_B2)) or -- compara A2 e B2 se A3 e I3 são iguais
          (not(i_A3 xor i_B3) and not(i_A2 xor i_B2) and i_A1 and not(i_B1)) or -- compara A1 e B1, se A2 e B2, e A3 e I3 são iguais
          (not(i_A3 xor i_B3) and not(i_A2 xor i_B2) and not(i_A1 xor i_B1) and i_A0 and not(i_B0)); -- compara A0 e B0 se as últimas deram iguais
  aeqb <= not((i_A3 xor i_B3) or (i_A2 xor i_B2) or (i_A1 xor i_B1) or (i_A0 xor i_B0)); -- fica 1 se as entradas de mesma ordem são iguais
  altb <= not(agtb or aeqb); -- se A não é maior que B, e B não é igual a A, então A é menor que B.
  -- saidas
  o_AGTB <= agtb or (aeqb and (not(i_AEQB) and not(i_ALTB))); -- joga 1 na saída se A > B, considerando o possível cascateamento
  o_ALTB <= altb or (aeqb and (not(i_AEQB) and not(i_AGTB))); -- joga 1 na saída se A < B, considerando o possível cascateamento
  o_AEQB <= aeqb and i_AEQB; -- joga 1 na saída se A = B, considerando o possível cascateamento
  
end architecture dataflow;

    
