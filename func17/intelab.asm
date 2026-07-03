  push cx
  push si
  push dx

  ; physical page number mode
  cli
  DO_NEXT_PAGE_5000:
  ; next page in ax....

  lodsw

 ; 0: 240, 1: 4240, 2: 8240, 3: C240...
 ; 4: 241, 5: 4241, 6: 8241, 7: C241...
 ; 8: 242, 9: 4242, A: 8242, B: C242...

  ; get port number

  mov  dx, ax
  lodsw

  cmp   dx, 0FFFFh   ; -1 check
  je    handle_default_page

  ror  ax, 1
  ror  ax, 1
  add  ax, INTEL_AB_4000_REGISTER

  xchg  ax, dx
  add   al, INTEL_AB_PAGE_OFFSET_AMT
  jnc   intel_ab_not_overflow
  add   al, 088h  ; page ON 080h + 8 to get gap pages
  intel_ab_not_overflow:
  out   dx, al   ; write 8 bit page num. 

  loop       DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret


  handle_default_page:
  ; mapping to page -1
  ; get the value again
  
  mov   dx, ax

  ror  ax, 1
  ror  ax, 1
  add  ax, INTEL_AB_4000_REGISTER
  xchg dx, ax


  cmp   al, 010h
  jae   gte_8000
  add   al, 90h

  out   dx, al   ; write 8 bit page num. 
  loop  DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

  gte_8000:

  add   al, 070h
  out   dx, al   ; write 8 bit page num. 
  loop  DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

COMMENT @

  ; need SI for indexing. Swap with ax for safekeeping
  xchg  ax, si
  ; load zero page for this page
  
  mov  dl, byte ptr ds:[default_page_struct + si]
  xchg  ax, si  ; put si back. ax has page index still
  xchg  ax, dx  ; now ax gets page value

  ; create dx port

  ; TODO does not handle E000 properly yet...


  out   dx, al   ; write 8 bit page num. 
  loop  DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

@ 
