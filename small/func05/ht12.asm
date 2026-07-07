 
  
  ; al and bx are still the args

  push cx
  push dx


  mov cx, ax  ; page number

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  mov ax, HT12_EMS_CONFIG_REGISTER
  cli
  out dx, al
  
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  in  al, dx   ; read in the port. we are going to AND the page on...
  mov dl, 1
  sal dl, cl ; get the bit for the page

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  or  al, dl  ; page is turned on
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page has been turned on (in case it was off)

  mov ax, cx
  add al, HT12_PAGE_REGISTER_0  ; add by page 0 offset
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al    ; select page

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  mov ax, bx
  add al, HT12_PAGE_OFFSET_AMT
  out dx, al ; write page
  sti

  pop dx
  pop cx
  xor ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  ; if we turn off the page then we must update the page bit...


  ; turn off the page
  not dx
  and al, dl   ; turn off page bit
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE

  out dx, al  ; page is now turned off
  sti

  pop dx
  pop cx
  xor ax, ax
  iret

