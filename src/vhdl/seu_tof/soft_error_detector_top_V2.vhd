library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library mylib;
use mylib.def_soft_error_detector.all;
use ieee.numeric_std.all;

entity soft_error_detector_top_V2 is
    generic (
        ARRAY_SIZE : integer := 40;  -- Size of the array
        ORIGIN_POSITION_X :  integer := 0;
        FIRST_Y_ORIGIN :  integer := 0
    );
    port (
        i_clk     : in  STD_LOGIC;
        i_rst     : in  STD_LOGIC;
        -- o_flk    : out STD_LOGIC_VECTOR(ARRAY_SIZE-1 downto 0);
        o_err_A : out STD_LOGIC;
        o_err_B : out STD_LOGIC
    );
end soft_error_detector_top_V2;


architecture Behavioral of soft_error_detector_top_V2 is

    component soft_error_detector_wrapper
        generic (
            origin : string
        );
        port (
            i_clk   : in  STD_LOGIC;
            i_rst   : in  STD_LOGIC;
            error_A : out STD_LOGIC;
            error_B : out STD_LOGIC
        );
    end component;

    signal error_A : STD_LOGIC_VECTOR(ARRAY_SIZE-1 downto 0);
    signal error_B : STD_LOGIC_VECTOR(ARRAY_SIZE-1 downto 0);

    signal error_A_SECOND : STD_LOGIC_VECTOR((ARRAY_SIZE/2)-1 downto 0);
    signal error_B_SECOND : STD_LOGIC_VECTOR((ARRAY_SIZE/2)-1 downto 0);

    signal error_A_or : STD_LOGIC;
    signal error_B_or : STD_LOGIC;

    constant SECOND_Xadr : integer := 2; 
begin

    gen_soft_error_detector : for i in 0 to ARRAY_SIZE-1 generate
    --gen_soft_error_detector : for i in 0 to ARRAY_SIZE-2 generate
        constant calculated_value : integer := i + FIRST_Y_ORIGIN ;
        begin
        
        u_soft_error_detector_wrapper : soft_error_detector_wrapper
            generic map (
                origin => GetXYPosition(ORIGIN_POSITION_X, calculated_value)
            )
            port map (
                i_clk  => i_clk,
                i_rst  => i_rst,
                error_A => error_A(i),
                error_B => error_B(i)
            );

        end ;
    end generate;

    --error_A(ARRAY_SIZE-1) <= '1';
    --error_B(ARRAY_SIZE-1) <= '0';



    gen_soft_error_detector_second : for i in 0 to (ARRAY_SIZE/2)-1 generate
        constant idx              : integer := 2*i;
        constant calculated_value : integer := idx + FIRST_Y_ORIGIN;
    begin

        u_soft_error_detector_wrapper : soft_error_detector_wrapper
            generic map (
                origin => GetXYPosition(ORIGIN_POSITION_X + SECOND_Xadr, calculated_value)
            )
            port map (
                i_clk  => i_clk,
                i_rst  => i_rst,
                error_A => error_A_SECOND(i),
                error_B => error_B_SECOND(i)
            );

    end generate;



    o_err_A <= reduce_or(error_A) or reduce_or(error_A_SECOND);
    o_err_B <= reduce_or(error_B) or reduce_or(error_B_SECOND);

    

end Behavioral;
