void _exit(int status)
{
	(void)status;
	__asm__ __volatile__("break");
	for (;;)
		;
}
