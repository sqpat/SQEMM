





FUNCTION_15_GET_PAGE_MAP:



SELFMODIFY_SCAMP_add_page_frame_offset_8:
  mov   bl, 4

  mov   cx, 4  ; page frame count


func_15_sub_00_save_next_page_frame_register:
  mov   ax, bx
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page

  in    ax, SCAMP_PAGE_SET_REGISTER
  stosw
  inc   bx
  loop  func_15_sub_00_save_next_page_frame_register
cmp bl, (DEFAULT_CONVENTIONAL_PAGE_COUNT + SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000) ; catch 2nd loop

je  func_15_sub_00_done_recording_registers
mov cl, DEFAULT_CONVENTIONAL_PAGE_COUNT
mov bl, SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000
jmp func_15_sub_00_save_next_page_frame_register




func_15_sub_00_done_recording_registers:
func_15_sub_01_done_recording_registers:

xchg  ax, cx  ; zero out ah for ret

ret

FUNCTION_15_SAVE_PAGE_MAP:

SELFMODIFY_SCAMP_add_page_frame_offset_9:
  mov   bl, 4
  mov   cx, 4  ; page frame count


func_15_sub_01_save_next_page_frame_register:
  mov   ax, bx
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page

  lodsw
  out   SCAMP_PAGE_SET_REGISTER, ax

  inc   bx
  loop  func_15_sub_01_save_next_page_frame_register
cmp bl, (DEFAULT_CONVENTIONAL_PAGE_COUNT + SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000) ; catch 2nd loop

je  func_15_sub_01_done_recording_registers
mov cl, DEFAULT_CONVENTIONAL_PAGE_COUNT
mov bl, SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000
jmp func_15_sub_01_save_next_page_frame_register

