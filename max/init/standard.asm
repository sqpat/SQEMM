

  ; page frame d000 for now
  ; todo parse
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; todo parse port

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], STANDARD_BOARD_CONST_PAGE_COUNT

