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
union REGS regs;

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
 
		if (checkparm("-sarc")){
			uint8_t i = 0x80;

			for (i = 0x00; i <= 0xfe; i++){
				outp (0x22, i);
				printf("%02x:%02x ", i, inp(0x23));
				if ((i % 0xd) == 0xc){
					printf("\n");
				}
			}
			outp (0x22, 0xff);
			printf("%02x:%02x ", i, inp(0x23));

			return 0;
		}

		if (checkparm("-sarc2")){
			uint8_t iter;
			uint8_t i = 0x80;
			uint8_t locs1[24];
			uint8_t locs2[6];

			for (iter = 0; iter < 24; iter++){
				locs1[iter] = *(uint8_t __far*)MK_FP(0x4000 + 0x400 * iter, 0);
			}

			for (iter = 0; iter < 6; iter++){
				locs2[iter] = *(uint8_t __far*)MK_FP(0xC800 + 0x400 * iter, 0);
			}

			for (i = 0x88; i <= 0x8f; i++){
				int16_t j = 0;
				FILE* fp;
				outp (0x22, i);
				printf("\n Register %x", i);
				
				for(j = 0; j <0xff; j++){

					if (((j&0x80) || (j& 0x40)) && ((j & 0xF) == 0)){
						continue;
					}


					if (j == 0xbe){
						//continue;
					}

					printf("%02x ", j);
					fp = fopen ("test.txt", "a");
					fprintf(fp, "%02x ", j);
					fclose(fp);
					
					outp(0x23, j);

					for (iter = 0; iter < 24; iter++){
						if (locs1[iter] != *(uint8_t __far*)MK_FP(0x4000 + 0x400 * iter, 0)){
							printf ("found a change: %lx %2x %2x", MK_FP(0x4000 + 0x400 * iter, 0), *(uint8_t __far*)MK_FP(0x4000 + 0x400 * iter, 0), locs1[iter]);
							return 0;
						}
					}

					for (iter = 0; iter < 6; iter++){
						locs2[iter] = *(uint8_t __far*)MK_FP(0xC800 + 0x400 * iter, 0);
						if (locs2[iter] != *(uint8_t __far*)MK_FP(0xC800 + 0x400 * iter, 0)){
							printf ("found a change: %lx %2x %2x", MK_FP(0xC800 + 0x400 * iter, 0), *(uint8_t __far*)MK_FP(0xC800 + 0x400 * iter, 0), locs2[iter]);
							return 0;

						}

					}

				}
			}


			return 0;
		}


		if (checkparm("-sarc3")){
			uint8_t iter;
			uint8_t locs1  = *(uint8_t __far*)MK_FP(0xD000, 0);

			int16_t j = 0;
			outp (0x22, 0x89);
			printf("\n Register %x", 0x89);
			
			for(j = 0; j <0xff; j++){

				if (((j&0x80) || (j& 0x40)) && ((j & 0xF) == 0)){
					continue;
				}


				if (j == 0xbe){
					//continue;
				}

				outp(0x23, j);

				if (locs1  != *(uint8_t __far*)MK_FP(0xD000, 0)){
					printf ("found a change: %x %lx %2x %2x", j,  MK_FP(0xD000, 0), *(uint8_t __far*)MK_FP(0xD000, 0), locs1);
					return 0;
				}


			}


			return 0;
		}

		if (checkparm("-emstest")){
			uint8_t iter;
			uint8_t locs1  = *(uint8_t __far*)MK_FP(0xD000, 0);

			uint8_t al = 0;
			uint8_t ah = 0x44;
			int16_t bx = 0;
			int16_t dx = 1;
			#define EMS_INT 0x67
			
			for (al = 0; al < 4; al++){
				uint8_t port1 = 0x88 + 2 * al;
				uint8_t port2 = 0x88 + 2 * al + 1;
				for(bx = -1; bx <128; bx++){
					uint8_t value1;
					uint8_t value2;
					uint8_t expected_value1 = (bx == -1) ? 0 :    0xC4 + al + ((bx & 3) << 4);
					uint8_t expected_value2 = (bx == -1) ? 0x00 : 0x20 + (bx >> 2) ;
					printf("write test al = %hhx bx = %hx:", al, bx);
					regs.h.al = al;  // physical page
					regs.w.bx = bx; // activepages[pageframeindex + i];    // logical page
					regs.w.dx = dx; // handle
					regs.h.ah = ah;
					int86(EMS_INT, &regs, &regs);
					if (regs.h.ah != 0) {
						printf("nonzero return %x %hhx %hhx", bx, al, regs.h.ah);
						return 0;
					}

					*((uint8_t __far*) MK_FP(0xD000 + 0x400 * al, 0)) = bx & 0xFF;

					outp (0x22, port1);
					value1 = 649 * al;
					value1 = inp (0x23);

					outp (0x22, port2);
					value2 = 648 * al;
					value2 = inp (0x23);

					if ((expected_value1 != value1) || (expected_value2 != value2)){
						outp (0x22, port1);
						printf("bad value? %hhx %hhx %hhx %hhx", 
							expected_value1, value1, 
							expected_value2, value2
						);

						value1 = inp (0x23);

						printf("check again: %hhx %hhx %hhx %hhx", 
							expected_value1, value1, 
							expected_value2, value2
						);
						if ((expected_value1 != value1) || (expected_value2 != value2)){
							return 0;
						}

					}
					printf("ok\n");


				}
			}

			for (al = 0; al < 4; al++){
				uint8_t port1 = 0x88 + 2 * al;
				uint8_t port2 = 0x88 + 2 * al + 1;
				for(bx = -1; bx <128; bx++){
					uint8_t value1;
					uint8_t value2;
					printf("read test al = %hhx bx = %hx:", al, bx);
					regs.h.al = al;  // physical page
					regs.w.bx = bx; // activepages[pageframeindex + i];    // logical page
					regs.w.dx = dx; // handle
					regs.h.ah = ah;
					int86(EMS_INT, &regs, &regs);
					if (regs.h.ah != 0) {
						printf("nonzero return %x %hhx %hhx", bx, al, regs.h.ah);
						return 0;
					}

					if ((*((uint8_t __far*) MK_FP(0xD000 + 0x400 * al, 0))) != (bx & 0xFF)){
						printf("bad data match! Expected %hhx vs %x.... %hhx %hhx", *((uint8_t __far*) MK_FP(0xD000 + 0x400 * al, 0)), bx, al, regs.h.ah);
						return 0;
					}

					printf("ok\n");


				}
			}


			return 0;
		}

		printf("Usage:\n -dump [filename]: simply dumps port contents 0 thru 0x400 \n -diff [filename1] [filename2]: diffs two dump files and prints results\n -auto: dumps to dump1.bin, then dump2.bin, then diffs using ignore list\n -autoupdate: -auto: dumps to dump1.bin/dump2.bin, diffs and updates ignore.bin");
		

        return 0;
}
