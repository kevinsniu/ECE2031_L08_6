LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LEDToggleController IS
	PORT (
		CLK			: IN STD_LOGIC; -- Clock
		CS				: IN STD_LOGIC; -- Chip signal select
		WRITE_EN		: IN STD_LOGIC; -- Write signal from SCOMP: when IO_DATA should be processed
		RESETN		: IN STD_LOGIC; -- Active-low reset.
		IO_DATA		: IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit data bus from SCOMP.
		LEDs			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0) -- 10-bit vector representing the state of 10 LEDS
	);
	END LEDToggleController;
	
ARCHITECTURE Behavior OF LEDToggleController IS
	SIGNAL stored_pattern : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); -- Saved Pattern
	SIGNAL current_state  : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); -- Current LED state
	SIGNAL display_state : STD_LOGIC := '1'; -- '1' = LEDs show current pattern, '0' = LEDs Off
BEGIN
	PROCESS
	(RESETN, CLK) -- Updates on RESET or clock edge
	BEGIN
		IF RESETN = '0' THEN
			stored_pattern <= (OTHERS => '0'); -- Reset stored pattern
			current_state  <= (OTHERS => '0'); -- Turns off current LEDs
			display_state 	<= '1'; -- Current LED visible
		ELSIF RISING_EDGE(CLK) THEN
			IF CS = '1' AND WRITE_EN = '1' THEN -- Writing to 0x20 : NOTE still questioning this and if it is the decoder that handles this
				IF display_state = '1' THEN
					stored_pattern <= current_state; -- Saves current pattern into stored pattern
					current_state <= (OTHERS => '0'); -- Current state LEDs are turned off
					display_state <= '0'; -- LEDs are off
				ELSE 
					-- Restore saved pattern
					current_state <= stored_pattern; -- Loads pattern into current LEDs
					display_state <= '1'; -- Enables visibility
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavior;

-- NOTE: the display_state signal is a control flag used to determine whether the LEDs should
-- 		show the stored pattern or be turned off. Its role is to toggle between the two states
--		1. display_state = '1':
--				Say LEDs display current pattern (1010101010), the pattern is stored into 
--				stored_pattern and display_enable is then set to '0' which will turn off LED
--		2. display_state = '0':
--				LEDs are forced off 
--				When writing to peripheral again, display_state is again set back to '1' and 
--				LEDs  show previously stored pattern.


-- Shouldve asked earlier, but NOTE: should we be able to control LEDs even if there is stored pattern
-- AKA, if there is a stored pattern, and we have a new current pattern (0001010101) and we toggle,
-- do save the current pattern then reload the saved pattern in stored_pattern?

-- Needs a lot of other stuff. 