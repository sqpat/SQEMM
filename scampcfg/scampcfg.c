#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <graph.h>

#include <i86.h>
#include "scampcfg.h"
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
 



/*
======================
=
= MML_CheckForEMS
=
= Routine from p36 of Extending DOS
=
=======================
*/
/*
char	emmname[9] = "EMMXXXX0";

boolean MML_CheckForEMS (void)
{
asm	mov	dx,OFFSET emmname[0]
asm	mov	ax,0x3d00
asm	int	0x21		// try to open EMMXXXX0 device
asm	jc	error

asm	mov	bx,ax
asm	mov	ax,0x4400

asm	int	0x21		// get device info
asm	jc	error

asm	and	dx,0x80
asm	jz	error

asm	mov	ax,0x4407

asm	int	0x21		// get status
asm	jc	error
asm	or	al,al
asm	jz	error

asm	mov	ah,0x3e
asm	int	0x21		// close handle
asm	jc	error

//
// EMS is good
//
  return true;

error:
//
// EMS is bad
//
  return false;
}

*/




/*
======================
=
= MML_SetupEMS
=
=======================
*/

/*
void MML_SetupEMS (void)
{
	char	str[80],str2[10];
	unsigned	error;

	totalEMSpages = freeEMSpages = EMSpageframe = EMSpagesmapped = 0;

asm {
	mov	ah,EMS_STATUS
	int	EMS_INT						// make sure EMS hardware is present
	or	ah,ah
	jnz	error

	mov	ah,EMS_VERSION
	int	EMS_INT
	or	ah,ah
	jnz	error
	cmp	al,0x32						// only work on ems 3.2 or greater
	jb	error

	mov	ah,EMS_GETFRAME
	int	EMS_INT						// find the page frame address
	or	ah,ah
	jnz	error
	mov	[EMSpageframe],bx

	mov	ah,EMS_GETPAGES
	int	EMS_INT						// find out how much EMS is there
	or	ah,ah
	jnz	error
	mov	[totalEMSpages],dx
	mov	[freeEMSpages],bx
	or	bx,bx
	jz	noEMS						// no EMS at all to allocate

	cmp	bx,4
	jle	getpages					// there is only 1,2,3,or 4 pages
	mov	bx,4						// we can't use more than 4 pages
	}

getpages:
asm {
	mov	[EMSpagesmapped],bx
	mov	ah,EMS_ALLOCPAGES			// allocate up to 64k of EMS
	int	EMS_INT
	or	ah,ah
	jnz	error
	mov	[EMShandle],dx
	}
	return;

error:
	error = _AH;
	strcpy (str,"MML_SetupEMS: EMS error 0x");
	itoa(error,str2,16);
	strcpy (str,str2);
	Quit (str);

noEMS:
;
}

*/

char EMSExists(void){
    char ems;
    //   if (!fnstreqn(int67, "EMMXXXX0", 8) && !fnstreqn(0x67, "EMMQXXX0", 8))
    	return ems; /* NULL */



       /*
       int16_t handle,devInfo,outputStatus;
       // The expanded memory manager if present should show up
       // as a filename
       if ((handle=open("EMMXXXX0",O_RDONLY|O_BINARY)) == -1)
            return false;
       devInfo=ioctl(handle,0);
       // if bit 7 is 0 it is a file
       if ((devInfo & 0x80) == 0)
       {
            printf("Found File EMMXXXX0?!?\n");
            close(handle);
            return false;
       }
       outputStatus=ioctl(handle,7);
       if (outputStatus==0)
       {
            printf("EMM present but not responding\n");
            close(handle);
            return false;
       }
       // file handle for EMS manager is useless for anything
       // further, so we'll just close it.
       close(handle);
       return true;
       */
  }



// CleanUp() tries to deallocate our EMS allocation
void FreeEMS(){
	int16_t errorreg;
   regs.h.ah=0x45;
   regs.w.dx=emshandle;
      intx86(EMS_INT, &regs, &regs);
   errorreg =  regs.h.ah;
   if (errorreg!=0) printf("Deallocation failed %x!\n", errorreg);
}
 
