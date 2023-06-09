-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- **********************************************************************
-- ENTIDAD (entradas/salidas, el fichero de simulaci�n no tiene)
-- **********************************************************************
entity fifo_tb is   
end entity;


-- **********************************************************************
-- ARQUITECTURA (descripci�n de los est�mulos)
-- **********************************************************************
architecture arch_fifo_tb of fifo_tb is

    -- global parameters --
    constant D1        : integer := 6;
    constant WORD_SIZE : integer := (D1 mod 5) + 3;
    constant FIFO_MAX  : integer := D1 + 2;
    constant periodo   : time    := 10 ns;  -- 100Mhz

    -- import component --
    component fifo
        generic (
            WORD_SIZE  : integer := (D1 mod 5) + 3;
            FIFO_MAX   : integer := D1 + 2
        ); 
        port (
            -- ENTRADAS --
            CLK          : in std_logic;
            RESET        : in std_logic;
            WRITE_FIFO   : in std_logic;
            READ_FIFO    : in std_logic;
            FIFO_WORD_WR : in std_logic_vector(WORD_SIZE-1 downto 0);
            -- SALIDAS
            FIFO_WORD_RD : out std_logic_vector(WORD_SIZE-1 downto 0);
            FIFO_EMPTY   : out std_logic;
            FIFO_FULL    : out std_logic
        );
    end component;
    
    -- Entradas --
    signal CLK_test          : std_logic := '1';
    signal RESET_test        : std_logic;
    signal WRITE_FIFO_test   : std_logic;
    signal READ_FIFO_test    : std_logic;
    signal FIFO_WORD_WR_test : std_logic_vector(WORD_SIZE - 1 downto 0);
    
    -- Salidas  --
    signal FIFO_WORD_RD_test : std_logic_vector(WORD_SIZE-1 downto 0);
    signal FIFO_EMPTY_test   : std_logic;
    signal FIFO_FULL_test    : std_logic;

begin

    CLK_test    <= not CLK_test after periodo/2;

    GenReset: PROCESS
    BEGIN
        RESET_test <= '1';     WAIT FOR periodo*3/4;
        RESET_test <= '0';     WAIT FOR 36*periodo;

        RESET_test <= '1';     WAIT FOR periodo;
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;
    
    fifo_inst : fifo
        port map(
            -- ENTRADAS --
            CLK          => CLK_test,
            RESET        => RESET_test,
            WRITE_FIFO   => WRITE_FIFO_test,
            READ_FIFO    => READ_FIFO_test,
            FIFO_WORD_WR => FIFO_WORD_WR_test,
            -- SALIDAS
            FIFO_WORD_RD => FIFO_WORD_RD_test,
            FIFO_EMPTY   => FIFO_EMPTY_test,
            FIFO_FULL    => FIFO_FULL_test
        );

    process
    begin
        -- **********************************************************************
        -- Prueba del escenario del enuciado
        -- **********************************************************************
        WRITE_FIFO_test <= '0';
        READ_FIFO_test  <= '0';
        wait for 3*periodo;
        -- a) initial (empty)
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "0001";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- b) after a write
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "0010";
        wait for periodo;
        FIFO_WORD_WR_test <= "0011";
        wait for periodo;
        FIFO_WORD_WR_test <= "0100";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- c) 3 more writes
        
        READ_FIFO_test <= '1';
        wait for periodo;
        READ_FIFO_test <= '0';
        wait for periodo;
        -- d) after a read
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "0101";
        wait for periodo;
        FIFO_WORD_WR_test <= "0110";
        wait for periodo;
        FIFO_WORD_WR_test <= "0111";
        wait for periodo;
        FIFO_WORD_WR_test <= "1000";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- e) 4 more writes
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "1001";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- f) 1 more write (full)
        
        READ_FIFO_test <= '1';
        wait for 2*periodo;
        READ_FIFO_test <= '0';
        wait for periodo;
        -- d) 2 reads
        
        READ_FIFO_test <= '1';
        wait for 5*periodo;
        READ_FIFO_test <= '0';
        wait for periodo;
        -- d) 5 more reads
        
        READ_FIFO_test <= '1';
        wait for periodo;
        READ_FIFO_test <= '0';
        wait for periodo;
        -- d) 1 more read (empty)

        -- **********************************************************************
        -- Prueba de interrupcion por el RESET
        -- **********************************************************************
        WRITE_FIFO_test <= '0';
        READ_FIFO_test  <= '0';
        wait for 3*periodo;
        -- a) initial (empty)
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "0001";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- b) after a write
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "0010";
        wait for periodo;
        FIFO_WORD_WR_test <= "0011";
        wait for periodo;
        FIFO_WORD_WR_test <= "0100";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- c) 3 more writes
        
        WRITE_FIFO_test   <= '1';
        FIFO_WORD_WR_test <= "0101";
        wait for periodo;
        FIFO_WORD_WR_test <= "0110";
        wait for periodo;
        FIFO_WORD_WR_test <= "0111";
        wait for periodo;
        FIFO_WORD_WR_test <= "1000";
        wait for periodo;
        WRITE_FIFO_test   <= '0';
        wait for periodo;
        -- e) 4 more writes
        wait;

    end process;

end architecture;
    


