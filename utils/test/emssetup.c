#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <graph.h>

#include <i86.h>
#include "test.h"
#include <sys/types.h>




#define TRUE (1 == 1)
#define FALSE (!TRUE)

//#define LOCKMEMORY
//#define NOINTS
//#define USE_USRHOOKS

#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>


int16_t emshandle;


#define BYTES_TO_ALLOCATE (4*1024*1024)
#define PAGE_FRAME_SIZE (16*1024)
#define EMS_INT 0x67

#define false 0
#define true 1


#ifndef __FIXEDTYPES__
#define __FIXEDTYPES__
typedef signed char				int8_t;
typedef unsigned char			uint8_t;
typedef short					int16_t;
typedef unsigned short			uint16_t;
#ifdef _M_I86
typedef long					int32_t;
typedef unsigned long			uint32_t;
#else
typedef int						int32_t;
typedef unsigned int			uint32_t;
#endif
typedef long long				int64_t;
typedef unsigned long long		uint64_t;
#endif

typedef uint8_t byte;
#define I_Error printf
// REGS stuff used for int calls
union REGS regs;
struct SREGS sregs;

#define intx86(a, b, c) int86(a, b, c)

static uint16_t pageframebase;

#define _outbyte(x,y) (outp(x,y))
#define _outhword(x,y) (outpw(x,y))

#define _inbyte(x) (inp(x))
#define _inhword(x) (inpw(x))
 



#define RODNEY_PAGE_SELECT_REGISTER  0xE8
#define RODNEY_EMS_ENABLE_REGISTER   0xE9
#define RODNEY_PAGE_SET_REGISTER     0xEA

int main(void) {
		int8_t i;
		for (i = 0; i < 0x40; i++){
			outp(RODNEY_PAGE_SELECT_REGISTER, i);
			outpw(RODNEY_PAGE_SET_REGISTER, 0);
		}


		outp(RODNEY_EMS_ENABLE_REGISTER, 0x00);

		printf("EMS Subsytem initialized");

		
        return 0;

}