int16_t errorreg;
int16_t numentries;

int16_t pagenum9000;
int16_t pageframe = 0;
int16_t pagedata2[8];
int16_t* far pointervalue2 = pagedata2;


void mapAOld() {
	int16_t i = 0;
	int16_t j = 0;
	int16_t k = 0;
	//return;
	for (i = 0; i < 4; i++){
		regs.h.ah = 0x44;  // function
		regs.h.al = pageframe+i;  // physical page
		regs.w.bx = 64+i;  // logical page
		regs.w.dx = emshandle; // handle
		intx86(EMS_INT, &regs, &regs);
		errorreg = regs.h.ah;
		if (errorreg != 0) {
			I_Error("Call 0x44 failed with value %x!\n", errorreg);
		}

		outp(0xe8, i + 4);
		j = inp(0xea);
		k = inp(0xeb);
		printf("%i %x %x:", i, j, k);
	}
	printf("\n");
}

void mapBOld() {
	int16_t i = 0;
	int16_t j = 0;
	int16_t k = 0;

	//return;

	for (i = 0; i < 4; i++){
		regs.h.ah = 0x44;  // function
		regs.h.al = pageframe+i;  // physical page
		regs.w.bx = 60+i;  // logical page
		regs.w.dx = emshandle; // handle
		intx86(EMS_INT, &regs, &regs);
		errorreg = regs.h.ah;
		if (errorreg != 0) {
			I_Error("Call 0x44 failed with value %x!\n", errorreg);
		}

		outp(0xe8, i + 4);
		j = inp(0xea);
		k = inp(0xeb);
		printf("%i %x %x:", i, j, k);

	}
	printf("\n");

}


void mapA() {
	pagedata2[0] = 4;
	pagedata2[1] = pagenum9000;
	pagedata2[2] = 5;
	pagedata2[3] = pagenum9000 + 1;
	pagedata2[4] = 6;
	pagedata2[5] = pagenum9000 + 2;
	pagedata2[6] = 7;
	pagedata2[7] = pagenum9000 + 3;

	regs.w.ax = 0x5000;  // physical page
	regs.w.cx = 0x04;  // physical page
	regs.w.dx = emshandle; // handle
	sregs.ds = (uint16_t)((uint32_t)pagedata2 >> 16);
	regs.w.si = (uint16_t)(((uint32_t)pagedata2) & 0xffff);
	intx86(EMS_INT, &regs, &regs);
	errorreg = regs.h.ah;
	numentries = regs.w.cx;
	if (errorreg != 0) {
		I_Error("Call 0x5000 failed with value %x!\n", errorreg);
	}
}

void mapB() {
	//page out, by paging in 60-63

	pagedata2[0] = 60;
	pagedata2[1] = pagenum9000;
	pagedata2[2] = 61;
	pagedata2[3] = pagenum9000 + 1;
	pagedata2[4] = 62;
	pagedata2[5] = pagenum9000 + 2;
	pagedata2[6] = 63;
	pagedata2[7] = pagenum9000 + 3;


	regs.w.ax = 0x5000;  // physical page
	regs.w.cx = 0x0004;  // physical page
	regs.w.dx = emshandle; // handle
	sregs.ds = (uint16_t)((uint32_t)pagedata2 >> 16);
	regs.w.si = (uint16_t)(((uint32_t)pagedata2) & 0xffff);
	intx86(EMS_INT, &regs, &regs);
	errorreg = regs.h.ah;
	numentries = regs.w.cx;
	if (errorreg != 0) {
		I_Error("Call 0x5000 failed with value %x!\n", errorreg);
	}


}


