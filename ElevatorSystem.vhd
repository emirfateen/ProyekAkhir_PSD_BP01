LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ElevatorSystem IS
    GENERIC (
        NUM_FLOORS : INTEGER := 8 -- Number of floors in the building
    );
    PORT (
        clk : IN STD_LOGIC; -- Clock signal
        reset : IN STD_LOGIC; -- Reset signal
        enable_key : IN STD_LOGIC; -- Enable key for the maintainer
        each_floor_up_request : IN STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Request signals from each floor
        each_floor_down_request : IN STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Request signals from each floor
        open_door_button : IN STD_LOGIC; -- Open door button
        close_door_button : IN STD_LOGIC; -- Close door button
        emergencyStop : IN STD_LOGIC; -- Emergency stop button
        weight_sensor : IN INTEGER; -- weight_sensor warning signal
        floor_indicator : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- 8 floors  
        openingDoor : OUT STD_LOGIC;
        closingDoor : OUT STD_LOGIC;
        movingUp : OUT STD_LOGIC;
        movingDown : OUT STD_LOGIC;
        emergencyLight : OUT STD_LOGIC
    );
END ENTITY ElevatorSystem;

ARCHITECTURE Behavioral OF ElevatorSystem IS
    SIGNAL elevator_floor_request : STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0);
    SIGNAL elevator_status : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL floor_request : STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0);
BEGIN
    -- Instantiate the RequestHandler
    requestHandler : ENTITY work.RequestHandler
    PORT MAP (
        clk => clk,
        reset => reset,
        elevator_floor_request => elevator_floor_request,
        each_floor_up_request => each_floor_up_request,
        each_floor_down_request => each_floor_down_request,
        elevator_status => elevator_status,
        floor_request => floor_request
    );

    -- Instantiate the ElevatorController
    elevatorController : ENTITY work.ElevatorController
    PORT MAP (
        clk => clk,
        reset => reset,
        enable_key => enable_key,
        floor_request => floor_request,
        open_door_button => open_door_button,
        close_door_button => close_door_button,
        emergencyStop => emergencyStop,
        weight_sensor => weight_sensor,
        elevator_floor_request => elevator_floor_request,
        elevator_status => elevator_status,
        floor_indicator => floor_indicator,
        openingDoor => openingDoor,
        closingDoor => closingDoor,
        movingUp => movingUp,
        movingDown => movingDown,
        emergencyLight => emergencyLight
    );
END Behavioral;