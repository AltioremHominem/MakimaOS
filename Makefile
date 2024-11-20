
CC = gcc
NASM = nasm
LD = ld

CFLAGS = -std=gnu2x -m32 -Wall -Wextra -g -ffreestanding -nostdlib  -I./include
NASMFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T linker.ld


KERNEL_DIR =kernel
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

ASM_SOURCES = $(wildcard $(KERNEL_DIR)/**/*.s)
C_SOURCES = $(wildcard $(KERNEL_DIR)/**/*.c)

ASM_OBJECTS = $(patsubst $(KERNEL_DIR)/%.s,$(OBJ_DIR)/%.o,$(ASM_SOURCES))
C_OBJECTS = $(patsubst $(KERNEL_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SOURCES))

KERNEL = $(BIN_DIR)/kernel.bin

all: directories $(KERNEL)

directories:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(BIN_DIR)

$(KERNEL): $(ASM_OBJECTS) $(C_OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.s
	@mkdir -p $(dir $@)
	$(NASM) $(NASMFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

run: $(KERNEL)
	qemu-system-i386 -kernel $(KERNEL)

debug: $(KERNEL)
	qemu-system-i386 -kernel $(KERNEL) -s -S

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all directories clean run debug disk-image

print-%:
	@echo $* = $($*)