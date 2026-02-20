library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;

package def_soft_error_detector is

    attribute RLOC_ORIGIN : string;
  --constant origins : array(0 to 1) of string;
  type origins_string is array (1 downto 0) of string(1 to 8);
  constant origins : origins_string := (
      "X056Y100",
      "X058Y100"
  );

    constant k_Y_line_num    : integer:= 25; 

    function GetXYPosition(index_X : integer; index_Y : integer ) return string;
    function reduce_or(vector : STD_LOGIC_VECTOR) return STD_LOGIC;

end package def_soft_error_detector;

package body def_soft_error_detector is

    function GetXYPosition(index_X : integer; index_Y : integer ) return string is
        variable int_str_1   : string(1 to 1);
        variable int_str_2   : string(1 to 2);
        variable int_str_3   : string(1 to 3);
        variable str_origin_X : string(1 to 4);
        variable int_str_Y1   : string(1 to 1);
        variable int_str_Y2   : string(1 to 2);
        variable int_str_Y3   : string(1 to 3);
        variable str_origin_Y : string(1 to 4);        
        variable str_origin : string(1 to 8); 
    begin
    
        if index_X  < 10 then
            int_str_1 := integer'image(index_X);
            str_origin_X := "X00" & int_str_1; 
        elsif index_X  < 100 then
            int_str_2 := integer'image(index_X);
            str_origin_X := "X0" & int_str_2; 
        else 
            int_str_3 := integer'image(index_X);
            str_origin_X := "X" & int_str_3; 
        end if;
        
        if index_Y  < 10 then
            int_str_Y1 := integer'image(index_Y);
            str_origin_Y := "Y00" & int_str_Y1; 
        elsif index_Y  < 100 then
            int_str_Y2 := integer'image(index_Y);
            str_origin_Y := "Y0" & int_str_Y2; 
        else 
            int_str_Y3 := integer'image(index_Y);
            str_origin_Y := "Y" & int_str_Y3; 
        end if;        
        
        str_origin := str_origin_X & str_origin_Y;                           
        return str_origin;
    end function;    


    function reduce_or(vector : STD_LOGIC_VECTOR) return STD_LOGIC is
        variable result : STD_LOGIC := '0';
    begin
        for i in vector'range loop
            result := result or vector(i);
        end loop;
    return result;
    
    end function;


end package body def_soft_error_detector;


