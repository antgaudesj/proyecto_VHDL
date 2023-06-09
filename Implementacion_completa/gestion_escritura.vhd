library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gestor_escritura is
    generic (
        WORD_SIZE    : integer := 5;   -- mod(7,5)+ 3 = 5
        WORD_FIFO    : integer := 9    -- D7 +5 EN BINARIO
    );
    port (
        -- ENTRADAS --
        CLK          : in std_logic;
        RESET        : in std_logic;
        BUTTON_1     : in std_logic;
        BUTTON_2     : in std_logic;
        FIFO_FULL    : in std_logic;
        -- SALIDAS --
        WRITE_FIFO   : out std_logic;
        WORD_FIFO_WR : out std_logic_vector(WORD_SIZE-1 downto 0); 
        LED          : out std_logic
    );
end entity;

architecture arch_gestor_escritura of gestor_escritura is

    -- CODIGO DEL ALUMNO --
    type ESTADOS is (reposo, escritura1, escritura2);
    signal actual, futuro : ESTADOS := reposo;

    constant WORD_FIFO_BIN : std_logic_vector(WORD_SIZE-2 downto 0) := std_logic_vector(to_unsigned(WORD_FIFO, WORD_SIZE-1));

begin

    -- PROCESO DE SINCRONIZACION
    process (CLK, RESET)
    begin
        -- RESET ASINCRONO A NIVEL ALTO
        if (RESET='1') then
            actual  <= reposo;
        elsif (rising_edge(CLK)) then
            actual  <= futuro;
        end if;
    end process;
    
    -- PROCESO COMBINACIONAL
    process (actual, BUTTON_1, BUTTON_2, FIFO_FULL)
    begin
        LED <= FIFO_FULL;

        case actual is
            when reposo =>
                WRITE_FIFO <= '0';
                if (FIFO_FULL = '0') then
                    if (BUTTON_1 = '1') then
                        futuro <= escritura1;
                    elsif (BUTTON_2 = '1') then
                        futuro <= escritura2;
                    else
                        futuro <= reposo;
                    end if;
                else
                    futuro <= reposo;
                end if;
            
            when escritura1 =>
                WRITE_FIFO <= '1';
                WORD_FIFO_WR <= '0' & WORD_FIFO_BIN;
                futuro <= reposo;
            
            when escritura2 =>
                WRITE_FIFO <= '1';
                WORD_FIFO_WR <= '1' & WORD_FIFO_BIN;
                futuro <= reposo;
            
            when others =>
                WRITE_FIFO <= '0';
                WORD_FIFO_WR <= (others => '0');
                futuro <= reposo;
            
        end case;
    end process;

end architecture;
