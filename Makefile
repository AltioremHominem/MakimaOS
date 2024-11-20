
CC = gcc
NASM = nasm
LD = ld

CFLAGS = -std=gnu23 -m32 -Wall -Wextra -g -ffreestanding -fno-stack-protector -nostdlib -nostdinc -I./src/include
NASMFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T linker.ld


KERNEL_DIR =kernel
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

ASM_SOURCES = $(wildcard $(KERNEL_DIR)/**/*.asm)
C_SOURCES = $(wildcard $(KERNEL_DIR)/**/*.c)

ASM_OBJECTS = $(patsubst $(KERNEL_DIR)/%.asm,$(OBJ_DIR)/%.o,$(ASM_SOURCES))
C_OBJECTS = $(patsubst $(KERNEL_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SOURCES))

KERNEL = $(BIN_DIR)/kernel.bin

all: directories $(KERNEL)

directories:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(BIN_DIR)

$(KERNEL): $(ASM_OBJECTS) $(C_OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.asm
	@mkdir -p $(dir $@)
	$(NASM) $(NASMFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

disk-image: $(KERNEL)
	@echo "Creando imagen de disco..."
	@dd if=/dev/zero of=$(BIN_DIR)/os.img bs=1M count=10
	@mkfs.fat -F 32 $(BIN_DIR)/os.img
	@mkdir -p mnt
	@mount $(BIN_DIR)/os.img mnt
	@cp $(KERNEL) mnt/kernel.bin
	@umount mnt
	@rmdir mnt

run: $(KERNEL)
	qemu-system-i386 -kernel $(KERNEL)

debug: $(KERNEL)
	qemu-system-i386 -kernel $(KERNEL) -s -S

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all directories clean run debug disk-image

print-%:
	@echo $* = $($*)