void I_InitEMS(void)
{
	char	emmname[9] = "EMMXXXX0";
	// todo check for device...


	int16_t numPagesToAllocate = 256; // 4MB
	int16_t pagestotal, pagesavail;
	uint8_t vernum;
	int16_t i, j;
	//int16_t far *pagedata;
	int16_t pagedata[80];
	int16_t* far pointervalue = pagedata;


	uint16_t* far fakepointer;

	printf("Checking for EMS existence...");

	regs.h.ah = 0x40;
	int86(EMS_INT, &regs, &regs);
	errorreg = regs.h.ah;
	if (errorreg) {
		I_Error("Couldn't init EMS, error %x", errorreg);
	}

	printf("EMS functional... Checking EMS Version...\n");

	regs.h.ah = 0x46;
	intx86(EMS_INT, &regs, &regs);
	vernum = regs.h.al;
	errorreg = regs.h.ah;
	if (errorreg != 0) {
		I_Error("Get EMS Version failed!");
	}
	//vernum = 10*(vernum >> 4) + (vernum&0xF);
	I_Error("EMS Version was %x\n", vernum);
	if (vernum < 32) {
		printf("Warning! EMS Version too low! Expected 3.2, found %i", vernum);
		//Applications like dosbox may support EMS but not report a proper version #?

	}

	printf("Getting page frame: ");
	// get page frame address
	regs.h.ah = 0x41;
	intx86(EMS_INT, &regs, &regs);
	pageframebase = regs.w.bx;
	errorreg = regs.h.ah;
	if (errorreg != 0) {
		I_Error("Could not get page frame!");
	}

	printf("Page frame was %x\n", pageframebase);
	printf("Checking pages available: ");


	regs.h.ah = 0x42;
	intx86(EMS_INT, &regs, &regs);
	pagesavail = regs.w.bx;
	pagestotal = regs.w.dx;
	printf("%i pages total, %i pages available\n", pagestotal, pagesavail);

	if (pagesavail < numPagesToAllocate) {
		//printf("Warning: %i pages of memory recommended, only %i available.", numPagesToAllocate, pagesavail);
		//printf("TODO In the future quit here unless a command line arg is supplied.");
		//I_Error("Quitting now...");
	}


	regs.w.bx = numPagesToAllocate;
	regs.h.ah = 0x43;
	intx86(EMS_INT, &regs, &regs);
	emshandle = regs.w.dx;
	errorreg = regs.h.ah;
	if (errorreg != 0) {
		// Error 0 = 0x00 = no error
		// Error 137 = 0x89 = zero pages
		// Error 136 = 0x88 = OUT_OF_LOG

		I_Error("Couldn't allocate %d EMS Pages, error %x", numPagesToAllocate, regs.h.ah);
	}

	printf("found handle %i ", emshandle);


	// do initial page remapping

	/*
	for (j = 0; j < 4; j++) {
		regs.h.al = j;  // physical page
		regs.w.bx = j;    // logical page
		regs.w.dx = emshandle; // handle
		regs.h.ah = 0x44;
		intx86(EMS_INT, &regs, &regs);
		errorreg = regs.h.ah;
		if (errorreg != 0) {
			I_Error("Mapping failed (%x) on page %i ! ", errorreg ,j);
		}
	}
	*/


	regs.w.ax = 0x5801;  // physical page
	intx86(EMS_INT, &regs, &regs);
	errorreg = regs.h.ah;
	numentries = regs.w.cx;
	if (errorreg != 0) {
		I_Error("Call 5801 failed with value %x!\n", errorreg);
	}
	printf("Total frame count: %i\n", numentries);


	regs.w.ax = 0x5800;  // physical page
	sregs.es = (uint16_t)((uint32_t)pointervalue >> 16);
	regs.w.di = (uint16_t)(((uint32_t)pointervalue) & 0xffff);
	intx86(EMS_INT, &regs, &regs);
	errorreg = regs.h.ah;
	//pagedata = MK_FP(sregs.es, regs.w.di);
	if (errorreg != 0) {
		I_Error("Call 25 failed with value %x!\n", errorreg);
	}

//	printf("Call 25 found:\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n%x\t%x\t%x\t%x\t%x\t%x\t%x\t%x\t\n",

	printf("Call 25 found:\n%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t\n%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t\n%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t\n%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t%x %x\t\n%x %x\t%x %x\t%x %x\t%x %x\n",
		pagedata[0], pagedata[1], pagedata[2], pagedata[3], pagedata[4],
		pagedata[5], pagedata[6], pagedata[7], pagedata[8], pagedata[9],
		pagedata[10], pagedata[11], pagedata[12], pagedata[13], pagedata[14],
		pagedata[15], pagedata[16], pagedata[17], pagedata[18], pagedata[19],
		pagedata[20], pagedata[21], pagedata[22], pagedata[23], pagedata[24],
		pagedata[25], pagedata[26], pagedata[27], pagedata[28], pagedata[29],
		pagedata[30], pagedata[31], pagedata[32], pagedata[33], pagedata[34],
		pagedata[35], pagedata[36], pagedata[37], pagedata[38], pagedata[39],
		pagedata[40], pagedata[41], pagedata[42], pagedata[43], pagedata[44],
		pagedata[45], pagedata[46], pagedata[47], pagedata[48], pagedata[49],
		pagedata[50], pagedata[51], pagedata[52], pagedata[53], pagedata[54],
		pagedata[55], pagedata[56], pagedata[57], pagedata[58], pagedata[59],
		pagedata[60], pagedata[61], pagedata[62], pagedata[63], pagedata[64],
		pagedata[65], pagedata[66], pagedata[67], pagedata[68], pagedata[69],
		pagedata[70], pagedata[71]

	);



	for (i = 0; i < numentries; i ++) {
		if (pagedata[i*2] == 0x9000u) {
			pagenum9000 = pagedata[(i*2) + 1];
			printf( "Pagenum for 0x9000 was: %x", pagenum9000);
		}
		if (pagedata[i*2] == pageframebase) {
			pageframe = pagedata[(i*2) + 1];
			printf(" Pagenum for %x was: %i", pageframebase, pageframe);
			
		}

	}


	//printf("\nPagenum for 0x9000 NOT FOUND!");

	//found:


	// initial setup, map seg 9000 memory to 4-7
	// cant do 0-3 cause up above we mapped that to page frame
	printf("\n");
	mapAOld();

	// write data

	fakepointer = MK_FP(0xD000, 0x0000);
	*fakepointer = 0x1234;
	fakepointer = MK_FP(0xD400, 0x0000);
	*fakepointer = 0x3456;

	fakepointer = MK_FP(0xD800, 0x0000);
	*fakepointer = 0x5678;
	fakepointer = MK_FP(0xDC00, 0x0000);
	*fakepointer = 0x789A;

	//page out, by paging in 60-63

	mapBOld();



	fakepointer = MK_FP(0xD000, 0x0000);
	*fakepointer = 0xAAAA;
	fakepointer = MK_FP(0xD400, 0x0000);
	*fakepointer = 0xBBBB;
	fakepointer = MK_FP(0xD800, 0x0000);
	*fakepointer = 0xCCCC;
	fakepointer = MK_FP(0xDC00, 0x0000);
	*fakepointer = 0xDDDD;
	 
	mapAOld();


	printf("\nvalues were:");
	fakepointer = MK_FP(0xD000, 0x0000);
	printf("%x ", *fakepointer);
	fakepointer = MK_FP(0xD400, 0x0000);
	printf("%x ", *fakepointer);
	fakepointer = MK_FP(0xD800, 0x0000);
	printf("%x ", *fakepointer);
	fakepointer = MK_FP(0xDc00, 0x0000);
	printf("%x ", *fakepointer);
	printf("\n");

	mapBOld();
	
	printf("\nother values were:");
	fakepointer = MK_FP(0xD000, 0x0000);
	printf("%x ", *fakepointer);
	fakepointer = MK_FP(0xD400, 0x0000);
	printf("%x ", *fakepointer);
	fakepointer = MK_FP(0xD800, 0x0000);
	printf("%x ", *fakepointer);
	fakepointer = MK_FP(0xDc00, 0x0000);
	printf("%x ", *fakepointer);
	
	/*
	1. try dosbox-x

	2. 
     FUNCTION 28   ALTERNATE MAP REGISTER SET
	     GET ALTERNATE MAP SAVE ARRAY SIZE SUBFUNCTION
	  - figure out size...

	3. 
	*/



    // EMS Handle
    //return emshandle;

 
   

       
} 

