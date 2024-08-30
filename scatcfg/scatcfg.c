#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <graph.h>

#include <i86.h>
#include "scatcfg.h"
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

#define CHIPSET_CONFIG_REGISTER_SELECT 0x22
#define CHIPSET_CONFIG_REGISTER_READWRITE 0x23

#define CHIPSET_CONFIG_EMS_PAGE_REGISTER_SELECT    0x20A
#define CHIPSET_CONFIG_EMS_PAGE_REGISTER_READWRITE 0x208

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


#define NUM_REGS 18

uint8_t config_regs[NUM_REGS] = 
  { 0x01, 0x40, 0x41, 0x44, 
    0x45, 0x46, 0x48, 0x49, 
	0x4A, 0x4B, 0x4C, 0x4D, 
	0x4E, 0x4F, 0x61, 0x70, 
	0x71, 0x92};

char * config_names[NUM_REGS] = {
	"DMACtrl",
	"Version",
	"Clock  ",
	"Perphrl",
	"Misc   ",
	"PwrMgmt",
	"ROM ENA",
	"RAM W/P",
	"Shadow1",
	"Shadow2",
	"Shadow3",
	"DRAMCfg",
	"ExtBnd ",
	"EMSCtrl",
	"Control",
	"RTCCMOS",
	"RTCData",
	"Sysctl "

};
 
// 7 chars per setting name.
// if it starts with a space, continuation from the last

char * setting_names_detailed[NUM_REGS * 8] = {
	"Reservd","Reservd","DMA16WT 1","@ 0    ","DMA8WT1","  0    ","D XMEMR","DClkDiv",
	"    0  ","   0   ","   0   ","   0   ","   0   ","   1   ","   0   ","  0",
	"Reservd"," QUICK ","Reservd","Reservd","Reservd"," BUSCLK","DRAMREF1,","@  0",
	"Reservd","XDVideo","XDGameP","XDSer 2","XDSer 1 ","XDParr","XD HDFD","Reservd",
	"NMIDisa","8042A20","CoprBsy","Int RTC","Reservd","Sense 2","Sense 1","Sense 0",
	"SlpEnab","AuxParD","Reservd","Reservd","CpuDiv1","CpuDiv0","SlpDiv1","SlpDiv0",
	" F8-FF "," F0-F7 "," E8-EF "," E0-E7 "," D8-DF "," D0-D7 "," C8-CF "," C0-C7 ",
	" F8-FF "," F0-F7 "," E8-EF "," E0-E7 "," D8-DF "," D0-D7 "," C8-CF "," C0-C7 ",
	" BC-BF "," B8-BB "," B4-B7 "," B0-B3 "," AC-AF "," A8-AB "," A4-A7 "," A0-A3 ",
	" DC-DF "," D8-DB "," D4-D7 "," D0-D3 "," CC-CF "," C8-CB "," C4-C7 "," C0-C3 ",
	" FC-FF "," F8-FB "," F4-F7 "," F0-F3 "," EC-EF "," E8-EB "," E4-E7 "," E0-E3 ",

	"Reservd","DRAMTmng2","@  1   ","@    0   ","DRAMCFG3","@   2   ","@    1   ","@    0",
	"RAS Enc","Reservd","Dis409F","Reservd","ExtdBnd3","@   2   ","@    1   ","@    0",
	"EMSEnab","EMS R/W","Reservd","Reservd","Reservd","Reservd","Reservd","I/O Base",
	"PARITY ","IOCHCHK","TMR2OUT","RFSHDet","CHCKDIS","PAR DIS","SpkData","TMR2Gat",
	
	"NMIDisa","RTCInd6","RTCInd5","RTCInd4","RTCInd3","RTCInd2","RTCInd1","RTCInd0",
	"RTCDat7","RTCDat6","RTCDat5","RTCDat4","RTCDat3","RTCDat2","RTCDat1","RTCDat0",
	"Reservd","Reservd","Reservd","Reservd","Reservd","Reservd","Alt A20","Alt Reset",

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
			outp(CHIPSET_CONFIG_REGISTER_SELECT, config_regs[i]);
//			printf ("%02X %s " BYTE_TO_BINARY_PATTERN" %s\n", config_regs[i], config_names[i], BYTE_TO_BINARY(value), setting_names[i]);
//			sprintf (bigstring,"%02X %s " BYTE_TO_BINARY_PATTERN"\0", config_regs[i], config_names[i], BYTE_TO_BINARY(value));

			sprintf (bigstring,"%02X\0", config_regs[i]);
			_outtext(bigstring);
			printchar(179);

			sprintf (bigstring,"%s\0", config_names[i]);
			_outtext(bigstring);
			printchar(179);
			value = inp (CHIPSET_CONFIG_REGISTER_READWRITE);

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

		_outtext ("Ad   0x209    0x208   Ad   0x209    0x208        \n");


		for (i = 0; i < 18; i++){

			outp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_SELECT, i);
			sprintf (bigstring,"%02X\0", i);
			_outtext(bigstring);

			value1 = inp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_READWRITE);
			printchar(179);
			value2 = inp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_READWRITE+1);

			fullvalue = (value2 << 8) + value1;

			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value2));
			_outtext(bigstring);
			printchar(179);
			sprintf (bigstring,BYTE_TO_BINARY_PATTERN"\0", BYTE_TO_BINARY(value1));
			_outtext(bigstring);
			printchar(179);
			

// 2nd half

			outp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_SELECT, i+18);
			sprintf (bigstring,"%02X\0", i+18);
			_outtext(bigstring);

			value1 = inp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_READWRITE);
			printchar(179);
			value2 = inp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_READWRITE+1);

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

		_outtext ("C&T SCAT configuration viewer/editor\n");
		//_outtext ("Basic configuration registers: \n");
		restart:


		if (checkparm("-ems")){
			printemsregisterdata();
			
			return 0;
		} 

		if (checkparm("-resetems")){
			int16_t i;
			int16_t baseoffset;
			for (i = 0; i < 24; i++){
				outp(CHIPSET_CONFIG_EMS_PAGE_REGISTER_SELECT, i);
				baseoffset = i * i; // delay for outp
				outpw(CHIPSET_CONFIG_EMS_PAGE_REGISTER_READWRITE, 0x03FF);
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

		// todo cleanup and put in own function?

		printstatus();
		_outtext ("Usage: M or m to modify, followed by port addr byte in hex, followed by value byte in hex. Any other key to quit.\n");
 

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

							outp(CHIPSET_CONFIG_REGISTER_SELECT, modifyport);
							delay = 325 * (keychar * keychar); // forced delay to prevent chipset crash
							outp(CHIPSET_CONFIG_REGISTER_READWRITE, modifyvalue);
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
