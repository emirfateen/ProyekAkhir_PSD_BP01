LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ElevatorController IS
    GENERIC (
        NUM_FLOORS : INTEGER := 8 -- Number of floors in the building
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable_key : IN STD_LOGIC; -- Enable key for the maintainer

        floor_request : IN STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- 8 floors
        open_door_button : IN STD_LOGIC; -- Open door button
        close_door_button : IN STD_LOGIC; -- Close door button
        emergencyStop : IN STD_LOGIC; -- Emergency stop button

        weight_sensor : IN INTEGER; -- weight_sensor warning signal

        elevator_floor_request : OUT STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- 8 floors
        elevator_status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- IDLE, MOVE_UP, MOVE_DOWN, EMERGENCY_STOP
        floor_indicator : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- 8 floors  

        openingDoor : OUT STD_LOGIC;
        closingDoor : OUT STD_LOGIC;
        movingUp : OUT STD_LOGIC;
        movingDown : OUT STD_LOGIC;
        emergencyLight : OUT STD_LOGIC
    );
END ElevatorController;

ARCHITECTURE Behavioral OF ElevatorController IS
    TYPE state_type IS (IDLE, MOVE_UP, MOVE_DOWN, OPEN_DOOR, CLOSE_DOOR, EMERGENCY_STOP);
    SIGNAL current_state, next_state : state_type;

    CONSTANT DOOR_DELAY : INTEGER := 5; -- Door open/close delay (adjust as needed)
    CONSTANT EMERGENCY_LIGHT_DELAY : INTEGER := 10; -- Emergency light duration (adjust as needed)
    CONSTANT WEIGHT_SENSOR_THRESHOLD : INTEGER := 100; -- Maximum allowable load (adjust as needed)

    SIGNAL door_timer : INTEGER := 0; -- Timer for door open/close duration
    SIGNAL emergency_light_state : STD_LOGIC := '0'; -- state type of emergency light
    SIGNAL elevator_position : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); -- 8 floors

    SIGNAL elevator_enabled : BOOLEAN := FALSE; -- Indicates whether the elevator is enabled
    SIGNAL floor_request_internal : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL encoder_input_temp : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL encoder_input : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL encoded_floor_request : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

    COMPONENT Encoder8x3
        PORT (
            input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    -- Instantiate the Encoder8x3 component
    encoder : Encoder8x3 PORT MAP(
        input => encoder_input,
        output => encoded_floor_request
    );
    PROCESS (enable_key, current_state, encoded_floor_request, elevator_position, emergencyStop, weight_sensor, clk, reset)
    BEGIN
        -- Default outputs
        movingUp <= '0';
        movingDown <= '0';
        openingDoor <= '0';
        closingDoor <= '0';
        emergencyLight <= '0';

        -- Default next state
        next_state <= current_state;

        IF reset = '1' THEN
            current_state <= IDLE;
            door_timer <= 0;
            emergency_light_state <= '0';

        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
            IF enable_key = '1' THEN
                elevator_enabled <= NOT elevator_enabled; -- Toggle enable/disable state
            END IF;
        END IF;

        -- state type machine logic
        CASE current_state IS
            WHEN IDLE =>
                floor_request_internal <= floor_request;
                FOR i IN 0 TO NUM_FLOORS-1 LOOP
                    IF floor_request_internal(i) = '1' THEN
                        -- Set encoder_input_temp based on the bit position
                        CASE i IS
                            WHEN 7 =>
                                encoder_input_temp <= "00000001";
                            WHEN 6 =>
                                encoder_input_temp <= "00000010";
                            WHEN 5 =>
                                encoder_input_temp <= "00000100";
                            WHEN 4 =>
                                encoder_input_temp <= "00001000";
                            WHEN 3 =>
                                encoder_input_temp <= "00010000";
                            WHEN 2 =>
                                encoder_input_temp <= "00100000";
                            WHEN 1 =>
                                encoder_input_temp <= "01000000";
                            WHEN OTHERS =>
                                encoder_input_temp <= "00000000";
                        END CASE;
                        encoder_input <= encoder_input_temp;
                        EXIT;
                    END IF;
                END LOOP;
                IF encoded_floor_request /= elevator_position THEN
                    IF encoded_floor_request > elevator_position THEN
                        next_state <= MOVE_UP;
                    ELSE
                        next_state <= MOVE_DOWN;
                    END IF;
                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN MOVE_UP =>
                movingUp <= '1';
                IF encoded_floor_request = elevator_position THEN
                    next_state <= OPEN_DOOR;
                ELSE
                    IF elevator_position = "1111" THEN
                        next_state <= IDLE;
                    END IF;
                    IF rising_edge(clk) THEN
                        elevator_position <= STD_LOGIC_VECTOR(unsigned(elevator_position) + 1);
                        next_state <= MOVE_UP;
                    END IF;
                    IF close_door_button = '1' THEN
                        next_state <= CLOSE_DOOR; -- Stay in the close door state
                    ELSIF open_door_button = '1' THEN
                        next_state <= OPEN_DOOR; -- Stay in the open door state
                    END IF;
                END IF;

            WHEN MOVE_DOWN =>
                movingDown <= '1';
                IF encoded_floor_request = elevator_position THEN
                    next_state <= OPEN_DOOR;
                ELSE
                    IF elevator_position = "0000" THEN
                        next_state <= IDLE;
                    END IF;
                    IF rising_edge(clk) THEN
                        elevator_position <= STD_LOGIC_VECTOR(unsigned(elevator_position) - 1);
                        next_state <= MOVE_DOWN;
                    END IF;
                    IF close_door_button = '1' THEN
                        next_state <= CLOSE_DOOR; -- Stay in the close door state
                    ELSIF open_door_button = '1' THEN
                        next_state <= OPEN_DOOR; -- Stay in the open door state
                    END IF;
                END IF;

            WHEN OPEN_DOOR =>
                openingDoor <= '1';
                door_timer <= door_timer + 1;
                IF door_timer >= DOOR_DELAY THEN
                    next_state <= CLOSE_DOOR;
                    door_timer <= 0;
                END IF;

            WHEN CLOSE_DOOR =>
                closingDoor <= '1';
                door_timer <= door_timer + 1;
                IF door_timer >= DOOR_DELAY THEN
                    next_state <= IDLE;
                    door_timer <= 0;
                END IF;

            WHEN EMERGENCY_STOP =>
                emergencyLight <= emergency_light_state;
                IF emergencyStop = '0' THEN
                    next_state <= IDLE;
                    emergency_light_state <= '0';
                END IF;
        END CASE;

        -- Emergency stop condition
        IF emergencyStop = '1' THEN
            next_state <= EMERGENCY_STOP;
            emergency_light_state <= '1';
        END IF;

        -- weight_sensor condition
        IF weight_sensor > WEIGHT_SENSOR_THRESHOLD THEN
            next_state <= EMERGENCY_STOP;
            emergency_light_state <= '1';
        END IF;
    END PROCESS;
END Behavioral;