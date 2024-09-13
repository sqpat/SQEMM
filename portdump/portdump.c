#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <graph.h>

#include <i86.h>
#include "portdump.h"
#include <sys/types.h>




#define TRUE (1 == 1)
#define FALSE (!TRUE)

//#define LOCKMEMORY
//#define NOINTS
//#define USE_USRHOOKS

#include <dos.h>
#include <bios.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

 

int16_t
main
( int16_t		argc,
  int8_t**	argv ) 
{ 
		int16_t i = 0;
		FILE* fp = fopen("dump.bin", "wb");
		
		for (i = 0; i < 0x400; i++){
			int8_t a = inp(i);
			fwrite(&a, 1, 1, fp);
		}

		fclose(fp);
		

        return 0;
}
