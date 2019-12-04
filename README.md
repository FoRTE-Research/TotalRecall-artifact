# TotalRecall ASPLOS 2020 Artifact Evaluation
TotalRecall is a library-level one-time checkpointing system to enable intermittent computation
on Flash-based microcontrollers by exploiting SRAM time-dependent volatility.

This repository contains artifacts to enable reviewers to reproduce the experiments/results described
in "Forget Failure: Exploiting SRAM Data Remanence for Low-overhead Intermittent Computation".

## Software pre-requisites
- git client
- make
- msp430-gcc version >= 8.3.0 (if you intend to build the binaries yourself)
- mspdebug version >= 0.25 (if you intend to flash the binaries to hardware)

Mspdebug has the following dependencies:
- libusb-dev
- libreadline-dev
- gcc
- make
- libmsp430.so

All of which except libmsp430.so can be installed on Ubuntu systems using `sudo apt install gcc make libusb-dev libreadline-dev`.
libmsp430.so is the driver library mspdebug requires to interface with MSP430 devices - it is available as part of msp430-gcc, but needs to be made available to mspdebug using the following commands.
```
sudo cp ~/ti/msp430-gcc/bin/libmsp430.so /usr/local/lib/
echo "export LD_PRELOAD=/usr/local/lib/libmsp430.so" >> ~/.bashrc
source ~/.bashrc
```
mspdebug should _not_ be installed from apt as the version there is outdated; use `git clone https://github.com/dlbeer/mspdebug` to get the most recent version and follow the instructions in the README therein to install.
Install msp430-gcc from http://www.ti.com/tool/MSP430-GCC-OPENSOURCE.

## Hardware pre-requisites
If you want to test on hardware, you need one of the MSP-EXP430G2ET or MSP-EXP430FR6989 Launchpads
from Texas Instruments.

## Benchmark binaries

### Pre-built binaries
We provide pre-generated binaries to make reproducing results possible without needing to set up the toolchain;
these binaries are in the prebuilt\_bin subdirectory of each devices directory.

### Building binaries
Run either "make DEVICE=msp430g2553" or "make DEVICE=msp430fr6989" inside the msp430 directory
depending on which platform you want to build for. The binaries are generated in the
{msp430g2553, msp430fr6989}/bin directories.

### Flashing binaries
Connect to the launchpad via `mspdebug tilib` and flash the program using `prog` in the mspdebug console
(e.g., `prog msp430g2553/bin/quicksort.out`). Use `run` to run the program; alternatively, close mspdebug using
CTRL+d and the MCU will begin execution.

### Platform notes
Because of differences in the Launchpads surrounding the MSP430G2553 and MSP430FR6989, the benchmarks will behave slightly differently depending on the MCU.

##### LED States
- On the MSP-EXP430G2ET, the green LED (P1.0) is illuminated during the checkpoint procedure. The RGB LED indicates benchmark status:
  - Blue: The benchmark is running.
  - Green: The benchmark completed with correct output.
  - Red: The benchmark completed with incorrect output.
- On the MSP-EXP430FR6989, there is no LED to indicate the checkpoint routine is executing. The red (P1.0) and green (P9.7) LEDs indicate benchmark status:
  - Both illuminated: The benchmark is running.
  - Green illuminated: The benchmark completed with correct output.
  - Red illuminated: The benchmark completed with incorrect output.

##### Power-off behavior
On the MSP-EXP430G2ET, the combination of the low-power device and onboard capacitance means that SRAM will retain its state for several minutes at room temperature if the device is unplugged.
This means you can unplug the device and easily observe state recovery from the SRAM in the case of a true power failure.
This is difficult on the more feature-rich MSP-EXP430FR6989 with its more power-intensive MCU - the onboard capacitance will not support SRAM retention for the time it takes a user to unplug the device and plug it back in.

## Experiment workflow

### Verifying functionality
Because creating a realistic energy harvesting environment is difficult without purpose-built hardware, the provided artifacts are designed primarily to allow users to verify functionality without adding energy harvesting hardware or creating an energy harvesting environment.
The TotalRecall checkpointing function is written as an ISR; in a real energy harvesting environment, it is triggered
by a "brownout detected" interrupt from a supply voltage supervisor. In these artifacts, it is triggered by a GPIO
interrupt that is connected to button S1 on the Launchpads (P1.3 on the MSP-EXP430G2ET and P1.1 on the MSP-EXP430FR6989).
To verify system functionality, we recommend following this example workflow:
1. Clone this repository using `git clone https://github.com/FoRTE-Research/TotalRecall-artifact`.
2. Install software dependencies using the instructions above.
3. Run `make DEVICE=msp430g2553` in the msp430 directory.
4. Flash the quicksort (msp430/msp430g2553/bin/quicksort.out) benchmark to the MSP430G2553.
5. Close mspdebug to allow the MCU to execute freely.
6. Press button S1 to take a checkpoint and halt execution. The LED connected to port P1.0 should flash green.
7. Reset the device either by pressing the reset button or unplugging the Launchpad. Execution will continue from where it left off when power is restored - if the benchmark was complete when the checkpoint occurred, the RGB LED will immediately turn green. Otherwise, the device will finish the benchmark starting from the point when the checkpoint was taken (e.g., if the checkpoint is taken 7 seconds into the quicksort benchmark it should reach completion in 3 seconds following a reset).
8. Verify that TotalRecall detects when SRAM state is lost by taking a checkpoint, unplugging the Launchpad, and then either waiting an extended time period (>= 5 minutes) or holding down the reset button, both of which drain the processor supply voltage. Restoring power to the device will start the benchmark execution from the beginning.
