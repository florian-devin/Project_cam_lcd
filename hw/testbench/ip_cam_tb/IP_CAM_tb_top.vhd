library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cmos_sensor_output_generator_constants.all;

entity ip_cam_tb is end;



architecture bench of ip_cam_tb is

   signal nReset          : std_logic;

   -- Camera interface
   signal Cam_Mclk        : std_logic := '0';
   signal Cam_Pixclk      : std_logic := '0';
   signal Cam_Hsync       : std_logic := '0';
   signal Cam_Vsync       : std_logic := '0';
   signal Cam_data        : std_logic_vector(5 downto 0) := (others => '0');
   signal CamReset_n      : std_logic;

   -- Avalon Slave interface ip
   signal AS_Address      : std_logic_vector(2 downto 0)  := (others => '0');
   signal AS_Cs_n         : std_logic := '1';
   signal AS_Write_n      : std_logic := '1';
   signal AS_Datawr       : std_logic_vector(31 downto 0) := (others => '0');
   signal AS_Read_n       : std_logic := '1';
   signal AS_Datard       : std_logic_vector(31 downto 0);

   -- Avalon Slave interface cmos
   signal CMOS_AS_Address : std_logic_vector(2 downto 0)  := (others => '0');
   signal CMOS_AS_Write   : std_logic := '0';
   signal CMOS_AS_Datawr  : std_logic_vector(31 downto 0) := (others => '0');
   signal CMOS_AS_Read    : std_logic := '0';
   signal CMOS_AS_Datard  : std_logic_vector(31 downto 0);
   signal CamReset        : std_logic;

   -- Avalon Master interface
   signal AM_Address      : std_logic_vector(31 downto 0);
   signal AM_byteEnable_n : std_logic_vector(3  downto 0);
   signal AM_BurstCount   : std_logic_vector(1  downto 0);
   signal AM_Write_n      : std_logic;
   signal AM_Datawr       : std_logic_vector(31 downto 0);
   signal AM_WaitRequest  : std_logic := '0';

   constant CLK_PER : time      := 10 ns;
   constant CLK_EN  : time      := 3 ns;

   signal clk       : std_logic := '0';
   signal clk_1     : std_logic := '0';
   signal en_clk    : std_logic := '0';

   signal finished  : boolean   := FALSE;

   -- Slave registers
   signal CamAddr_exp      : std_logic_vector(31 downto 0) := (others => '0');
   signal CamLength_exp    : std_logic_vector(31 downto 0) := (others => '0');
   signal CamStatus_exp    : std_logic := '0';
   signal CamStart_exp     : std_logic := '0';
   signal CamStop_exp      : std_logic := '0';
   signal CamSnapshot_exp  : std_logic := '0';

   --CMOS reg value
   constant FRAME_WIDTH       : positive := 5;
   constant FRAME_HEIGHT      : positive := 4;
   constant FRAME_FRAME_BLANK : positive := 1;
   constant FRAME_LINE_BLANK  : natural  := 1;
   constant LINE_LINE_BLANK   : positive := 1;
   constant LINE_FRAME_BLANK  : natural  := 1;

   --IP_CAM reg const 
   constant IP_CAM_ADDR_REG      : std_logic_vector(2 downto 0)  := "000"; --RW
   constant IP_CAM_LENGTH_REG    : std_logic_vector(2 downto 0)  := "001"; --RW
   constant IP_CAM_STATUS_REG    : std_logic_vector(2 downto 0)  := "010"; --RO
   constant IP_CAM_START_REG     : std_logic_vector(2 downto 0)  := "011"; --WO
   constant IP_CAM_STOP_REG      : std_logic_vector(2 downto 0)  := "100"; --WO
   constant IP_CAM_SNAPSHOT_REG  : std_logic_vector(2 downto 0)  := "101"; --WO

   constant START_ADDR_REG_VAL   : std_logic_vector(31 downto 0) := x"0000000F";
   constant LENGTH_REG_VAL       : std_logic_vector(31 downto 0) := x"00000FFF";

   -- CHECK_DATA_OUT
   signal addr_exp         : std_logic_vector(31 downto 0) := (others => '0');
   signal data_exp         : std_logic_vector(31 downto 0) := (others => '0');

   signal data1_exp        : std_logic_vector(15 downto 0) := (others => '0');
   signal data_red1_exp    : std_logic_vector(5 downto 0)  := (others => '0');
   signal data_green1a_exp : std_logic_vector(6 downto 0)  := (others => '0');
   signal data_green1b_exp : std_logic_vector(6 downto 0)  := (others => '0');
   signal data_blue1_exp   : std_logic_vector(5 downto 0)  := (others => '0');

   signal data2_exp        : std_logic_vector(15 downto 0) := (others => '0');
   signal data_red2_exp    : std_logic_vector(5 downto 0)  := (others => '0');
   signal data_green2a_exp : std_logic_vector(6 downto 0)  := (others => '0');
   signal data_green2b_exp : std_logic_vector(6 downto 0)  := (others => '0');
   signal data_blue2_exp   : std_logic_vector(5 downto 0)  := (others => '0');

   signal ligne_cnt        : unsigned(9 downto 0) := "0000000001";
   signal old_hsync        : std_logic := '0';
   signal old_vsync        : std_logic := '0';


