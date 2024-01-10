----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/12/20 18:08:12
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (7 downto 0);         
           swL : in STD_LOGIC;
           swR : in STD_LOGIC;
           r : out STD_LOGIC;
           g : out STD_LOGIC;
           b : out STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC);
end top;

architecture Behavioral of top is
component pp
    Port ( clk   : in STD_LOGIC;
           rst   : in STD_LOGIC;
           swL   : in STD_LOGIC;
           swR   : in STD_LOGIC;
           led   : out STD_LOGIC_VECTOR (7 downto 0)
           );
end component; 
signal LED_t : STD_LOGIC_VECTOR (7 downto 0);

component vgatest
  port(clock: in std_logic;
       rst  :in std_logic;
       x : in integer range 0 to 639;
       y : in integer range 0 to 479;
       R, G, B, H, V : out std_logic
       );
end component; 
signal x_t : integer range 0 to 639;
signal y_t : integer range 0 to 479;

begin

pp1 : pp
port map (
    clk => clk,
    rst => rst, 
    swL => swL, 
    swR => swR, 
    led => led_t
);

vga1: vgatest
port map (
  clock => clk, rst => rst,
  x => x_t, y => y_t,
  R=>r, G=>g, B=>b, 
  H=>hsync, V=>vsync
);

led_vga:process(led_t, clk, rst)
begin
 if rst='1' then
          x_t <= 40;
          y_t <= 200;
    elsif clk'event and clk = '1' then
  case led_t is
      when "1000"&"0000" => 
          x_t <= 40;
          y_t <= 200;
      when "0100"&"0000" => 
          x_t <= 120;
          y_t <= 200;
      when "0010"&"0000" => 
          x_t <= 200;
          y_t <= 200;
      when "0001"&"0000" => 
          x_t <= 280;
          y_t <= 200;
      when "0000"&"1000" => 
          x_t <= 360;
          y_t <= 200;
      when "0000"&"0100" => 
          x_t <= 440;
          y_t <= 200;  
      when "0000"&"0010" => 
          x_t <= 520;
          y_t <= 200;
      when "0000"&"0001" => 
          x_t <= 600;
          y_t <= 200; 
      when "1111"&"0000" => 
          x_t <= 40;
          y_t <= 100; 
      when "0000"&"1111" => 
          x_t <= 600;
          y_t <= 100; 
      when others => 
          null;
  end case;
  end if;
end process;
    led <= led_t;
end Behavioral;
