LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY user IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	);
END user;

ARCHITECTURE Behavioral OF user IS
	CONSTANT size  : INTEGER := 8;
	SIGNAL user_on : STD_LOGIC; -- indicates whether user is over current pixel position
	-- current user position - intitialized to center of screen
	SIGNAL user_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL user_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current user motion - initialized to +4 pixels/frame
	SIGNAL user_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
BEGIN
	red <= '1'; -- color setup for red user on white background
	green <= NOT user_on;
	blue  <= NOT user_on;
	-- process to draw user current pixel address is covered by user position
	bdraw : PROCESS (user_x, user_y, pixel_row, pixel_col) IS
	BEGIN
		IF (pixel_col >= user_x - size) AND
		 (pixel_col <= user_x + size) AND
			 (pixel_row >= user_y - size) AND
			 (pixel_row <= user_y + size) THEN
				user_on <= '1';
		ELSE
			user_on <= '0';
		END IF;
		END PROCESS;
		-- process to move user once every frame (i.e. once every vsync pulse)
		muser : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF user_y + size >= 600 THEN
				user_y_motion <= "11111111000"; -- -8 pixels
			ELSIF user_y <= size THEN
				user_y_motion <= "00000000100"; -- +4 pixels
			END IF;
			user_y <= user_y + user_y_motion; -- compute next user position
		END PROCESS;
END Behavioral;
