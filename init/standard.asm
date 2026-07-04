
; offset pages by 2 MB

  mov   dx, STANDARD_BOARD_PAGE_REGISTER_0
  mov   ax, STANDARD_BOARD_PAGE_OFFSET_AMT
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; page frame d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], STANDARD_BOARD_CONST_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], STANDARD_BOARD_CONST_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], STANDARD_BOARD_PAGE_FRAME_COUNT

