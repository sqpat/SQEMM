 
  
  ; al and bx are still the args

  ; 88h + 2*ax
  mov  ah, SARC_RC2016_PAGE_REGISTER_0
  add  ah, al
  add  ah, al

  xchg ah, al
 

  cli
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  inc  al     
  xchg ah, al  

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h


  add  al, 0C4h ; pages 0-4 map to d000-dc000


  ; ah is now the next port to write to.
  ; al contains bits 0-3 (d000  page frame target)
  ;    and bits 6-7 (conventional mapping)
  ;    needs bits 4-5 (bits 1-2 of bx)

  mov ah, bl
  and ah, 03h
  sal ah, 4
  add al, ah

  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  and al, 03

  sal al, 1
  add al, SARC_RC2016_PAGE_REGISTER_0 + 1
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  mov ax, bx
  sar ax, 2
  add al, SARC_RC2016_PAGE_OFFSET_AMT
  out SARC_RC2016_CHIPSET_VALUE_PORT, al
  sti

  xor   ax, ax  
  iret

  handle_default_page_44h:
  ; mapping to page -1

  mov   al, 00h
  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  xchg ah, al


  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  
  xor   ax, ax

  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  sti

  iret

