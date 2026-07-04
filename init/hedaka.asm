; todo: enable ems if not set in bios? dont know registers 
; initialization of registers
  mov   dx, 0208h
  mov   ax, HEDAKA_PAGE_OFFSET_AMT
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

  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], HEDAKA_CONST_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], HEDAKA_CONST_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], HEDAKA_PAGE_FRAME_COUNT

