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
#include <bios.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>


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
	"    1  ","   1   ","   0   ","   1   ","   0   ","   1   ","   1   ","  0",
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
	_settextcolor(15);
	_outtext(bytes);
	_settextcolor(7);
}

void printstatus(){

		byte value;
		int16_t i, j;
		byte bit;
		char bigstring[60];

		_outtext ("Ad Name  Value Bit 7   Bit 6   Bit 5   Bit 4   Bit 3   Bit 2   Bit 1   Bit 0 \n");

		for (i = 0; i < NUM_REGS; i++){
			outp(0xec, config_regs[i]);
//			printf ("%02X %s " BYTE_TO_BINARY_PATTERN" %s\n", config_regs[i], config_names[i], BYTE_TO_BINARY(value), setting_names[i]);
//			sprintf (bigstring,"%02X %s " BYTE_TO_BINARY_PATTERN"\0", config_regs[i], config_names[i], BYTE_TO_BINARY(value));

			sprintf (bigstring,"%02X\0", config_regs[i]);
			_outtext(bigstring);
			printchar(179);

			sprintf (bigstring,"%s\0", config_names[i]);
			_outtext(bigstring);
			printchar(179);
			value = inp (0xed);

//			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value));
			sprintf (bigstring,"%02X\0", (value));
			_outtext(bigstring);
			printchar(179);



			bit = 0x80;
			for (j = 0; j < 8; j++){
				
				if (j > 0){
					if (setting_names_detailed[i * 8 + j][0] != '@'){
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
}

byte addkeystroke(byte initialvalue, byte keychar){
	byte usednibble = 0;
	if (keychar >= 'a'){
		usednibble = 0xA + keychar - 'a';
	} else if (keychar >= 'A'){
		usednibble = 0xA + keychar - 'A';
	} else if (keychar >= '0'){
		usednibble = keychar - '0';
	}
	initialvalue <<= 4;
	initialvalue += usednibble;
	return initialvalue;

}


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

void printemsregisterdata(){
		byte value1;
		int16_t value2;
		int16_t fullvalue;
		int16_t i, j;
		byte bit;
		char bigstring[60];

		_outtext ("Ad   0xEB     0xEA   Ad   0xEB     0xEA        \n");


		for (i = 0; i < 18; i++){

			outp(0xe8, i);
			sprintf (bigstring,"%02X\0", i);
			_outtext(bigstring);

			value1 = inp(0xea);
			printchar(179);
			value2 = inp(0xeb);

			fullvalue = (value2 << 8) + value1;

			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value2));
			_outtext(bigstring);
			printchar(179);
			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value1));
			_outtext(bigstring);
			printchar(179);
			

// 2nd half

			outp(0xe8, i+18);
			sprintf (bigstring,"%02X\0", i+18);
			_outtext(bigstring);

			value1 = inp(0xea);
			printchar(179);
			value2 = inp(0xeb);

			fullvalue = (value2 << 8) + value1;

			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value2));
			_outtext(bigstring);
			printchar(179);
			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value1));
			_outtext(bigstring);
			printchar(179);
			
			
			sprintf (bigstring,"\n\0");
			_outtext(bigstring);




		}


}

int16_t
main
( int16_t		argc,
  int8_t**	argv ) 
{ 
		byte keychar;
		byte modifyvalue;
		byte modifyport;
		byte step;
		int16_t delay;
		char bigstring[60];

		myargc = argc;
		myargv = argv;

		_outtext ("VLSI SCAMP configuration viewer/editor\n");
		//_outtext ("Basic configuration registers: \n");
		restart:


		if (checkparm("-ems")){
			printemsregisterdata();
			
			return 0;
		} 

		if (checkparm("-resetems")){
			int16_t i;
			int16_t baseoffset;
			for (i = 12; i < 36; i++){
				outp(0xE8, i);
				baseoffset = i * i; // delay for outp
				outp(0xEA, 0xFF);
				baseoffset = i * i; // delay for outp
				outp(0xEB, 0xFF);
			}
			return 0;
		}
		

		if (checkparm("-set4000")){
			int16_t i;
			int16_t baseoffset;
			for (i = 0; i < 24; i++){
				byte __far *loc = MK_FP(0x4000 + i * 0x400, 0);
				*loc = (i+1) * 2;
			}
			return 0;
		}

		if (checkparm("-set4000g")){
			int16_t i;
			int16_t baseoffset;

			outp(0xFB, 0x00);
			
			outp(0xEC, 0x0B);
			outp(0xED, 0xE0); // enable global


			for (i = 0; i < 24; i++){
				byte __far *loc = MK_FP(0x4000 + i * 0x400, 2);
				*loc = (0x40 + (i+1) * 2);
			}
			return 0;

			outp(0xEC, 0x0B);
			outp(0xED, 0xA0); // disable global

			// dummy write to disable config registers in scamp
			//outp(0xF9, 0x00);
		}

		// todo cleanup and put in own function?

		printstatus();
		_outtext ("\nUsage: M or m to modify, followed by port addr byte in hex, followed by value byte in hex. Any other key to quit.\n");
 

 		keychar = _bios_keybrd(_KEYBRD_READ);
		if (keychar == 'm' || keychar == 'M'){
			byte printed[3];
			
			// print "m " to screen
			printed[0] = keychar;
			printed[1] = ' ';
			printed[2] = '\0';
			_outtext(printed);
			
			// initialize these
			modifyvalue = 0;
			modifyport = 0;
	 		step = 0;
			// we'll just loop and use step 0-3 to keep track of our current place in this. 
			while (true){
				keychar = _bios_keybrd(_KEYBRD_READ);
				if ((keychar >= '0' && keychar <= '9') ||
					(keychar >= 'a' && keychar <= 'f')||
					(keychar >= 'A' && keychar <= 'F')){
						
						printed[0] = keychar;  // print typed char to screen
						printed[1] = '\0';
						_outtext(printed);

				

						if (step == 0){
							modifyport = addkeystroke(modifyport, keychar);
						} else if (step == 1){
							printed[0] = ' ';  // throw in another space
							_outtext(printed);

							modifyport = addkeystroke(modifyport, keychar);
						} else if (step == 2){
							modifyvalue = addkeystroke(modifyvalue, keychar);
						} else if (step == 3){
							modifyvalue = addkeystroke(modifyvalue, keychar);

							outp(0xec, modifyport);
							delay = 325 * (keychar * keychar); // forced delay to prevent chipset crash
							outp(0xed, modifyvalue);
							sprintf (bigstring,"\nWrote value %2X to port %2X\n", modifyvalue, modifyport);
							_outtext(bigstring);
							goto restart;

						}
						
						step++;
					}
					 else {
						break;
					}
			}

		}

		

        return 0;
}
