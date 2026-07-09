; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push cx
  push di
  push es
  push cs
  pop  es
  mov  di, OFFSET page_frame_stack
  mov  cx, 4
  
SELFMODIFY_FANTASY_add_page_frame_offset_6:
  mov   bl, 4

save_next_register:
  mov   ax, bx

  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  in    ax, FANTASY_PAGE_SET_REGISTER
  stosw

  inc   bx
  loop  save_next_register

  xchg  ax, cx  ; zero out ah for ret
  pop   es
  pop   di
  pop   cx
  pop   bx ; restore from ax


iret