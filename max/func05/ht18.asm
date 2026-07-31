
  ; note: HT18 maps 0-4 not to the page frame but rather to 4000-4c00
  ; which is unfortunate. its not really backward compatible with 0-3 = page frame 3.2 style programming...
  ; for now in sqemm, call 44h (a 3.2 call) will map 0-4 to the page frame and ignore backfill register addresses.



; note: bx on stack

  
  ; al and bx are still the args
  push  ax   ; gross, need to store al.
  push  dx  
 
  mov   dx, HT18_PAGE_SELECT_REGISTER
  sub   al, HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   func_05_do_conventional_map
  SELFMODIFY_HT18_add_page_frame_register_offset_1:
  add   al, HT18_PAGE_C000_REGISTER_OFFSET + HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA ; convert 0-4 to page frame. adds back subtracted 04h too
  func_05_do_conventional_map:   ; conventional page should be good.

  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  inc   bx    ; -1 check
  jz    handle_default_page_44h
  
SELFMODIFY_HT18_add_page_offset_2_minus_1:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  
  HT18_ENABLE_ON_MACRO
  
  out   dx, ax   ; write 16 bit page num. 

  
  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah

  iret


  handle_default_page_44h:
  ; mapping to page -1
  xchg  ax, bx  ; zero
  out   dx, ax   ; write 16 bit page num. 

  
  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah
  iret

