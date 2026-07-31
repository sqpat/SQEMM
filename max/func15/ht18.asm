FUNCTION_15_GET_PAGE_MAP:
  push  dx

  mov   dx, HT18_PAGE_SELECT_REGISTER
SELFMODIFY_HT18_add_page_frame_register_offset_4:
  mov   bl, HT18_PAGE_C000_REGISTER_OFFSET

  mov   cx, 4  ; page frame count


func_15_sub_00_save_next_page_frame_register:
  mov   ax, bx
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  in    ax, dx
  stosw
  inc   dx
  inc   dx
  inc   bx
  loop  func_15_sub_00_save_next_page_frame_register
cmp bl, 24 ; catch 2nd loop thru
je  func_15_sub_00_done_recording_registers
mov cl, 24
xor bx, bx
jmp func_15_sub_00_save_next_page_frame_register


func_15_sub_00_done_recording_registers:
func_15_sub_01_done_recording_registers:

SELFMODIFY_func_15_return:
  xchg  ax, cx  ; zero out ah for ret

  pop   dx
  ret



; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
push  dx
mov   dx, HT18_PAGE_SELECT_REGISTER

SELFMODIFY_HT18_add_page_frame_register_offset_6:
  mov   bl, HT18_PAGE_C000_REGISTER_OFFSET
  mov   cx, 4 ; page frame count




func_15_sub_01_save_next_page_frame_register:
  mov   ax, bx
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  lodsw
  out   dx, ax

  inc   dx
  inc   dx
  inc   bx
  loop  func_15_sub_01_save_next_page_frame_register
cmp bl, 24
je  func_15_sub_01_done_recording_registers
mov cl, 24
xor bx, bx
jmp func_15_sub_01_save_next_page_frame_register

