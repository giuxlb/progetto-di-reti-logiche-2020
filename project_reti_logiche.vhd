----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.02.2020 17:54:33
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
  port (
     i_clk          : in  std_logic;
     i_start       : in  std_logic;
     i_rst          : in  std_logic;
     i_data         : in  std_logic_vector(7 downto 0);
     o_address      : out std_logic_vector(15 downto 0);
     o_done         : out std_logic;
     o_en           : out std_logic;
     o_we           : out std_logic;
     o_data         : out std_logic_vector (7 downto 0)
       );
end project_reti_logiche;
        
 
architecture Behavioral of project_reti_logiche is
type tipi_stato is (attendo_start,salvo_address_req,salvo_address,
                    check_counter,salvo_wz_req,salvo_wz,
                    esec,rst_off_wz,incr_counter,incr_offset,
                    trovato,non_trovato,attesa_abbasso_start,done);
signal stato : tipi_stato;
signal stato_next : tipi_stato;
signal address_to_process : std_logic_vector(7 downto 0);
signal wz_0 : std_logic_vector(7 downto 0);
signal counter : integer range 0 to 8;
signal temp_counter : integer range 0 to 8;
signal offset_counter : integer range 0 to 4;
signal temp_offset_counter : integer range 0 to 4;
signal onehot : std_logic_vector(3 downto 0);

begin

    process(i_clk)
    begin
        if i_clk'event and i_clk='1' then
            if i_rst='1' then
                stato<=attendo_start;
            else
                stato<=stato_next;
            end if;
            
            case stato is
                    
                when attendo_start =>
                    counter<=0;
                    o_done<='0';
                    if i_start='1' then
                        stato_next<=salvo_address_req;
                    else
                        stato_next<=attendo_start;
                    end if;
                
                when salvo_address_req =>
                    o_en<='1';
                    o_we<='0';
                    o_address<=std_logic_vector(to_unsigned(8,16));
                    stato_next<=salvo_address;
                    
                when salvo_address =>
                    address_to_process<=i_data;
                    stato_next<=check_counter;
                
                when check_counter =>
                    if counter>7 then
                        stato_next<=non_trovato;
                    else
                        stato_next<=salvo_wz_req;
                    end if;
                
                when salvo_wz_req =>
                    o_en<='1';
                    o_we<='0';
                    o_address<=std_logic_vector(to_unsigned(counter,16));
                    stato_next<=salvo_wz;
                    
                when salvo_wz=>
                    wz_0<=i_data;
                    offset_counter<=0;
                    stato_next<=esec;
                    
                when esec=>
                    if to_integer(unsigned(wz_0))+0=to_integer(unsigned(address_to_process)) then
                        onehot<="0001";
                        stato_next<=trovato;
                    elsif to_integer(unsigned(wz_0))+1=to_integer(unsigned(address_to_process)) then
                        onehot<="0010";
                        stato_next<=trovato;
                    elsif to_integer(unsigned(wz_0))+2=to_integer(unsigned(address_to_process)) then
                        onehot<="0100";                       
                        stato_next<=trovato;
                    elsif to_integer(unsigned(wz_0))+3=to_integer(unsigned(address_to_process)) then
                        onehot<="1000";                           
                        stato_next<=trovato;
                    else
                        stato_next<=rst_off_wz;
                    end if;
                    
                when incr_offset =>
                    offset_counter<=temp_offset_counter;
                    stato_next<=esec;
                
                when rst_off_wz =>

                            temp_counter<=counter+1;
                            stato_next<=incr_counter;
                
                when incr_counter =>
                    counter<=temp_counter;
                    stato_next<=check_counter;
                                                      
                when trovato =>
                    o_data(7)<='1';
                    case counter is
                        when 0 =>
                            o_data(6 downto 4)<="000";
                        when 1 =>
                            o_data(6 downto 4)<="001";
                        when 2 =>
                            o_data(6 downto 4)<="010";
                        when 3 =>
                            o_data(6 downto 4)<="011";
                        when 4 =>
                            o_data(6 downto 4)<="100";
                        when 5 =>
                            o_data(6 downto 4)<="101";
                        when 6 =>
                            o_data(6 downto 4)<="110";
                        when 7 =>
                            o_data(6 downto 4)<="111";
                        when 8 =>
                       
                        end case;
                    o_data(3 downto 0)<=onehot(3 downto 0);
                    o_address<=std_logic_vector(to_unsigned(9,16));
                    o_we<='1';
                    o_en<='1';
                    stato<=done;
                    
                
                when non_trovato =>
                    o_address<=std_logic_vector(to_unsigned(9,16));
                    o_we<='1';
                    o_en<='1';
                    o_data<=address_to_process;
                    stato<=done;
                    
                
                when done =>
                    o_done<='1';
                    stato_next<=attesa_abbasso_start;
                                
                when attesa_abbasso_start =>
                    if i_start='0' then
                        stato<=attendo_start;
                    else
                        stato<=attesa_abbasso_start;  
                    end if;
            end case;
        end if;   
    end process;
end Behavioral;
