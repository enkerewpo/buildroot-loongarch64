// 读写 u32 数字
// > rtc-ram 0x11223344
// > rtc-ram
// 0x11223344

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>

#define RAM_REG 0x14
#define RTC_ADDR 0x32

typedef enum {
	MTHD_W,
	MTHD_R,
} method_e;

typedef struct cmd_s
{
	method_e method;
	unsigned int value;
} cmd_t;

static int fdRtc;

int open_rtc()
{
	fdRtc = open("/dev/i2c-1", O_RDWR);
	ioctl(fdRtc, I2C_SLAVE_FORCE, RTC_ADDR);
	return 0;
}

int close_rtc()
{
	close(fdRtc);
	return 0;
}

int x_rtc(unsigned char* s, int s_l, unsigned char* r, int r_l, int m_n)
{
	struct i2c_rdwr_ioctl_data io = {0};
	struct i2c_msg msg[2] = {0};

	msg[0].addr = RTC_ADDR;
	msg[0].flags = I2C_SMBUS_WRITE;
	msg[0].buf = s;
	msg[0].len = s_l;

	msg[1].addr = RTC_ADDR;
	msg[1].flags = I2C_SMBUS_READ;
	msg[1].len = r_l;
	msg[1].buf = r;

	io.msgs = msg;
	io.nmsgs = m_n;

	return ioctl(fdRtc, I2C_RDWR, (unsigned long)&io);
}

int w_rtc(cmd_t* cmd)
{
	unsigned char buf[5] = {0};
	int i = 0;
	buf[0] = RAM_REG;
	for (i = 0; i < 4; i++)
	{
		buf[i + 1] = ((cmd->value >> (i * 8)) & 0xff);
	}

	x_rtc(buf, sizeof(buf), NULL, 0, 1);

	return 0;
}

int r_rtc(cmd_t* cmd)
{
	unsigned char s[1] = {RAM_REG};
	unsigned char r[4] = {0};

	x_rtc(s, sizeof(s), r, sizeof(r), 2);

	cmd->value = (r[3] << 24) | (r[2] << 16) | (r[1] << 8) | (r[0]);

	return 0;
}

int parse(int argc, char** argv, cmd_t* cmd)
{
	char* eptr;
	switch (argc)
	{
		case 2:
			cmd->method = MTHD_W;
			cmd->value = strtoul(argv[1], &eptr, 16);
			break;
		default:
			cmd->method = MTHD_R;
			break;
	}

	return 0;
}


int main (int argc, char** argv)
{
	cmd_t cmd = {0};

	parse(argc, argv, &cmd);

	open_rtc();

	switch (cmd.method)
	{
		case MTHD_W:	w_rtc(&cmd);
			break;
		case MTHD_R:	r_rtc(&cmd); printf("0x%x\n", cmd.value);
			break;
		default:
			break;
	}

	close_rtc();

	return 0;
}
