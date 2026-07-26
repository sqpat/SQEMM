
UTIL_get_page:

; return value at page index (ax) in (ax)
  push  dx
  ror   ax, 1
  ror   ax, 1
  SELFMODIFY_NEAT_set_page_select_register_7:
  add   ax, NEAT_PAGE_REGISTER_0
  xchg  ax, dx

  xor   ah, ah
  in    al, dx

  return_page_unmapped:
  pop   dx
  ret



UTIL_set_page_reverse_arg:
; write page (ax) to page index (dx)
   xchg  ax, dx
UTIL_set_page:
public UTIL_set_page
; write page (dx) to page index (ax)


  xchg  ax, dx
  ror   dx, 1
  ror   dx, 1
  SELFMODIFY_NEAT_set_page_select_register_8:
  add dx, NEAT_PAGE_REGISTER_0

  SELFMODIFY_NEAT_add_page_offset_and_enable_4:
  add   ax, NEAT_PAGE_OFFSET_AMT

  out   dx, al   ; select EMS page



  xchg  ax, dx


  ret


UTIL_unmap_all_pages:

  push  dx
  push  ax
SELFMODIFY_NEAT_set_page_select_register_3:
  mov   dx, NEAT_PAGE_REGISTER_0
  mov   al, NEAT_CHIPSET_UNMAP_VALUE
  
  out   dx, al

  add   dh, 040h
  out   dx, al

  add   dh, 040h
  out   dx, al

  add   dh, 040h
  out   dx, al

  pop   ax
  pop   dx
  ret

; sigh. so neat maps A14-A20 on bits 0-6 of the page register.
; then a21/a22 are two bits (for each of the 4 page registers) of 8 bit chipset register 0x6E


COMMENT @

UTIL_map_NEAT_page_full:


test ax, ax
js   do_unmap

; map 9 bit AX to port DX

push cx
push dx
push ax

MOV  CX, 0FF03h
AND  CL, DL    ; use those bit before setting up page register
shl  cl, 1     ; cl has shift count

SHIFT_MACRO ror dx 2
SELFMODIFY_NEAT_set_page_select_register_7:
add  dx, NEAT_PAGE_REGISTER_0

; write first byte
shl  ax, 1     ; move bit 7-8 into bits 0-1 of ah
shr  al, 1     ; move bit 0-6 back into place
or   al, 080h  ; bit 7 = enable ems page
out  dx, al

; write last two bits via chipset reg.
mov  al, 3     ; bit mask
shl  ax, cl    ; shift both the mask (al) and actual bits (ah) at once

XOR  CH, AL    ; apply mask


shl  ah, cl    ; shift 0 2 4 or 6 
shl  ch, cl    ; bit mask
not  ch        ; reverse bit mask
mov  al, NEAT_CHIPSET_ADDRESS_EXTENSION_REGISTER  ; NEAT ems address extension register
out  NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al  ; NEAT chipset register select
in   al, NEAT_CHIPSET_CONFIG_REGISTER_READWRITE  ; read current value
and  al, ch    ; mask out previous value
or   al, ah    ; copy in new bits
out  NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al  ; NEAT chipset register set value

pop  ax
pop  dx
pop  cx
ret

do_unmap:

@

