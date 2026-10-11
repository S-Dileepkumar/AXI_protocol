
# ============================================================
# AXI VIP - Verilator Simulation Makefile
# Outputs: AXI_VIP/sim/results/
# ============================================================

VERILATOR ?= verilator
TOP       ?= top

SIM_DIR   := .
RESULTS   := results
LOGS      := $(RESULTS)/logs
WAVES     := $(RESULTS)/waves
REPORTS   := $(RESULTS)/reports
OBJ_DIR   := build/obj_dir
UVM_HOME ?= ../../third_party/uvm
UVM_SRC  := $(UVM_HOME)/src

UVM_PKG  := $(UVM_SRC)/uvm_pkg.sv


# Source directories relative to AXI_VIP/sim
IF_DIR      := ../AXI_IF
MASTER_DIR  := ../AXI_MASTER
SLAVE_DIR   := ../AXI_SLAVE
TB_DIR      := ../AXI_TB
TOP_DIR     := ../AXI_TOP
TEST_DIR    := ../trans_test

# Collect source files.
# Adjust source order if packages depend on other packages.
IF_SRCS     := $(sort $(wildcard $(IF_DIR)/*.sv $(IF_DIR)/*.v))
MASTER_SRCS := $(sort $(wildcard $(MASTER_DIR)/*.sv $(MASTER_DIR)/*.v))
SLAVE_SRCS  := $(sort $(wildcard $(SLAVE_DIR)/*.sv $(SLAVE_DIR)/*.v))
TEST_SRCS   := $(sort $(wildcard $(TEST_DIR)/*.sv $(TEST_DIR)/*.v))
PKG_SRCS    := $(wildcard $(TB_DIR)/axi_package.sv)
TOP_SRCS    := $(wildcard $(TOP_DIR)/*.sv $(TOP_DIR)/*.v)

SRCS := $(IF_SRCS) $(MASTER_SRCS) $(SLAVE_SRCS) \
        $(PKG_SRCS) $(TEST_SRCS) $(TOP_SRCS)

# Verilator options
VFLAGS := --binary --timing --trace \
          --top-module $(TOP) \
          --Mdir $(OBJ_DIR) \
          -Wno-fatal \
          -I$(TB_DIR) \
          -I$(MASTER_DIR) \
          -I$(SLAVE_DIR)
VFLAGS += +incdir+$(UVM_SRC)
VFLAGS += +incdir+$(TB_DIR)
VFLAGS += +incdir+$(MASTER_DIR)
VFLAGS += +incdir+$(SLAVE_DIR)

SIM_EXE := $(OBJ_DIR)/V$(TOP)

.PHONY: all help check lint build run regress clean results

all: run

help:
	@echo "AXI VIP Verilator Targets"
	@echo "  make check    - Check required tools and sources"
	@echo "  make lint     - Run Verilator lint"
	@echo "  make build    - Compile the testbench"
	@echo "  make run      - Build and run one simulation"
	@echo "  make regress  - Run the configured simulation"
	@echo "  make results  - Create result directories"
	@echo "  make clean    - Remove generated results and build files"

results:
	mkdir -p $(LOGS) $(WAVES) $(REPORTS)

check: results
	@command -v $(VERILATOR) >/dev/null || \
	  { echo "ERROR: Verilator not found"; exit 1; }
	@$(VERILATOR) --version
	@test -n "$(SRCS)" || \
	  { echo "ERROR: No SystemVerilog/Verilog sources found"; exit 1; }
	@echo "Sources discovered: $(words $(SRCS))"

lint: check
	$(VERILATOR) --lint-only --timing \
	  --top-module $(TOP) $(VFLAGS_LINT) $(SRCS) \
	  > $(LOGS)/lint.log 2>&1 || \
	  { cat $(LOGS)/lint.log; exit 1; }
	@cat $(LOGS)/lint.log
	@echo "Lint completed. See $(LOGS)/lint.log"

build: check
	@echo "Building AXI VIP..."
	@set -o pipefail; \
	  $(VERILATOR) $(VFLAGS) $(SRCS) \
	  2>&1 | tee $(LOGS)/build.log

run: build
	@echo "Running AXI VIP simulation..."
	@set -o pipefail; \
	  $(SIM_EXE) +trace_file=$(WAVES)/axi_wave.vcd \
	  2>&1 | tee $(LOGS)/simulation.log
	@echo "Simulation completed."

regress: run
	@echo "Regression completed."

clean:
	rm -rf build $(RESULTS)
