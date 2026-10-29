/*
 * bin2s — embed binary as MIPS assembly (PS2SDK / Free McBoot convention).
 * Usage: bin2s <infile> <outfile.s> <symbol>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
	FILE *in, *out;
	unsigned char *buf;
	long sz;
	long i;

	if (argc != 4) {
		fprintf(stderr, "Usage: bin2s infile outfile.s symbol\n");
		return 1;
	}

	in = fopen(argv[1], "rb");
	if (!in) {
		perror(argv[1]);
		return 1;
	}
	fseek(in, 0, SEEK_END);
	sz = ftell(in);
	fseek(in, 0, SEEK_SET);
	buf = malloc(sz);
	if (!buf || fread(buf, 1, sz, in) != (size_t)sz) {
		fprintf(stderr, "read failed\n");
		fclose(in);
		return 1;
	}
	fclose(in);

	out = fopen(argv[2], "w");
	if (!out) {
		perror(argv[2]);
		return 1;
	}

	fprintf(out, ".ifdef .gasversion.\n");
	fprintf(out, ".section .mdebug.abiN32\n");
	fprintf(out, ".else\n");
	fprintf(out, ".section .mdebug.eabi64\n");
	fprintf(out, ".endif\n");
	fprintf(out, ".previous\n");
	fprintf(out, ".ifdef .gasversion.\n");
	fprintf(out, ".nan legacy\n");
	fprintf(out, ".module singlefloat\n");
	fprintf(out, ".module oddspreg\n");
	fprintf(out, ".endif\n");
	fprintf(out, ".sdata\n\n");
	fprintf(out, ".align 2\n");
	fprintf(out, ".type size_%s,@object\n", argv[3]);
	fprintf(out, ".size size_%s,4\n", argv[3]);
	fprintf(out, ".globl size_%s\n", argv[3]);
	fprintf(out, "size_%s:\t.word %ld\n\n", argv[3], sz);
	fprintf(out, ".data\n\n");
	fprintf(out, ".balign 16\n\n");
	fprintf(out, ".globl %s\n", argv[3]);
	fprintf(out, ".type %s,@object\n", argv[3]);
	fprintf(out, ".size %s,%ld\n", argv[3], sz);
	fprintf(out, "%s:\n", argv[3]);

	for (i = 0; i < sz; i++) {
		if ((i % 16) == 0)
			fprintf(out, "\t.byte ");
		fprintf(out, "0x%02x", buf[i]);
		if ((i % 16) == 15 || i == sz - 1)
			fputc('\n', out);
		else
			fputs(", ", out);
	}

	free(buf);
	fclose(out);
	return 0;
}
