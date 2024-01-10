----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/11/08 17:04:43
-- Design Name: 
-- Module Name: pp - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pp_inout is
    Port ( clk   : in STD_LOGIC;
           rst   : in STD_LOGIC;
           swR   : in STD_LOGIC;
           txrx  : inout std_logic;
           LED   : out STD_LOGIC_VECTOR (7 downto 0);
           L7seg : out STD_LOGIC_VECTOR (6 downto 0)
           );
end pp_inout;

architecture Behavioral of pp_inout is
type STATE_T is (movingR, movingL, R_Loss, Idle, waitBack); --四種狀態 右移中 左移中 右輸 初始狀態 等球回來
signal state, prevState: STATE_T;
signal LEDreg: std_logic_vector(7 downto 0);
signal Lscore: std_logic_vector(3 downto 0);
signal divcnt: std_logic_vector(23 downto 0);
signal divclk: std_logic; --, divclk_old: std_logic;
signal rnd   : std_logic_vector(4 downto 0);
begin

LED <= LEDreg;

FSM: process(clk, rst, LEDreg)
begin
    if rst='0' then
        state <= Idle;
    elsif clk'event and clk = '1' then
        prevState <= state;
        case state is
            when Idle => --初始狀態 自己或對手發球
                if swR = '1'  and LEDreg = "0000"&"0001" then --把球打出 自己發球
                    state <= movingL;   --右邊發球所以球往左跑            
                elsif LEDreg = "1000"&"0000" then -- 球在門口並且正在進來 對手發球
                    state <= movingR; --左邊發球所以球往右跑
                end if;
            when movingR => --moving in
                if  LEDreg = "0000"&"0001" and swR='1' then -- right_hit then
                    state <= movingL; --moving out
                elsif (LEDreg > "0000"&"0001" and swR='1') or LEDreg = "0000"&"0000" then ---right_lost then
                    state <= R_Loss; --Lwin;
                end if;
            when movingL =>
                if LEDreg = "00000000" then
                    state <= waitBack;
                end if;
            when waitBack =>
                if  LEDreg = "1000"&"0000" then --左邊對手把球打回來 球要往右跑
                    state <= movingR;
                end if;                                   
            when R_Loss => --Lwin =>
                if swR= '1' and LEDreg = "0000"&"0001" then
                    state <= movingL;
                end if;
            when others =>
                state <= movingR;
        end case;
    end if;
end process;

txrx_p: process(state, LEDreg(7))
begin
    if state = movingL then
        txrx <= not LEDreg(7);
    else
        txrx <= 'Z';
    end if;
end process;

shift_reg_p: process(divclk, rst, state, swR) --swL
begin
    if rst='0' then
        LEDreg <= "0000"&"0000";
    elsif divclk'event and divclk = '1' then
        case state is
            when idle =>
                if swR = '1' then
                    LEDreg <= "0000"&"0001"; --"1000"&"0000";
                elsif txrx = '0' then -- ball is at the door and coming in
                    LEDreg(7) <= not txrx; --"1000"&"0000";                 
                end if;
            when movingR => --moving in
                LEDreg(7         ) <= not txrx; --'0';
                LEDreg(6 downto 0) <= LEDreg(7 downto 1);
            when movingL =>
                LEDreg(7 downto 1) <= LEDreg(6 downto 0);
                LEDreg(         0) <= '0';   
            when waitBack => 
                LEDreg(7         ) <= not txrx;         
            when R_loss => --Lwin =>
                if swR = '1' then
                    LEDreg <= "0000"&"0001"; --"1000"&"0000";
                else
                    LEDreg <= "1111"&"0000";
                end if;   
            when others =>
                LEDreg <= "1111"&"1111";                    
        end case;
    end if;
end process;

Lscore_p: process(clk, rst, prevState, state)
begin
    if rst='0' then
        Lscore <= "0000";
        --Rscore <= "0000";
    elsif clk'event and clk = '1' then
        case state is
            when movingR => null;
            when movingL => null;
            when R_loss => --Lwin =>
                if prevState = movingR then 
                    Lscore <= Lscore+'1';
                else
                    null;
                end if;           
            when others =>
                null;
        end case;
    end if;
end process;

divclk_p:process(clk, rst, rnd)
begin
    if rst = '0' then
        divclk <= '0';
        --divclk_old <= '0';
        divcnt <= "00000000"&"00000000"&"000"&"00000";--&"00001"
    elsif clk'event and clk='1' then
        if divcnt < "11111111"&"11111111"&"111"&"11111" then --&rnd then --rnd&"1111"&"11111111"&"11111111" then
            divcnt <= divcnt + '1';
            --divclk_old <= divclk;
        else
            divclk <= not divclk;
            --divclk_old <= divclk;
            divcnt <= (others=>'0');
        end if;
    
    end if;
end process;

    with Lscore SELect
   L7seg<= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0
				
				
end Behavioral;