// thanks stack overflow

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  ((byte) & 0x80 ? '1' : '0'), \
  ((byte) & 0x40 ? '1' : '0'), \
  ((byte) & 0x20 ? '1' : '0'), \
  ((byte) & 0x10 ? '1' : '0'), \
  ((byte) & 0x08 ? '1' : '0'), \
  ((byte) & 0x04 ? '1' : '0'), \
  ((byte) & 0x02 ? '1' : '0'), \
  ((byte) & 0x01 ? '1' : '0') 


#define NUM_REGS 17

int8_t config_regs[NUM_REGS] = 
  { 0x00, 0x02, 0x03, 0x05, 
    0x06, 0x07, 0xA, 0xB, 
	0xC, 0xE, 0xF, 0x10, 
	0x11, 0x13, 0x14, 0x15, 
	0x16};

char * config_names[NUM_REGS] = {
	"VER    ",
	"SLTPTR ",
	"RAMMAP ",
	"RAMSET ",
	"REFCTL ",
	"CLKCTL ",
	"MCDCTL ",
	"EMSEN1 ",
	"EMSEN2 ",
	"ABAXS  ",
	"CAXS   ",
	"DAXS   ",
	"FEAXS  ",
	"SLPCTL ",
	"MISCSET",
	"ROMDMA ",
	"BUSCTL "

};



