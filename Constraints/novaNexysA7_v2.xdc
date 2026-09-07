## NOVA CPU constraints for the Digilent Nexys A7-100T
## Top-level module: novaNexysA7

## Artix-7 configuration bank settings for the Nexys A7 3.3 V interface.
## These remove the CFGBVS-1 DRC warning before bitstream generation.
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## 100 MHz oscillator
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {CLK100MHZ}]
create_clock -add -name board_clock -period 10.000 -waveform {0.000 5.000} [get_ports {CLK100MHZ}]

## Controls
## SW[0]   : 0 = manual single-step, 1 = automatic slow run
## SW[2:1] : LED display selection
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {SW[0]}]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {SW[1]}]
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports {SW[2]}]

## Center pushbutton: one CPU cycle per debounced press in manual mode
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {BTNC}]

## Dedicated active-low CPU reset pushbutton
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports {CPU_RESETN}]

## Sixteen individual LEDs
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports {LED[0]}]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports {LED[1]}]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports {LED[2]}]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports {LED[3]}]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {LED[4]}]
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {LED[5]}]
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports {LED[6]}]
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {LED[7]}]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {LED[8]}]
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports {LED[9]}]
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {LED[10]}]
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports {LED[11]}]
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {LED[12]}]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {LED[13]}]
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports {LED[14]}]
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports {LED[15]}]

## Buttons and switches are asynchronous to the board oscillator. The RTL uses
## synchronizers and a debouncer, so these external paths are intentionally not
## analyzed as synchronous input paths. LEDs have no external timing requirement.
set_false_path -from [get_ports {CPU_RESETN BTNC SW[0] SW[1] SW[2]}]
set_false_path -to [get_ports {LED[0] LED[1] LED[2] LED[3] LED[4] LED[5] LED[6] LED[7] LED[8] LED[9] LED[10] LED[11] LED[12] LED[13] LED[14] LED[15]}]
