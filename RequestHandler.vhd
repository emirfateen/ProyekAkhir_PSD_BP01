LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RequestHandler IS
    GENERIC (
        NUM_FLOORS : INTEGER := 8 -- Number of floors in the building
    );
    PORT (
        clk : IN STD_LOGIC; -- Clock signal
        reset : IN STD_LOGIC; -- Reset signal

        elevator_floor_request : IN STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Request signals from elevator
        each_floor_up_request : IN STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Request signals from each floor
        each_floor_down_request : IN STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Request signals from each floor
        elevator_status : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Status signals from elevator

        floor_request : OUT STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0) -- Up request signals from each floor
    );
END ENTITY RequestHandler;

ARCHITECTURE Behavioral OF RequestHandler IS
    -- TYPE floor_request_element IS RECORD
    --     up_request : STD_LOGIC;
    --     down_request : STD_LOGIC;
    -- END RECORD;
    -- type each_floor_req is array (NUM_FLOORS - 1 downto 0) of floor_request_element;
    -- SIGNAL each_floor_request_reg : each_floor_req;
    SIGNAL each_floor_request_reg : STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Register to store each floor requests
    SIGNAL elevator_request_reg : STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Register to store elevator requests
    SIGNAL floor_request_reg : STD_LOGIC_VECTOR(NUM_FLOORS - 1 DOWNTO 0); -- Internal signal for up requests
BEGIN
    PROCESS (clk, reset, elevator_floor_request, each_floor_up_request, each_floor_down_request, elevator_status)
    BEGIN
        elevator_request_reg <= elevator_floor_request;
        IF reset = '1' THEN
            floor_request_reg <= (OTHERS => '0');
            elevator_request_reg <= (OTHERS => '0');
        END IF;
        IF elevator_status = "00" THEN
            IF elevator_request_reg = "00000000" THEN
                floor_request_reg <= (OTHERS => '0');
            ELSE
                floor_request_reg <= elevator_request_reg;
            END IF;
        ELSIF elevator_status = "01" THEN
            each_floor_request_reg <= each_floor_up_request;
            IF elevator_request_reg = "00000000" THEN
                floor_request_reg <= (OTHERS => '0');
            ELSE
                floor_request_reg <= elevator_request_reg OR each_floor_request_reg;
            END IF;
        ELSIF elevator_status = "10" THEN
            each_floor_request_reg <= each_floor_down_request;
            IF elevator_request_reg = "00000000" THEN
                floor_request_reg <= (OTHERS => '0');
            ELSE
                floor_request_reg <= elevator_request_reg OR each_floor_request_reg;
            END IF;
        ELSIF elevator_status = "11" THEN
            floor_request_reg <= (OTHERS => '0');
        END IF;
        floor_request <= floor_request_reg;
        -- Logic to handle requests from each floor and from elevator
        -- 00 means elevator in idle state
        -- 01 means elevator going up
        -- 10 means elevator going down
        -- 11 means elevator emergency stop
    END PROCESS;
END ARCHITECTURE Behavioral;