/*
 * Minimal digital pad — launch keys only (no analog / repeat logic).
 */
#include <kernel.h>
#include <libpad.h>

u32 new_pad;

static char padBuf0[256] __attribute__((aligned(64)));
static char padBuf1[256] __attribute__((aligned(64)));
static struct padButtonStatus buttons0;
static struct padButtonStatus buttons1;

static void waitPadReady(int port)
{
	int state;
	while ((state = padGetState(port, 0)) != PAD_STATE_DISCONN
		&& state != PAD_STATE_STABLE
		&& state != PAD_STATE_FINDCTP1)
		;
}

void waitAnyPadReady(void)
{
	waitPadReady(0);
	waitPadReady(1);
}

int setupPad(void)
{
	padInit(0);
	if (!padPortOpen(0, 0, padBuf0))
		return 0;
	if (!padPortOpen(1, 0, padBuf1))
		return 0;
	waitPadReady(0);
	waitPadReady(1);
	padSetMainMode(0, 0, PAD_MMODE_DIGITAL, PAD_MMODE_UNLOCK);
	padSetMainMode(1, 0, PAD_MMODE_DIGITAL, PAD_MMODE_UNLOCK);
	waitPadReady(0);
	waitPadReady(1);
	return 1;
}

int readPad(void)
{
	u32 pressed = 0;
	int ret0 = 0, ret1 = 0;

	if (padGetState(0, 0) == PAD_STATE_STABLE
		|| padGetState(0, 0) == PAD_STATE_FINDCTP1) {
		ret0 = padRead(0, 0, &buttons0);
		if (ret0)
			pressed |= (u32)(0xffff ^ buttons0.btns);
	}
	if (padGetState(1, 0) == PAD_STATE_STABLE
		|| padGetState(1, 0) == PAD_STATE_FINDCTP1) {
		ret1 = padRead(1, 0, &buttons1);
		if (ret1)
			pressed |= (u32)(0xffff ^ buttons1.btns);
	}
	new_pad = pressed;
	return ret0 | ret1;
}
