# 4-Bit Array Multiplier: RTL to GDSII

## Team Members
* **Yogesh Krishna** — `2024102035`
* **Gaurav Reddy Yerreddi** — `2024112006`

---

## Repository Structure

```text
<team-repository>/
|-- README.md
|-- rtl/
|   |-- full_adder.v
|   `-- mult_array.v
|-- tb/
|   `-- tb_mult.v
|-- synth/
|   |-- synth.tcl
|   |-- mult_array_netlist.v
|   `-- mult_array_stat.rpt
|-- sta/
|   |-- sta.tcl
|   `-- mult_array_timing.rpt
|-- pnr/
|   |-- config.json
|   |-- metrics.json
|   `-- mult_array.gds
`-- report/
    `-- report.pdf
```

---

## Execution Commands (in Order)

### Part A: RTL Design and Verification
```bash
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
gtkwave mult.vcd
```

### Part B: Logic Synthesis with Yosys
```bash
yosys -c synth/synth.tcl
```

```bash
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls
```

### Part C: Static Timing Analysis with OpenSTA
```bash
sta sta/sta.tcl
```

### Part D: Physical Design (RTL to GDSII)
```bash
cd pnr
librelane config.json
klayout mult_array.gds
```

#### Part D Clock Period Attempts
| Run # | Target Clock Period | Worst Setup Slack | Setup Violations | Outcome |
| :---: | :---: | :---: | :---: | :--- |
| 1 | 4.0 ns | -1.688 ns | 15 | Failed: Timing violation in slow corners  |
| 2 | 4.5 ns | -1.188 ns | 12 | Failed: Slack improved by +0.50 ns |
| 3 | 5.0 ns | -0.688 ns | 9 | Failed: Slack improved by +0.50 ns |
| 4 | 5.5 ns | -0.188 ns | 6 | Failed: Slack improved by +0.50 ns |
| 5 | 6.0 ns | +0.046 ns | 0 | **PASSED**: Met timing across all PVT corners |