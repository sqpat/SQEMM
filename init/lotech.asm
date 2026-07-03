
  mov   dx, LOTECH_PAGE_REGISTER_0
  mov   ax, 000h 
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count+1], LOTECH_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_handle_count+1], 01h