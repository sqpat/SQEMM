; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push cx
  push di
  push si
  


SELFMODIFY_FANTASY_add_page_frame_offset_8:
  mov   bl, 4

  mov   cx, 4  ; page frame count


  cmp   byte ptr cs:[_current_call_subfunction_value], 1
  je    func_15_sub_01
  ja    not_func_15_sub_00

func_15_sub_00:
func_15_sub_00_save_next_page_frame_register:
  mov   ax, bx
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page

  in    ax, FANTASY_PAGE_SET_REGISTER
  stosw
  inc   bx
  loop  func_15_sub_00_save_next_page_frame_register
cmp bl, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_COUNT + FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000) ; catch 2nd loop

je  func_15_sub_00_done_recording_registers
mov cl, FANTASY_CHIPSET_CONVENTIONAL_PAGE_COUNT
mov bl, FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000
jmp func_15_sub_00_save_next_page_frame_register

func_15_sub_03:
;          GET SIZE OF PAGE MAP SAVE ARRAY SUBFUNCTION
mov  cx, LENGTH_OF_STACK
; fall thru

func_15_sub_00_done_recording_registers:
func_15_sub_01_done_recording_registers:

SELFMODIFY_func_15_return:
  xchg  ax, cx  ; zero out ah for ret
func_15_pop_and_return:
  pop   si
  pop   di
  pop   cx
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

 ; combination of function 00 and function 01. Self modify and run them.
 mov     byte ptr cs:[SELFMODIFY_func_15_return], RET_OPCODE
 call    func_15_sub_00
 mov     byte ptr cs:[SELFMODIFY_func_15_return], XCHG_AX_CX_OPCODE
 mov      cl, 4 ; page frame count
SELFMODIFY_FANTASY_add_page_frame_offset_9:
  mov   bl, 4

; fall thru and run this one


func_15_sub_01:

func_15_sub_01_save_next_page_frame_register:
  mov   ax, bx
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page

  lodsw
  out   FANTASY_PAGE_SET_REGISTER, ax

  inc   bx
  loop  func_15_sub_01_save_next_page_frame_register
cmp bl, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_COUNT + FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000) ; catch 2nd loop

je  func_15_sub_01_done_recording_registers
mov cl, FANTASY_CHIPSET_CONVENTIONAL_PAGE_COUNT
mov bl, FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000
jmp func_15_sub_01_save_next_page_frame_register