char * setting_names[NUM_REGS] = {
	"1\t1\t0\t1\t0\t0\t0\t1",
	"A23\tA22\tA21\tA20\tA19\tA18\tA17\tA26",
	"1\tROMMOV1,0\tREMP384\tMEMAP3\tMEMAP2\tMEMAP1\tMEMAP0",
	"1\t1\t1\tDRAMWS\t-FASTSX\t-PGMD\t-ENPAR\tRASOFF",
	"1\t1\t1\t1\t1\t1\tCASREF\tREFSPD",
	"ENVDSP CLK2DIV1,0\tFCLK2DIV1,0\tBOSCSNS\tSCLKDIV1,0",
	"1\t1\t1\t1\tMCPGEN3\tMCPGEN2\tMCPGEN1\tMCPGEN0",
	"EMSENAB BFENAB   1\tEMSMAP\tB/EC00\tB/E800\tB/E400\tB/E000",
	"DC00 D800\tD400\tD000\tA/CC00\tA/C800\tA/C400\tA/C000",

	"B800 Access\tB000 Access\tA800 Access\tA000 Access",
	"CC00 Access\tC800 Access\tC400 Access\tC000 Access",
	"DC00 Access\tD800 Access\tD400 Access\tD000 Access",
	"F800 Access\tF000 Access\tE800 Access\tE000 Access",
	"SLP\tDIVCLK3\tDIVCLK2\tDIVCLK1\tDIVCLK0\tSLPSTS\tPINFNC\tENSYCK",
	"-VSF F1CTL\tFASTRC\t1\t1\tRAMDRV\t10/16IO\tIRQIN",
	"ROMWS1,0\tDMAWS8(1),(0)\tDMAWS16(1),(0)\tDMACLK\tMEMTM",
	"ROMWID STLDRV DSKTMG 1\tCMDLY2\tCMDLY1\t16WS\t8WS"

};


// 7 chars per setting name.
// if it starts with a space, continuation from the last