begin
   CMOS : entity work.cmos_sensor_output_generator
   generic map(
      PIX_DEPTH  => 6,
      MAX_WIDTH  => 1920,
      MAX_HEIGHT => 1080
   )
   port map(
      clk         => Cam_Pixclk,
      reset       => CamReset,

      -- Avalon-MM slave
      addr        => CMOS_AS_Address,
      read        => CMOS_AS_Read,
      write       => CMOS_AS_Write,
      rddata      => CMOS_AS_Datard,
      wrdata      => CMOS_AS_Datawr,

      frame_valid => Cam_Vsync,
      line_valid  => Cam_Hsync,
      data        => Cam_data
   );

   DUT : entity work.IP_CAM_Top
      port map (
        Clk             => clk,
        nReset          => nReset,

        -- Camera interface
        Cam_Mclk        => Cam_Mclk,
        Cam_Pixclk      => Cam_Pixclk,
        Cam_Hsync       => Cam_Hsync,
        Cam_Vsync       => Cam_Vsync,
        Cam_data        => Cam_data,
        CamReset_n      => CamReset_n,

        -- Avalon Slave interface
        AS_Address      => AS_Address,
        AS_Cs_n         => AS_Cs_n,
        AS_Write_n      => AS_Write_n,
        AS_Datawr       => AS_Datawr,
        AS_Read_n       => AS_Read_n,
        AS_Datard       => AS_Datard,

        -- Avalon Master interface
        AM_Address      => AM_Address,
        AM_byteEnable_n => AM_byteEnable_n,
        AM_BurstCount   => AM_BurstCount,
        AM_Write_n      => AM_Write_n,
        AM_Datawr       => AM_Datawr,
        AM_WaitRequest  => AM_WaitRequest
      );


   CamReset <= not(CamReset_n);
   
   

   -- clock generator
   clk <= not clk after CLK_PER/2 when not finished;
   Cam_Pixclk <= not Cam_Pixclk after CLK_PER*2 when not finished;


   CHECK_DATA_OUT : process (AM_Write_n, clk, CamAddr_exp)
      variable data_green1_exp : std_logic_vector(6 downto 0)  := (others => '0');
      variable data_green2_exp : std_logic_vector(6 downto 0)  := (others => '0');
   begin
      if (falling_edge(AM_Write_n)) then
         -- AM_Address check
         assert(AM_Address = addr_exp)
         report "IP_CAM_AM_Address : AM_Address error. Avalon bus value : " & 
           integer'image(to_integer(unsigned(AM_Address))) & " expected value : " & 
           integer'image(to_integer(unsigned(addr_exp))) severity error;

         -- AM_Datawr check
         assert(AM_Datawr = data_exp)
         report "IP_CAM_AM_Datawr : AM_Datawr error. Avalon bus value : " & 
           integer'image(to_integer(unsigned(AM_Datawr))) & " expected value : " & 
           integer'image(to_integer(unsigned(data_exp))) severity error;

      elsif (rising_edge(AM_Write_n)) then
         if (addr_exp = std_logic_vector(unsigned(START_ADDR_REG_VAL) + unsigned(LENGTH_REG_VAL))) then
            addr_exp       <= START_ADDR_REG_VAL;
         else
            addr_exp       <= std_logic_vector(unsigned(addr_exp) + 1);
         end if;

         data_red1_exp     <= std_logic_vector(unsigned(data_red1_exp)    + 4);
         data_green1a_exp  <= "0" & std_logic_vector(resize(unsigned(data_green1a_exp), 6) + 4);
         data_green1b_exp  <= "0" & std_logic_vector(resize(unsigned(data_green1b_exp), 6) + 4);
         data_blue1_exp    <= std_logic_vector(unsigned(data_blue1_exp)   + 4);

         data_red2_exp     <= std_logic_vector(unsigned(data_red2_exp)    + 4);
         data_green2a_exp  <= "0" & std_logic_vector(resize(unsigned(data_green2a_exp), 6) + 4);
         data_green2b_exp  <= "0" & std_logic_vector(resize(unsigned(data_green2b_exp), 6) + 4);
         data_blue2_exp    <= std_logic_vector(unsigned(data_blue2_exp)   + 4);

      end if;

      if (nReset = '0') then
         addr_exp          <= START_ADDR_REG_VAL;
         data_red1_exp     <= "000000" ; -- 0
         data_green1a_exp  <= "0000001"; -- 1
         data_green1b_exp  <= "0110000"; -- 
         data_blue1_exp    <= "110000" ; -- 
         
         data_red2_exp     <= "000010" ; -- 
         data_green2a_exp  <= "0000011"; -- 
         data_green2b_exp  <= "0110010"; -- 
         data_blue2_exp    <= "110010" ; -- 

         data_exp <= data2_exp & data1_exp;

      elsif (rising_edge(clk)) then
         data_green1_exp   :=  std_logic_vector((unsigned(data_green1a_exp) + unsigned(data_green1b_exp)) / 2);
         data_green2_exp   :=  std_logic_vector((unsigned(data_green2a_exp) + unsigned(data_green2b_exp)) / 2);
	      data1_exp         <= data_red1_exp(5 downto 1) & data_green1_exp(5 downto 0) & data_blue1_exp(5 downto 1);
	      data2_exp         <= data_red2_exp(5 downto 1) & data_green2_exp(5 downto 0) & data_blue2_exp(5 downto 1);
         data_exp          <= data2_exp & data1_exp;
         if (Cam_Hsync = '1' and old_hsync = '0') then
            if (ligne_cnt(0) = '0') then
               data_red1_exp     <= std_logic_vector(       resize(ligne_cnt * 240                                           , data_red1_exp'length )  + to_unsigned(0 , data_red1_exp'length    ));
               data_green1a_exp  <= std_logic_vector("0" &  resize(ligne_cnt * 240 + to_unsigned(1 , data_green1a_exp'length), data_red1_exp'length )                                             );
               data_green1b_exp  <= std_logic_vector("0" &  resize(ligne_cnt * 240 + to_unsigned(48, data_green1b_exp'length), data_red1_exp'length )                                             );
               data_blue1_exp    <= std_logic_vector(       resize(ligne_cnt * 240                                           , data_blue1_exp'length)  + to_unsigned(49, data_blue1_exp'length   ));

               data_red2_exp     <= std_logic_vector(       resize(ligne_cnt * 240                                           , data_red2_exp'length )  + to_unsigned(2 , data_red2_exp'length    ));
               data_green2a_exp  <= std_logic_vector("0" &  resize(ligne_cnt * 240 + to_unsigned(3 , data_green2a_exp'length), data_red1_exp'length )                                             );
               data_green2b_exp  <= std_logic_vector("0" &  resize(ligne_cnt * 240 + to_unsigned(50, data_green2b_exp'length), data_red1_exp'length )                                             );
               data_blue2_exp    <= std_logic_vector(       resize(ligne_cnt * 240                                           , data_blue2_exp'length)  + to_unsigned(51, data_blue2_exp'length   ));
            end if;
            ligne_cnt <= ligne_cnt + 1;
         end if;
         if (Cam_Vsync = '1' and old_vsync = '0') then
            ligne_cnt <= "0000000000";
         end if;
         old_hsync <= Cam_Hsync;
         old_vsync <= Cam_Vsync;
      end if;
   end process;

   -- stimulus generator
   process
      constant ALL_ONES  : signed(31 downto 0) := (others => '1');
      constant ALL_ZEROS : signed(31 downto 0) := (others => '0');

      
      -- wait for applying next stimulus
      procedure wait_next_stim is
      begin
         wait until rising_edge(clk);
         wait for CLK_PER/4;
      end procedure wait_next_stim;

      -- initialize the DUT
      procedure init is
      begin
        -- TODO : initialise dut
         nReset <= '0';
         wait for 3 ns;
         nReset <= '1';
         
      end procedure init;


      
      -- finish simulation
      procedure finish is
      begin
         wait until rising_edge(clk);
         wait until rising_edge(clk);
         finished <= TRUE;
         wait;
      end procedure finish;

      procedure AS_WriteReg(addr : std_logic_vector(2 downto 0); data : in std_logic_vector(31 downto 0)) is 
      begin
        wait_next_stim;
        AS_Address           <= addr;
        AS_Datawr            <= data;
        AS_Write_n           <= '0';
        AS_Cs_n              <= '0';
        wait until        rising_edge(clk);
        case addr is
            when "000" => CamAddr_exp       <= data;
            when "001" => CamLength_exp     <= data;
            when "011" => CamStart_exp      <= '1';
            when "100" => CamStart_exp      <= '0'; 
                          CamSnapshot_exp   <= '0';     --CamStop
            when "101" => CamSnapshot_exp   <= '1';
            when others => null;
        end case;
        AS_Write_n           <= '1';
        AS_Cs_n              <= '1';
      end procedure AS_WriteReg;

      procedure AS_ReadReg(addr : std_logic_vector(2 downto 0)) is 
      begin
        wait_next_stim;
        AS_Address           <= addr;
        AS_Read_n            <= '0';
        AS_Cs_n              <= '0';
        wait until        rising_edge(clk);
        wait for          CLK_PER/4;
        case addr is
            when "000" => 
               assert(AS_Datard = CamAddr_exp)
               report "IP_CAM_CamAddr_RD : CamAddr Read error. read value : " & 
                 integer'image(to_integer(unsigned(AS_Datard))) & "expected value : " & 
                 integer'image(to_integer(unsigned(CamAddr_exp))) severity error;
            when "001" => 
               assert(AS_Datard = CamLength_exp)
               report "IP_CAM_CamLength_RD : CamLength Read error. read value : " & 
                  integer'image(to_integer(unsigned(AS_Datard))) & "expected value : " & 
                  integer'image(to_integer(unsigned(CamLength_exp))) severity error;
            when "010" => 
               assert(AS_Datard(0) = CamStatus_exp)
               report "IP_CAM_CamStatus_RD : CamStatus Read error." severity error;
            when others => null;
        end case;
        AS_Read_n            <= '1';
        AS_Cs_n              <= '1';
      end procedure AS_ReadReg;


      procedure CMOS_write_register(constant ofst : in std_logic_vector;
                               constant val  : in natural) is
      begin
      wait until falling_edge(Cam_Pixclk);
      CMOS_AS_Address   <= ofst;
      CMOS_AS_Write  <= '1';
      CMOS_AS_Datawr <= std_logic_vector(to_unsigned(val, CMOS_AS_Datawr'length));
      
      wait until falling_edge(Cam_Pixclk);
      CMOS_AS_Address   <= (others => '0');
      CMOS_AS_Write  <= '0';
      CMOS_AS_Datawr <= (others => '0');
      end procedure CMOS_write_register;



   begin
      init;

      -- configure CMOS
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST, 240);
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST, 320);
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST, FRAME_FRAME_BLANK);
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST, FRAME_LINE_BLANK);
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST, LINE_LINE_BLANK);
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST, LINE_FRAME_BLANK);
      CMOS_write_register(CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST, 1);
      --CMOS_config("000",x"00000140");
      --CMOS_config("001",x"000000F0");
      --CMOS_config("110",x"00000001");

      -- random write/read
      AS_WriteReg(IP_CAM_ADDR_REG, x"FFFFFFFF");
      AS_ReadReg (IP_CAM_ADDR_REG);
      AS_WriteReg(IP_CAM_LENGTH_REG, x"AAAAAAAA");
      AS_ReadReg (IP_CAM_LENGTH_REG);
      AS_ReadReg (IP_CAM_STATUS_REG);

      --start aquisition
      AS_WriteReg(IP_CAM_ADDR_REG, START_ADDR_REG_VAL);
      AS_ReadReg (IP_CAM_ADDR_REG);
      AS_WriteReg(IP_CAM_LENGTH_REG, LENGTH_REG_VAL);
      AS_ReadReg (IP_CAM_LENGTH_REG);
      AS_WriteReg(IP_CAM_START_REG, x"00000001");
      AS_WriteReg(IP_CAM_SNAPSHOT_REG, x"00000001");

      -- start aquisition


      wait for 200 ms;

      finish;
   end process;

end architecture bench;
