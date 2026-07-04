
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

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], HT18_PAGE_FRAME_COUNT
