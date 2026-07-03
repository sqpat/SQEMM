
  ; for porting to other chipsets, prepare chipset registers
  ; and driver variables here. In this case we set page frame
  ; to D000, set 36 mappable pages, we are only allowing a
  ; single handle, and set 256 mappable pages. we also prepare
  ; ems registers to initial values and enable EMS and backfill.


  ; hard coded to d000 for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_total_EMS_page_count+1], PAGE_COUNT_4_MB
  mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count+1], SCAMP_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr ds:[_RESIDENT_VARIABLE_handle_count+1], 01h


  ; enable d000 register and backfill

  mov        al, 0Bh
  out        0ECh, al
  mul        al  ; delay
  ;mov        al, 0A0h   ; turn on ems 
  mov        al, 0E0h   ; turn on ems, backfill
  out        0EDh, al


  mov        al, 0Ch
  out        0ECh, al
  mul        al  ; delay
  mov        al, 0F0h  ; turn on d000 as page frame
  out        0EDh, al

  ; set first four page registers for d000
  xor   cx, cx
  mov   cl, 4h  ; 24 registers, 0C to 23
  mov   ax, 4

  enablepageloop:
  out   SCAMP_PAGE_SELECT_REGISTER, al
  sub   ax, 4
  xchg  ax, ax
  xchg  ax, ax
  out   SCAMP_PAGE_SET_REGISTER, ax
  add   ax, 5         ; inc included..
  loop enablepageloop


  ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ;  4-28 to be 4-28

  mov   ax, 0Ch
  mov   cl, 18h  ; 24 registers, 0C to 23

  ; 0c maps to 10, 
  ; 0d maps to 11, 
  ; ...
  ; 23 maps to 27

  enablebackfillloop:
  out   SCAMP_PAGE_SELECT_REGISTER, al
  add   ax, 4
  xchg  ax, ax
  xchg  ax, ax
  out   SCAMP_PAGE_SET_REGISTER, ax
  sub   ax, 3       ; inc included..
  loop enablebackfillloop

  ; note: we must treat 'set page to default/-1' case as these values
  ; and we must offset every page set offset by 28h otherwise to avoid these defaults.