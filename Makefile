NVCC ?= nvcc

# GPU architecture reference:
# sm_86: RTX A4500
# sm_90, sm_90a: Hopper
# sm_100, sm_100a: B200/GB200
# sm_103, sm_103a: B300/GB300
# sm_121: GB10/DGX Spark
ARCH ?= sm_86

CXXSTD ?= c++17
OPT ?= -O3 # optimization level for CPU code

NVCCFLAGS := $(OPT) --std=$(CXXSTD) -arch=$(ARCH)
WARNFLAGS := -Xcompiler -Wall -Xcompiler -Wextra

BUILD_DIR := build

# Sanity check binary.
SANITY_BIN := $(BUILD_DIR)/00_sanity/check_cuda.out
VECTOR_ADD := $(BUILD_DIR)/01_vector_add/vector_add.out

PROGRAMS := $(SANITY_BIN) $(VECTOR_ADD)

.PHONY: all run gpu sanity vector_add clean help

all: $(PROGRAMS)

run: all
	./$(SANITY_BIN)

gpu:
	nvidia-smi
	nvcc --version
	nvidia-smi topo -m

sanity: $(SANITY_BIN)
	./$(SANITY_BIN)

vector_add: $(VECTOR_ADD)
	./$(VECTOR_ADD)

define CUDA_PROGRAM
$2: $1
	@mkdir -p $$(dir $$@)
	$$(NVCC) $$(NVCCFLAGS) $$(WARNFLAGS) $$< -o $$@
endef

$(eval $(call CUDA_PROGRAM,00_sanity/check_cuda.cu,$(SANITY_BIN)))
$(eval $(call CUDA_PROGRAM,01_vector_add/vector_add.cu,$(VECTOR_ADD)))

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Targets:"
	@echo "  make all"
	@echo "  make run"
	@echo "  make sanity"
	@echo "  make vector_add"
	@echo "  make clean"
