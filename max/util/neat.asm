
UTIL_get_page:

UTIL_map_NEAT_read_page_full:

; return value at page index (ax) in (ax)
; read page ax
  push  cx
  push  dx

  cwd   ; zero dx. get ah zero for free later.

  mov  cl, 3
  AND  CL, AL    ; use those bit before setting up page register
  shl  cl, 1     ; cl has shift count

  SHIFT_MACRO ror ax 2

  SELFMODIFY_NEAT_set_page_select_register_4:
  add   ax, NEAT_PAGE_REGISTER_0

  xchg  ax, dx  ; ax 0
  in    al, dx  ; ah 0
  pop   dx
  shl   al, 1   ; bits 0-6 now 1-7
  jnc   return_unmapped  ; bit 7 was off, so unmapped.
  mov   ah, al
  mov   al, NEAT_CHIPSET_ADDRESS_EXTENSION_REGISTER
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al  ; NEAT chipset register select
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE  ; read current value


  shr  al, cl  ; al bits 0/1 now a21/a22
  xchg al, ah
  shr  ax, 1   ; bits 1-7 back to 0-6 in al. ah 0-1 carries int ax 7-8
  SELFMODIFY_NEAT_sub_page_offset:
  sub  ax, NEAT_PAGE_OFFSET_AMT
  and  ax, 01FFh  ; max page index, clear out other ah bits possibly still present.
  pop  cx
  ret


  return_unmapped:
  mov  ax, -1
  pop  cx
  ret


; clobber dx ok i think
UTIL_set_page:
public UTIL_set_page



xchg  ax, dx
; fall thru.

UTIL_map_NEAT_write_page_full:


; write page (dx) to page index (ax)


  inc  ax
  jz   do_unmap
  dec  ax
  push ax

  SELFMODIFY_NEAT_add_page_offset:
  add   ax, NEAT_PAGE_OFFSET_AMT 


  ; map 9 bit AX to port DX

  push cx
  push dx

  MOV  CX, 0FF03h  ; mask bits..
  AND  CL, DL    ; use those bit before setting up page register
  shl  cl, 1     ; cl has shift count

  SHIFT_MACRO ror dx 2
  SELFMODIFY_NEAT_set_page_select_register_2:
  add  dx, NEAT_PAGE_REGISTER_0

  ; write first byte
  shl  ax, 1     ; move bit 7-8 into bits 0-1 of ah
  shr  al, 1     ; move bit 0-6 back into place
  or   al, NEAT_PAGE_ENABLE_FLAG  ; bit 7 = enable ems page
  out  dx, al

  ; write last two bits via chipset reg.
  mov  al, 3     ; bit mask
  shl  ax, cl    ; shift both the mask (al) and actual bits (ah) at once

  XOR  CH, AL    ; apply mask

  mov  al, NEAT_CHIPSET_ADDRESS_EXTENSION_REGISTER  ; NEAT ems address extension register
  out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al  ; NEAT chipset register select
  in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE  ; read current value
  and  al, ch    ; mask out previous value
  or   al, ah    ; copy in new bits
  out  NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al  ; NEAT chipset register set value

  pop  dx
  pop  cx
  pop  ax
  ret

  do_unmap:

  ; i guess we dont touch the other reg? not sure...

  push dx

  SHIFT_MACRO ror dx 2
  SELFMODIFY_NEAT_set_page_select_register_1:
  add  dx, NEAT_PAGE_REGISTER_0
  out  dx, al  ; zero; unmap
  dec  ax      ; restore ax
  pop  dx  ; restore dx
  ret



UTIL_unmap_all_pages:

  push  dx
  push  ax
SELFMODIFY_NEAT_set_page_select_register_3:
  mov   dx, NEAT_PAGE_REGISTER_0
  xor   ax, ax
  
  out   dx, al

  mov   dh, 042h
  out   dx, al

  mov   dh, 082h
  out   dx, al

  mov   dh, 0C2h
  out   dx, al

  pop   ax
  pop   dx
  ret

; sigh. so neat maps A14-A20 on bits 0-6 of the page register.
; then a21/a22 are two bits (for each of the 4 page registers) of 8 bit chipset register 0x6E


