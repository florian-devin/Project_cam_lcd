library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ip_cam_tb is end;

architecture bench of ip_cam_tb is

   signal nReset          : std_logic;

   -- Camera interface
   signal Cam_Mclk        : std_logic := '0';
   signal Cam_Pixclk      : std_logic;
   signal Cam_Hsync       : std_logic := '0';
   signal Cam_Vsync       : std_logic := '0';
   signal Cam_data        : std_logic_vector(5 downto 0) := (others => '0');
   signal CamReset_n      : std_logic;

   -- Avalon Slave interface
   signal AS_Address      : std_logic_vector(2 downto 0)  := (others => '0');
   signal AS_Cs_n         : std_logic := '1';
   signal AS_Write_n      : std_logic := '1';
   signal AS_Datawr       : std_logic_vector(31 downto 0) := (others => '0');
   signal AS_Read_n       : std_logic := '1';
   signal AS_Datard       : std_logic_vector(31 downto 0);

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

begin

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

   -- clock generator
   clk <= not clk after CLK_PER/2 when not finished;


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



   begin
      init;
      AS_WriteReg("000", x"FFFFFFFF");
      AS_ReadReg ("000");
      AS_WriteReg("001", x"AAAAAAAA");
      AS_ReadReg ("001");
      AS_WriteReg("010", x"55555555");
      AS_ReadReg ("010");

      AS_WriteReg("000", x"44A54573");
      AS_ReadReg ("000");
      AS_WriteReg("001", x"96EA4684");
      AS_ReadReg ("001");
      AS_WriteReg("010", x"1268AB53");
      AS_ReadReg ("010");

      

      finish;
   end process;

end architecture bench;
