  push cx
  push si
  push dx

  ; physical page number mode
  cli
  func1701_loop_next_page:
  ; next page in ax....

  lodsw
  mov  dx, ax
  lodsw

  call util_get_register_for_segment

  cmp dx, 0FFFFh
  je    func17_01_handle_default_page

  mov ah, al
  sal al, 1
  add al, SARC_RC2016_PAGE_REGISTER_0

  out  SARC_RC2016_CHIPSET_INDEX_PORT, al

  
  mov al, ah 

  add  al, 0C4h ; pages 0-4 map to d000-dc000

  mov ah, dl
  and ah, 03h
  sal ah, 4
  add al, ah

  out  SARC_RC2016_CHIPSET_VALUE_PORT, al

  and al, 03h  ; restore page number
  sal al, 1
  add al, SARC_RC2016_PAGE_REGISTER_0 + 1

  out SARC_RC2016_CHIPSET_INDEX_PORT, al
  mov ax, dx
  sar ax, 2
  add ax, SARC_RC2016_PAGE_OFFSET_AMT
  out SARC_RC2016_CHIPSET_VALUE_PORT, al
 

  loop       func1701_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

    func17_01_handle_default_page:
  ; mapping to page -1
  ; dx is scratch, ax is page

  mov dx, ax
  add dx, SARC_RC2016_PAGE_REGISTER_0
  add dx, ax
  xchg dx, ax
  ; select page register
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  inc  ax     ; dx has next register
  xchg dx, ax
  mov   al, 0h
  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  xchg dx, ax
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  xor ax, ax
  out  SARC_RC2016_CHIPSET_VALUE_PORT, al


  loop       func1701_loop_next_page
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret
