################################################################################
# NOVA CPU core-only synthesis constraint
#
# This constraint defines the intended 100 MHz clock for timing analysis while
# cpuCore is selected as the synthesis top. It intentionally contains no FPGA
# package-pin assignments; those belong in the later Nexys A7 top-level XDC.
################################################################################

create_clock -add -name cpu_core_clock -period 10.000 -waveform {0.000 5.000} [get_ports {clk}]
