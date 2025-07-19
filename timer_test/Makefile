# Makefile for timer_test - LoongArch64 static build
# Target: loongarch64-unknown-linux-gnu

# Compiler and flags
CC = loongarch64-unknown-linux-gnu-gcc
CFLAGS = -Wall -Wextra -g -std=c99
LDFLAGS = -lm -static
TARGETS = timer_test init_1

# Default target
all: $(TARGETS) copy

$(TARGETS): $(wildcard *.c)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

copy:
	cp $(TARGETS) ../rootfs_ramdisk_overlay/

# Clean build artifacts
clean:
	rm -f $(TARGETS)
	rm -f ../rootfs_ramdisk_overlay/$(TARGETS)

# Phony targets
.PHONY: all clean copy