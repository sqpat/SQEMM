
  ; lets set default values for the conventional registers...

  mov   dx, INTEL_AB_ENABLE_REGISTER
  ; todo not sure how this really works. sometimes needs 40, sometimes 80?
  mov   al, 0C0h
  out   dx, al

; todo INC and constants

; manually remap memory... 
; intel above board sets up with:
; 0x4000 = 0x10  0x4400 = 0x11   0x4800 = 0x12   0x4C00 = 0x13
; 0x5000 = 0x14  0x5400 = 0x15   0x5800 = 0x16   0x5C00 = 0x17
; 0x6000 = 0x18  0x6400 = 0x19   0x6800 = 0x1A   0x6C00 = 0x1B
; 0x7000 = 0x1C  0x7400 = 0x1D   0x7800 = 0x1E   0x7C00 = 0x1F
; 0x8000 = 0x00  0x8400 = 0x01   0x8800 = 0x02   0x8C00 = 0x03
; 0x9000 = 0x04  0x9400 = 0x05   0x9800 = 0x06   0x9C00 = 0x07

; observe gap of 0x8-0xF
; in theory we should sti/cli and memcpy but lets assume nothing important is in 6000-8000
  cli
  mov   al, 090h
  mov   dx, INTEL_AB_4000_REGISTER ; 00240h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 091h
  mov   dx, 04240h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 092h
  mov   dx, 08240h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 093h
  mov   dx, 0C240h
  out   dx, al   ; write 8 bit page num. 

  mov   al, 094h
  mov   dx, 00241h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 095h
  mov   dx, 04241h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 096h
  mov   dx, 08241h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 097h
  mov   dx, 0C241h
  out   dx, al   ; write 8 bit page num. 

  mov   al, 098h
  mov   dx, 00242h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 099h
  mov   dx, 04242h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 09Ah
  mov   dx, 08242h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 09Bh
  mov   dx, 0C242h
  out   dx, al   ; write 8 bit page num. 


  mov   al, 09Ch
  mov   dx, 00243h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 09Dh
  mov   dx, 04243h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 09Eh
  mov   dx, 08243h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 09Fh
  mov   dx, 0C243h
  out   dx, al   ; write 8 bit page num. 


  mov   al, 080h
  mov   dx, 00244h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 081h
  mov   dx, 04244h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 082h
  mov   dx, 08244h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 083h
  mov   dx, 0C244h
  out   dx, al   ; write 8 bit page num. 

  mov   al, 084h
  mov   dx, 00245h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 085h
  mov   dx, 04245h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 086h
  mov   dx, 08245h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 087h
  mov   dx, 0C245h
  out   dx, al   ; write 8 bit page num. 

COMMENT @
; enable upper pages code
  mov   al, 08Ch
  mov   dx, 00247h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 08Dh
  mov   dx, 04247h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 08Eh
  mov   dx, 08247h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 08Fh
  mov   dx, 0C247h
  out   dx, al   ; write 8 bit page num. 



  mov   al, 08Ch
  mov   dx, 00248h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 08Dh
  mov   dx, 04248h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 08Eh
  mov   dx, 08248h
  out   dx, al   ; write 8 bit page num. 
  mov   al, 08Fh
  mov   dx, 0C248h
  out   dx, al   ; write 8 bit page num. 

  mov   ah, 6
  mov   al, 090h
  mov   dx, INTEL_AB_4000_REGISTER
  backfillouterloop:
  mov   cx, 4
  cmp   al, 0A0h
  jne   enablebackfillloop
  mov   al, 080h

  enablebackfillloop:
  out   dx, al
  inc   al
  add   dx, 4000h
  loop enablebackfillloop
  sub   dx, 0C001h   
  sub   ah, 1
  jne   backfillouterloop
@

  sti


  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 128 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], INTEL_AB_CONST_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], INTEL_AB_CONST_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], INTEL_AB_PAGE_FRAME_COUNT

