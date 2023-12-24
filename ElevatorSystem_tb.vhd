library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ElevatorSystem_tb IS
END ElevatorSystem_tb;

ARCHITECTURE behavior OF ElevatorSystem_tb IS 

    COMPONENT ElevatorSystem
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable_key : IN  std_logic;
         each_floor_up_request : IN  std_logic_vector(7 downto 0);
         each_floor_down_request : IN  std_logic_vector(7 downto 0);
         open_door_button : IN  std_logic;
         close_door_button : IN  std_logic;
         emergencyStop : IN  std_logic;
         weight_sensor : IN  integer;
         floor_indicator : OUT  std_logic_vector(2 downto 0);
         openingDoor : OUT  std_logic;
         closingDoor : OUT  std_logic;
         movingUp : OUT  std_logic;
         movingDown : OUT  std_logic;
         emergencyLight : OUT  std_logic
        );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable_key : std_logic := '0';
   signal each_floor_up_request : std_logic_vector(7 downto 0) := (others => '0');
   signal each_floor_down_request : std_logic_vector(7 downto 0) := (others => '0');
   signal open_door_button : std_logic := '0';
   signal close_door_button : std_logic := '0';
   signal emergencyStop : std_logic := '0';
   signal weight_sensor : integer := 0;

    --Outputs
   signal floor_indicator : std_logic_vector(2 downto 0);
   signal openingDoor : std_logic;
   signal closingDoor : std_logic;
   signal movingUp : std_logic;
   signal movingDown : std_logic;
   signal emergencyLight : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: ElevatorSystem PORT MAP (
          clk => clk,
          reset => reset,
          enable_key => enable_key,
          each_floor_up_request => each_floor_up_request,
          each_floor_down_request => each_floor_down_request,
          open_door_button => open_door_button,
          close_door_button => close_door_button,
          emergencyStop => emergencyStop,
          weight_sensor => weight_sensor,
          floor_indicator => floor_indicator,
          openingDoor => openingDoor,
          closingDoor => closingDoor,
          movingUp => movingUp,
          movingDown => movingDown,
          emergencyLight => emergencyLight
        );

    -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
        wait for 100 ns;	
      
      -- release reset state
      reset <= '0'; 
      
      -- insert stimulus here 
      
      wait;
   end process;
END;