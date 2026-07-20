; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push dx
  push cx
  push di
  push si
  
SELFMODIFY_SCAT_set_page_select_register_7:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
SELFMODIFY_SCAT_set_page_frame_register_offset_5:
  mov   bl, 0 


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
  call  COMMON_util_get_physical_register_for_segment
  ;cmp   al, SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  ;jae   func_16_do_conventional_map
  ;add   al, bl
  func_16_do_conventional_map:
  out   dx, al   ; select EMS page
  stosw 

  dec   dx
  dec   dx
  in    ax, dx
  stosw
  inc   dx
  inc   dx

  loop  func_16_sub_00_save_next_page_frame_register

func_16_sub_00_done_recording_registers:
func_16_sub_01_done_recording_registers:
  xchg  ax, cx  ; zero ax

func_16_pop_and_return:
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax
  pop   ax
  xor   ah, ah

iret

not_func_16_sub_00:
cmp   byte ptr cs:[_current_call_subfunction_value], 2
ja    func_16_bad_subfunction
; fall thru

func_16_sub_02:
;          GET SIZE OF PARTIAL PAGE MAP SAVE ARRAY SUBFUNCTION
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax

  pop   ax
  xor   ah, ah
  mov  al, bl ; num pages

  SHIFT_MACRO shl  al 2 ; two words per entry.
  add  al, 2  ; count
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
  pop   si
  pop   di
  pop   cx
  pop   dx
  pop   bx ; restore from ax
  pop   ax

  mov        ah, 084h
  iret


