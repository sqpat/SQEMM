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
#define true TRUE
#define false FALSE

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
uint8_t**		myargv;
uint16_t ignorelist[1024];

 int16_t  checkparm (uint8_t *check)
{
    int16_t		i;

    for (i = 1;i<myargc;i++)
    {
	if ( !strcasecmp(check, myargv[i]) )
	    return i;
    }

    return 0;
}


void dodump(uint8_t* filename){
	int16_t i = 0;
	FILE* fp = fopen(filename, "wb");
	for (i = 0; i < 0x400; i++){
		int8_t a = inp(i);
		fwrite(&a, 1, 1, fp);
	}
	fclose(fp);

}

int16_t inignorelist(uint8_t* ignorefilename, int16_t port){
	FILE* fp = fopen(ignorefilename, "rb");
	if (!fp){
		fclose(fp);
		return false;
	}
	
	
	while (! feof(fp)){
		uint16_t a = fgetc(fp);
		uint16_t b = fgetc(fp);
		a = (b << 8) + a;
		if (a == port){
			fclose(fp);
			return true; // found in ignore list ignore
		}
	}
	
	fclose(fp);
	return false;
}

void dodiff(uint8_t* filename1, uint8_t* filename2, uint8_t* ignorefilename){
	int16_t i = 0;
	int16_t j = 0;
	//int16_t perline = 0;
	FILE* fp1 = fopen(filename1, "rb");
	FILE* fp2 = fopen(filename2, "rb");

	for (i = 0; i < 0x400; i++){
		int8_t a = fgetc(fp1);
		int8_t b = fgetc(fp2);
		

		if (!inignorelist("ignore.bin", i)){
			if (a != b){
				ignorelist[j] = i;
				j++;
				printf("%x: %hhx vs %hhx\t", i, a, b);
				/*
				perline++;
				if (perline == 5){
					perline = 0;
					printf("\n");
				}
				*/
			}
		}
		
	}


	ignorelist[j] = 0xFFFF;

	fclose(fp1);
	fclose(fp2);

}

uint8_t buffer1[512];

void insertintoignorelist(uint16_t newvalue, int16_t pos){
	int16_t i = pos;
	uint16_t next = newvalue;

	
	while (ignorelist[i] != 0xFFFF){
		int16_t temp = ignorelist[i];
		ignorelist[i] = next;
		next = temp;
		i++;
	}

	ignorelist[i] = next;
	ignorelist[i+1] = 0xFFFF;
}

void addtoignorelistfile(uint8_t* filename){
	int16_t currentarrayindex = 0;
	FILE* fp = fopen(filename, "rb");
	uint16_t currentvalue;
	

	// combine file and current ignore lists into one in memory
	while (! feof(fp)){
		uint16_t a = fgetc(fp);
		uint16_t b = fgetc(fp);
		int16_t i;
		a = (b << 8) + a;

		if (a >= 0x400){
			// seems to be getting garbage FF eof otherwise, need to clean up the logic
			break;
		}

		// todo, lazy, could improve
		for (i = 0; true; i++){
			// should eventually hit 0xFFFF and exit.

			if (a == ignorelist[i]){
				//printf("ignoring  %x\n ", a);
				break;
			}
			// should catch 0xFFFF worst case and exit
			if (a < ignorelist[i]){
				//printf("adding %x\n", a);
				insertintoignorelist(a, i);
				break;
			}
		}
		
	}
	fclose(fp);



	currentvalue = ignorelist[currentarrayindex];
	// now write that to temp file
 	remove (filename);
	fp = fopen(filename, "wb+");
	while (currentvalue != 0xFFFF){
		//printf("writing %x \n", currentvalue);

		fwrite(&currentvalue, sizeof(int16_t), 1, fp);
		currentarrayindex++;
		currentvalue = ignorelist[currentarrayindex];
	}
	// end of file, just put all the rest of the fields in.



	fclose(fp);


}



int16_t main ( int16_t		argc, uint8_t**	argv )  { 
		int16_t dumpparm;
		int16_t diffparm;
		myargc = argc;
		myargv = argv;
		ignorelist[0] = 0xFFFF;
		dumpparm = checkparm("-dump");
		diffparm = checkparm("-diff");

		if (dumpparm && (dumpparm < (myargc - 1))){
			dodump(myargv[dumpparm + 1]);
			return 0;

		}

		if (diffparm && (diffparm < (myargc - 2))){
			dodiff(myargv[diffparm + 1], myargv[diffparm + 2], "ignore.bin");
			return 0;

		}

		if (checkparm("-auto")){
			
			printf("dumping twice to dump1.bin and dump2.bin then diffing:\n");
			dodump("dump1.bin");
			dodump("dump2.bin");
			dodiff("dump1.bin", "dump2.bin", "ignore.bin");

			return 0;
		}

		if (checkparm("-autoupdate")){
			
			printf("dumping twice to dump1.bin and dump2.bin then diffing:\n");
			dodump("dump1.bin");
			dodump("dump2.bin");
			dodiff("dump1.bin", "dump2.bin", "ignore.bin");
			if (ignorelist[0] != 0xFFFF){
				addtoignorelistfile("ignore.bin");
			}

			return 0;
		}
 


		printf("Usage:\n -dump [filename]: simply dumps port contents 0 thru 0x400 \n -diff [filename1] [filename2]: diffs two dump files and prints results\n -auto: dumps to dump1.bin, then dump2.bin, then diffs using ignore list\n -autoupdate: -auto: dumps to dump1.bin/dump2.bin, diffs and updates ignore.bin");
		

        return 0;
}
