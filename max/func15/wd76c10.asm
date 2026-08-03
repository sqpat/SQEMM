FUNCTION_15_GET_PAGE_MAP:
  push  dx

SELFMODIFY_WD76C10_add_page_frame_register_offset_4:
  mov   bx, WD76C10_PAGE_C000_REGISTER_OFFSET

  mov   cx, 4  ; page frame count


func_15_sub_00_save_next_page_frame_register:
  mov   dx, WD76C10_PAGE_SELECT_REGISTER
  mov   ax, bx
  out   dx, ax   ; select EMS page

  mov   dx, WD76C10_PAGE_SET_REGISTER
  in    ax, dx
  stosw
  inc   bx
  cmp   bx, 8
  je    func_1500_adjust_bx_skip_2000_pages
  loop  func_15_sub_00_save_next_page_frame_register
cmp bl, 32 ; catch 2nd loop thru
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

func_1500_adjust_bx_skip_2000_pages:
  add bx, 8
  loop  func_15_sub_00_save_next_page_frame_register




; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
push  dx


SELFMODIFY_WD76C10_add_page_frame_register_offset_6:
  mov   bx, WD76C10_PAGE_C000_REGISTER_OFFSET
  mov   cx, 4 ; page frame count




func_15_sub_01_save_next_page_frame_register:
  mov   dx, WD76C10_PAGE_SELECT_REGISTER
  mov   ax, bx
  out   dx, ax   ; select EMS page

  mov   dx, WD76C10_PAGE_SET_REGISTER
  lodsw
  out   dx, ax

  inc   bx
  cmp   bx, 8
  je    func_1501_adjust_bx_skip_2000_pages

  loop  func_15_sub_01_save_next_page_frame_register
cmp bl, 32
je  func_15_sub_01_done_recording_registers
mov cl, 24
xor bx, bx
jmp func_15_sub_01_save_next_page_frame_register

func_1501_adjust_bx_skip_2000_pages:
  add bx, 8
  loop  func_15_sub_01_save_next_page_frame_register
