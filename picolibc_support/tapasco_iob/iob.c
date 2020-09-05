/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright © 2019 Keith Packard
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials provided
 *    with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * 
 *
 * Copyright © 2020 Embedded Systems and Applications Group, TU Darmstadt
 * 
 * Modified underlaying source code for own usage.
 * 
 */

#include <stdio.h>
#include <sys/cdefs.h>

#define STDOUT_BASE ((int *) 0x11000080)
#define STDOUT_SIZE ((int *) 0x11000090)
#define STDIN_BASE  ((int *) 0x110000A0)
#define STDIN_SIZE  ((int *) 0x110000B0)
#define RAM_OFFSET  0x80000000

/*
 * stdio implementation for RISC-V cores included in TaPaSCo
 */

char * stdout_buffer = 0;
int stdout_offset = 0;
int stdout_size = 0;

char * stdin_buffer = 0;
int stdin_offset = 0;
int stdin_size = 0;

/* 
 * initialize pointers before main() is even called
 */
static void __attribute__((constructor)) init_iob()
{
	stdout_buffer = (char *) (*STDOUT_BASE + RAM_OFFSET);
	stdout_size = *STDOUT_SIZE;
	stdin_buffer = (char *) (*STDIN_BASE + RAM_OFFSET);
	stdin_size = *STDIN_SIZE;
}

static int
tapasco_putc(char c, FILE *file)
{
	// check whether buffer address is set and size is not exceeded
	if (stdout_buffer != 0 && stdout_offset < stdout_size) {
		stdout_buffer[stdout_offset] = c;
		++stdout_offset;
		return c;
	}
	return EOF;
}

static int
tapasco_getc(FILE *file)
{
	// check whether buffer address is set and size is not exceeded
	if (stdin_buffer != 0 && stdin_offset < stdin_size) {
		char c = stdin_buffer[stdin_offset];
		++stdin_offset;
		return c;
	}
	return EOF;
}

/*
 * flush is not implemented since all data is written directly to memory anyway
 */ 
static int
tapasco_flush(FILE *file)
{
	(void) file;
	return 0;
}

static FILE __stdio = FDEV_SETUP_STREAM(tapasco_putc, tapasco_getc, tapasco_flush, _FDEV_SETUP_RW);

FILE *const __iob[3] = { &__stdio, &__stdio, &__stdio };
