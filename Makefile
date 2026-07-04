NVCC ?= nvcc

# GPU architecture reference:
# sm_86: RTX A4500
# sm_90, sm_90a: Hopper
# sm_100, sm_100a: B200/GB200
# sm_103, sm_103a: B300/GB300
# sm_121: GB10/DGX Spark
ARCH ?= sm_121

CXXSTD ?= c++17
OPT ?= -O3 # optimization level for CPU code

NVCCFLAGS := $(OPT) --std=$(CXXSTD) -arch=$(ARCH)
WARNFLAGS := -Xcompiler -Wall -Xcompiler -Wextra

BUILD_DIR := build

# Sanity check binary.
SANITY_BIN := $(BUILD_DIR)/00_sanity/check_cuda.out

PROGRAMS := $(SANITY_BIN)

.PHONY: all run gpu sanity clean help

all: $(PROGRAMS)

run: all
	./$(SANITY_BIN)

gpu:
	nvidia-smi
	nvcc --version
	nvidia-smi topo -m

sanity: $(SANITY_BIN)
	./$(SANITY_BIN)

define CUDA_PROGRAM
$2: $1
	@mkdir -p $$(dir $$@)
	$$(NVCC) $$(NVCCFLAGS) $$(WARNFLAGS) $$< -o $$@
endef

$(eval $(call CUDA_PROGRAM,00_sanity/check_cuda.cu,$(SANITY_BIN)))

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Targets:"
	@echo "  make all"
	@echo "  make run"
	@echo "  make sanity"
	@echo "  make clean"
