# ============================================================
# AXI VIP - Verilator Makefile
# Results: AXI_VIP/sim/results/
# ============================================================

SHELL := /bin/bash

VERILATOR ?= verilator
TOP       ?= top

# UVM path can be overridden by GitHub Actions.
UVM_HOME ?= $(abspath ../../third_party/uvm)
UVM_SRC  := $(UVM_HOME)/src
UVM_PKG  := $(UVM_SRC)/uvm_pkg.sv

RESULTS := results
LOGS    := $(RESULTS)/logs
WAVES   := $(RESULTS)/waves
REPORTS := $(RESULTS)/reports

OBJ_DIR := build/obj_dir
SIM_EXE := $(OBJ_DIR)/V$(TOP)

# Source directories relative to AXI_VIP/sim.
IF_DIR     := ../AXI_IF
MASTER_DIR := ../AXI_MASTER
SLAVE_DIR  := ../AXI_SLAVE
TB_DIR     := ../AXI_TB
TOP_DIR    := ../AXI_TOP
TEST_DIR   := ../trans_test

# Only compile files that are NOT already `include`d by axi_package.sv.
# Master/Slave agent files, drivers, monitors, sequences, configs, etc.
# are pulled in via `include` inside the package (which has import uvm_pkg::*;).
IF_SRCS   := $(sort $(wildcard $(IF_DIR)/*.sv $(IF_DIR)/*.v))
PKG_SRCS  := $(wildcard $(TB_DIR)/axi_package.sv)
TEST_SRCS := $(sort $(wildcard $(TEST_DIR)/*.sv $(TEST_DIR)/*.v))
TOP_SRCS  := $(sort $(wildcard $(TOP_DIR)/*.sv $(TOP_DIR)/*.v))

SRCS := $(IF_SRCS) \
	$(PKG_SRCS) \
	$(TEST_SRCS) \
	$(TOP_SRCS)

# Include directories (required so `include "foo.sv"` inside the package works).
INCLUDES := -I$(UVM_SRC) \
	-I$(TB_DIR) \
	-I$(MASTER_DIR) \
	-I$(SLAVE_DIR) \
	-I$(IF_DIR)

# Common Verilator options.
# +define+UVM_NO_DPI is commonly needed for Accellera/chipsalliance UVM with Verilator.
COMMON_FLAGS := --timing -Wno-fatal \
	-Wno-MISINDENT \
	-Wno-WIDTHTRUNC \
	-Wno-WIDTHEXPAND \
	+define+UVM_NO_DPI \
	$(INCLUDES)

BUILD_FLAGS := --binary --trace \
	--top-module $(TOP) \
	--Mdir $(OBJ_DIR)

.PHONY: all help results check lint build run regress clean

all: run

help:
	@echo "AXI VIP Verilator Targets"
	@echo "  make check   - Check tools, UVM and source files"
	@echo "  make lint    - Run Verilator lint"
	@echo "  make build   - Compile the simulation"
	@echo "  make run     - Build and run the simulation"
	@echo "  make regress - Run the configured regression"
	@echo "  make results - Create output directories"
	@echo "  make clean   - Remove build files and results"

results:
	mkdir -p $(LOGS) $(WAVES) $(REPORTS)

check: results
	@command -v $(VERILATOR) >/dev/null || \
	  { echo "ERROR: Verilator not found"; exit 1; }
	@test -f "$(UVM_PKG)" || \
	  { echo "ERROR: UVM package not found: $(UVM_PKG)"; exit 1; }
	@test -n "$(SRCS)" || \
	  { echo "ERROR: No HDL source files found"; exit 1; }
	@$(VERILATOR) --version
	@echo "UVM source: $(UVM_SRC)"
	@echo "Sources discovered: $(words $(SRCS))"

lint: check
	@set -o pipefail; \
	  $(VERILATOR) --lint-only $(COMMON_FLAGS) \
	  --top-module $(TOP) \
	  $(UVM_PKG) $(SRCS) \
	  2>&1 | tee $(LOGS)/lint.log

build: check
	@set -o pipefail; \
	  $(VERILATOR) $(COMMON_FLAGS) $(BUILD_FLAGS) \
	  $(UVM_PKG) $(SRCS) \
	  2>&1 | tee $(LOGS)/build.log

run: build
	@echo "Running AXI VIP simulation..."
	@set -o pipefail; \
	  $(SIM_EXE) \
	  +trace_file=$(abspath $(WAVES)/axi_wave.vcd) \
	  2>&1 | tee $(LOGS)/simulation.log
	@echo "Simulation completed."

regress: run
	@echo "Regression completed."

clean:
	rm -rf build $(RESULTS)
