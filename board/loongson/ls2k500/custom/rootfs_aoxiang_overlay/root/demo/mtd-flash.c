// 读写 flash : mtd-flash <len> <value>
// > mtd-flash 4 0x11223344
// > mtd-flash 4
// 0x11223344
// > mtd-flash 1
// 0x11

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>

#define MAX_LEN 4
#define BLOCK_SIZE 0x100000
#define MTD_BLOCK_DEV "/dev/mtdblock7"

typedef enum {
	MTHD_W,
	MTHD_R,
} method_e;

typedef struct cmd_s
{
	method_e method;
	unsigned char value[MAX_LEN];
	int size;
} cmd_t;

static int fdMtd;
unsigned char* mapMtd = NULL;

void print_array(unsigned char* array, int size)
{
	printf("0x");
	for (int i = 0; i < size; i++)
		printf("%02x", array[i]);
	printf("\n");
}

int open_mtd()
{
	fdMtd = open(MTD_BLOCK_DEV, O_RDWR);
	mapMtd = mmap(NULL, BLOCK_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fdMtd, 0);

	return 0;
}

int close_mtd()
{
	munmap(mapMtd, BLOCK_SIZE);
	close(fdMtd);
	return 0;
}

int w_mtd(cmd_t* cmd)
{
	memcpy(mapMtd, cmd->value, cmd->size);

	return 0;
}

int r_mtd(cmd_t* cmd)
{
	memcpy(cmd->value, mapMtd, cmd->size);

	return 0;
}

int parse(int argc, char** argv, cmd_t* cmd)
{
	char* eptr;
	unsigned int value;
	int i = 0;

	switch (argc)
	{
		case 2:
			cmd->method = MTHD_R;
			cmd->size = strtol(argv[1], &eptr, 16);
			break;
		case 3:
			cmd->method = MTHD_W;
			cmd->size = strtol(argv[1], &eptr, 16);
			value = strtoul(argv[2], &eptr, 16);
			for (i = 0; i < 4; i++)
				cmd->value[3 - i] = ((value >> (i * 8)) & 0xff);
			break;
		default:
			cmd->method = MTHD_R;
			cmd->size = MAX_LEN;
			break;
	}

	if (cmd->size > MAX_LEN){ cmd->size = MAX_LEN;}

	return 0;
}

int main (int argc, char** argv)
{
	cmd_t cmd = {0};

	parse(argc, argv, &cmd);

	open_mtd();

	switch (cmd.method)
	{
		case MTHD_W:	w_mtd(&cmd);
			break;
		case MTHD_R:	r_mtd(&cmd);
				print_array(cmd.value, cmd.size);
			break;
		default:
			break;
	}

	close_mtd();

	return 0;
}
