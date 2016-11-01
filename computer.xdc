set_property PACKAGE_PIN AK17           [get_ports CLK_P]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports CLK_P]
set_property ODT RTT_48                 [get_ports CLK_P]
create_clock -period 3.333              [get_ports CLK_P]

set_property PACKAGE_PIN AK16           [get_ports CLK_N]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports CLK_N]
set_property ODT RTT_48                 [get_ports CLK_N]

set_property PACKAGE_PIN G25     [get_ports UART_RX]
set_property IOSTANDARD LVCMOS18 [get_ports UART_RX]
set_property PACKAGE_PIN K26     [get_ports UART_TX]
set_property IOSTANDARD LVCMOS18 [get_ports UART_TX]

set_property PACKAGE_PIN AD10     [get_ports SW10] 
set_property IOSTANDARD  LVCMOS18 [get_ports SW10]

set_property PACKAGE_PIN AE10     [get_ports SW7] 
set_property IOSTANDARD  LVCMOS18 [get_ports SW7] 
# Bank  84 VCCO -          - IO_L15P_T2L_N4_AD11P_64
set_property PACKAGE_PIN AE8      [get_ports SW9] 
set_property IOSTANDARD  LVCMOS18 [get_ports SW9] 
# Bank  84 VCCO -          - IO_L15N_T2L_N5_AD11N_64
set_property PACKAGE_PIN AF8      [get_ports SW8] 
set_property IOSTANDARD  LVCMOS18 [get_ports SW8] 
# Bank  84 VCCO -          - IO_L14P_T2L_N2_GC_64
set_property PACKAGE_PIN AF9      [get_ports SW6] 
set_property IOSTANDARD  LVCMOS18 [get_ports SW6]  

set_property PACKAGE_PIN P20      [get_ports LED2] 
set_property IOSTANDARD  LVCMOS18 [get_ports LED2] 
# Bank  85 VCCO -          - IO_L20N_T3L_N3_AD1N_D09_65
set_property PACKAGE_PIN P21      [get_ports LED3] 
set_property IOSTANDARD  LVCMOS18 [get_ports LED3] 
# Bank  85 VCCO -          - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property PACKAGE_PIN N22      [get_ports LED4] 
set_property IOSTANDARD  LVCMOS18 [get_ports LED4] 
# Bank  85 VCCO -          - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property PACKAGE_PIN M22      [get_ports LED5] 
set_property IOSTANDARD  LVCMOS18 [get_ports LED5] 
# Bank  85 VCCO -          - IO_L18P_T2U_N10_AD2P_D12_65
set_property PACKAGE_PIN R23      [get_ports LED6] 
set_property IOSTANDARD  LVCMOS18 [get_ports LED6] 
# Bank  85 VCCO -          - IO_L18N_T2U_N11_AD2N_D13_65
set_property PACKAGE_PIN P23      [get_ports LED7] 
set_property IOSTANDARD  LVCMOS18 [get_ports LED7] 