char * setting_names_detailed[NUM_REGS * 8] = {
	"    1  ","   1   ","   0   ","   1   ","   0   ","   0   ","   0   ","  1",
	"  A23  ","  A22  ","  A21  ","  A20  ","  A19  ","  A18  ","  A17  ","  A26",
	"    1  ","ROMMOV1,","@ROMMOV0","REMP384","MEMAP3 ","MEMAP2 ","MEMAP1 ","MEMAP0",
	"    1  ","   1   ","   1   ","DRAMWS ","-FASTSX","-PGMD  ","-ENPAR ","RASOFF",
	"    1  ","   1   ","   1   ","   1   ","   1   ","   1   ","CASREF ","REFSPD",
	"ENVDSP ","  CLK2DIV1,", "@0   ","  FCLK2DIV1,","@0  ","BOSCSNS","  SCLKDIV1,","@0",
	"    1  ","   1   ","   1   ","   1   ","MCPGEN3","MCPGEN2","MCPGEN1","MCPGEN0",
	"EMSENAB","BFENAB ","   1   ","EMSMAP ","B/EC00 ","B/E800 ","B/E400 ","B/E000",
	" DC00  ","D800   ","D400   ","D000   ","A/CC00 ","A/C800 ","A/C400 ","A/C000",
	" B800","@ Access   "," B000 ","@ Access  ","  A800 ","@ Access ","  A000 ","@ Access",
	" CC00","@ Access   "," C800 ","@ Access  ","  C400 ","@ Access ","  C000 ","@ Access",
	" DC00","@ Access   "," D800 ","@ Access  ","  D400 ","@ Access ","  D000 ","@ Access",
	" F800","@ Access   "," F000 ","@ Access  ","  E800 ","@ Access ","  E000 ","@ Access",
	"  SLP  ","DIVCLK3,","@DIVCLK2,","@DIVCLK1,","@DIVCLK0","SLPSTS ","PINFNC ","ENSYCK",
	" -VSF  ","F1CTL  ","FASTRC ","   1   ","   1   ","RAMDRV ","10/16IO","IRQIN",
	"ROMWS1 ","ROMSW0 ","DMAWS8 (1),","@(0) ","DMAWS16(1),","@(0) ","DMACLK ","MEMTM",
	"ROMWID ","STLDRV ","DSKTMG ","   1   ","CMDLY2 ","CMDLY1 ","16WS   ","8WS"

};


void printchar(byte a){
	char bytes[2];
	bytes[0] = a;
	bytes[1] = '\0';
	_outtext(bytes);
}

int main(void)
  {
		byte value;
		int16_t i, j;
		byte bit;
		char bigstring[60];
		_outtext ("VLSI SCAMP configuration viewer/editor\n");
		_outtext ("Basic configuration registers: \n");
		_outtext ("Addr Name Value  Bit 7  Bit 6  Bit 5  Bit 4  Bit 3  Bit 2  Bit 1  Bit 0 \n");

		for (i = 0; i < NUM_REGS; i++){
			outp(0xec, config_regs[i]);
			value = inp (0xed);
//			printf ("%02X %s " BYTE_TO_BINARY_PATTERN" %s\n", config_regs[i], config_names[i], BYTE_TO_BINARY(value), setting_names[i]);
//			sprintf (bigstring,"%02X %s " BYTE_TO_BINARY_PATTERN"\0", config_regs[i], config_names[i], BYTE_TO_BINARY(value));

			sprintf (bigstring,"%02X\0", config_regs[i]);
			_outtext(bigstring);
			printchar(179);

			sprintf (bigstring,"%s\0", config_names[i]);
			_outtext(bigstring);
			printchar(179);

//			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value));
			sprintf (bigstring,"%02X\0", (value));
			_outtext(bigstring);
			printchar(179);



			bit = 0x80;
			for (j = 0; j < 8; j++){
				
				if (j > 0){
					if (setting_names_detailed[i * 8 + j][0] != '@'){
						_settextcolor(7);
						printchar(179);
					}
				}

				if (value & bit){
					_settextcolor(14);
				} else {
					_settextcolor(7);
				}

				sprintf(bigstring,"%s\0", setting_names_detailed[i * 8 + j]);
				if (bigstring[0] == '@'){
					int16_t k = 0;
					while(bigstring[k] != '\0'){
						bigstring[k] = bigstring[k+1];
						k++;
					}
				}

				_outtext(bigstring);
				bit >>= 1;
			}
			_settextcolor(7);

			_outtext("\n");
		}
 


        return 0;
}
