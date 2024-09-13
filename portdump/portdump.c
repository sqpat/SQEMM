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

int16_t		myargc;
int8_t**		myargv;

 int16_t  checkparm (int8_t *check)
{
    int16_t		i;

    for (i = 1;i<myargc;i++)
    {
	if ( !strcasecmp(check, myargv[i]) )
	    return i;
    }

    return 0;
}


void dodump(int8_t* filename){
	int16_t i = 0;
	FILE* fp = fopen(filename, "wb");
	for (i = 0; i < 0x400; i++){
		int8_t a = inp(i);
		fwrite(&a, 1, 1, fp);
	}
	fclose(fp);

}

void dodiff(int8_t* filename1, int8_t* filename2){
	int16_t i = 0;
	int16_t perline = 0;
	FILE* fp1 = fopen(filename1, "rb");
	FILE* fp2 = fopen(filename2, "rb");
	for (i = 0; i < 0x400; i++){
		int8_t a = fgetc(fp1);
		int8_t b = fgetc(fp2);
		if (a != b){
			printf("%hhx: %hhx vs %hhx\t", i, a, b);
			perline++;
			if (perline == 4){
				perline = 0;
				printf("\n");
			}
		}
		
	}

	fclose(fp1);
	fclose(fp2);

}



int16_t
main
( int16_t		argc,
  int8_t**	argv ) 
{ 
		int16_t dumpparm;
		int16_t diffparm;
		myargc = argc;
		myargv = argv;
		dumpparm = checkparm("-dump");
		diffparm = checkparm("-diff");

		if (dumpparm && (dumpparm < (myargc - 1))){
			dodump(myargv[dumpparm + 1]);
			return 0;

		}

		if (diffparm && (diffparm < (myargc - 2))){
			dodiff(myargv[diffparm + 1], myargv[diffparm + 2]);
			return 0;

		}

		if (checkparm("-auto")){
			printf("dumping twice to dump1.bin and dump2.bin then diffing:\n");
			dodump("dump1.bin");
			dodump("dump2.bin");
			dodiff("dump1.bin", "dump2.bin");
			return 0;

		}



		printf("Usage: -dump [filename] or -diff [filename1] [filename2] or -auto");
		

        return 0;
}
