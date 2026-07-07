; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push dx
  push cx
  push di
  push si
  
SELFMODIFY_SCAT_set_page_select_register_6:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
SELFMODIFY_SCAT_add_page_frame_register_offset_4:
  mov   bl, SCAT_PAGE_C000_REGISTER_OFFSET

  mov   cx, 4  ; page frame count


  cmp   byte ptr cs:[_current_call_subfunction_value], 1
  je    func_15_sub_01
  ja    not_func_15_sub_00

func_15_sub_00:
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
cmp bx, 24 ; catch 2nd loop thru
je  func_15_sub_00_done_recording_registers
mov cx, 24
xor bx, bx
jmp func_15_sub_00_save_next_page_frame_register

func_15_sub_03:
;          GET SIZE OF PAGE MAP SAVE ARRAY SUBFUNCTION
mov  cx, (2 * LENGTH_OF_STACK)
; fall thru

func_15_sub_00_done_recording_registers:
func_15_sub_01_done_recording_registers:

SELFMODIFY_func_15_return:
  xchg  ax, cx  ; zero out ah for ret
func_15_pop_and_return:
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax


iret
func_15_bad_subfunction:
mov        ah, 084h
jmp   func_15_pop_and_return

not_func_15_sub_00:
cmp   byte ptr cs:[_current_call_subfunction_value], 3
ja    func_15_bad_subfunction
je    func_15_sub_03
; fall thru
func_15_sub_02:

XCHG_AX_CX_OPCODE = 091h
 ; combination of function 00 and function 01. Self modify and run them.
 mov     byte ptr cs:[SELFMODIFY_func_15_return], RET_OPCODE
 call    func_15_sub_00
 mov     byte ptr cs:[SELFMODIFY_func_15_return], XCHG_AX_CX_OPCODE

SELFMODIFY_SCAT_add_page_frame_register_offset_6:
  mov   bl, SCAT_PAGE_C000_REGISTER_OFFSET

; fall thru and run this one


func_15_sub_01:

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
cmp bx, 24
je  func_15_sub_01_done_recording_registers
mov cx, 24
xor bx, bx
jmp func_15_sub_01_save_next_page_frame_register

