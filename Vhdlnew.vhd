library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vhdlnew is
    Port (
        clk       : in  STD_LOGIC;
        cs        : in  STD_LOGIC;
        ResetN    : in  STD_LOGIC;
        write_en  : in  STD_LOGIC;
        IO_DATA   : in  STD_LOGIC_VECTOR(15 downto 0);
        pwm_out   : out STD_LOGIC  
    );
end vhdlnew;

architecture Behavioral of vhdlnew is
    signal duty_cycle : UNSIGNED(7 downto 0) := (others => '0');
    signal counter    : UNSIGNED(7 downto 0) := (others => '0');
    signal pwm_reg    : STD_LOGIC := '0';
begin
    -- Assign internal PWM signal to output
    pwm_out <= pwm_reg;

    -- Duty Cycle Update Process
    process(clk, ResetN)
    begin
        if ResetN = '0' then
            duty_cycle <= (others => '0');
        elsif rising_edge(clk) then
            if cs = '1' and write_en = '1' then
                duty_cycle <= UNSIGNED(IO_DATA(7 downto 0));  -- Take lower 8 bits
            end if;
        end if;
    end process;

    -- PWM Generation Process
    process(clk, ResetN)
    begin
        if ResetN = '0' then
            counter  <= (others => '0');
            pwm_reg <= '0';
        elsif rising_edge(clk) then
            counter <= counter + 1;

            if counter = duty_cycle then
                pwm_reg <= '0';  -- Turn off when duty reached
            elsif counter = "11111111" then  -- 255
                pwm_reg <= '1';  -- Turn on again at overflow
            end if;
        end if;
    end process;

end Behavioral;
