
  ; enable d000 register and backfill


  ; first lets get system memory (which may be needed in a few spots.)
  out   0FBh, al  ; dummy write enable
  mov   al, 2  ; SLOT POINTER
  out   SCAMP_CHIPSET_INDEX_REGISTER, al
  in    al, SCAMP_CHIPSET_READWRITE_REGISTER

  xchg  ax, dx

  mov   al, 3  ; RAMMAP
  out   SCAMP_CHIPSET_INDEX_REGISTER, al
  in    al, SCAMP_CHIPSET_READWRITE_REGISTER
  mov   ah, al
  and   al, 0Fh  ; MEMMAP0-MEMMAP3 ; al = A16-A23 of top of memory 

  mov   bx, OFFSET _SCAMP_DRAM_BANK_LOOKUP
  xlat  byte ptr ds:[bx]

  xor   ah, ah
  inc   ax     ; todo necessary...?
  xor   dh, dh

  
  sub   ax, dx
  jbe   scamp_memory_error  ; shouldnt happen? might if RAMMAP is a weird config.
  ; dl = slot pointer (top of XMS/page offset in 64k blocks)
  ; al = amount of ems memory (in 64k blocks)
  ; bl = top of memory. technically 384k extra is available too.

  SHIFT_MACRO shl dx 2   ; offset, 16k to 64k blocks
  mov   word ptr ds:[chipset_page_offset], dx
  SHIFT_MACRO shl ax 2   ; num ems pages
  
  ; test  ah, 010h         ; todo test for relocation?
  ;add  ax, 24            ; lets not include 384k relocated ram.

  mov  word ptr ds:[chipset_num_pages], ax

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
  mov   ax, word ptr ds:[_INIT_PARAM_PAGEFRAME_ARG]
  test  ax, ax
  jnz   use_parsed_page_frame
  mov   ax, 0100h            ; corresponds to 0D000h
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_default_parameter
  jmp   use_parsed_page_frame

scamp_memory_error:  ; make room for this here with jmp above
  mov  DX, OFFSET STRING_bad_memory_chipset
  jmp  DRIVER_NOT_INSTALLED
  

use_parsed_page_frame:

  ; ah is 0 1 or 2    (C D or E)
  ; al is 0 4 8 or 12


  mov   bx, ax
  SHIFT_MACRO  shl bh 2
  SHIFT_MACRO  shr bl 2
  or    bl, bh
  
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_1+1], bl
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_2+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_3+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_4+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_5+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_6+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_8+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_9+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_10+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_11+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_12+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_13+1], bl 
  mov   byte ptr ds:[SELFMODIFY_SCAMP_add_page_frame_offset_14+1], bl 

  SHIFT_MACRO   shl ah 4  ; 0 1 2 to 00 10 20  (C D E)
  or    al, ah


  add   al, 0C0h
  mov   byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2], al 

  mov   ah, al
  xor   al, al

  stc   ; hex print
  mov   di, OFFSET string_good_page_frame_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_frame_param
  call  print_driver_param

  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

  mov   ax, word ptr ds:[_INIT_PARAM_OFFSET_ARG]
  test  ax, ax
  jnz   use_parsed_offset

  mov   ax, word ptr ds:[chipset_page_offset]
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter

use_parsed_offset:

  mov   word ptr ds:[_INIT_PARAM_OFFSET], ax



  push  ax ; 44h
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_6+1], ax
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_7+1], ax
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_8+1], ax

  dec   ax  ; 44h - 1
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_1+2], ax  ; minus ones
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_2+2], ax
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_3+2], ax
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_4+2], ax

  sub   ax, 3 ; 40h
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_minus4_4+1], ax ; minus 4
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_minus4_5+1], ax

  dec   ax  ; 40h - 1
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_minus4_6+1], ax

  sub   ax, 3 ; 40h - SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT  (40h - 4)
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_minus4_1+1], ax
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_minus4_2+1], ax
  mov   word ptr ds:[SELFMODIFY_SCAMP_add_page_offset_minus4_3+1], ax

  
  add   ax, 8 ; 44h

  mov   di, OFFSET string_good_page_offset_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_offset_param
  call  print_driver_param_4_char_int



  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter

  mov   ax, word ptr ds:[_INIT_PARAM_PAGECOUNT_ARG]
  test  ax, ax
  jnz   use_parsed_pagecount

  mov   ax, word ptr ds:[chipset_num_pages]
  mov   word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_chipset_parameter

use_parsed_pagecount:


  cmp   ax, MAX_PAGE_COUNT
  jbe   page_count_bounds_ok

  mov  DX, OFFSET string_bad_page_count_param
  jmp  DRIVER_NOT_INSTALLED

page_count_bounds_ok:
  
  pop   dx
  ; ax is pages, dx is offset.


  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], ax
  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], ax ;  we don't subtract, because this chipset does not include backfill in its total memory count i guess.



  mov   di, OFFSET string_good_page_count_param_EDIT_OFFSET
  mov   dx, OFFSET string_good_page_count_param
  call  print_driver_param_4_char_int


  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?


; Program the registers now.



  ; pre-enit these. they seem to crash (emulator at least) otherwise?
  mov   cx, 4
  mov   dx, word ptr ds:[_INIT_PARAM_OFFSET]

loop_init_page_registers:
    SELFMODIFY_SCAMP_add_page_frame_offset_11:
    mov   al, 4
    add   al, 4
    sub   al, cl
    out   SCAMP_PAGE_SELECT_REGISTER, al
    
    cbw
    add   ax, dx
    out   SCAMP_PAGE_SET_REGISTER, ax
    loop  loop_init_page_registers

      ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ;  4-28 to be 4-28

  mov   ax, 0Ch
  mov   cl, 18h  ; 24 registers, 0C to 23

  ; 0c maps to 10, 
  ; 0d maps to 11, 
  ; ...
  ; 23 maps to 27

enablebackfillloop:
  out   SCAMP_PAGE_SELECT_REGISTER, al
  add   ax, SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT
  xchg  ax, ax ; delay
  xchg  ax, ax
  out   SCAMP_PAGE_SET_REGISTER, ax
  sub   ax, 3       ; inc included..
  loop enablebackfillloop

  xor   bx, bx
  mov   bl, byte ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+2] ; get page frame.
  sub   bl, 0C0h
  mov   dx, bx
  shr   bx, 1  ; word lookup.
  mov   cx, bx
  mov   bx, word ptr ds:[bx + _SCAMP_EMS_INIT_REGISTERS]

  mov   al, 0Bh
  out   SCAMP_CHIPSET_INDEX_REGISTER, al
  mov   al, bh   ; turn on ems, backfill, possibly enable some registers.
  out   SCAMP_CHIPSET_READWRITE_REGISTER, al
  

  mov   al, 0Ch
  out   SCAMP_CHIPSET_INDEX_REGISTER, al
  xchg  ax, bx ; possibly enable some pages
  out   SCAMP_CHIPSET_READWRITE_REGISTER, al

