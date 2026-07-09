; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push dx
  push cx
  push di
  push si
  
SELFMODIFY_SCAT_set_page_select_register_7:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
SELFMODIFY_SCAT_add_page_frame_register_offset_5:
  mov   bl, SCAT_PAGE_C000_REGISTER_OFFSET ; includes 0Ch


  cmp   byte ptr cs:[_current_call_subfunction_value], 1
  je    func_16_sub_01
  ja    not_func_16_sub_00

func_16_sub_00:

; ds:si format
; partial_page_map_struct     STRUC
;             mappable_segment_count   DW  ?
;             mappable_segment         DW  (?)  DUP  (?)
;          partial_page_map_struct     ENDS


  lodsw
  stosw        ; count
  xchg  ax, cx ; count

func_16_sub_00_save_next_page_frame_register:
  lodsw
  ; ax has segment... 
  call  util_get_register_for_segment
  sub   al, SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   func_16_do_conventional_map
  add   al, bl
  func_16_do_conventional_map:
  out   dx, al   ; select EMS page
  stosw 

  dec   dx
  dec   dx
  in    ax, dx
  stosw
  inc   dx
  inc   dx
  inc   bx
  loop  func_16_sub_00_save_next_page_frame_register
  jmp  func_16_sub_00_done_recording_registers

not_func_16_sub_00:
cmp   byte ptr cs:[_current_call_subfunction_value], 2
ja    func_16_bad_subfunction
; fall thru

func_16_sub_02:
;          GET SIZE OF PARTIAL PAGE MAP SAVE ARRAY SUBFUNCTION

mov  ax, bx ; num pages
SHIFT_MACRO shl  ax 2 ; two words per entry.
add  ax, 2  ; count
; fall thru

func_16_sub_00_done_recording_registers:
func_16_sub_01_done_recording_registers:

func_16_pop_and_return:
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax


iret


func_16_sub_01:
  lodsw
  xchg ax, cx  ; count
func_16_sub_01_save_next_page_frame_register:
  lodsw
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  lodsw
  out   dx, ax

  inc   dx
  inc   dx
  loop  func_16_sub_01_save_next_page_frame_register
jmp func_16_sub_01_done_recording_registers


func_16_bad_subfunction:
mov        ah, 084h
jmp   func_16_pop_and_return


