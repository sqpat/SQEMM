
; enable writes to registers...
  mov al, HT18_EMS_CONFIG_REGISTER
  mov dx, HT18_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al
  mov dx, HT18_CHIPSET_CONFIG_REGISTER_READWRITE
  in al, dx
  or al, 02h                                        ; enable EMS flag on
  out dx, al

  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  mov   word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count], MAX_PAGE_COUNT
  mov   word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], MAX_PAGE_COUNT
  mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], PAGE_FRAME_COUNT ; todo... should we decrease based on stuff like ROMS etc?

