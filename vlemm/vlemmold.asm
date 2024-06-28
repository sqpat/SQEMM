0x28F0:
2020 2020 2020 2020 3E2B 412B 492B 562B 102C 752C EF2C F42C 262D 572D 5A2D 5D2D 682D 7B2D A02D DD2D 6F2E 142F 1530 4E30 C630 5431 9631 6132 9337 D237 0F38 1C38 F938 4639


;0x2749
 ; some 3 byte struct arrary related to the ems page registers
 ; byte 0:
 ; byte 1:
 ; byte 2: ems register



;0x2879: 
  ;some word offset used for

; 0x2887
  ; some word result - stores calculated offset  from 2879



; 0x28F8: Function pointer table

0x28F8:
dw3E2B 412B 492B 562B 102C 752C EF2C F42C 262D 572D 5A2D 5D2D 682D 7B2D A02D DD2D 6F2E 142F 1530 4E30 C630 5431 9631 6132 9337 D237 0F38 1C38 F938 4639 50B8 070E CD10 58C3 5053 5281 FAFF 0077 1DB8 1700 F7E2 2E03 0679 288B D82E

; BEEP function
BEEP:
0x2934:  50          push ax
0x2935:  B8 07 0E    mov  ax, 0xe07
0x2938:  CD 10       int  0x10
0x293a:  58          pop  ax
0x293b:  C3          ret  

; look up emm handle. if cant find it return 0 in carry flag. otherwise carry flag = 1 result in 0x2887
GET_EMM_HANDLE:
0x293c:  50                push       ax
0x293d:  53                push       bx
0x293e:  52                push       dx
0x293f:  81 FA FF 00       cmp        dx, 0xff
0x2943:  77 1D             ja         RETURN_CARRY_FLAG
0x2945:  B8 17 00          mov        ax, 0x17
0x2948:  F7 E2             mul        dx
0x294a:  2E 03 06 79 28    add        ax, word ptr cs:[0x2879]
0x294f:  8B D8             mov        bx, ax
0x2951:  2E 8B 5F 0A       mov        bx, word ptr cs:[bx + 0xa]
0x2955:  83 FB 00          cmp        bx, 0
0x2958:  74 08             je         RETURN_CARRY_FLAG
0x295a:  2E A3 87 28       mov        word ptr cs:[0x2887], ax
RETURN_NO_CARRY_FLAG:
0x295e:  F8                clc        
0x295f:  EB 02             jmp        RETURN_WITH_RESULT
0x2961:  90                nop        
RETURN_CARRY_FLAG:
0x2962:  F9                stc        
RETURN_WITH_RESULT:
0x2963:  5A                pop        dx
0x2964:  5B                pop        bx
0x2965:  58                pop        ax
0x2966:  C3                ret        

; read from chipset register AL into AL
READCHIPSETREG:
0x2967:  E6 EC             out        0xec, al
0x2969:  EB 00             jmp        0x296b
0x296b:  EB 00             jmp        0x296d
0x296d:  E4 ED             in         al, 0xed
0x296f:  C3                ret      

; WRITE AH TO chipset register AL
WRITECHIPSETREG:
0x2970:  E6 EC             out        0xec, al
0x2972:  EB 00             jmp        0x2974
0x2974:  EB 00             jmp        0x2976
0x2976:  86 C4             xchg       ah, al
0x2978:  E6 ED             out        0xed, al
0x297a:  86 C4             xchg       ah, al
0x297c:  C3                ret        

; READ from EMS index port AL  into AX
READEMSPORT:
0x297d:  E6 E8             out        0xe8, al
0x297f:  EB 00             jmp        0x2981
0x2981:  EB 00             jmp        0x2983
0x2983:  E5 EA             in         ax, 0xea
0x2985:  C3                ret        

; WRITE AL to ems index port DX to port EA/EAB
WRITEEMSPORT:
0x2986:  E6 E8             out        0xe8, al
0x2988:  EB 00             jmp        0x298a
0x298a:  EB 00             jmp        0x298c
0x298c:  50                push       ax
0x298d:  8B C2             mov        ax, dx
0x298f:  E7 EA             out        0xea, ax
0x2991:  58                pop        ax
0x2992:  C3                ret
        

; 
0x2993:  50                push       ax
0x2994:  53                push       bx
0x2995:  51                push       cx
0x2996:  52                push       dx
0x2997:  E8 F3 00          call       READWEIRDSTRUCTBYTE2
0x299a:  3C 23             cmp        al, 0x23
0x299c:  77 67             ja         EXIT_FUNCTION  ; exit if al > 35 or 0x23. 0x23 is the maximum page frame register 
0x299e:  8B D3             mov        dx, bx
0x29a0:  E8 E3 FF          call       WRITEEMSPORT
0x29a3:  3C 0B             cmp        al, 0xb
0x29a5:  77 34             ja         0x29db
0x29a7:  3C 07             cmp        al, 7
0x29a9:  77 17             ja         0x29c2
0x29ab:  B4 01             mov        ah, 1
0x29ad:  8A C8             mov        cl, al
0x29af:  D2 E4             shl        ah, cl
0x29b1:  B0 0C             mov        al, 0xc
0x29b3:  E8 B1 FF          call       READCHIPSETREG
0x29b6:  0A C4             or         al, ah
0x29b8:  8A E0             mov        ah, al
0x29ba:  B0 0C             mov        al, 0xc
0x29bc:  E8 B1 FF          call       WRITECHIPSETREG
0x29bf:  EB 44             jmp        EXIT_FUNCTION
0x29c1:  90                nop        
0x29c2:  2C 08             sub        al, 8
0x29c4:  B4 01             mov        ah, 1
0x29c6:  8A C8             mov        cl, al
0x29c8:  D2 E4             shl        ah, cl
0x29ca:  B0 0B             mov        al, 0xb
0x29cc:  E8 98 FF          call       READCHIPSETREG
0x29cf:  0A C4             or         al, ah
0x29d1:  8A E0             mov        ah, al
0x29d3:  B0 0B             mov        al, 0xb
0x29d5:  E8 98 FF          call       WRITECHIPSETREG
0x29d8:  EB 2B             jmp        EXIT_FUNCTION
0x29da:  90                nop        
0x29db:  80 3E ED 28 00    cmp        byte ptr [0x28ed], 0
0x29e0:  74 23             je         EXIT_FUNCTION
0x29e2:  2C 0C             sub        al, 0xc
0x29e4:  8A C8             mov        cl, al
0x29e6:  B8 01 00          mov        ax, 1
0x29e9:  D3 E0             shl        ax, cl
0x29eb:  2E 8B 1E EE 28    mov        bx, word ptr cs:[0x28ee]
0x29f0:  0B D8             or         bx, ax
0x29f2:  2E 89 1E EE 28    mov        word ptr cs:[0x28ee], bx
0x29f7:  B0 0B             mov        al, 0xb
0x29f9:  E8 6B FF          call       READCHIPSETREG
0x29fc:  0C 40             or         al, 0x40
0x29fe:  8A E0             mov        ah, al
0x2a00:  B0 0B             mov        al, 0xb
0x2a02:  E8 6B FF          call       WRITECHIPSETREG
EXIT_FUNCTION:
0x2a05:  5A                pop        dx
0x2a06:  59                pop        cx
0x2a07:  5B                pop        bx
0x2a08:  58                pop        ax
0x2a09:  C3                ret        

0x2a0a:  50                push       ax
0x2a0b:  53                push       bx
0x2a0c:  51                push       cx
0x2a0d:  52                push       dx
0x2a0e:  E8 7C 00          call       READWEIRDSTRUCTBYTE2
0x2a11:  3C 23             cmp        al, 0x23
0x2a13:  77 73             ja         0x2a88
0x2a15:  3C 0B             cmp        al, 0xb
0x2a17:  77 38             ja         0x2a51
0x2a19:  3C 07             cmp        al, 7
0x2a1b:  77 19             ja         0x2a36
0x2a1d:  B4 01             mov        ah, 1
0x2a1f:  8A C8             mov        cl, al
0x2a21:  D2 E4             shl        ah, cl
0x2a23:  F6 D4             not        ah
0x2a25:  B0 0C             mov        al, 0xc
0x2a27:  E8 3D FF          call       READCHIPSETREG
0x2a2a:  22 C4             and        al, ah
0x2a2c:  8A E0             mov        ah, al
0x2a2e:  B0 0C             mov        al, 0xc
0x2a30:  E8 3D FF          call       WRITECHIPSETREG
0x2a33:  EB 53             jmp        0x2a88
0x2a35:  90                nop        
0x2a36:  2C 08             sub        al, 8
0x2a38:  B4 01             mov        ah, 1
0x2a3a:  8A C8             mov        cl, al
0x2a3c:  D2 E4             shl        ah, cl
0x2a3e:  F6 D4             not        ah
0x2a40:  B0 0B             mov        al, 0xb
0x2a42:  E8 22 FF          call       READCHIPSETREG
0x2a45:  22 C4             and        al, ah
0x2a47:  8A E0             mov        ah, al
0x2a49:  B0 0B             mov        al, 0xb
0x2a4b:  E8 22 FF          call       WRITECHIPSETREG
0x2a4e:  EB 38             jmp        0x2a88
0x2a50:  90                nop        
0x2a51:  BA 10 00          mov        dx, 0x10
0x2a54:  8A E0             mov        ah, al
0x2a56:  80 EC 0C          sub        ah, 0xc
0x2a59:  02 D4             add        dl, ah
0x2a5b:  E8 28 FF          call       WRITEEMSPORT
0x2a5e:  2C 0C             sub        al, 0xc
0x2a60:  8A C8             mov        cl, al
0x2a62:  B8 01 00          mov        ax, 1
0x2a65:  D3 E0             shl        ax, cl
0x2a67:  F7 D0             not        ax
0x2a69:  2E 8B 1E EE 28    mov        bx, word ptr cs:[0x28ee]
0x2a6e:  23 D8             and        bx, ax
0x2a70:  2E 89 1E EE 28    mov        word ptr cs:[0x28ee], bx
0x2a75:  83 FB 00          cmp        bx, 0
0x2a78:  75 0E             jne        0x2a88
0x2a7a:  B0 0B             mov        al, 0xb
0x2a7c:  E8 E8 FE          call       READCHIPSETREG
0x2a7f:  24 BF             and        al, 0xbf
0x2a81:  8A E0             mov        ah, al
0x2a83:  B0 0B             mov        al, 0xb
0x2a85:  E8 E8 FE          call       WRITECHIPSETREG
0x2a88:  5A                pop        dx
0x2a89:  59                pop        cx
0x2a8a:  5B                pop        bx
0x2a8b:  58                pop        ax
0x2a8c:  C3                ret

; mul al by 3, add to 0x2749, get the byte there + 2
; read byte at 0x2749 + [al * 3] + 2;

READWEIRDSTRUCTBYTE2:
0x2a8d:  56                push       si
0x2a8e:  51                push       cx
0x2a8f:  BE 49 27          mov        si, 0x2749
0x2a92:  32 E4             xor        ah, ah
0x2a94:  B1 03             mov        cl, 3
0x2a96:  F6 E1             mul        cl
0x2a98:  03 F0             add        si, ax
0x2a9a:  2E 8A 44 02       mov        al, byte ptr cs:[si + 2]
0x2a9e:  59                pop        cx
0x2a9f:  5E                pop        si
0x2aa0:  C3                ret


; read byte at 0x2749 + [al * 3] + 2;
; get byte at 28a1
; if ax == byte at 2749 return bl
; else 
; finds the index of the 3 byte mystery struct with first byte == ax

FINDWEIRDSTRUCTINDEX:
0x2aa1:  56                push       si
0x2aa2:  53                push       bx
0x2aa3:  51                push       cx
0x2aa4:  B3 00             mov        bl, 0
0x2aa6:  BE 49 27          mov        si, 0x2749
0x2aa9:  2E 8B 0E A1 28    mov        cx, word ptr cs:[0x28a1]
0x2aae:  2E 39 04          cmp        word ptr cs:[si], ax
0x2ab1:  74 07             je         0x2aba
0x2ab3:  FE C3             inc        bl
0x2ab5:  83 C6 03          add        si, 3
0x2ab8:  E2 F4             loop       0x2aae
0x2aba:  8A C3             mov        al, bl
0x2abc:  59                pop        cx
0x2abd:  5B                pop        bx
0x2abe:  5E                pop        si
0x2abf:  C3                ret

0x2ac0:  50                push       ax
0x2ac1:  51                push       cx
0x2ac2:  52                push       dx
0x2ac3:  56                push       si
0x2ac4:  BE 49 27          mov        si, 0x2749
0x2ac7:  2E 8A 44 02       mov        al, byte ptr cs:[si + 2]
0x2acb:  E8 AF FE          call       READEMSPORT
0x2ace:  AB                stosw      word ptr es:[di], ax
0x2acf:  83 C6 03          add        si, 3
0x2ad2:  E2 F3             loop       0x2ac7
0x2ad4:  B0 0B             mov        al, 0xb
0x2ad6:  E8 8E FE          call       READCHIPSETREG
0x2ad9:  AA                stosb      byte ptr es:[di], al
0x2ada:  B0 0C             mov        al, 0xc
0x2adc:  E8 88 FE          call       READCHIPSETREG
0x2adf:  AA                stosb      byte ptr es:[di], al
0x2ae0:  5E                pop        si
0x2ae1:  5A                pop        dx
0x2ae2:  59                pop        cx
0x2ae3:  58                pop        ax
0x2ae4:  C3                ret

0x2ae5:  50                push       ax
0x2ae6:  53                push       bx
0x2ae7:  51                push       cx
0x2ae8:  52                push       dx
0x2ae9:  BB 49 27          mov        bx, 0x2749
0x2aec:  AD                lodsw      ax, word ptr [si]
0x2aed:  8B D0             mov        dx, ax
0x2aef:  2E 8A 47 02       mov        al, byte ptr cs:[bx + 2]
0x2af3:  E8 90 FE          call       WRITEEMSPORT
0x2af6:  83 C3 03          add        bx, 3
0x2af9:  E2 F1             loop       0x2aec
0x2afb:  AC                lodsb      al, byte ptr [si]
0x2afc:  8A E0             mov        ah, al
0x2afe:  B0 0B             mov        al, 0xb
0x2b00:  E8 6D FE          call       WRITECHIPSETREG
0x2b03:  AC                lodsb      al, byte ptr [si]
0x2b04:  8A E0             mov        ah, al
0x2b06:  B0 0C             mov        al, 0xc
0x2b08:  E8 65 FE          call       WRITECHIPSETREG
0x2b0b:  5A                pop        dx
0x2b0c:  59                pop        cx
0x2b0d:  5B                pop        bx
0x2b0e:  58                pop        ax
0x2b0f:  C3                ret   

MAIN_EMS_INTERRUPT_VECTOR:
0x2b10:  51                   push       cx
0x2b11:  56                   push       si
0x2b12:  57                   push       di
0x2b13:  55                   push       bp
0x2b14:  1E                   push       ds
0x2b15:  06                   push       es
0x2b16:  FC                   cld        

; don't support OS function types
0x2b17:  80 FC 5D             cmp        ah, 0x5d
0x2b1a:  77 1F                ja         RETURN_RESULT_84

; don't support 'GET STATUS' call
0x2b1c:  80 FC 40             cmp        ah, 0x40
0x2b1f:  72 1A                jb         RETURN_RESULT_84

; subtract 0x40 - things are now 0x40 indexed..

0x2b21:  80 EC 40             sub        ah, 0x40
0x2b24:  53                   push       bx
0x2b25:  8A DC                mov        bl, ah
0x2b27:  32 FF                xor        bh, bh
0x2b29:  D1 E3                shl        bx, 1          ; get word offset of AH - 0x40
0x2b2b:  2E 8B 9F F8 28       mov        bx, word ptr cs:[bx + 0x28f8]
0x2b30:  2E 89 1E 83 28       mov        word ptr cs:[0x2883], bx
0x2b35:  5B                   pop        bx
0x2b36:  2E FF 26 83 28       jmp        word ptr cs:[0x2883]

; The function code passed to the memory manager is not defined.
RETURN_RESULT_84:
0x2b3b:  E9 B1 0E             jmp        RETURNINTERRUPTRESULT_84

EMS_FUNCTION_0x40:
0x2b3e:  E9 53 0F             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x41:
0x2b41:  2E 8B 1E 81 28       mov        bx, word ptr cs:[0x2881]
0x2b46:  E9 4B 0F             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x42:
0x2b49:  2E 8B 16 95 28       mov        dx, word ptr cs:[0x2895]
0x2b4e:  2E 8B 1E 89 28       mov        bx, word ptr cs:[0x2889]
0x2b53:  E9 3E 0F             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x43:
0x2b56:  0E                   push       cs
0x2b57:  1F                   pop        ds
0x2b58:  53                   push       bx
0x2b59:  83 FB 00             cmp        bx, 0
0x2b5c:  74 41                je         0x2b9f
0x2b5e:  3B 1E 95 28          cmp        bx, word ptr [0x2895]
0x2b62:  77 42                ja         0x2ba6
0x2b64:  3B 1E 89 28          cmp        bx, word ptr [0x2889]
0x2b68:  77 2E                ja         0x2b98
0x2b6a:  83 3E 85 28 00       cmp        word ptr [0x2885], 0
0x2b6f:  74 20                je         0x2b91
0x2b71:  8B 36 79 28          mov        si, word ptr [0x2879]
0x2b75:  BA 00 00             mov        dx, 0
0x2b78:  B9 FF 00             mov        cx, 0xff
0x2b7b:  83 7C 0A 00          cmp        word ptr [si + 0xa], 0
0x2b7f:  74 2C                je         0x2bad
0x2b81:  83 C6 17             add        si, 0x17
0x2b84:  42                   inc        dx
0x2b85:  E2 F4                loop       0x2b7b
0x2b87:  E9 6A 0E             jmp        RETURNINTERRUPTRESULT_85
0x2b8a:  BA 00 00             mov        dx, 0
0x2b8d:  5B                   pop        bx
0x2b8e:  E9 54 0E             jmp        RETURNINTERRUPTRESULT_80
0x2b91:  BA 00 00             mov        dx, 0
0x2b94:  5B                   pop        bx
0x2b95:  E9 5C 0E             jmp        RETURNINTERRUPTRESULT_85
0x2b98:  BA 00 00             mov        dx, 0
0x2b9b:  5B                   pop        bx
0x2b9c:  E9 64 0E             jmp        RETURNINTERRUPTRESULT_88
0x2b9f:  BA 00 00             mov        dx, 0
0x2ba2:  5B                   pop        bx
0x2ba3:  E9 62 0E             jmp        RETURNINTERRUPTRESULT_89
0x2ba6:  BA 00 00             mov        dx, 0
0x2ba9:  5B                   pop        bx
0x2baa:  E9 51 0E             jmp        RETURNINTERRUPTRESULT_87
0x2bad:  83 3C 00             cmp        word ptr [si], 0
0x2bb0:  75 D8                jne        0x2b8a
0x2bb2:  B0 00                mov        al, 0
0x2bb4:  B9 08 00             mov        cx, 8
0x2bb7:  8B FE                mov        di, si
0x2bb9:  81 C7 02 00          add        di, 2
0x2bbd:  0E                   push       cs
0x2bbe:  07                   pop        es
0x2bbf:  F3 AE                repe scasb al, byte ptr es:[di]
0x2bc1:  75 C7                jne        0x2b8a
0x2bc3:  BF 0A 00             mov        di, 0xa
0x2bc6:  03 FE                add        di, si
0x2bc8:  89 1C                mov        word ptr [si], bx
0x2bca:  8B 36 7D 28          mov        si, word ptr [0x287d]
0x2bce:  8B CB                mov        cx, bx
0x2bd0:  83 FB 00             cmp        bx, 0
0x2bd3:  75 03                jne        0x2bd8
0x2bd5:  B9 01 00             mov        cx, 1
0x2bd8:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2bdc:  73 AC                jae        0x2b8a
0x2bde:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2be2:  72 A6                jb         0x2b8a
0x2be4:  83 7C 02 00          cmp        word ptr [si + 2], 0
0x2be8:  74 05                je         0x2bef
0x2bea:  83 C6 04             add        si, 4
0x2bed:  EB E9                jmp        0x2bd8
0x2bef:  89 35                mov        word ptr [di], si
0x2bf1:  BF 02 00             mov        di, 2
0x2bf4:  03 FE                add        di, si
0x2bf6:  83 C6 04             add        si, 4
0x2bf9:  E2 DD                loop       0x2bd8
0x2bfb:  83 FB 00             cmp        bx, 0
0x2bfe:  74 08                je         0x2c08

db  C7h

EMS_FUNCTION_0x44:
0x2c01:  05 FF FF       add ax, 0xffff
0x2c04:  29 1E 89 28    sub word ptr [0x2889], bx
0x2c08:  FF 0E 85 28    dec word ptr [0x2885]
0x2c0c:  5B                   pop        bx
0x2c0d:  E9 84 0E             jmp        RETURNINTERRUPTRESULT0
0x2c10:  0E                   push       cs
0x2c11:  1F                   pop        ds
0x2c12:  53                   push       bx
0x2c13:  52                   push       dx
0x2c14:  32 E4                xor        ah, ah
0x2c16:  8B F8                mov        di, ax
0x2c18:  2E 3B 06 A1 28       cmp        ax, word ptr cs:[0x28a1]
0x2c1d:  72 03                jb         0x2c22
0x2c1f:  EB 4F                jmp        RETURN_RESULT_8B
0x2c21:  90                   nop        
0x2c22:  E8 17 FD             call       GET_EMM_HANDLE
0x2c25:  73 03                jae        0x2c2a
0x2c27:  EB 3D                jmp        RETURN_RESULT_83
0x2c29:  90                   nop        
0x2c2a:  E8 DD FD             call       0x2a0a
0x2c2d:  83 FB FF             cmp        bx, -1
0x2c30:  74 2A                je         RETURN_RESULT_00
0x2c32:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2c36:  3B 1C                cmp        bx, word ptr [si]
0x2c38:  72 03                jb         0x2c3d
0x2c3a:  EB 2F                jmp        RETURN_RESULT_8A
0x2c3c:  90                   nop        
0x2c3d:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2c40:  8B CB                mov        cx, bx
0x2c42:  E3 05                jcxz       0x2c49
0x2c44:  8B 74 02             mov        si, word ptr [si + 2]
0x2c47:  E2 FB                loop       0x2c44
0x2c49:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2c4d:  73 12                jae        RETURN_RESULT_80
0x2c4f:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2c53:  72 0C                jb         RETURN_RESULT_80
0x2c55:  8B 1C                mov        bx, word ptr [si]
0x2c57:  8B C7                mov        ax, di
0x2c59:  E8 37 FD             call       0x2993
RETURN_RESULT_00:
0x2c5c:  5A                   pop        dx
0x2c5d:  5B                   pop        bx
0x2c5e:  E9 33 0E             jmp        RETURNINTERRUPTRESULT0
RETURN_RESULT_80:
0x2c61:  5A                   pop        dx
0x2c62:  5B                   pop        bx
0x2c63:  E9 7F 0D             jmp        RETURNINTERRUPTRESULT_80

; The memory manager couldn't find the EMM handle your program specified.
RETURN_RESULT_83:
0x2c66:  5A                   pop        dx
0x2c67:  5B                   pop        bx
0x2c68:  E9 7F 0D             jmp        RETURNINTERRUPTRESULT_83

RETURN_RESULT_8A:
0x2c6b:  5A                   pop        dx
0x2c6c:  5B                   pop        bx
0x2c6d:  E9 9D 0D             jmp        RETURNINTERRUPTRESULT_8A

RETURN_RESULT_8B:
0x2c70:  5A                   pop        dx
0x2c71:  5B                   pop        bx
0x2c72:  E9 9D 0D             jmp        RETURNINTERRUPTRESULT_8B

EMS_FUNCTION_0x45:
0x2c75:  0E                   push       cs
0x2c76:  1F                   pop        ds
0x2c77:  53                   push       bx
0x2c78:  52                   push       dx
0x2c79:  E8 C0 FC             call       GET_EMM_HANDLE
0x2c7c:  72 67                jb         0x2ce5
0x2c7e:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2c82:  80 7C 0C FF          cmp        byte ptr [si + 0xc], 0xff
0x2c86:  74 62                je         0x2cea
0x2c88:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2c8c:  8B 0C                mov        cx, word ptr [si]
0x2c8e:  83 F9 00             cmp        cx, 0
0x2c91:  74 20                je         0x2cb3
0x2c93:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2c96:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2c9a:  73 44                jae        0x2ce0
0x2c9c:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2ca0:  72 3E                jb         0x2ce0
0x2ca2:  8B 7C 02             mov        di, word ptr [si + 2]
0x2ca5:  C7 44 02 00 00       mov        word ptr [si + 2], 0
0x2caa:  83 FF FF             cmp        di, -1
0x2cad:  74 04                je         0x2cb3
0x2caf:  8B F7                mov        si, di
0x2cb1:  EB E3                jmp        0x2c96
0x2cb3:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2cb7:  8B 1D                mov        bx, word ptr [di]
0x2cb9:  01 1E 89 28          add        word ptr [0x2889], bx
0x2cbd:  C7 05 00 00          mov        word ptr [di], 0
0x2cc1:  83 FA 00             cmp        dx, 0
0x2cc4:  74 09                je         0x2ccf
0x2cc6:  FF 06 85 28          inc        word ptr [0x2885]
0x2cca:  C7 45 0A 00 00       mov        word ptr [di + 0xa], 0
0x2ccf:  83 C7 02             add        di, 2
0x2cd2:  0E                   push       cs
0x2cd3:  07                   pop        es
0x2cd4:  B0 00                mov        al, 0
0x2cd6:  B9 08 00             mov        cx, 8
0x2cd9:  F3 AA                rep stosb  byte ptr es:[di], al
0x2cdb:  5A                   pop        dx
0x2cdc:  5B                   pop        bx
0x2cdd:  E9 B4 0D             jmp        RETURNINTERRUPTRESULT0
0x2ce0:  5A                   pop        dx
0x2ce1:  5B                   pop        bx
0x2ce2:  E9 00 0D             jmp        RETURNINTERRUPTRESULT_80
0x2ce5:  5A                   pop        dx
0x2ce6:  5B                   pop        bx
0x2ce7:  E9 00 0D             jmp        RETURNINTERRUPTRESULT_83
0x2cea:  5A                   pop        dx
0x2ceb:  5B                   pop        bx
0x2cec:  E9 0A 0D             jmp        RETURNINTERRUPTRESULT_86

EMS_FUNCTION_0x46:
; Get Version, return 4.0
0x2cef:  B0 40                mov        al, 0x40
0x2cf1:  E9 A0 0D             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x47:
0x2cf4:  0E                   push       cs
0x2cf5:  1F                   pop        ds
0x2cf6:  53                   push       bx
0x2cf7:  52                   push       dx
0x2cf8:  E8 41 FC             call       GET_EMM_HANDLE
0x2cfb:  72 E8                jb         0x2ce5
0x2cfd:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2d01:  80 7C 0C FF          cmp        byte ptr [si + 0xc], 0xff
0x2d05:  74 1A                je         0x2d21
0x2d07:  C6 44 0C FF          mov        byte ptr [si + 0xc], 0xff
0x2d0b:  8B FE                mov        di, si
0x2d0d:  83 C7 0D             add        di, 0xd
0x2d10:  8C C8                mov        ax, cs
0x2d12:  8E C0                mov        es, ax
0x2d14:  51                   push       cx
0x2d15:  B9 04 00             mov        cx, 4
0x2d18:  E8 A5 FD             call       0x2ac0
0x2d1b:  59                   pop        cx
0x2d1c:  5A                   pop        dx
0x2d1d:  5B                   pop        bx
0x2d1e:  E9 73 0D             jmp        RETURNINTERRUPTRESULT0
0x2d21:  5A                   pop        dx
0x2d22:  5B                   pop        bx
0x2d23:  E9 F6 0C             jmp        RETURNINTERRUPTRESULT_8D

EMS_FUNCTION_0x48:
0x2d26:  0E                   push       cs
0x2d27:  1F                   pop        ds
0x2d28:  53                   push       bx
0x2d29:  52                   push       dx
0x2d2a:  E8 0F FC             call       GET_EMM_HANDLE
0x2d2d:  72 B6                jb         0x2ce5
0x2d2f:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2d33:  80 7C 0C FF          cmp        byte ptr [si + 0xc], 0xff
0x2d37:  75 19                jne        0x2d52
0x2d39:  C6 44 0C 00          mov        byte ptr [si + 0xc], 0
0x2d3d:  83 C6 0D             add        si, 0xd
0x2d40:  51                   push       cx
0x2d41:  B9 04 00             mov        cx, 4
0x2d44:  E8 9E FD             call       0x2ae5
0x2d47:  59                   pop        cx
0x2d48:  5A                   pop        dx
0x2d49:  5B                   pop        bx
0x2d4a:  E9 47 0D             jmp        RETURNINTERRUPTRESULT0
0x2d4d:  5A                   pop        dx
0x2d4e:  5B                   pop        bx
0x2d4f:  E9 93 0C             jmp        RETURNINTERRUPTRESULT_80
0x2d52:  5A                   pop        dx
0x2d53:  5B                   pop        bx
0x2d54:  E9 CA 0C             jmp        RETURNINTERRUPTRESULT_8E

EMS_FUNCTION_0x49:
0x2d57:  E9 3A 0D             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x4A:
0x2d5a:  E9 37 0D             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x4B:
0x2d5d:  BB FF 00             mov        bx, 0xff
0x2d60:  2E 2B 1E 85 28       sub        bx, word ptr cs:[0x2885]
0x2d65:  E9 2C 0D             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x4C:
0x2d68:  E8 D1 FB             call       GET_EMM_HANDLE
0x2d6b:  72 0B                jb         0x2d78
0x2d6d:  2E 8B 1E 87 28       mov        bx, word ptr cs:[0x2887]
0x2d72:  2E 8B 1F             mov        bx, word ptr cs:[bx]
0x2d75:  E9 1C 0D             jmp        RETURNINTERRUPTRESULT0
0x2d78:  E9 6F 0C             jmp        RETURNINTERRUPTRESULT_83

EMS_FUNCTION_0x4D:
0x2d7b:  52                   push       dx
0x2d7c:  0E                   push       cs
0x2d7d:  1F                   pop        ds
0x2d7e:  B9 FF 00             mov        cx, 0xff
0x2d81:  33 C0                xor        ax, ax
0x2d83:  33 D2                xor        dx, dx
0x2d85:  8B 1E 79 28          mov        bx, word ptr [0x2879]
0x2d89:  8B F3                mov        si, bx
0x2d8b:  83 7C 0A 00          cmp        word ptr [si + 0xa], 0
0x2d8f:  74 03                je         0x2d94
0x2d91:  42                   inc        dx
0x2d92:  AB                   stosw      word ptr es:[di], ax
0x2d93:  A5                   movsw      word ptr es:[di], word ptr [si]
0x2d94:  40                   inc        ax
0x2d95:  83 C3 17             add        bx, 0x17
0x2d98:  E2 EF                loop       0x2d89
0x2d9a:  8B DA                mov        bx, dx
0x2d9c:  5A                   pop        dx
0x2d9d:  E9 F4 0C             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x4E:
0x2da0:  3C 03                cmp        al, 3
0x2da2:  72 03                jb         0x2da7
0x2da4:  EB 23                jmp        0x2dc9
0x2da6:  90                   nop        
0x2da7:  3C 01                cmp        al, 1
0x2da9:  74 11                je         0x2dbc
0x2dab:  51                   push       cx
0x2dac:  2E 8B 0E A1 28       mov        cx, word ptr cs:[0x28a1]
0x2db1:  E8 0C FD             call       0x2ac0
0x2db4:  59                   pop        cx
0x2db5:  3C 00                cmp        al, 0
0x2db7:  75 03                jne        0x2dbc
0x2db9:  E9 D8 0C             jmp        RETURNINTERRUPTRESULT0
0x2dbc:  51                   push       cx
0x2dbd:  2E 8B 0E A1 28       mov        cx, word ptr cs:[0x28a1]
0x2dc2:  E8 20 FD             call       0x2ae5
0x2dc5:  59                   pop        cx
0x2dc6:  E9 CB 0C             jmp        RETURNINTERRUPTRESULT0
0x2dc9:  3C 03                cmp        al, 3
0x2dcb:  74 03                je         0x2dd0
0x2dcd:  E9 56 0C             jmp        RETURNINTERRUPTRESULT_8F
0x2dd0:  2E A1 A1 28          mov        ax, word ptr cs:[0x28a1]
0x2dd4:  D1 E0                shl        ax, 1
0x2dd6:  04 02                add        al, 2
0x2dd8:  32 E4                xor        ah, ah
0x2dda:  E9 B7 0C             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x4F:
0x2ddd:  3C 00                cmp        al, 0
0x2ddf:  74 03                je         0x2de4
0x2de1:  EB 3C                jmp        0x2e1f
0x2de3:  90                   nop        
0x2de4:  53                   push       bx
0x2de5:  52                   push       dx
0x2de6:  8B EF                mov        bp, di
0x2de8:  FC                   cld        
0x2de9:  AD                   lodsw      ax, word ptr [si]
0x2dea:  2E 3B 06 A1 28       cmp        ax, word ptr cs:[0x28a1]
0x2def:  77 23                ja         0x2e14
0x2df1:  AB                   stosw      word ptr es:[di], ax
0x2df2:  8B C8                mov        cx, ax
0x2df4:  E3 0E                jcxz       0x2e04
0x2df6:  AD                   lodsw      ax, word ptr [si]
0x2df7:  E8 A7 FC             call       FINDWEIRDSTRUCTINDEX
0x2dfa:  AA                   stosb      byte ptr es:[di], al
0x2dfb:  E8 8F FC             call       READWEIRDSTRUCTBYTE2
0x2dfe:  E8 7C FB             call       READEMSPORT
0x2e01:  AB                   stosw      word ptr es:[di], ax
0x2e02:  E2 F2                loop       0x2df6
0x2e04:  5A                   pop        dx
0x2e05:  5B                   pop        bx
0x2e06:  E9 8B 0C             jmp        RETURNINTERRUPTRESULT0
0x2e09:  5A                   pop        dx
0x2e0a:  5B                   pop        bx
0x2e0b:  26 C7 46 00 00 00    mov        word ptr es:[bp], 0
0x2e11:  E9 FE 0B             jmp        RETURNINTERRUPTRESULT_8B
0x2e14:  5A                   pop        dx
0x2e15:  5B                   pop        bx
0x2e16:  26 C7 46 00 00 00    mov        word ptr es:[bp], 0
0x2e1c:  E9 6B 0C             jmp        RETURNINTERRUPTRESULT_A3
0x2e1f:  3C 01                cmp        al, 1
0x2e21:  74 03                je         0x2e26
0x2e23:  EB 2E                jmp        0x2e53
0x2e25:  90                   nop        
0x2e26:  53                   push       bx
0x2e27:  52                   push       dx
0x2e28:  FC                   cld        
0x2e29:  AD                   lodsw      ax, word ptr [si]
0x2e2a:  8B C8                mov        cx, ax
0x2e2c:  2E 3B 0E A1 28       cmp        cx, word ptr cs:[0x28a1]
0x2e31:  77 16                ja         0x2e49
0x2e33:  E3 0A                jcxz       0x2e3f
0x2e35:  AC                   lodsb      al, byte ptr [si]
0x2e36:  8A D8                mov        bl, al
0x2e38:  AD                   lodsw      ax, word ptr [si]
0x2e39:  93                   xchg       ax, bx
0x2e3a:  E8 56 FB             call       0x2993
0x2e3d:  E2 F6                loop       0x2e35
0x2e3f:  5A                   pop        dx
0x2e40:  5B                   pop        bx
0x2e41:  E9 50 0C             jmp        RETURNINTERRUPTRESULT0
0x2e44:  5A                   pop        dx
0x2e45:  5B                   pop        bx
0x2e46:  E9 9C 0B             jmp        RETURNINTERRUPTRESULT_80
0x2e49:  5A                   pop        dx
0x2e4a:  5B                   pop        bx
0x2e4b:  E9 3C 0C             jmp        RETURNINTERRUPTRESULT_A3
0x2e4e:  5A                   pop        dx
0x2e4f:  5B                   pop        bx
0x2e50:  E9 14 0C             jmp        RETURNINTERRUPTRESULT_9C
0x2e53:  3C 02                cmp        al, 2
0x2e55:  74 03                je         0x2e5a
0x2e57:  E9 CC 0B             jmp        RETURNINTERRUPTRESULT_8F
0x2e5a:  2E 3B 1E A1 28       cmp        bx, word ptr cs:[0x28a1]
0x2e5f:  77 09                ja         0x2e6a
0x2e61:  B0 03                mov        al, 3
0x2e63:  F6 E3                mul        bl
0x2e65:  04 02                add        al, 2
0x2e67:  E9 2A 0C             jmp        RETURNINTERRUPTRESULT0
0x2e6a:  B0 00                mov        al, 0
0x2e6c:  E9 A3 0B             jmp        RETURNINTERRUPTRESULT_8B

EMS_FUNCTION_0x50:
0x2e6f:  83 F9 00             cmp        cx, 0
0x2e72:  75 03                jne        0x2e77
0x2e74:  E9 AF 0B             jmp        RETURNINTERRUPTRESULT_8F
0x2e77:  53                   push       bx
0x2e78:  52                   push       dx
0x2e79:  32 E4                xor        ah, ah
0x2e7b:  2E A3 A5 28          mov        word ptr cs:[0x28a5], ax
0x2e7f:  AD                   lodsw      ax, word ptr [si]
0x2e80:  8B D8                mov        bx, ax
0x2e82:  AD                   lodsw      ax, word ptr [si]
0x2e83:  2E 83 3E A5 28 00    cmp        word ptr cs:[0x28a5], 0
0x2e89:  74 03                je         0x2e8e
0x2e8b:  E8 13 FC             call       FINDWEIRDSTRUCTINDEX
0x2e8e:  E8 0B 00             call       0x2e9c
0x2e91:  0A E4                or         ah, ah
0x2e93:  75 02                jne        0x2e97
0x2e95:  E2 E8                loop       0x2e7f
0x2e97:  5A                   pop        dx
0x2e98:  5B                   pop        bx
0x2e99:  E9 FA 0B             jmp        RETURNINTERRUPTRESULT
0x2e9c:  1E                   push       ds
0x2e9d:  53                   push       bx
0x2e9e:  51                   push       cx
0x2e9f:  52                   push       dx
0x2ea0:  56                   push       si
0x2ea1:  57                   push       di
0x2ea2:  0E                   push       cs
0x2ea3:  1F                   pop        ds
0x2ea4:  8B F8                mov        di, ax
0x2ea6:  E8 93 FA             call       GET_EMM_HANDLE
0x2ea9:  73 03                jae        0x2eae
0x2eab:  EB 3D                jmp        RETURN_RESULT_B_83
0x2ead:  90                   nop        
0x2eae:  E8 59 FB             call       0x2a0a
0x2eb1:  83 FB FF             cmp        bx, -1
0x2eb4:  74 2A                je         RETURN_RESULT_B_00
0x2eb6:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2eba:  3B 1C                cmp        bx, word ptr [si]
0x2ebc:  72 03                jb         0x2ec1
0x2ebe:  EB 2F                jmp        RETURN_RESULT_B_8A
0x2ec0:  90                   nop        
0x2ec1:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2ec4:  8B CB                mov        cx, bx
0x2ec6:  E3 05                jcxz       0x2ecd
0x2ec8:  8B 74 02             mov        si, word ptr [si + 2]
0x2ecb:  E2 FB                loop       0x2ec8
0x2ecd:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2ed1:  73 12                jae        RETURN_RESULT_B_80
0x2ed3:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2ed7:  72 0C                jb         RETURN_RESULT_B_80
0x2ed9:  8B 1C                mov        bx, word ptr [si]
0x2edb:  8B C7                mov        ax, di
0x2edd:  E8 B3 FA             call       0x2993

RETURN_RESULT_B_00:
0x2ee0:  B4 00                mov        ah, 0
0x2ee2:  EB 15                jmp        RETURN_RESULT_B
0x2ee4:  90                   nop        

RETURN_RESULT_B_80:
0x2ee5:  B4 80                mov        ah, 0x80
0x2ee7:  EB 10                jmp        RETURN_RESULT_B
0x2ee9:  90                   nop        

; The memory manager couldn't find the EMM handle your program specified.
RETURN_RESULT_B_83:
0x2eea:  B4 83                mov        ah, 0x83
0x2eec:  EB 0B                jmp        RETURN_RESULT_B
0x2eee:  90                   nop        

RETURN_RESULT_B_8A:
0x2eef:  B4 8A                mov        ah, 0x8a
0x2ef1:  EB 06                jmp        RETURN_RESULT_B
0x2ef3:  90                   nop        

;unused
RETURN_RESULT_B_8B:
0x2ef4:  B4 8B                mov        ah, 0x8b
0x2ef6:  EB 01                jmp        RETURN_RESULT_B
0x2ef8:  90                   nop        

RETURN_RESULT_B:
0x2ef9:  5F                   pop        di
0x2efa:  5E                   pop        si
0x2efb:  5A                   pop        dx
0x2efc:  59                   pop        cx
0x2efd:  5B                   pop        bx
0x2efe:  1F                   pop        ds
0x2eff:  C3                   ret

0x2f00:  5A                   pop        dx
0x2f01:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2f05:  8B 1D                mov        bx, word ptr [di]
0x2f07:  E9 E0 0A             jmp        RETURNINTERRUPTRESULT_83
0x2f0a:  5A                   pop        dx
0x2f0b:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2f0f:  8B 1D                mov        bx, word ptr [di]
0x2f11:  E9 EA 0A             jmp        RETURNINTERRUPTRESULT_87

EMS_FUNCTION_0x51:
0x2f14:  52                   push       dx
0x2f15:  0E                   push       cs
0x2f16:  1F                   pop        ds
0x2f17:  E8 22 FA             call       GET_EMM_HANDLE
0x2f1a:  72 E4                jb         0x2f00
0x2f1c:  81 FB DC 03          cmp        bx, 0x3dc
0x2f20:  77 E8                ja         0x2f0a
0x2f22:  8B 36 87 28          mov        si, word ptr [0x2887]
0x2f26:  8B 0C                mov        cx, word ptr [si]
0x2f28:  8B EB                mov        bp, bx
0x2f2a:  3B CB                cmp        cx, bx
0x2f2c:  74 74                je         0x2fa2
0x2f2e:  72 03                jb         0x2f33
0x2f30:  E9 8D 00             jmp        0x2fc0
0x2f33:  83 F9 00             cmp        cx, 0
0x2f36:  75 08                jne        0x2f40
0x2f38:  8B FE                mov        di, si
0x2f3a:  83 C7 0A             add        di, 0xa
0x2f3d:  EB 29                jmp        0x2f68
0x2f3f:  90                   nop        
0x2f40:  2B D9                sub        bx, cx
0x2f42:  3B 1E 89 28          cmp        bx, word ptr [0x2889]
0x2f46:  77 6E                ja         0x2fb6
0x2f48:  8B 7C 0A             mov        di, word ptr [si + 0xa]
0x2f4b:  49                   dec        cx
0x2f4c:  E3 11                jcxz       0x2f5f
0x2f4e:  3B 3E 7F 28          cmp        di, word ptr [0x287f]
0x2f52:  73 58                jae        0x2fac
0x2f54:  3B 3E 7D 28          cmp        di, word ptr [0x287d]
0x2f58:  72 52                jb         0x2fac
0x2f5a:  8B 7D 02             mov        di, word ptr [di + 2]
0x2f5d:  E2 EF                loop       0x2f4e
0x2f5f:  83 7D 02 FF          cmp        word ptr [di + 2], -1
0x2f63:  75 47                jne        0x2fac
0x2f65:  83 C7 02             add        di, 2
0x2f68:  8B CB                mov        cx, bx
0x2f6a:  8B 36 7D 28          mov        si, word ptr [0x287d]
0x2f6e:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2f72:  73 38                jae        0x2fac
0x2f74:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2f78:  72 32                jb         0x2fac
0x2f7a:  83 7C 02 00          cmp        word ptr [si + 2], 0
0x2f7e:  74 05                je         0x2f85
0x2f80:  83 C6 04             add        si, 4
0x2f83:  EB E9                jmp        0x2f6e
0x2f85:  89 35                mov        word ptr [di], si
0x2f87:  8B FE                mov        di, si
0x2f89:  83 C7 02             add        di, 2
0x2f8c:  83 C6 04             add        si, 4
0x2f8f:  E2 DD                loop       0x2f6e
0x2f91:  C7 05 FF FF          mov        word ptr [di], 0xffff
0x2f95:  29 1E 89 28          sub        word ptr [0x2889], bx
0x2f99:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2f9d:  89 2D                mov        word ptr [di], bp
0x2f9f:  EB 01                jmp        0x2fa2
0x2fa1:  90                   nop        
0x2fa2:  5A                   pop        dx
0x2fa3:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2fa7:  8B 1D                mov        bx, word ptr [di]
0x2fa9:  E9 E8 0A             jmp        RETURNINTERRUPTRESULT0
0x2fac:  5A                   pop        dx
0x2fad:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2fb1:  8B 1D                mov        bx, word ptr [di]
0x2fb3:  E9 2F 0A             jmp        RETURNINTERRUPTRESULT_80
0x2fb6:  5A                   pop        dx
0x2fb7:  8B 3E 87 28          mov        di, word ptr [0x2887]
0x2fbb:  8B 1D                mov        bx, word ptr [di]
0x2fbd:  E9 43 0A             jmp        RETURNINTERRUPTRESULT_88
0x2fc0:  8B CB                mov        cx, bx
0x2fc2:  83 F9 00             cmp        cx, 0
0x2fc5:  75 06                jne        0x2fcd
0x2fc7:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2fca:  EB 24                jmp        0x2ff0
0x2fcc:  90                   nop        
0x2fcd:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2fd0:  83 E9 01             sub        cx, 1
0x2fd3:  E3 11                jcxz       0x2fe6
0x2fd5:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2fd9:  73 D1                jae        0x2fac
0x2fdb:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2fdf:  72 CB                jb         0x2fac
0x2fe1:  8B 74 02             mov        si, word ptr [si + 2]
0x2fe4:  E2 EF                loop       0x2fd5
0x2fe6:  8B 7C 02             mov        di, word ptr [si + 2]
0x2fe9:  C7 44 02 FF FF       mov        word ptr [si + 2], 0xffff
0x2fee:  8B F7                mov        si, di
0x2ff0:  3B 36 7F 28          cmp        si, word ptr [0x287f]
0x2ff4:  73 B6                jae        0x2fac
0x2ff6:  3B 36 7D 28          cmp        si, word ptr [0x287d]
0x2ffa:  72 B0                jb         0x2fac
0x2ffc:  8B 7C 02             mov        di, word ptr [si + 2]
0x2fff:  C7 44 02 00 00       mov        word ptr [si + 2], 0
0x3004:  83 FF FF             cmp        di, -1
0x3007:  74 04                je         0x300d
0x3009:  8B F7                mov        si, di
0x300c:  E3 8B                jcxz       0x2f99
0x300e:  3E 87 28             xchg       word ptr ds:[bx + si], bp
0x3011:  89 2D                mov        word ptr [di], bp
0x3013:  EB 8D                jmp        0x2fa2

EMS_FUNCTION_0x52:
0x3015:  3C 00                cmp        al, 0
0x3017:  75 0A                jne        0x3023
0x3019:  E8 20 F9             call       GET_EMM_HANDLE
0x301c:  72 1E                jb         0x303c
0x301e:  B0 00                mov        al, 0
0x3020:  E9 71 0A             jmp        RETURNINTERRUPTRESULT0
0x3023:  3C 01                cmp        al, 1
0x3025:  75 1B                jne        0x3042
0x3027:  E8 12 F9             call       GET_EMM_HANDLE
0x302a:  72 10                jb         0x303c
0x302c:  80 FB 00             cmp        bl, 0
0x302f:  75 03                jne        0x3034
0x3031:  E9 60 0A             jmp        RETURNINTERRUPTRESULT0
0x3034:  80 FB 01             cmp        bl, 1
0x3037:  75 06                jne        0x303f
0x3039:  E9 EF 09             jmp        RETURNINTERRUPTRESULT_90
0x303c:  E9 AB 09             jmp        RETURNINTERRUPTRESULT_83
0x303f:  E9 EE 09             jmp        RETURNINTERRUPTRESULT_91
0x3042:  3C 02                cmp        al, 2
0x3044:  75 05                jne        0x304b
0x3046:  B0 00                mov        al, 0
0x3048:  E9 49 0A             jmp        RETURNINTERRUPTRESULT0
0x304b:  E9 D8 09             jmp        RETURNINTERRUPTRESULT_8F

EMS_FUNCTION_0x53:
0x304e:  53                   push       bx
0x304f:  52                   push       dx
0x3050:  E8 E9 F8             call       GET_EMM_HANDLE
0x3053:  72 62                jb         0x30b7
0x3055:  3C 01                cmp        al, 1
0x3057:  77 63                ja         0x30bc
0x3059:  74 14                je         0x306f
0x305b:  0E                   push       cs
0x305c:  1F                   pop        ds
0x305d:  8B 36 87 28          mov        si, word ptr [0x2887]
0x3061:  81 C6 02 00          add        si, 2
0x3065:  B9 04 00             mov        cx, 4
0x3068:  F3 A5                rep movsw  word ptr es:[di], word ptr [si]
0x306a:  5A                   pop        dx
0x306b:  5B                   pop        bx
0x306c:  E9 25 0A             jmp        RETURNINTERRUPTRESULT0
0x306f:  8C D8                mov        ax, ds
0x3071:  8E C0                mov        es, ax
0x3073:  8B FE                mov        di, si
0x3075:  B9 04 00             mov        cx, 4
0x3078:  33 C0                xor        ax, ax
0x307a:  F3 AF                repe scasw ax, word ptr es:[di]
0x307c:  8C C8                mov        ax, cs
0x307e:  8E C0                mov        es, ax
0x3080:  74 20                je         0x30a2
0x3082:  8B EE                mov        bp, si
0x3084:  2E A1 79 28          mov        ax, word ptr cs:[0x2879]
0x3088:  05 02 00             add        ax, 2
0x308b:  B9 FF 00             mov        cx, 0xff
0x308e:  8B F5                mov        si, bp
0x3090:  8B F8                mov        di, ax
0x3092:  8B D9                mov        bx, cx
0x3094:  B9 04 00             mov        cx, 4
0x3097:  F3 A7                repe cmpsw word ptr [si], word ptr es:[di]
0x3099:  74 26                je         0x30c1
0x309b:  05 17 00             add        ax, 0x17
0x309e:  8B CB                mov        cx, bx
0x30a0:  E2 EC                loop       0x308e
0x30a2:  2E 8B 3E 87 28       mov        di, word ptr cs:[0x2887]
0x30a7:  81 C7 02 00          add        di, 2
0x30ab:  8B F5                mov        si, bp
0x30ad:  B9 04 00             mov        cx, 4
0x30b0:  F3 A5                rep movsw  word ptr es:[di], word ptr [si]
0x30b2:  5A                   pop        dx
0x30b3:  5B                   pop        bx
0x30b4:  E9 DD 09             jmp        RETURNINTERRUPTRESULT0
0x30b7:  5A                   pop        dx
0x30b8:  5B                   pop        bx
0x30b9:  E9 2E 09             jmp        RETURNINTERRUPTRESULT_83
0x30bc:  5A                   pop        dx
0x30bd:  5B                   pop        bx
0x30be:  E9 65 09             jmp        RETURNINTERRUPTRESULT_8F
0x30c1:  5A                   pop        dx
0x30c2:  5B                   pop        bx
0x30c3:  E9 BA 09             jmp        RETURNINTERRUPTRESULT_A1

EMS_FUNCTION_0x54:
0x30c6:  53                   push       bx
0x30c7:  52                   push       dx
0x30c8:  3C 00                cmp        al, 0
0x30ca:  75 2F                jne        0x30fb
0x30cc:  0E                   push       cs
0x30cd:  1F                   pop        ds
0x30ce:  33 C0                xor        ax, ax
0x30d0:  33 D2                xor        dx, dx
0x30d2:  8B 1E 79 28          mov        bx, word ptr [0x2879]
0x30d6:  B9 FF 00             mov        cx, 0xff
0x30d9:  83 7F 0A 00          cmp        word ptr [bx + 0xa], 0
0x30dd:  74 0F                je         0x30ee
0x30df:  AB                   stosw      word ptr es:[di], ax
0x30e0:  8B F3                mov        si, bx
0x30e2:  81 C6 02 00          add        si, 2
0x30e6:  51                   push       cx
0x30e7:  B9 04 00             mov        cx, 4
0x30ea:  F3 A5                rep movsw  word ptr es:[di], word ptr [si]
0x30ec:  59                   pop        cx
0x30ed:  42                   inc        dx
0x30ee:  83 C3 17             add        bx, 0x17
0x30f1:  40                   inc        ax
0x30f2:  E2 E5                loop       0x30d9
0x30f4:  8A C2                mov        al, dl
0x30f6:  5A                   pop        dx
0x30f7:  5B                   pop        bx
0x30f8:  E9 99 09             jmp        RETURNINTERRUPTRESULT0
0x30fb:  3C 01                cmp        al, 1
0x30fd:  75 3A                jne        0x3139
0x30ff:  1E                   push       ds
0x3100:  07                   pop        es
0x3101:  8B FE                mov        di, si
0x3103:  B9 04 00             mov        cx, 4
0x3106:  33 C0                xor        ax, ax
0x3108:  F3 AF                repe scasw ax, word ptr es:[di]
0x310a:  74 43                je         0x314f
0x310c:  0E                   push       cs
0x310d:  07                   pop        es
0x310e:  8B EE                mov        bp, si
0x3110:  33 D2                xor        dx, dx
0x3112:  2E A1 79 28          mov        ax, word ptr cs:[0x2879]
0x3116:  05 02 00             add        ax, 2
0x3119:  B9 FF 00             mov        cx, 0xff
0x311c:  8B F5                mov        si, bp
0x311e:  8B F8                mov        di, ax
0x3120:  8B D9                mov        bx, cx
0x3122:  B9 04 00             mov        cx, 4
0x3125:  F3 A7                repe cmpsw word ptr [si], word ptr es:[di]
0x3127:  74 0B                je         0x3134
0x3129:  42                   inc        dx
0x312a:  05 17 00             add        ax, 0x17
0x312d:  8B CB                mov        cx, bx
0x312f:  E2 EB                loop       0x311c
0x3131:  EB 17                jmp        0x314a
0x3133:  90                   nop        
0x3134:  5A                   pop        dx
0x3135:  5B                   pop        bx
0x3136:  E9 5B 09             jmp        RETURNINTERRUPTRESULT0
0x3139:  3C 02                cmp        al, 2
0x313b:  75 08                jne        0x3145
0x313d:  5A                   pop        dx
0x313e:  5B                   pop        bx
0x313f:  BB FF 00             mov        bx, 0xff
0x3142:  E9 4F 09             jmp        RETURNINTERRUPTRESULT0
0x3145:  5A                   pop        dx
0x3146:  5B                   pop        bx
0x3147:  E9 DC 08             jmp        RETURNINTERRUPTRESULT_8F
0x314a:  5A                   pop        dx
0x314b:  5B                   pop        bx
0x314c:  E9 2C 09             jmp        RETURNINTERRUPTRESULT_A0
0x314f:  5A                   pop        dx
0x3150:  5B                   pop        bx
0x3151:  E9 2C 09             jmp        RETURNINTERRUPTRESULT_A1

EMS_FUNCTION_0x55:
0x3154:  53                   push       bx
0x3155:  52                   push       dx
0x3156:  8B EC                mov        bp, sp
0x3158:  2E 8C 1E AB 28       mov        word ptr cs:[0x28ab], ds
0x315d:  2E 89 36 AD 28       mov        word ptr cs:[0x28ad], si
0x3162:  32 ED                xor        ch, ch
0x3164:  8A 4C 04             mov        cl, byte ptr [si + 4]
0x3167:  C5 74 05             lds        si, ptr [si + 5]
0x316a:  B4 50                mov        ah, 0x50
0x316c:  CD 67                int        0x67
0x316e:  80 FC 00             cmp        ah, 0
0x3171:  74 05                je         0x3178
0x3173:  5A                   pop        dx
0x3174:  5B                   pop        bx
0x3175:  E9 1E 09             jmp        RETURNINTERRUPTRESULT
0x3178:  2E 8E 1E AB 28       mov        ds, word ptr cs:[0x28ab]
0x317d:  2E 8B 36 AD 28       mov        si, word ptr cs:[0x28ad]
0x3182:  16                   push       ss
0x3183:  07                   pop        es
0x3184:  8B FD                mov        di, bp
0x3186:  83 C7 0C             add        di, 0xc
0x3189:  A5                   movsw      word ptr es:[di], word ptr [si]
0x318a:  A5                   movsw      word ptr es:[di], word ptr [si]
0x318b:  5A                   pop        dx
0x318c:  5B                   pop        bx
0x318d:  E9 04 09             jmp        RETURNINTERRUPTRESULT0
0x3190:  BB 20 00             mov        bx, 0x20
0x3193:  E9 FE 08             jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x56:
0x3196:  3C 02                cmp        al, 2
0x3198:  74 F6                je         0x3190
0x319a:  83 C4 02             add        sp, 2
0x319d:  2E 89 26 B1 28       mov        word ptr cs:[0x28b1], sp
0x31a2:  51                   push       cx
0x31a3:  56                   push       si
0x31a4:  57                   push       di
0x31a5:  55                   push       bp
0x31a6:  1E                   push       ds
0x31a7:  06                   push       es
0x31a8:  53                   push       bx
0x31a9:  52                   push       dx
0x31aa:  3C 02                cmp        al, 2
0x31ac:  72 03                jb         0x31b1
0x31ae:  E9 A4 00             jmp        EXITINTERRUPTA2
0x31b1:  2E 8C 1E AB 28       mov        word ptr cs:[0x28ab], ds
0x31b6:  2E 89 36 AD 28       mov        word ptr cs:[0x28ad], si
0x31bb:  2E A3 A3 28          mov        word ptr cs:[0x28a3], ax
0x31bf:  2E 89 16 A9 28       mov        word ptr cs:[0x28a9], dx
0x31c4:  32 ED                xor        ch, ch
0x31c6:  8A 4C 04             mov        cl, byte ptr [si + 4]
0x31c9:  8B 7C 05             mov        di, word ptr [si + 5]
0x31cc:  8B 5C 07             mov        bx, word ptr [si + 7]
0x31cf:  8B F7                mov        si, di
0x31d1:  8E DB                mov        ds, bx
0x31d3:  B4 50                mov        ah, 0x50
0x31d5:  CD 67                int        0x67
0x31d7:  80 FC 00             cmp        ah, 0
0x31da:  74 03                je         0x31df
0x31dc:  EB 77                jmp        EXITINTERRUPTA2
0x31de:  90                   nop        
0x31df:  2E 8B 2E B1 28       mov        bp, word ptr cs:[0x28b1]
0x31e4:  C7 46 06 11 32       mov        word ptr [bp + 6], 0x3211
0x31e9:  8C 4E 08             mov        word ptr [bp + 8], cs
0x31ec:  2E A1 AB 28          mov        ax, word ptr cs:[0x28ab]
0x31f0:  8E D8                mov        ds, ax
0x31f2:  2E 8B 36 AD 28       mov        si, word ptr cs:[0x28ad]
0x31f7:  8B 04                mov        ax, word ptr [si]
0x31f9:  89 46 00             mov        word ptr [bp], ax
0x31fc:  8B 44 02             mov        ax, word ptr [si + 2]
0x31ff:  89 46 02             mov        word ptr [bp + 2], ax
0x3202:  8B 46 0E             mov        ax, word ptr [bp + 0xe]
0x3205:  89 46 04             mov        word ptr [bp + 4], ax
0x3208:  5A                   pop        dx
0x3209:  5B                   pop        bx
0x320a:  07                   pop        es
0x320b:  1F                   pop        ds
0x320c:  5D                   pop        bp
0x320d:  5F                   pop        di
0x320e:  5E                   pop        si
0x320f:  59                   pop        cx
0x3210:  CF                   iret
0x3211:  52                   push       dx
0x3212:  53                   push       bx
0x3213:  06                   push       es
0x3214:  1E                   push       ds
0x3215:  55                   push       bp
0x3216:  57                   push       di
0x3217:  56                   push       si
0x3218:  51                   push       cx
0x3219:  9C                   pushf      
0x321a:  5D                   pop        bp
0x321b:  2E A1 AB 28          mov        ax, word ptr cs:[0x28ab]
0x321f:  8E D8                mov        ds, ax
0x3221:  2E 8B 36 AD 28       mov        si, word ptr cs:[0x28ad]
0x3226:  2E A1 A3 28          mov        ax, word ptr cs:[0x28a3]
0x322a:  2E 8B 16 A9 28       mov        dx, word ptr cs:[0x28a9]
0x322f:  32 ED                xor        ch, ch
0x3231:  8A 4C 09             mov        cl, byte ptr [si + 9]
0x3234:  8B 7C 0A             mov        di, word ptr [si + 0xa]
0x3237:  8B 5C 0C             mov        bx, word ptr [si + 0xc]
0x323a:  8B F7                mov        si, di
0x323c:  8E DB                mov        ds, bx
0x323e:  B4 50                mov        ah, 0x50
0x3240:  CD 67                int        0x67
0x3242:  8B DD                mov        bx, bp
0x3244:  2E 8B 2E B1 28       mov        bp, word ptr cs:[0x28b1]
0x3249:  89 5E 0E             mov        word ptr [bp + 0xe], bx
0x324c:  59                   pop        cx
0x324d:  5E                   pop        si
0x324e:  5F                   pop        di
0x324f:  5D                   pop        bp
0x3250:  1F                   pop        ds
0x3251:  07                   pop        es
0x3252:  5B                   pop        bx
0x3253:  5A                   pop        dx
0x3254:  CF                   iret
EXITINTERRUPTA2:
0x3255:  5A                   pop        dx
0x3256:  5B                   pop        bx
0x3257:  07                   pop        es
0x3258:  1F                   pop        ds
0x3259:  5D                   pop        bp
0x325a:  5F                   pop        di
0x325b:  5E                   pop        si
0x325c:  59                   pop        cx
0x325d:  83 C4 0A             add        sp, 0xa
0x3260:  CF                   iret

EMS_FUNCTION_0x57:
0x3261:  53                   push       bx
0x3262:  52                   push       dx
0x3263:  3C 01                cmp        al, 1
0x3265:  77 3C                ja         0x32a3
0x3267:  32 E4                xor        ah, ah
0x3269:  2E A3 A5 28          mov        word ptr cs:[0x28a5], ax
0x326d:  8C C8                mov        ax, cs
0x326f:  8E C0                mov        es, ax
0x3271:  BF BB 28             mov        di, 0x28bb
0x3274:  B9 12 00             mov        cx, 0x12
0x3277:  F3 A4                rep movsb  byte ptr es:[di], byte ptr [si]
0x3279:  0E                   push       cs
0x327a:  1F                   pop        ds
0x327b:  83 3E BD 28 10       cmp        word ptr [0x28bd], 0x10
0x3280:  75 05                jne        0x3287
0x3282:  83 3E BB 28 00       cmp        word ptr [0x28bb], 0
0x3287:  77 1F                ja         0x32a8
0x3289:  80 3E BF 28 01       cmp        byte ptr [0x28bf], 1
0x328e:  77 1D                ja         0x32ad
0x3290:  80 3E C6 28 01       cmp        byte ptr [0x28c6], 1
0x3295:  77 16                ja         0x32ad
0x3297:  A1 BB 28             mov        ax, word ptr [0x28bb]
0x329a:  0B 06 BD 28          or         ax, word ptr [0x28bd]
0x329e:  75 26                jne        0x32c6
0x32a0:  E9 E4 00             jmp        0x3387
0x32a3:  5A                   pop        dx
0x32a4:  5B                   pop        bx
0x32a5:  E9 7E 07             jmp        RETURNINTERRUPTRESULT_8F
0x32a8:  5A                   pop        dx
0x32a9:  5B                   pop        bx
0x32aa:  E9 9C 07             jmp        RETURNINTERRUPTRESULT_96
0x32ad:  5A                   pop        dx
0x32ae:  5B                   pop        bx
0x32af:  E9 A1 07             jmp        RETURNINTERRUPTRESULT_98
0x32b2:  5A                   pop        dx
0x32b3:  5B                   pop        bx
0x32b4:  E9 2E 07             jmp        RETURNINTERRUPTRESULT_80
0x32b7:  5A                   pop        dx
0x32b8:  5B                   pop        bx
0x32b9:  E9 88 07             jmp        RETURNINTERRUPTRESULT_95
0x32bc:  5A                   pop        dx
0x32bd:  5B                   pop        bx
0x32be:  E9 29 07             jmp        RETURNINTERRUPTRESULT_83
0x32c1:  5A                   pop        dx
0x32c2:  5B                   pop        bx
0x32c3:  E9 47 07             jmp        RETURNINTERRUPTRESULT_8A
0x32c6:  80 3E BF 28 01       cmp        byte ptr [0x28bf], 1
0x32cb:  75 4F                jne        0x331c
0x32cd:  81 3E C2 28 FF 3F    cmp        word ptr [0x28c2], 0x3fff
0x32d3:  77 E2                ja         0x32b7
0x32d5:  8B 16 C0 28          mov        dx, word ptr [0x28c0]
0x32d9:  E8 60 F6             call       GET_EMM_HANDLE
0x32dc:  72 DE                jb         0x32bc
0x32de:  A1 87 28             mov        ax, word ptr [0x2887]
0x32e1:  A3 CF 28             mov        word ptr [0x28cf], ax
0x32e4:  8B F0                mov        si, ax
0x32e6:  A1 C4 28             mov        ax, word ptr [0x28c4]
0x32e9:  39 04                cmp        word ptr [si], ax
0x32eb:  76 D4                jbe        0x32c1
0x32ed:  B8 00 40             mov        ax, 0x4000
0x32f0:  F7 26 C4 28          mul        word ptr [0x28c4]
0x32f4:  03 06 C2 28          add        ax, word ptr [0x28c2]
0x32f8:  83 D2 00             adc        dx, 0
0x32fb:  03 06 BB 28          add        ax, word ptr [0x28bb]
0x32ff:  13 16 BD 28          adc        dx, word ptr [0x28bd]
0x3303:  2D 01 00             sub        ax, 1
0x3306:  83 DA 00             sbb        dx, 0
0x3309:  B9 00 40             mov        cx, 0x4000
0x330c:  F7 F1                div        cx
0x330e:  39 04                cmp        word ptr [si], ax
0x3310:  76 AF                jbe        0x32c1
0x3312:  A3 B7 28             mov        word ptr [0x28b7], ax
0x3315:  89 16 B9 28          mov        word ptr [0x28b9], dx
0x3319:  E9 95 00             jmp        0x33b1
0x331c:  A1 C4 28             mov        ax, word ptr [0x28c4]
0x331f:  B1 04                mov        cl, 4
0x3321:  32 F6                xor        dh, dh
0x3323:  8A D4                mov        dl, ah
0x3325:  D2 EA                shr        dl, cl
0x3327:  C1 E0 04             shl        ax, 4
0x332a:  03 06 C2 28          add        ax, word ptr [0x28c2]
0x332e:  83 D2 00             adc        dx, 0
0x3331:  89 16 C4 28          mov        word ptr [0x28c4], dx
0x3335:  A3 C2 28             mov        word ptr [0x28c2], ax
0x3338:  03 06 BB 28          add        ax, word ptr [0x28bb]
0x333c:  13 16 BD 28          adc        dx, word ptr [0x28bd]
0x3340:  2D 01 00             sub        ax, 1
0x3343:  83 DA 00             sbb        dx, 0
0x3346:  83 FA 10             cmp        dx, 0x10
0x3349:  75 03                jne        0x334e
0x334b:  3D 00 00             cmp        ax, 0
0x334e:  77 5C                ja         0x33ac
0x3350:  89 16 B7 28          mov        word ptr [0x28b7], dx
0x3354:  A3 B9 28             mov        word ptr [0x28b9], ax
0x3357:  8B 1E 81 28          mov        bx, word ptr [0x2881]
0x335b:  C1 C3 04             rol        bx, 4
0x335e:  8B CB                mov        cx, bx
0x3360:  83 E3 F0             and        bx, 0xfff0
0x3363:  83 E1 0F             and        cx, 0xf
0x3366:  3B D1                cmp        dx, cx
0x3368:  75 02                jne        0x336c
0x336a:  3B C3                cmp        ax, bx
0x336c:  72 43                jb         0x33b1
0x336e:  8B 16 C4 28          mov        dx, word ptr [0x28c4]
0x3372:  A1 C2 28             mov        ax, word ptr [0x28c2]
0x3375:  81 C3 00 C0          add        bx, 0xc000
0x3379:  83 D1 00             adc        cx, 0
0x337c:  3B D1                cmp        dx, cx
0x337e:  75 02                jne        0x3382
0x3380:  3B C3                cmp        ax, bx
0x3382:  77 2D                ja         0x33b1
0x3384:  EB 1C                jmp        0x33a2
0x3386:  90                   nop        
0x3387:  5A                   pop        dx
0x3388:  5B                   pop        bx
0x3389:  B4 00                mov        ah, 0
0x338b:  2E 80 3E D1 28 FF    cmp        byte ptr cs:[0x28d1], 0xff
0x3391:  75 02                jne        0x3395
0x3393:  B4 92                mov        ah, 0x92
0x3395:  E9 FE 06             jmp        RETURNINTERRUPTRESULT
0x3398:  5A                   pop        dx
0x3399:  5B                   pop        bx
0x339a:  E9 4D 06             jmp        RETURNINTERRUPTRESULT_83
0x339d:  5A                   pop        dx
0x339e:  5B                   pop        bx
0x339f:  E9 6B 06             jmp        RETURNINTERRUPTRESULT_8A
0x33a2:  5A                   pop        dx
0x33a3:  5B                   pop        bx
0x33a4:  E9 98 06             jmp        RETURNINTERRUPTRESULT_94
0x33a7:  5A                   pop        dx
0x33a8:  5B                   pop        bx
0x33a9:  E9 98 06             jmp        RETURNINTERRUPTRESULT_95
0x33ac:  5A                   pop        dx
0x33ad:  5B                   pop        bx
0x33ae:  E9 D4 06             jmp        RETURNINTERRUPTRESULT_A2
0x33b1:  80 3E C6 28 01       cmp        byte ptr [0x28c6], 1
0x33b6:  75 4F                jne        0x3407
0x33b8:  81 3E C9 28 FF 3F    cmp        word ptr [0x28c9], 0x3fff
0x33be:  77 E7                ja         0x33a7
0x33c0:  8B 16 C7 28          mov        dx, word ptr [0x28c7]
0x33c4:  E8 75 F5             call       GET_EMM_HANDLE
0x33c7:  72 CF                jb         0x3398
0x33c9:  A1 87 28             mov        ax, word ptr [0x2887]
0x33cc:  A3 CD 28             mov        word ptr [0x28cd], ax
0x33cf:  8B F0                mov        si, ax
0x33d1:  A1 CB 28             mov        ax, word ptr [0x28cb]
0x33d4:  39 04                cmp        word ptr [si], ax
0x33d6:  76 C5                jbe        0x339d
0x33d8:  B8 00 40             mov        ax, 0x4000
0x33db:  F7 26 CB 28          mul        word ptr [0x28cb]
0x33df:  03 06 C9 28          add        ax, word ptr [0x28c9]
0x33e3:  83 D2 00             adc        dx, 0
0x33e6:  03 06 BB 28          add        ax, word ptr [0x28bb]
0x33ea:  13 16 BD 28          adc        dx, word ptr [0x28bd]
0x33ee:  2D 01 00             sub        ax, 1
0x33f1:  83 DA 00             sbb        dx, 0
0x33f4:  B9 00 40             mov        cx, 0x4000
0x33f7:  F7 F1                div        cx
0x33f9:  39 04                cmp        word ptr [si], ax
0x33fb:  76 A0                jbe        0x339d
0x33fd:  A3 B3 28             mov        word ptr [0x28b3], ax
0x3400:  89 16 B5 28          mov        word ptr [0x28b5], dx
0x3404:  EB 6F                jmp        0x3475
0x3406:  90                   nop        
0x3407:  A1 CB 28             mov        ax, word ptr [0x28cb]
0x340a:  B1 04                mov        cl, 4
0x340c:  32 F6                xor        dh, dh
0x340e:  8A D4                mov        dl, ah
0x3410:  D2 EA                shr        dl, cl
0x3412:  C1 E0 04             shl        ax, 4
0x3415:  03 06 C9 28          add        ax, word ptr [0x28c9]
0x3419:  83 D2 00             adc        dx, 0
0x341c:  89 16 CB 28          mov        word ptr [0x28cb], dx
0x3420:  A3 C9 28             mov        word ptr [0x28c9], ax
0x3423:  03 06 BB 28          add        ax, word ptr [0x28bb]
0x3427:  13 16 BD 28          adc        dx, word ptr [0x28bd]
0x342b:  2D 01 00             sub        ax, 1
0x342e:  83 DA 00             sbb        dx, 0
0x3431:  83 FA 10             cmp        dx, 0x10
0x3434:  75 03                jne        0x3439
0x3436:  3D 00 00             cmp        ax, 0
0x3439:  76 03                jbe        0x343e
0x343b:  E9 6E FF             jmp        0x33ac
0x343e:  89 16 B3 28          mov        word ptr [0x28b3], dx
0x3442:  A3 B5 28             mov        word ptr [0x28b5], ax
0x3445:  8B 1E 81 28          mov        bx, word ptr [0x2881]
0x3449:  C1 C3 04             rol        bx, 4
0x344c:  8B CB                mov        cx, bx
0x344e:  83 E3 F0             and        bx, 0xfff0
0x3451:  83 E1 0F             and        cx, 0xf
0x3454:  3B D1                cmp        dx, cx
0x3456:  75 02                jne        0x345a
0x3458:  3B C3                cmp        ax, bx
0x345a:  72 19                jb         0x3475
0x345c:  8B 16 CB 28          mov        dx, word ptr [0x28cb]
0x3460:  A1 C9 28             mov        ax, word ptr [0x28c9]
0x3463:  81 C3 00 C0          add        bx, 0xc000
0x3467:  83 D1 00             adc        cx, 0
0x346a:  3B D1                cmp        dx, cx
0x346c:  75 02                jne        0x3470
0x346e:  3B C3                cmp        ax, bx
0x3470:  77 03                ja         0x3475
0x3472:  E9 2D FF             jmp        0x33a2
0x3475:  C6 06 D1 28 00       mov        byte ptr [0x28d1], 0
0x347a:  C6 06 D2 28 00       mov        byte ptr [0x28d2], 0
0x347f:  80 3E BF 28 00       cmp        byte ptr [0x28bf], 0
0x3484:  75 0A                jne        0x3490
0x3486:  80 3E C6 28 00       cmp        byte ptr [0x28c6], 0
0x348b:  74 0D                je         0x349a
0x348d:  E9 92 00             jmp        0x3522
0x3490:  80 3E C6 28 01       cmp        byte ptr [0x28c6], 1
0x3495:  74 7A                je         0x3511
0x3497:  E9 88 00             jmp        0x3522
0x349a:  8B 0E C4 28          mov        cx, word ptr [0x28c4]
0x349e:  8B 1E C2 28          mov        bx, word ptr [0x28c2]
0x34a2:  8B 3E B7 28          mov        di, word ptr [0x28b7]
0x34a6:  8B 36 B9 28          mov        si, word ptr [0x28b9]
0x34aa:  8B 16 CB 28          mov        dx, word ptr [0x28cb]
0x34ae:  A1 C9 28             mov        ax, word ptr [0x28c9]
0x34b1:  3B D1                cmp        dx, cx
0x34b3:  75 07                jne        0x34bc
0x34b5:  3B C3                cmp        ax, bx
0x34b7:  75 03                jne        0x34bc
0x34b9:  E9 D8 05             jmp        RETURNINTERRUPTRESULT0
0x34bc:  72 3C                jb         0x34fa
0x34be:  3B D7                cmp        dx, di
0x34c0:  75 02                jne        0x34c4
0x34c2:  3B C6                cmp        ax, si
0x34c4:  77 5C                ja         0x3522
0x34c6:  89 3E C4 28          mov        word ptr [0x28c4], di
0x34ca:  89 36 C2 28          mov        word ptr [0x28c2], si
0x34ce:  89 0E B7 28          mov        word ptr [0x28b7], cx
0x34d2:  89 1E B9 28          mov        word ptr [0x28b9], bx
0x34d6:  8B 2E B3 28          mov        bp, word ptr [0x28b3]
0x34da:  89 2E CB 28          mov        word ptr [0x28cb], bp
0x34de:  8B 2E B5 28          mov        bp, word ptr [0x28b5]
0x34e2:  89 2E C9 28          mov        word ptr [0x28c9], bp
0x34e6:  89 16 B3 28          mov        word ptr [0x28b3], dx
0x34ea:  A3 B5 28             mov        word ptr [0x28b5], ax
0x34ed:  C6 06 D1 28 FF       mov        byte ptr [0x28d1], 0xff
0x34f2:  C6 06 D2 28 01       mov        byte ptr [0x28d2], 1
0x34f7:  EB 29                jmp        0x3522
0x34f9:  90                   nop        
0x34fa:  8B 16 B3 28          mov        dx, word ptr [0x28b3]
0x34fe:  A1 B5 28             mov        ax, word ptr [0x28b5]
0x3501:  3B D1                cmp        dx, cx
0x3503:  75 02                jne        0x3507
0x3505:  3B C3                cmp        ax, bx
0x3507:  72 19                jb         0x3522
0x3509:  C6 06 D1 28 FF       mov        byte ptr [0x28d1], 0xff
0x350e:  EB 12                jmp        0x3522
0x3510:  90                   nop        
0x3511:  A1 C0 28             mov        ax, word ptr [0x28c0]
0x3514:  39 06 C7 28          cmp        word ptr [0x28c7], ax
0x3518:  75 08                jne        0x3522
0x351a:  E9 7D FF             jmp        0x349a
0x351d:  5A                   pop        dx
0x351e:  5B                   pop        bx
0x351f:  E9 2C 05             jmp        RETURNINTERRUPTRESULT_97
0x3522:  80 3E D1 28 FF       cmp        byte ptr [0x28d1], 0xff
0x3527:  75 07                jne        0x3530
0x3529:  A1 A5 28             mov        ax, word ptr [0x28a5]
0x352c:  3C 01                cmp        al, 1
0x352e:  74 ED                je         0x351d
0x3530:  FC                   cld        
0x3531:  C7 06 D9 28 00 10    mov        word ptr [0x28d9], 0x1000
0x3537:  C7 06 DB 28 01 00    mov        word ptr [0x28db], 1
0x353d:  C7 06 D7 28 00 00    mov        word ptr [0x28d7], 0
0x3543:  C7 06 D5 28 00 40    mov        word ptr [0x28d5], 0x4000
0x3549:  C7 06 D3 28 00 00    mov        word ptr [0x28d3], 0
0x354f:  80 3E D2 28 00       cmp        byte ptr [0x28d2], 0
0x3554:  74 1F                je         0x3575
0x3556:  FD                   std        
0x3557:  C7 06 D9 28 00 F0    mov        word ptr [0x28d9], 0xf000
0x355d:  C7 06 DB 28 FF FF    mov        word ptr [0x28db], 0xffff
0x3563:  C7 06 D7 28 FF FF    mov        word ptr [0x28d7], 0xffff
0x3569:  C7 06 D5 28 FF FF    mov        word ptr [0x28d5], 0xffff
0x356f:  C7 06 D3 28 FF 3F    mov        word ptr [0x28d3], 0x3fff
0x3575:  B0 00                mov        al, 0
0x3577:  E8 13 F5             call       READWEIRDSTRUCTBYTE2
0x357a:  E8 00 F4             call       READEMSPORT
0x357d:  A3 A9 28             mov        word ptr [0x28a9], ax
0x3580:  B0 01                mov        al, 1
0x3582:  E8 08 F5             call       READWEIRDSTRUCTBYTE2
0x3585:  E8 F5 F3             call       READEMSPORT
0x3588:  A3 AD 28             mov        word ptr [0x28ad], ax
0x358b:  80 3E BF 28 00       cmp        byte ptr [0x28bf], 0
0x3590:  75 10                jne        0x35a2
0x3592:  A1 C4 28             mov        ax, word ptr [0x28c4]
0x3595:  C1 C8 04             ror        ax, 4
0x3598:  8E D8                mov        ds, ax
0x359a:  2E 8B 36 C2 28       mov        si, word ptr cs:[0x28c2]
0x359f:  EB 21                jmp        0x35c2
0x35a1:  90                   nop        
0x35a2:  2E 8B 36 C2 28       mov        si, word ptr cs:[0x28c2]
0x35a7:  2E 8E 1E 81 28       mov        ds, word ptr cs:[0x2881]
0x35ac:  2E 8B 1E C4 28       mov        bx, word ptr cs:[0x28c4]
0x35b1:  2E 8B 16 C0 28       mov        dx, word ptr cs:[0x28c0]
0x35b6:  B8 00 44             mov        ax, 0x4400
0x35b9:  CD 67                int        0x67
0x35bb:  0A E4                or         ah, ah
0x35bd:  74 03                je         0x35c2
0x35bf:  E9 F0 FC             jmp        0x32b2
0x35c2:  2E 80 3E C6 28 00    cmp        byte ptr cs:[0x28c6], 0
0x35c8:  75 19                jne        0x35e3
0x35ca:  2E A1 CB 28          mov        ax, word ptr cs:[0x28cb]
0x35ce:  C1 C8 04             ror        ax, 4
0x35d1:  8E C0                mov        es, ax
0x35d3:  2E 8B 3E C9 28       mov        di, word ptr cs:[0x28c9]
0x35d8:  2E 80 3E BF 28 00    cmp        byte ptr cs:[0x28bf], 0
0x35de:  74 32                je         0x3612
0x35e0:  E9 C5 00             jmp        0x36a8
0x35e3:  2E A1 81 28          mov        ax, word ptr cs:[0x2881]
0x35e7:  05 00 04             add        ax, 0x400
0x35ea:  8E C0                mov        es, ax
0x35ec:  2E 8B 3E C9 28       mov        di, word ptr cs:[0x28c9]
0x35f1:  2E 8B 1E CB 28       mov        bx, word ptr cs:[0x28cb]
0x35f6:  2E 8B 16 C7 28       mov        dx, word ptr cs:[0x28c7]
0x35fb:  B8 01 44             mov        ax, 0x4401
0x35fe:  CD 67                int        0x67
0x3600:  0A E4                or         ah, ah
0x3602:  74 03                je         0x3607
0x3604:  E9 AB FC             jmp        0x32b2
0x3607:  2E 80 3E BF 28 00    cmp        byte ptr cs:[0x28bf], 0
0x360d:  74 55                je         0x3664
0x360f:  E9 DA 00             jmp        0x36ec
0x3612:  2E A1 A5 28          mov        ax, word ptr cs:[0x28a5]
0x3616:  3D 00 00             cmp        ax, 0
0x3619:  74 0C                je         0x3627
0x361b:  26 8A 25             mov        ah, byte ptr es:[di]
0x361e:  8A 04                mov        al, byte ptr [si]
0x3620:  88 24                mov        byte ptr [si], ah
0x3622:  AA                   stosb      byte ptr es:[di], al
0x3623:  AC                   lodsb      al, byte ptr [si]
0x3624:  EB 02                   jmp        0x3628
0x3626:  90                      nop        
0x3627:  A4                      movsb      byte ptr es:[di], byte ptr [si]
0x3628:  2E 83 2E BB 28 01       sub        word ptr cs:[0x28bb], 1
0x362e:  2E 83 1E BD 28 00       sbb        word ptr cs:[0x28bd], 0
0x3634:  2E A1 BB 28             mov        ax, word ptr cs:[0x28bb]
0x3638:  2E 0B 06 BD 28          or         ax, word ptr cs:[0x28bd]
0x363d:  75 03                   jne        0x3642
0x363f:  E9 3A 01                jmp        0x377c
0x3642:  2E 3B 36 D7 28          cmp        si, word ptr cs:[0x28d7]
0x3647:  75 09                   jne        0x3652
0x3649:  8C D8                   mov        ax, ds
0x364b:  2E 03 06 D9 28          add        ax, word ptr cs:[0x28d9]
0x3650:  8E D8                   mov        ds, ax
0x3652:  2E 3B 3E D7 28          cmp        di, word ptr cs:[0x28d7]
0x3657:  75 B9                   jne        0x3612
0x3659:  8C C0                   mov        ax, es
0x365b:  2E 03 06 D9 28          add        ax, word ptr cs:[0x28d9]
0x3660:  8E C0                   mov        es, ax
0x3662:  EB AE                   jmp        0x3612
0x3664:  2E A1 A5 28             mov        ax, word ptr cs:[0x28a5]
0x3668:  3C 00                   cmp        al, 0
0x366a:  74 0C                   je         0x3678
0x366c:  26 8A 25                mov        ah, byte ptr es:[di]
0x366f:  8A 04                   mov        al, byte ptr [si]
0x3671:  88 24                   mov        byte ptr [si], ah
0x3673:  AA                      stosb      byte ptr es:[di], al
0x3674:  AC                      lodsb      al, byte ptr [si]
0x3675:  EB 02                   jmp        0x3679
0x3677:  90                      nop        
0x3678:  A4                      movsb      byte ptr es:[di], byte ptr [si]
0x3679:  2E 83 2E BB 28 01       sub        word ptr cs:[0x28bb], 1
0x367f:  2E 83 1E BD 28 00       sbb        word ptr cs:[0x28bd], 0
0x3685:  2E A1 BB 28             mov        ax, word ptr cs:[0x28bb]
0x3689:  2E 0B 06 BD 28          or         ax, word ptr cs:[0x28bd]
0x368e:  75 03                   jne        0x3693
0x3690:  E9 E9 00                jmp        0x377c
0x3693:  E8 BC 00                call       0x3752
0x3696:  2E 3B 36 D7 28          cmp        si, word ptr cs:[0x28d7]
0x369b:  75 C7                   jne        0x3664
0x369d:  8C D8                   mov        ax, ds
0x369f:  2E 03 06 D9 28          add        ax, word ptr cs:[0x28d9]
0x36a4:  8E D8                   mov        ds, ax
0x36a6:  EB BC                   jmp        0x3664
0x36a8:  2E A1 A5 28             mov        ax, word ptr cs:[0x28a5]
0x36ac:  3C 00                   cmp        al, 0
0x36ae:  74 0C                   je         0x36bc
0x36b0:  26 8A 25                mov        ah, byte ptr es:[di]
0x36b3:  8A 04                   mov        al, byte ptr [si]
0x36b5:  88 24                   mov        byte ptr [si], ah
0x36b7:  AA                      stosb      byte ptr es:[di], al
0x36b8:  AC                      lodsb      al, byte ptr [si]
0x36b9:  EB 02                   jmp        0x36bd
0x36bb:  90                      nop        
0x36bc:  A4                      movsb      byte ptr es:[di], byte ptr [si]
0x36bd:  2E 83 2E BB 28 01       sub        word ptr cs:[0x28bb], 1
0x36c3:  2E 83 1E BD 28 00       sbb        word ptr cs:[0x28bd], 0
0x36c9:  2E A1 BB 28             mov        ax, word ptr cs:[0x28bb]
0x36cd:  2E 0B 06 BD 28          or         ax, word ptr cs:[0x28bd]
0x36d2:  75 03                   jne        0x36d7
0x36d4:  E9 A5 00                jmp        0x377c
0x36d7:  E8 4A 00                call       0x3724
0x36da:  2E 3B 3E D7 28          cmp        di, word ptr cs:[0x28d7]
0x36df:  75 C7                   jne        0x36a8
0x36e1:  8C C0                   mov        ax, es
0x36e3:  2E 03 06 D9 28          add        ax, word ptr cs:[0x28d9]
0x36e8:  8E C0                   mov        es, ax
0x36ea:  EB BC                   jmp        0x36a8
0x36ec:  2E A1 A5 28             mov        ax, word ptr cs:[0x28a5]
0x36f0:  3D 00 00                cmp        ax, 0
0x36f3:  74 0C                   je         0x3701
0x36f5:  26 8A 25                mov        ah, byte ptr es:[di]
0x36f8:  8A 04                   mov        al, byte ptr [si]
0x36fa:  88 24                   mov        byte ptr [si], ah
0x36fc:  AA                      stosb      byte ptr es:[di], al
0x36fd:  AC                      lodsb      al, byte ptr [si]
0x36fe:  EB 02                   jmp        0x3702
0x3700:  90                      nop        
0x3701:  A4                      movsb      byte ptr es:[di], byte ptr [si]
0x3702:  2E 83 2E BB 28 01       sub        word ptr cs:[0x28bb], 1
0x3708:  2E 83 1E BD 28 00       sbb        word ptr cs:[0x28bd], 0
0x370e:  2E A1 BB 28             mov        ax, word ptr cs:[0x28bb]
0x3712:  2E 0B 06 BD 28          or         ax, word ptr cs:[0x28bd]
0x3717:  75 03                   jne        0x371c
0x3719:  EB 61                   jmp        0x377c
0x371b:  90                      nop        
0x371c:  E8 33 00                call       0x3752
0x371f:  E8 02 00                call       0x3724
0x3722:  EB C8                   jmp        0x36ec
0x3724:  2E 3B 36 D5 28          cmp        si, word ptr cs:[0x28d5]
0x3729:  75 22                   jne        0x374d
0x372b:  2E 8B 1E C4 28          mov        bx, word ptr cs:[0x28c4]
0x3730:  2E 03 1E DB 28          add        bx, word ptr cs:[0x28db]
0x3735:  2E 89 1E C4 28          mov        word ptr cs:[0x28c4], bx
0x373a:  2E 8B 16 C0 28          mov        dx, word ptr cs:[0x28c0]
0x373f:  B8 00 44                mov        ax, 0x4400
0x3742:  CD 67                   int        0x67
0x3744:  0A E4                   or         ah, ah
0x3746:  75 06                   jne        0x374e
0x3748:  2E 8B 36 D3 28          mov        si, word ptr cs:[0x28d3]
0x374d:  C3                      ret

0x374e:  58                      pop        ax
0x374f:  E9 60 FB                jmp        0x32b2
0x3752:  2E 3B 3E D5 28          cmp        di, word ptr cs:[0x28d5]
0x3757:  75 22                   jne        0x377b
0x3759:  2E 8B 1E CB 28          mov        bx, word ptr cs:[0x28cb]
0x375e:  2E 03 1E DB 28          add        bx, word ptr cs:[0x28db]
0x3763:  2E 89 1E CB 28          mov        word ptr cs:[0x28cb], bx
0x3768:  2E 8B 16 C7 28          mov        dx, word ptr cs:[0x28c7]
0x376d:  B8 01 44                mov        ax, 0x4401
0x3770:  CD 67                   int        0x67
0x3772:  0A E4                   or         ah, ah
0x3774:  75 D8                   jne        0x374e
0x3776:  2E 8B 3E D3 28          mov        di, word ptr cs:[0x28d3]
0x377b:  C3                      ret

0x377c:  0E                      push       cs
0x377d:  1F                      pop        ds
0x377e:  B0 00                   mov        al, 0
0x3780:  8B 1E A9 28             mov        bx, word ptr [0x28a9]
0x3784:  E8 0C F2                call       0x2993
0x3787:  B0 01                   mov        al, 1
0x3789:  8B 1E A9 28             mov        bx, word ptr [0x28a9]
0x378d:  E8 03 F2                call       0x2993
0x3790:  E9 F4 FB                jmp        0x3387

EMS_FUNCTION_0x58:
0x3793:  83 C4 0C                add        sp, 0xc
0x3796:  3C 00                   cmp        al, 0
0x3798:  75 28                   jne        EXITINTERRUPTB
0x379a:  1E                      push       ds
0x379b:  06                      push       es
0x379c:  56                      push       si
0x379d:  57                      push       di
0x379e:  53                      push       bx
0x379f:  0E                      push       cs
0x37a0:  1F                      pop        ds
0x37a1:  BE BF 27                mov        si, 0x27bf
0x37a4:  2E 8B 0E A1 28          mov        cx, word ptr cs:[0x28a1]
0x37a9:  8B 04                   mov        ax, word ptr [si]
0x37ab:  AB                      stosw      word ptr es:[di], ax
0x37ac:  8B 44 02                mov        ax, word ptr [si + 2]
0x37af:  AB                      stosw      word ptr es:[di], ax
0x37b0:  83 C6 04                add        si, 4
0x37b3:  E2 F4                   loop       0x37a9
0x37b5:  2E 8B 0E A1 28          mov        cx, word ptr cs:[0x28a1]
0x37ba:  B4 00                   mov        ah, 0
0x37bc:  5B                      pop        bx
0x37bd:  5F                      pop        di
0x37be:  5E                      pop        si
0x37bf:  07                      pop        es
0x37c0:  1F                      pop        ds
0x37c1:  CF                      iret
EXITINTERRUPTB:
0x37c2:  3C 01                   cmp        al, 1
0x37c4:  75 09                   jne        EXITINTERRUPTB_RESULT8F
0x37c6:  2E 8B 0E A1 28          mov        cx, word ptr cs:[0x28a1]
0x37cb:  B8 00 00                mov        ax, 0
0x37ce:  CF                      iret
EXITINTERRUPTB_RESULT8F:
0x37cf:  B4 8F                   mov        ah, 0x8f
0x37d1:  CF                      iret

EMS_FUNCTION_0x59:
0x37d2:  3C 00                   cmp        al, 0
0x37d4:  75 25                   jne        0x37fb
0x37d6:  0E                      push       cs
0x37d7:  1F                      pop        ds
0x37d8:  80 3E DD 28 FF          cmp        byte ptr [0x28dd], 0xff
0x37dd:  75 19                   jne        0x37f8
0x37df:  8D 36 E3 28             lea        si, [0x28e3]
0x37e3:  50                      push       ax
0x37e4:  2E A1 A1 28             mov        ax, word ptr cs:[0x28a1]
0x37e8:  D1 E0                   shl        ax, 1
0x37ea:  89 44 04                mov        word ptr [si + 4], ax
0x37ed:  58                      pop        ax
0x37ee:  51                      push       cx
0x37ef:  B9 05 00                mov        cx, 5
0x37f2:  F3 A5                   rep movsw  word ptr es:[di], word ptr [si]
0x37f4:  59                      pop        cx
0x37f5:  E9 9C 02                jmp        RETURNINTERRUPTRESULT0
0x37f8:  E9 94 02                jmp        RETURNINTERRUPTRESULT_A4
0x37fb:  3C 01                   cmp        al, 1
0x37fd:  75 0D                   jne        0x380c
0x37ff:  2E 8B 16 95 28          mov        dx, word ptr cs:[0x2895]
0x3804:  2E 8B 1E 89 28          mov        bx, word ptr cs:[0x2889]
0x3809:  E9 88 02                jmp        RETURNINTERRUPTRESULT0
0x380c:  E9 17 02                jmp        RETURNINTERRUPTRESULT_8F

EMS_FUNCTION_0x5a:
0x380f:  0E                      push       cs
0x3810:  1F                      pop        ds
0x3811:  3C 01                   cmp        al, 1
0x3813:  77 04                   ja         0x3819
0x3815:  53                      push       bx
0x3816:  E9 45 F3                jmp        0x2b5e
0x3819:  E9 0A 02                jmp        RETURNINTERRUPTRESULT_8F

EMS_FUNCTION_0x5B:
0x381c:  2E 80 3E DD 28 FF       cmp        byte ptr cs:[0x28dd], 0xff
0x3822:  75 2E                   jne        0x3852
0x3824:  3C 00                   cmp        al, 0
0x3826:  75 2D                   jne        0x3855
0x3828:  83 C4 0C                add        sp, 0xc
0x382b:  2E 8E 06 DF 28          mov        es, word ptr cs:[0x28df]
0x3830:  2E 8B 3E E1 28          mov        di, word ptr cs:[0x28e1]
0x3835:  8C C0                   mov        ax, es
0x3837:  0B C7                   or         ax, di
0x3839:  74 0A                   je         0x3845
0x383b:  51                      push       cx
0x383c:  2E 8B 0E A1 28          mov        cx, word ptr cs:[0x28a1]
0x3841:  E8 7C F2                call       0x2ac0
0x3844:  59                      pop        cx
0x3845:  2E 8E 06 DF 28          mov        es, word ptr cs:[0x28df]
0x384a:  2E 8B 3E E1 28          mov        di, word ptr cs:[0x28e1]
0x384f:  B3 00                   mov        bl, 0
0x3851:  CF                      iret
0x3852:  E9 3A 02                jmp        RETURNINTERRUPTRESULT_A4
0x3855:  3C 01                   cmp        al, 1
0x3857:  74 03                   je         0x385c
0x3859:  EB 34                   jmp        0x388f
0x385b:  90                      nop        
0x385c:  53                      push       bx
0x385d:  52                      push       dx
0x385e:  80 FB 00                cmp        bl, 0
0x3861:  75 25                   jne        0x3888
0x3863:  2E 89 3E E1 28          mov        word ptr cs:[0x28e1], di
0x3868:  2E 8C 06 DF 28          mov        word ptr cs:[0x28df], es
0x386d:  8C C0                   mov        ax, es
0x386f:  0B C7                   or         ax, di
0x3871:  74 0E                   je         0x3881
0x3873:  06                      push       es
0x3874:  1F                      pop        ds
0x3875:  8B F7                   mov        si, di
0x3877:  51                      push       cx
0x3878:  2E 8B 0E A1 28          mov        cx, word ptr cs:[0x28a1]
0x387d:  E8 65 F2                call       0x2ae5
0x3880:  59                      pop        cx
0x3881:  5A                      pop        dx
0x3882:  5B                      pop        bx
0x3883:  B4 00                   mov        ah, 0
0x3885:  E9 0C 02                jmp        RETURNINTERRUPTRESULT0
0x3888:  5A                      pop        dx
0x3889:  5B                      pop        bx
0x388a:  B4 9C                   mov        ah, 0x9c
0x388c:  E9 D8 01                jmp        RETURNINTERRUPTRESULT_9C
0x388f:  3C 02                   cmp        al, 2
0x3891:  75 13                   jne        0x38a6
0x3893:  2E A1 A1 28             mov        ax, word ptr cs:[0x28a1]
0x3897:  D1 E0                   shl        ax, 1
0x3899:  05 02 00                add        ax, 2
0x389c:  05 02 00                add        ax, 2
0x389f:  8B D0                   mov        dx, ax
0x38a1:  B4 00                   mov        ah, 0
0x38a3:  E9 EE 01                jmp        RETURNINTERRUPTRESULT0
0x38a6:  3C 03                   cmp        al, 3
0x38a8:  75 07                   jne        0x38b1
0x38aa:  B3 00                   mov        bl, 0
0x38ac:  B4 00                   mov        ah, 0
0x38ae:  E9 E3 01                jmp        RETURNINTERRUPTRESULT0
0x38b1:  3C 04                   cmp        al, 4
0x38b3:  75 0D                   jne        0x38c2
0x38b5:  80 FB 00                cmp        bl, 0
0x38b8:  75 05                   jne        0x38bf
0x38ba:  B4 00                   mov        ah, 0
0x38bc:  E9 D5 01                jmp        RETURNINTERRUPTRESULT0
0x38bf:  E9 A5 01                jmp        RETURNINTERRUPTRESULT_9C
0x38c2:  3C 05                   cmp        al, 5
0x38c4:  75 07                   jne        0x38cd
0x38c6:  B3 00                   mov        bl, 0
0x38c8:  B4 00                   mov        ah, 0
0x38ca:  E9 C7 01                jmp        RETURNINTERRUPTRESULT0
0x38cd:  3C 06                   cmp        al, 6
0x38cf:  75 0A                   jne        0x38db
0x38d1:  80 FB 00                cmp        bl, 0
0x38d4:  75 E9                   jne        0x38bf
0x38d6:  B4 00                   mov        ah, 0
0x38d8:  E9 B9 01                jmp        RETURNINTERRUPTRESULT0
0x38db:  3C 07                   cmp        al, 7
0x38dd:  75 0A                   jne        0x38e9
0x38df:  80 FB 00                cmp        bl, 0
0x38e2:  75 DB                   jne        0x38bf
0x38e4:  B4 00                   mov        ah, 0
0x38e6:  E9 AB 01                jmp        RETURNINTERRUPTRESULT0
0x38e9:  3C 08                   cmp        al, 8
0x38eb:  75 0A                   jne        0x38f7
0x38ed:  80 FB 00                cmp        bl, 0
0x38f0:  75 CD                   jne        0x38bf
0x38f2:  B4 00                   mov        ah, 0
0x38f4:  E9 9D 01                jmp        RETURNINTERRUPTRESULT0
0x38f7:  EB FE                   jmp        0x38f7

EMS_FUNCTION_0x5C:
0x38f9:  53                      push       bx
0x38fa:  8C C8                   mov        ax, cs
0x38fc:  8E D8                   mov        ds, ax
0x38fe:  8E C0                   mov        es, ax
0x3900:  8D 3E BD 00             lea        di, [0xbd]
0x3904:  57                      push       di
0x3905:  32 C0                   xor        al, al
0x3907:  BB FF 00                mov        bx, 0xff
0x390a:  B9 17 00                mov        cx, 0x17
0x390d:  F3 AA                   rep stosb  byte ptr es:[di], al
0x390f:  4B                      dec        bx
0x3910:  75 F8                   jne        0x390a
0x3912:  5F                      pop        di
0x3913:  81 C7 02 00             add        di, 2
0x3917:  8D 36 F0 28             lea        si, [0x28f0]
0x391b:  B9 08 00                mov        cx, 8
0x391e:  F3 A4                   rep movsb  byte ptr es:[di], byte ptr [si]
0x3920:  8D 06 CD 17             lea        ax, [0x17cd]
0x3924:  AB                      stosw      word ptr es:[di], ax
0x3925:  8D 3E CD 17             lea        di, [0x17cd]
0x3929:  33 C0                   xor        ax, ax
0x392b:  B9 DC 03                mov        cx, 0x3dc
0x392e:  81 C7 02 00             add        di, 2
0x3932:  AB                      stosw      word ptr es:[di], ax
0x3933:  E2 F9                   loop       0x392e
0x3935:  B8 FF 00                mov        ax, 0xff
0x3938:  48                      dec        ax
0x3939:  A3 85 28                mov        word ptr [0x2885], ax
0x393c:  A1 95 28                mov        ax, word ptr [0x2895]
0x393f:  A3 89 28                mov        word ptr [0x2889], ax
0x3942:  5B                      pop        bx
0x3943:  E9 4E 01                jmp        RETURNINTERRUPTRESULT0

EMS_FUNCTION_0x5D:
0x3946:  0E                      push       cs
0x3947:  1F                      pop        ds
0x3948:  83 C4 0C                add        sp, 0xc
0x394b:  3C 00                   cmp        al, 0
0x394d:  75 2B                   jne        0x397a
0x394f:  80 3E DE 28 FF          cmp        byte ptr [0x28de], 0xff
0x3954:  74 0B                   je         0x3961
0x3956:  8B 1E 75 28             mov        bx, word ptr [0x2875]
0x395a:  8B 0E 77 28             mov        cx, word ptr [0x2877]
0x395e:  EB 0D                   jmp        0x396d
0x3960:  90                      nop        
0x3961:  3B 1E 75 28             cmp        bx, word ptr [0x2875]
0x3965:  75 42                   jne        RETURNINTERRUPTRESULTA4
0x3967:  3B 0E 77 28             cmp        cx, word ptr [0x2877]
0x396b:  75 3C                   jne        RETURNINTERRUPTRESULTA4
0x396d:  C6 06 DD 28 FF          mov        byte ptr [0x28dd], 0xff
0x3972:  C6 06 DE 28 FF          mov        byte ptr [0x28de], 0xff
0x3977:  B4 00                   mov        ah, 0
0x3979:  CF                      iret

0x397a:  3C 01                   cmp        al, 1
0x397c:  75 31                   jne        0x39af
0x397e:  80 3E DE 28 FF          cmp        byte ptr [0x28de], 0xff
0x3983:  74 0B                   je         0x3990
0x3985:  8B 1E 75 28             mov        bx, word ptr [0x2875]
0x3989:  8B 0E 77 28             mov        cx, word ptr [0x2877]
0x398d:  EB 0D                   jmp        0x399c
0x398f:  90                      nop        
0x3990:  3B 1E 75 28             cmp        bx, word ptr [0x2875]
0x3994:  75 13                   jne        RETURNINTERRUPTRESULTA4
0x3996:  3B 0E 77 28             cmp        cx, word ptr [0x2877]
0x399a:  75 0D                   jne        RETURNINTERRUPTRESULTA4
0x399c:  C6 06 DD 28 00          mov        byte ptr [0x28dd], 0
0x39a1:  C6 06 DE 28 FF          mov        byte ptr [0x28de], 0xff
0x39a6:  B4 00                   mov        ah, 0
0x39a8:  CF                      iret

RETURNINTERRUPTRESULTA4:
0x39a9:  B4 A4                   mov        ah, 0xa4
0x39ab:  CF                      iret

RETURNINTERRUPTRESULT8F:
0x39ac:  B4 8F                   mov        ah, 0x8f
0x39ae:  CF                      iret

0x39af:  3C 02                   cmp        al, 2
0x39b1:  75 F9                   jne        RETURNINTERRUPTRESULT8F
0x39b3:  80 3E DE 28 FF          cmp        byte ptr [0x28de], 0xff
0x39b8:  75 EF                   jne        RETURNINTERRUPTRESULTA4
0x39ba:  3B 1E 75 28             cmp        bx, word ptr [0x2875]
0x39be:  75 E9                   jne        RETURNINTERRUPTRESULTA4
0x39c0:  3B 0E 77 28             cmp        cx, word ptr [0x2877]
0x39c4:  75 E3                   jne        RETURNINTERRUPTRESULTA4
0x39c6:  02 F9                   add        bh, cl
0x39c8:  2A EB                   sub        ch, bl
0x39ca:  86 FD                   xchg       ch, bh
0x39cc:  D1 C3                   rol        bx, 1
0x39ce:  D1 C9                   ror        cx, 1
0x39d0:  89 1E 75 28             mov        word ptr [0x2875], bx
0x39d4:  89 0E 77 28             mov        word ptr [0x2877], cx
0x39d8:  C6 06 DD 28 FF          mov        byte ptr [0x28dd], 0xff
0x39dd:  C6 06 DE 28 00          mov        byte ptr [0x28de], 0
0x39e2:  B4 00                   mov        ah, 0
0x39e4:  CF                      iret

; JUMP TABLE FOR EMS RETURN VALUES

; The manager detected a malfunction in the memory manager software.
RETURNINTERRUPTRESULT_80:
0x39e5:  B4 80                   mov        ah, 0x80
0x39e7:  E9 AC 00                jmp        RETURNINTERRUPTRESULT

; The memory manager couldn't find the EMM handle your program specified.
RETURNINTERRUPTRESULT_83:
0x39ea:  B4 83                   mov        ah, 0x83
0x39ec:  E9 A7 00                jmp        RETURNINTERRUPTRESULT

; The function code passed to the memory manager is not defined.
RETURNINTERRUPTRESULT_84:
0x39ef:  B4 84                   mov        ah, 0x84
0x39f1:  E9 A2 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_85:
0x39f4:  B4 85                   mov        ah, 0x85
0x39f6:  E9 9D 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_86:
0x39f9:  B4 86                   mov        ah, 0x86
0x39fb:  E9 98 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_87:
0x39fe:  B4 87                   mov        ah, 0x87
0x3a00:  E9 93 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_88:
0x3a03:  B4 88                   mov        ah, 0x88
0x3a05:  E9 8E 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_89:
0x3a08:  B4 89                   mov        ah, 0x89
0x3a0a:  E9 89 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_8A:
0x3a0d:  B4 8A                   mov        ah, 0x8a
0x3a0f:  E9 84 00                jmp        RETURNINTERRUPTRESULT

RETURNINTERRUPTRESULT_8B:
0x3a12:  B4 8B                   mov        ah, 0x8b
0x3a14:  E9 7F 00                jmp        RETURNINTERRUPTRESULT

;unused
; There is no room in the save area to store the state of the page mapping registers.  The state of the map registers has not been saved.
RETURNINTERRUPTRESULT_8C:
0x3a17:  B4 8C                   mov        ah, 0x8c
0x3a19:  EB 7B                   jmp        RETURNINTERRUPTRESULT
0x3a1b:  90                      nop        

; The save area already contains the page mapping register state for the EMM handle your program specified.
RETURNINTERRUPTRESULT_8D:
0x3a1c:  B4 8D                   mov        ah, 0x8d
0x3a1e:  EB 76                   jmp        RETURNINTERRUPTRESULT
0x3a20:  90                      nop        

; There is no page mapping register state in the save area for the specified EMM handle.  Your program didn't save the contents of the page mapping hardware, so Restore Page Map can't restore it.
RETURNINTERRUPTRESULT_8E:
0x3a21:  B4 8E                   mov        ah, 0x8e
0x3a23:  EB 71                   jmp        RETURNINTERRUPTRESULT
0x3a25:  90                      nop        

;The subfunction parameter is invalid.
RETURNINTERRUPTRESULT_8F:
0x3a26:  B4 8F                   mov        ah, 0x8f
0x3a28:  EB 6C                   jmp        RETURNINTERRUPTRESULT
0x3a2a:  90                      nop        

; The attribute type is undefined.
RETURNINTERRUPTRESULT_90:
0x3a2b:  B4 90                   mov        ah, 0x90
0x3a2d:  EB 67                   jmp        RETURNINTERRUPTRESULT
0x3a2f:  90                      nop        

; This feature is not supported.
RETURNINTERRUPTRESULT_91:
0x3a30:  B4 91                   mov        ah, 0x91
0x3a32:  EB 62                   jmp        RETURNINTERRUPTRESULT
0x3a34:  90                      nop        

; unused
; The source and destination expanded memory regions have the same handle and overlap.  This is valid for a move.  The move has been completed and the destination region has a
; full copy of the source region.  However, at least a portion of the source region has been overwritten by the move.  Note that the source and destination expanded memory
; regions with different handles will never physically overlap because the different handles specify totally different regions of expanded memory.
RETURNINTERRUPTRESULT_92:
0x3a35:  B4 92                   mov        ah, 0x92
0x3a37:  EB 5D                   jmp        RETURNINTERRUPTRESULT
0x3a39:  90                      nop        

; unused
; The length of the source or destination expanded memory region specified exceeds the length of the expanded memory region allocated either the source or destination handle.
; Insufficient pages are allocated to this handle to move a region of the size specified.  The program can recover from this condition by allocating additional pages to the
; destination or source handle and attempting to execute the function again.  However, if the application program allocated as much expanded memory as it thought it needed,
; this may be a program error and is not recoverable.
RETURNINTERRUPTRESULT_93:
0x3a3a:  B4 93                   mov        ah, 0x93
0x3a3c:  EB 58                   jmp        RETURNINTERRUPTRESULT
0x3a3e:  90                      nop        

; The conventional memory region and expanded memory region overlap.  This is invalid, the conventional memory region cannot overlap the expanded memory region.
RETURNINTERRUPTRESULT_94:
0x3a3f:  B4 94                   mov        ah, 0x94
0x3a41:  EB 53                   jmp        RETURNINTERRUPTRESULT
0x3a43:  90                      nop        

; The offset within the logical page exceeds the length of the logical page.  The initial source or destination offsets within an expanded memory region must be between 0000h and 3FFFh (16383 or (length of a logical page - 1)).
RETURNINTERRUPTRESULT_95:
0x3a44:  B4 95                   mov        ah, 0x95
0x3a46:  EB 4E                   jmp        RETURNINTERRUPTRESULT
0x3a48:  90                      nop        

; Region length exceeds 1M byte.
RETURNINTERRUPTRESULT_96:
0x3a49:  B4 96                   mov        ah, 0x96
0x3a4b:  EB 49                   jmp        RETURNINTERRUPTRESULT
0x3a4d:  90                      nop        

; The source and destination expanded memory regions have the same handle and overlap.  This is invalid, the source and destination expanded memory regions cannot have the same
; handle and overlap when they are being exchanged. Note that the source and destination expanded memory regions which have different handles will never physically overlap
; because the different handles specify totally different regions of expanded memory.
RETURNINTERRUPTRESULT_97:
0x3a4e:  B4 97                   mov        ah, 0x97
0x3a50:  EB 44                   jmp        RETURNINTERRUPTRESULT
0x3a52:  90                      nop        

; The memory source and destination types are undefined.
RETURNINTERRUPTRESULT_98:
0x3a53:  B4 98                   mov        ah, 0x98
0x3a55:  EB 3F                   jmp        RETURNINTERRUPTRESULT
0x3a57:  90                      nop        

; unused, nonexistant in spec
RETURNINTERRUPTRESULT_99:
0x3a58:  B4 99                   mov        ah, 0x99
0x3a5a:  EB 3A                   jmp        RETURNINTERRUPTRESULT
0x3a5c:  90                      nop        

; unused
; Alternate map register sets are supported, but the alternate map register set specified is not supported.
; Alternate DMA register sets are supported, but the alternate DMA register set specified is not supported.
RETURNINTERRUPTRESULT_9A:
0x3a5d:  B4 9A                   mov        ah, 0x9a
0x3a5f:  EB 35                   jmp        RETURNINTERRUPTRESULT
0x3a61:  90                      nop        

; unused
; Alternate map register sets are supported.  However, all alternate map register sets are currently allocated.
; Alternate DMA register sets are supported.  However, all alternate DMA register sets are currently allocated.
RETURNINTERRUPTRESULT_9B:
0x3a62:  B4 9B                   mov        ah, 0x9b
0x3a64:  EB 30                   jmp        RETURNINTERRUPTRESULT
0x3a66:  90                      nop        

; Alternate map register sets are not supported and the alternate map register set specified is not zero.
; Alternate DMA register sets are not supported and the alternate DMA register set specified is not zero.
RETURNINTERRUPTRESULT_9C:
0x3a67:  B4 9C                   mov        ah, 0x9c
0x3a69:  EB 2B                   jmp        RETURNINTERRUPTRESULT
0x3a6b:  90                      nop        

; unused
; Alternate map register sets are supported, but the alternate map register set specified is either not defined or not allocated.
; DMA register sets are supported, but the DMA register set specified is either not defined or not allocated.
RETURNINTERRUPTRESULT_9D:
0x3a6c:  B4 9D                   mov        ah, 0x9d
0x3a6e:  EB 26                   jmp        RETURNINTERRUPTRESULT
0x3a70:  90                      nop        

; unused
; Dedicated DMA channels are not supported.
RETURNINTERRUPTRESULT_9E:
0x3a71:  B4 9E                   mov        ah, 0x9e
0x3a73:  EB 21                   jmp        RETURNINTERRUPTRESULT
0x3a75:  90                      nop        

; unused
; Dedicated DMA channels are supported, but the DMA channel specified is not supported.
RETURNINTERRUPTRESULT_9f:
0x3a76:  B4 9F                   mov        ah, 0x9f
0x3a78:  EB 1C                   jmp        RETURNINTERRUPTRESULT
0x3a7a:  90                      nop        

; No corresponding handle could be found for the handle name specified.
RETURNINTERRUPTRESULT_A0:
0x3a7b:  B4 A0                   mov        ah, 0xa0
0x3a7d:  EB 17                   jmp        RETURNINTERRUPTRESULT
0x3a7f:  90                      nop        

; A handle found had no name (all ASCII nulls).
; A handle with this name already exists.  The specified handle was not assigned a name.
RETURNINTERRUPTRESULT_A1:
0x3a80:  B4 A1                   mov        ah, 0xa1
0x3a82:  EB 12                   jmp        RETURNINTERRUPTRESULT
0x3a84:  90                      nop        

; An attempt was made to wrap around the 1M-byte address space of conventional memory during the move.  The combination of source/destination 
; starting address and length of the region to be moved exceeds 1M byte.  No data was moved.
; An attempt was made to wrap around the 1M-byte address space of conventional memory during the exchange.  The source starting address together 
; with the length of the region to be exchanged exceeds 1M byte.  No data was exchanged.
RETURNINTERRUPTRESULT_A2:
0x3a85:  B4 A2                   mov        ah, 0xa2
0x3a87:  EB 0D                   jmp        RETURNINTERRUPTRESULT
0x3a89:  90                      nop        

; The contents of the source array have been corrupted, or the pointer passed to the subfunction is invalid.
RETURNINTERRUPTRESULT_A3:
0x3a8a:  B4 A3                   mov        ah, 0xa3
0x3a8c:  EB 08                   jmp        RETURNINTERRUPTRESULT
0x3a8e:  90                      nop        

; The operating system has denied access to this function. The function cannot be used at this time.
RETURNINTERRUPTRESULT_A4:
0x3a8f:  B4 A4                   mov        ah, 0xa4
0x3a91:  EB 03                   jmp        RETURNINTERRUPTRESULT
0x3a93:  90                      nop        

RETURNINTERRUPTRESULT0:
0x3a94:  B4 00                   mov        ah, 0
RETURNINTERRUPTRESULT:
0x3a96:  07                      pop        es
0x3a97:  1F                      pop        ds
0x3a98:  5D                      pop        bp
0x3a99:  5F                      pop        di
0x3a9a:  5E                      pop        si
0x3a9b:  59                      pop        cx
0x3a9c:  CF                      iret

; TODO SOME VARIABLES

; 0x3ab5: 3 byte structs, 0xE of them.

010004 020006 030008 040008 050010 060018 070020 080020 09803F 0A0020 0B803F 0C000C 0D0014 0E0030

; 3ADF something else

; 0x3ae3  stores slot pointer * 4
; 0x3ae7  stores slot pointer

; TODO STRINGS GO HERE


DRIVER_INIT:
0x3f57:  8C C8                   mov        ax, cs
0x3f59:  8E D8                   mov        ds, ax
0x3f5b:  C7 06 48 00 A5 00       mov        word ptr [0x48], 0xa5
0x3f61:  8D 16 0B 3B             lea        dx, [0x3b0b]
0x3f65:  E8 67 05                call       PRINT_STRING
; get interrupt vector. check it's header/string
0x3f68:  B8 67 35                mov        ax, 0x3567
0x3f6b:  CD 21                   int        0x21
0x3f6d:  BF 0A 00                mov        di, 0xa
0x3f70:  8B F7                   mov        si, di
0x3f72:  B9 08 00                mov        cx, 8
0x3f75:  F3 A6                   repe cmpsb byte ptr [si], byte ptr es:[di]
 
0x3f77:  75 07                   jne        EMS_INTERRUPT_FREE
; an ems driver is already installed
0x3f79:  8D 16 EA 3A             lea        dx, [0x3aea]
0x3f7d:  E9 37 05                jmp        DRIVER_NOT_INSTALLED_2

EMS_INTERRUPT_FREE:
0x3f80:  B0 03                   mov        al, 3           ; register 03h  DRAM Map Register 
0x3f82:  E8 E2 E9                call       READCHIPSETREG
0x3f85:  8A E0                   mov        ah, al
0x3f87:  24 0F                   and        al, 0xf
0x3f89:  3C 00                   cmp        al, 0
0x3f8b:  72 14                   jb         INIT_ERROR_RAM
0x3f8d:  3C 0F                   cmp        al, 0xf
0x3f8f:  7D 10                   jge        INIT_ERROR_RAM  ; 0x0f (1111) is an invalid value for MEMAP0-3

; use 3ab5 lookup table to find this configuration value
; it's a preconfigured lookup table of words
0x3f91:  B9 0E 00                mov        cx, 0xe
0x3f94:  8D 36 B5 3A             lea        si, [0x3ab5]
CHECK_NEXT_STRUCT:
0x3f98:  38 04                   cmp        byte ptr [si], al
0x3f9a:  74 0C                   je         INIT_RAM_OK:
0x3f9c:  83 C6 03                add        si, 3
0x3f9f:  E2 F7                   loop       CHECK_NEXT_STRUCT

"System ram specified error"
INIT_ERROR_RAM:
0x3fa1:  8D 16 31 3D             lea        dx, [0x3d31]
0x3fa5:  E9 08 05                jmp        DRIVER_NOT_INSTALLED

INIT_RAM_OK:
0x3fa8:  F6 C4 10                test       ah, 0x10
0x3fab:  74 17                   je         MYSTERY_1
0x3fad:  81 7C 01 00 08          cmp        word ptr [si + 1], 0x800
0x3fb2:  74 19                   je         MYSTERY_2
0x3fb4:  81 7C 01 00 0C          cmp        word ptr [si + 1], 0xc00
0x3fb9:  74 12                   je         MYSTERY_2
0x3fbb:  81 7C 01 00 10          cmp        word ptr [si + 1], 0x1000
0x3fc0:  74 0B                   je         MYSTERY_2
0x3fc2:  EB DD                   jmp        INIT_ERROR_RAM

; MEMAP == 0x10
MYSTERY_1:
0x3fc4:  C7 06 E8 3A 00 00       mov        word ptr [0x3ae8], 0
0x3fca:  EB 07                   jmp        MYSTERY_3
0x3fcc:  90                      nop        

MYSTERY_2:
0x3fcd:  C7 06 E8 3A 80 01       mov        word ptr [0x3ae8], 0x180

MYSTERY_3:
0x3fd3:  8B 44 01                mov        ax, word ptr [si + 1]
0x3fd6:  03 06 E8 3A             add        ax, word ptr [0x3ae8]
0x3fda:  A3 DF 3A                mov        word ptr [0x3adf], ax

0x3fdd:  B0 02                   mov        al, 2     ; register 02h  SLTPTR 
0x3fdf:  E8 85 E9                call       READCHIPSETREG
0x3fe2:  3C 10                   cmp        al, 0x10            ; 0x10 slotpointer means at least 1M
0x3fe4:  73 02                   jae        AT_LEAST_1_MEG_SLOT_POINTER
0x3fe6:  B0 10                   mov        al, 0x10            ; adjust slot pointer downward

AT_LEAST_1_MEG_SLOT_POINTER:
0x3fe8:  A2 E7 3A                mov        byte ptr [0x3ae7], al
0x3feb:  32 E4                   xor        ah, ah
0x3fed:  C1 E0 02                shl        ax, 2
0x3ff0:  A3 E3 3A                mov        word ptr [0x3ae3], ax
0x3ff3:  C1 E0 04                shl        ax, 4
0x3ff6:  3B 06 DF 3A             cmp        ax, word ptr [0x3adf]

0x3ffa:  72 0C                   jb         0x4008
0x3ffc:  74 03                   je         0x4001
0x3ffe:  E9 DE 00                jmp        0x40df
0x4001:  8D 16 F8 3B             lea        dx, [0x3bf8]
0x4005:  E9 A8 04                jmp        DRIVER_NOT_INSTALLED
0x4008:  93                      xchg       ax, bx
0x4009:  A1 DF 3A                mov        ax, word ptr [0x3adf]
0x400c:  2B C3                   sub        ax, bx
0x400e:  A3 E1 3A                mov        word ptr [0x3ae1], ax
0x4011:  B1 04                   mov        cl, 4
0x4013:  D3 E8                   shr        ax, cl
0x4015:  A3 95 28                mov        word ptr [0x2895], ax
0x4018:  B0 0B                   mov        al, 0xb
0x401a:  E8 4A E9                call       READCHIPSETREG
0x401d:  0C 80                   or         al, 0x80
0x401f:  8A E0                   mov        ah, al
0x4021:  B0 0B                   mov        al, 0xb
0x4023:  E8 4A E9                call       WRITECHIPSETREG
0x4026:  C4 36 71 28             les        si, ptr [0x2871]
0x402a:  26 C4 74 12             les        si, ptr es:[si + 0x12]
0x402e:  EB 02                   jmp        0x4032
0x4030:  90                      nop        
0x4031:  46                      inc        si
0x4032:  26 80 3C 20             cmp        byte ptr es:[si], 0x20
0x4036:  74 F9                   je         0x4031
0x4038:  26 80 3C 0D             cmp        byte ptr es:[si], 0xd
0x403c:  75 03                   jne        0x4041
0x403e:  EB 59                   jmp        0x4099
0x4040:  90                      nop        
0x4041:  26 80 3C 0A             cmp        byte ptr es:[si], 0xa
0x4045:  75 03                   jne        0x404a
0x4047:  EB 50                   jmp        0x4099
0x4049:  90                      nop        
0x404a:  26 80 3C 1A             cmp        byte ptr es:[si], 0x1a
0x404e:  75 03                   jne        0x4053
0x4050:  EB 47                   jmp        0x4099
0x4052:  90                      nop        
0x4053:  26 80 24 DF             and        byte ptr es:[si], 0xdf
0x4057:  26 80 3C 46             cmp        byte ptr es:[si], 0x46
0x405b:  74 02                   je         0x405f
0x405d:  EB D2                   jmp        0x4031
0x405f:  26 80 7C 01 3A          cmp        byte ptr es:[si + 1], 0x3a
0x4064:  75 CB                   jne        0x4031
0x4066:  26 80 7C 02 30          cmp        byte ptr es:[si + 2], 0x30
0x406b:  72 C4                   jb         0x4031
0x406d:  26 80 7C 02 38          cmp        byte ptr es:[si + 2], 0x38
0x4072:  77 BD                   ja         0x4031
0x4074:  26 8A 44 02             mov        al, byte ptr es:[si + 2]
0x4078:  2C 30                   sub        al, 0x30
0x407a:  8A F8                   mov        bh, al
0x407c:  A2 4E 3F                mov        byte ptr [0x3f4e], al
0x407f:  83 C6 03                add        si, 3
0x4082:  EB AE                   jmp        0x4032
0x4084:  8D 16 0E 3C             lea        dx, [0x3c0e]
0x4088:  E9 25 04                jmp        DRIVER_NOT_INSTALLED
0x408b:  8D 16 3C 3C             lea        dx, [0x3c3c]
0x408f:  E9 1E 04                jmp        DRIVER_NOT_INSTALLED
0x4092:  8D 16 69 3C             lea        dx, [0x3c69]
0x4096:  E9 17 04                jmp        DRIVER_NOT_INSTALLED
0x4099:  8D 16 97 3C             lea        dx, [0x3c97]
0x409d:  E8 2F 04                call       PRINT_STRING
0x40a0:  A0 4E 3F                mov        al, byte ptr [0x3f4e]
0x40a3:  B3 06                   mov        bl, 6
0x40a5:  F6 E3                   mul        bl
0x40a7:  8D 16 18 3F             lea        dx, [0x3f18]
0x40ab:  03 D0                   add        dx, ax
0x40ad:  E8 1F 04                call       PRINT_STRING
0x40b0:  32 E4                   xor        ah, ah
0x40b2:  8A C7                   mov        al, bh
0x40b4:  E8 E3 04                call       FIND_BIOSES
0x40b7:  32 E4                   xor        ah, ah
0x40b9:  A0 4E 3F                mov        al, byte ptr [0x3f4e]
0x40bc:  E8 85 04                call       0x4544
0x40bf:  A3 81 28                mov        word ptr [0x2881], ax
0x40c2:  8D 16 08 3D             lea        dx, [0x3d08]
0x40c6:  E8 06 04                call       PRINT_STRING
0x40c9:  06                      push       es
0x40ca:  57                      push       di
0x40cb:  0E                      push       cs
0x40cc:  07                      pop        es
0x40cd:  BF 2B 3D                mov        di, 0x3d2b
0x40d0:  E8 39 04                call       HEX_WORD_TO_ASCII
0x40d3:  8D 16 2B 3D             lea        dx, [0x3d2b]
0x40d7:  E8 F5 03                call       PRINT_STRING
0x40da:  5F                      pop        di
0x40db:  07                      pop        es
0x40dc:  EB 35                   jmp        0x4113
0x40de:  90                      nop        
0x40df:  8D 16 7C 3D             lea        dx, [0x3d7c]
0x40e3:  E9 CA 03                jmp        DRIVER_NOT_INSTALLED
0x40e6:  E9 48 FF                jmp        0x4031
0x40e9:  26 80 3C 42             cmp        byte ptr es:[si], 0x42
0x40ed:  75 F7                   jne        0x40e6
0x40ef:  26 80 7C 01 3A          cmp        byte ptr es:[si + 1], 0x3a
0x40f4:  75 F0                   jne        0x40e6
0x40f6:  26 80 7C 02 30          cmp        byte ptr es:[si + 2], 0x30
0x40fb:  72 E9                   jb         0x40e6
0x40fd:  26 80 7C 02 31          cmp        byte ptr es:[si + 2], 0x31
0x4102:  77 E2                   ja         0x40e6
0x4104:  26 8A 44 02             mov        al, byte ptr es:[si + 2]
0x4108:  2C 30                   sub        al, 0x30
0x410a:  A2 ED 28                mov        byte ptr [0x28ed], al
0x410d:  83 C6 03                add        si, 3
0x4110:  E9 1F FF                jmp        0x4032
0x4113:  80 3E ED 28 00          cmp        byte ptr [0x28ed], 0
0x4118:  74 09                   je         0x4123
0x411a:  C7 06 A1 28 24 00       mov        word ptr [0x28a1], 0x24
0x4120:  EB 07                   jmp        0x4129
0x4122:  90                      nop        
0x4123:  C7 06 A1 28 0C 00       mov        word ptr [0x28a1], 0xc
0x4129:  C7 06 A6 17 00 00       mov        word ptr [0x17a6], 0
0x412f:  BB B5 17                mov        bx, 0x17b5
0x4132:  B9 0C 00                mov        cx, 0xc
0x4135:  2E 80 3F FF             cmp        byte ptr cs:[bx], 0xff
0x4139:  75 08                   jne        0x4143
0x413b:  83 2E A1 28 01          sub        word ptr [0x28a1], 1
0x4140:  EB 07                   jmp        0x4149
0x4142:  90                      nop        
0x4143:  2E 83 06 A6 17 01       add        word ptr cs:[0x17a6], 1
0x4149:  43                      inc        bx
0x414a:  E2 E9                   loop       0x4135
0x414c:  A1 81 28                mov        ax, word ptr [0x2881]
0x414f:  BE 49 27                mov        si, 0x2749
0x4152:  B9 04 00                mov        cx, 4
0x4155:  8B D8                   mov        bx, ax
0x4157:  81 EB 00 C0             sub        bx, 0xc000
0x415b:  C1 EB 0A                shr        bx, 0xa
0x415e:  89 04                   mov        word ptr [si], ax
0x4160:  88 5C 02                mov        byte ptr [si + 2], bl
0x4163:  83 C6 03                add        si, 3
0x4166:  05 00 04                add        ax, 0x400
0x4169:  E2 EA                   loop       0x4155
0x416b:  8B D0                   mov        dx, ax
0x416d:  81 3E 81 28 00 C0       cmp        word ptr [0x2881], 0xc000
0x4173:  74 2C                   je         0x41a1
0x4175:  B8 00 C0                mov        ax, 0xc000
0x4178:  8B D8                   mov        bx, ax
0x417a:  81 EB 00 C0             sub        bx, 0xc000
0x417e:  C1 EB 0A                shr        bx, 0xa
0x4182:  80 BF B5 17 FF       cmp        byte ptr [bx + 0x17b5], 0xff
0x4187:  74 08                je         0x4191
0x4189:  89 04                mov        word ptr [si], ax
0x418b:  88 5C 02             mov        byte ptr [si + 2], bl
0x418e:  83 C6 03             add        si, 3
0x4191:  05 00 04             add        ax, 0x400
0x4194:  3B 06 81 28          cmp        ax, word ptr [0x2881]
0x4198:  75 DE                jne        0x4178
0x419a:  8B C2                mov        ax, dx
0x419c:  3D 00 F0             cmp        ax, 0xf000
0x419f:  74 21                je         0x41c2
0x41a1:  8B D8                mov        bx, ax
0x41a3:  81 EB 00 C0          sub        bx, 0xc000
0x41a7:  C1 EB 0A             shr        bx, 0xa
NOSMART
0x41aa:  2E 80 BF B5 17 FF    cmp        byte ptr cs:[bx + 0x17b5], 0xff
SMART
0x41b0:  74 08                je         0x41ba
0x41b2:  89 04                mov        word ptr [si], ax
0x41b4:  88 5C 02             mov        byte ptr [si + 2], bl
0x41b7:  83 C6 03             add        si, 3
0x41ba:  05 00 04             add        ax, 0x400
0x41bd:  3D 00 F0             cmp        ax, 0xf000
0x41c0:  75 DF                jne        0x41a1
0x41c2:  80 3E ED 28 00       cmp        byte ptr [0x28ed], 0
0x41c7:  74 17                je         0x41e0
0x41c9:  B3 0C                mov        bl, 0xc
0x41cb:  B8 00 40             mov        ax, 0x4000
0x41ce:  B9 18 00             mov        cx, 0x18
0x41d1:  88 5C 02             mov        byte ptr [si + 2], bl
0x41d4:  89 04                mov        word ptr [si], ax
0x41d6:  FE C3                inc        bl
0x41d8:  83 C6 03             add        si, 3
0x41db:  05 00 04             add        ax, 0x400
0x41de:  E2 F1                loop       0x41d1
0x41e0:  A1 81 28             mov        ax, word ptr [0x2881]
0x41e3:  8E C0                mov        es, ax
0x41e5:  B0 80                mov        al, 0x80
0x41e7:  E6 61                out        0x61, al
0x41e9:  1E                   push       ds
0x41ea:  6A 40                push       0x40
0x41ec:  1F                   pop        ds
0x41ed:  A1 60 00             mov        ax, word ptr [0x60]
0x41f0:  1F                   pop        ds
0x41f1:  A3 E5 3A             mov        word ptr [0x3ae5], ax
0x41f4:  B9 00 0F             mov        cx, 0xf00
0x41f7:  B4 01                mov        ah, 1
0x41f9:  CD 10                int        0x10
0x41fb:  8B 0E 95 28          mov        cx, word ptr [0x2895]
0x41ff:  8B 1E E3 3A          mov        bx, word ptr [0x3ae3]
0x4203:  32 C0                xor        al, al
0x4205:  E8 8B E7             call       0x2993
0x4208:  51                   push       cx
0x4209:  B9 00 20             mov        cx, 0x2000
0x420c:  B8 FE FF             mov        ax, 0xfffe
0x420f:  33 FF                xor        di, di
0x4211:  F3 AB                rep stosw  word ptr es:[di], ax
0x4213:  59                   pop        cx
0x4214:  43                   inc        bx
0x4215:  E2 EC                loop       0x4203
0x4217:  8B 2E 95 28          mov        bp, word ptr [0x2895]
0x421b:  33 C0                xor        ax, ax
0x421d:  A3 95 28             mov        word ptr [0x2895], ax
0x4220:  8D 36 CD 17          lea        si, [0x17cd]
0x4224:  80 3E ED 28 00       cmp        byte ptr [0x28ed], 0
0x4229:  74 03                je         0x422e
0x422b:  83 C6 60             add        si, 0x60
0x422e:  B8 00 00             mov        ax, 0
0x4231:  B1 04                mov        cl, 4
0x4233:  F6 E1                mul        cl
0x4235:  03 F0                add        si, ax
0x4237:  8B 1E E3 3A          mov        bx, word ptr [0x3ae3]
0x423b:  8D 16 13 3F          lea        dx, [0x3f13]
0x423f:  E8 8D 02             call       PRINT_STRING
0x4242:  A1 95 28             mov        ax, word ptr [0x2895]
0x4245:  8D 16 83 3E          lea        dx, [0x3e83]
0x4249:  E8 83 02             call       PRINT_STRING
0x424c:  8D 16 A8 3E          lea        dx, [0x3ea8]
0x4250:  E8 7C 02             call       PRINT_STRING
0x4253:  40                   inc        ax
0x4254:  50                   push       ax
0x4255:  E8 82 02             call       0x44da
0x4258:  8D 16 83 3E          lea        dx, [0x3e83]
0x425c:  E8 70 02             call       PRINT_STRING
0x425f:  80 3E 56 3F 01       cmp        byte ptr [0x3f56], 1
0x4264:  75 03                jne        0x4269
0x4266:  E9 B5 00             jmp        0x431e
0x4269:  B4 01                mov        ah, 1
0x426b:  CD 16                int        0x16
0x426d:  74 1B                je         0x428a
0x426f:  B4 00                mov        ah, 0
0x4271:  CD 16                int        0x16
0x4273:  3C 1B                cmp        al, 0x1b
0x4275:  75 13                jne        0x428a
0x4277:  C6 06 56 3F 01       mov        byte ptr [0x3f56], 1
0x427c:  8D 16 83 3E          lea        dx, [0x3e83]
0x4280:  E8 4C 02             call       PRINT_STRING
0x4283:  8D 16 CD 3E          lea        dx, [0x3ecd]
0x4287:  E8 45 02             call       PRINT_STRING
0x428a:  B9 04 00             mov        cx, 4
0x428d:  32 C0                xor        al, al
0x428f:  E8 01 E7             call       0x2993
0x4292:  FE C0                inc        al
0x4294:  E2 F9                loop       0x428f
0x4296:  B8 34 12             mov        ax, 0x1234
0x4299:  B9 00 20             mov        cx, 0x2000
0x429c:  33 FF                xor        di, di
0x429e:  F3 AF                repe scasw ax, word ptr es:[di]
0x42a0:  B8 34 12             mov        ax, 0x1234
0x42a3:  B9 00 20             mov        cx, 0x2000
0x42a6:  33 FF                xor        di, di
0x42a8:  F3 AF                repe scasw ax, word ptr es:[di]
0x42aa:  E4 61                in         al, 0x61
0x42ac:  8A E0                mov        ah, al
0x42ae:  80 CC 0C             or         ah, 0xc
0x42b1:  24 F3                and        al, 0xf3
0x42b3:  B9 02 00             mov        cx, 2
0x42b6:  86 C4                xchg       ah, al
0x42b8:  E6 61                out        0x61, al
0x42ba:  EB 00                jmp        0x42bc
0x42bc:  EB 00                jmp        0x42be
0x42be:  E2 F6                loop       0x42b6
0x42c0:  B8 FE FF             mov        ax, 0xfffe
0x42c3:  33 FF                xor        di, di
0x42c5:  B9 00 20             mov        cx, 0x2000
0x42c8:  26 39 05             cmp        word ptr es:[di], ax
0x42cb:  75 13                jne        0x42e0
0x42cd:  83 C7 02             add        di, 2
0x42d0:  E2 F6                loop       0x42c8
0x42d2:  EB 15                jmp        0x42e9
0x42d4:  90                   nop        
0x42d5:  50                   push       ax
0x42d6:  E4 61                in         al, 0x61
0x42d8:  A8 C0                test       al, 0xc0
0x42da:  58                   pop        ax
0x42db:  74 0C                je         0x42e9
0x42dd:  EB 50                jmp        0x432f
0x42df:  90                   nop        
0x42e0:  26 39 05             cmp        word ptr es:[di], ax
0x42e3:  EB 00                jmp        0x42e5
0x42e5:  75 48                jne        0x432f
0x42e7:  EB E4                jmp        0x42cd
0x42e9:  3D FE FF             cmp        ax, 0xfffe
0x42ec:  74 0D                je         0x42fb
0x42ee:  3D 55 AA             cmp        ax, 0xaa55
0x42f1:  74 0E                je         0x4301
0x42f3:  3D AA 55             cmp        ax, 0x55aa
0x42f6:  74 0F                je         0x4307
0x42f8:  EB 1B                jmp        0x4315
0x42fa:  90                   nop        
0x42fb:  B8 55 AA             mov        ax, 0xaa55
0x42fe:  EB 0A                jmp        0x430a
0x4300:  90                   nop        
0x4301:  B8 AA 55             mov        ax, 0x55aa
0x4304:  EB 04                jmp        0x430a
0x4306:  90                   nop        
0x4307:  B8 01 01             mov        ax, 0x101
0x430a:  81 EF 00 40          sub        di, 0x4000
0x430e:  B9 00 20             mov        cx, 0x2000
0x4311:  F3 AB                rep stosw  word ptr es:[di], ax
0x4313:  EB B0                jmp        0x42c5
0x4315:  33 FF                xor        di, di
0x4317:  33 C0                xor        ax, ax
0x4319:  B9 00 20             mov        cx, 0x2000
0x431c:  F3 AB                rep stosw  word ptr es:[di], ax
0x431e:  89 1C                mov        word ptr [si], bx
0x4320:  83 C6 04             add        si, 4
0x4323:  FF 06 95 28          inc        word ptr [0x2895]
0x4327:  58                   pop        ax
0x4328:  4D                   dec        bp
0x4329:  74 14                je         0x433f
0x432b:  43                   inc        bx
0x432c:  E9 24 FF             jmp        0x4253
0x432f:  8D 16 18 3E          lea        dx, [0x3e18]
0x4333:  E8 99 01             call       PRINT_STRING
0x4336:  8D 16 A3 3E          lea        dx, [0x3ea3]
0x433a:  E8 92 01             call       PRINT_STRING
0x433d:  EB E8                jmp        0x4327
0x433f:  8D 16 F2 3E          lea        dx, [0x3ef2]
0x4343:  E8 89 01             call       PRINT_STRING
0x4346:  A1 95 28             mov        ax, word ptr [0x2895]
0x4349:  A3 89 28             mov        word ptr [0x2889], ax
0x434c:  E8 8B 01             call       0x44da
0x434f:  8D 16 A3 3E          lea        dx, [0x3ea3]
0x4353:  E8 79 01             call       PRINT_STRING
0x4356:  8D 16 03 3F          lea        dx, [0x3f03]
0x435a:  E8 72 01             call       PRINT_STRING
0x435d:  E4 61                in         al, 0x61
0x435f:  EB 01                jmp        0x4362
0x4361:  90                   nop        
0x4362:  0C 0C                or         al, 0xc
0x4364:  E6 61                out        0x61, al
0x4366:  EB 01                jmp        0x4369
0x4368:  90                   nop        
0x4369:  24 F3                and        al, 0xf3
0x436b:  E6 61                out        0x61, al
0x436d:  90                   nop        
0x436e:  90                   nop        
0x436f:  B0 0F                mov        al, 0xf
0x4371:  E6 70                out        0x70, al
0x4373:  8B 0E E5 3A          mov        cx, word ptr [0x3ae5]
0x4377:  B4 01                mov        ah, 1
0x4379:  CD 10                int        0x10
0x437b:  B9 04 00             mov        cx, 4
0x437e:  B0 00                mov        al, 0
0x4380:  E8 87 E6             call       0x2a0a
0x4383:  FE C0                inc        al
0x4385:  E2 F9                loop       0x4380
0x4387:  A1 95 28             mov        ax, word ptr [0x2895]
0x438a:  A3 89 28             mov        word ptr [0x2889], ax
0x438d:  80 3E ED 28 00       cmp        byte ptr [0x28ed], 0
0x4392:  74 05                je         0x4399
0x4394:  83 06 95 28 18       add        word ptr [0x2895], 0x18
0x4399:  8D 36 CD 17          lea        si, [0x17cd]
0x439d:  80 3E ED 28 00       cmp        byte ptr [0x28ed], 0
0x43a2:  74 22                je         0x43c6
0x43a4:  B9 18 00             mov        cx, 0x18
0x43a7:  BB 00 00             mov        bx, 0
0x43aa:  B8 00 40             mov        ax, 0x4000
0x43ad:  C1 E8 0A             shr        ax, 0xa
0x43b0:  89 04                mov        word ptr [si], ax
0x43b2:  89 74 02             mov        word ptr [si + 2], si
0x43b5:  83 44 02 04          add        word ptr [si + 2], 4
0x43b9:  05 01 00             add        ax, 1
0x43bc:  83 C6 04             add        si, 4
0x43bf:  E2 EF                loop       0x43b0
0x43c1:  C7 44 FE FF FF       mov        word ptr [si - 2], 0xffff
0x43c6:  83 3E E8 3A 00       cmp        word ptr [0x3ae8], 0
0x43cb:  75 22                jne        0x43ef
0x43cd:  B8 00 C0             mov        ax, 0xc000
0x43d0:  C1 E8 0A             shr        ax, 0xa
0x43d3:  BB B5 17             mov        bx, 0x17b5
0x43d6:  B9 0C 00             mov        cx, 0xc
0x43d9:  2E 80 3F FF          cmp        byte ptr cs:[bx], 0xff
0x43dd:  74 0A                je         0x43e9
0x43df:  89 04                mov        word ptr [si], ax
0x43e1:  83 C6 04             add        si, 4
0x43e4:  83 06 95 28 01       add        word ptr [0x2895], 1
0x43e9:  05 01 00             add        ax, 1
0x43ec:  43                   inc        bx
0x43ed:  E2 EA                loop       0x43d9
0x43ef:  8D 36 BD 00          lea        si, [0xbd]
0x43f3:  89 36 79 28          mov        word ptr [0x2879], si
0x43f7:  8D 06 CD 17          lea        ax, [0x17cd]
0x43fb:  89 44 0A             mov        word ptr [si + 0xa], ax
0x43fe:  80 3E ED 28 00       cmp        byte ptr [0x28ed], 0
0x4403:  74 24                je         0x4429
0x4405:  C7 04 18 00          mov        word ptr [si], 0x18
0x4409:  B9 18 00             mov        cx, 0x18
0x440c:  BA 10 00             mov        dx, 0x10
0x440f:  B0 0C                mov        al, 0xc
0x4411:  E8 72 E5             call       WRITEEMSPORT
0x4414:  04 01                add        al, 1
0x4416:  83 C2 01             add        dx, 1
0x4419:  E2 F6                loop       0x4411
0x441b:  B0 0B                mov        al, 0xb
0x441d:  E8 47 E5             call       READCHIPSETREG
0x4420:  0C 40                or         al, 0x40
0x4422:  8A E0                mov        ah, al
0x4424:  B0 0B                mov        al, 0xb
0x4426:  E8 47 E5             call       WRITECHIPSETREG
0x4429:  B8 FF 00             mov        ax, 0xff
0x442c:  48                   dec        ax
0x442d:  A3 85 28             mov        word ptr [0x2885], ax
0x4430:  8D 36 CD 17          lea        si, [0x17cd]
0x4434:  89 36 7D 28          mov        word ptr [0x287d], si
0x4438:  A1 95 28             mov        ax, word ptr [0x2895]
0x443b:  BB 04 00             mov        bx, 4
0x443e:  F7 E3                mul        bx
0x4440:  03 F0                add        si, ax
0x4442:  89 36 7F 28          mov        word ptr [0x287f], si
0x4446:  BE BF 27             mov        si, 0x27bf
0x4449:  B8 00 40             mov        ax, 0x4000
0x444c:  8B 0E A1 28          mov        cx, word ptr [0x28a1]
0x4450:  BB 49 27             mov        bx, 0x2749
0x4453:  BA 00 00             mov        dx, 0
0x4456:  3B 07                cmp        ax, word ptr [bx]
0x4458:  74 09                je         0x4463
0x445a:  83 C3 03             add        bx, 3
0x445d:  42                   inc        dx
0x445e:  E2 F6                loop       0x4456
0x4460:  EB 09                jmp        0x446b
0x4462:  90                   nop        
0x4463:  89 04                mov        word ptr [si], ax
0x4465:  89 54 02             mov        word ptr [si + 2], dx
0x4468:  83 C6 04             add        si, 4
0x446b:  05 00 04             add        ax, 0x400
0x446e:  3D 00 F0             cmp        ax, 0xf000
0x4471:  75 D9                jne        0x444c
0x4473:  B4 00                mov        ah, 0
0x4475:  CD 1A                int        0x1a
0x4477:  02 F1                add        dh, cl
0x4479:  2A EA                sub        ch, dl
0x447b:  86 F5                xchg       ch, dh
0x447d:  8B D9                mov        bx, cx
0x447f:  89 1E 75 28          mov        word ptr [0x2875], bx
0x4483:  8B CA                mov        cx, dx
0x4485:  89 0E 77 28          mov        word ptr [0x2877], cx

; set interrupt vector  0x67
0x4489:  8D 16 10 2B          lea        dx, [0x2b10]
0x448d:  B0 67                mov        al, 0x67
0x448f:  B4 25                mov        ah, 0x25
0x4491:  CD 21                int        0x21

DRIVER_INSTALLED:
0x4493:  8D 16 2B 3E          lea        dx, [0x3e2b]
0x4497:  E8 35 00             call       PRINT_STRING
0x449a:  C4 1E 71 28          les        bx, ptr [0x2871]
0x449e:  26 C7 47 03 00 01    mov        word ptr es:[bx + 3], 0x100
0x44a4:  B8 B5 3A             mov        ax, 0x3ab5
0x44a7:  26 89 47 0E          mov        word ptr es:[bx + 0xe], ax
0x44ab:  26 8C 4F 10          mov        word ptr es:[bx + 0x10], cs
0x44af:  C3                   ret

; DRIVER NOT INSTALLED
; preloaded with string 'reason' for the print string
DRIVER_NOT_INSTALLED:
0x44b0:  E8 1C 00             call       PRINT_STRING 
0x44b3:  8D 16 58 3E          lea        dx, [0x3e58]
DRIVER_NOT_INSTALLED_2:
0x44b7:  E8 15 00             call       PRINT_STRING
0x44ba:  C4 1E 71 28          les        bx, ptr [0x2871]
0x44be:  26 C7 47 03 0C 81    mov        word ptr es:[bx + 3], 0x810c
0x44c4:  26 C7 47 0E 00 00    mov        word ptr es:[bx + 0xe], 0
0x44ca:  26 8C 4F 10          mov        word ptr es:[bx + 0x10], cs
0x44ce:  C3                   ret

; prints string ending in '$' in DS:DX
PRINT_STRING:
0x44cf:  1E                   push       ds
0x44d0:  50                   push       ax
0x44d1:  0E                   push       cs
0x44d2:  1F                   pop        ds
0x44d3:  B4 09                mov        ah, 9
0x44d5:  CD 21                int        0x21
0x44d7:  58                   pop        ax
0x44d8:  1F                   pop        ds
0x44d9:  C3                   ret

0x44da:  50                   push       ax
0x44db:  53                   push       bx
0x44dc:  51                   push       cx
0x44dd:  52                   push       dx
0x44de:  57                   push       di
0x44df:  06                   push       es
0x44e0:  0E                   push       cs
0x44e1:  07                   pop        es
0x44e2:  50                   push       ax
0x44e3:  8D 3E A3 3E          lea        di, [0x3ea3]
0x44e7:  B8 20 20             mov        ax, 0x2020
0x44ea:  B9 02 00             mov        cx, 2
0x44ed:  FC                   cld        
0x44ee:  F3 AB                rep stosw  word ptr es:[di], ax
0x44f0:  58                   pop        ax
0x44f1:  33 D2                xor        dx, dx
0x44f3:  BB 0A 00             mov        bx, 0xa
0x44f6:  F7 F3                div        bx
0x44f8:  92                   xchg       ax, dx
0x44f9:  04 30                add        al, 0x30
0x44fb:  4F                   dec        di
0x44fc:  88 05                mov        byte ptr [di], al
0x44fe:  8B C2                mov        ax, dx
0x4500:  83 FA 00             cmp        dx, 0
0x4503:  75 EC                jne        0x44f1
0x4505:  07                   pop        es
0x4506:  5F                   pop        di
0x4507:  5A                   pop        dx
0x4508:  59                   pop        cx
0x4509:  5B                   pop        bx
0x450a:  58                   pop        ax
0x450b:  C3                   ret


; calls GET_ASCII_CHAR four four nibbles of the word to generate four ascii values. result stored in es:di
HEX_WORD_TO_ASCII:
0x450c:  50                   push       ax
0x450d:  53                   push       bx
0x450e:  51                   push       cx
0x450f:  52                   push       dx
0x4510:  8B D8                mov        bx, ax
0x4512:  8A C7                mov        al, bh
0x4514:  C0 E8 04             shr        al, 4
0x4517:  E8 1B 00             call       GET_ASCII_CHAR
0x451a:  8A C7                mov        al, bh
0x451c:  24 0F                and        al, 0xf
0x451e:  E8 14 00             call       GET_ASCII_CHAR
0x4521:  8A C3                mov        al, bl
0x4523:  C0 E8 04             shr        al, 4
0x4526:  E8 0C 00             call       GET_ASCII_CHAR
0x4529:  8A C3                mov        al, bl
0x452b:  24 0F                and        al, 0xf
0x452d:  E8 05 00             call       GET_ASCII_CHAR
0x4530:  5A                   pop        dx
0x4531:  59                   pop        cx
0x4532:  5B                   pop        bx
0x4533:  58                   pop        ax
0x4534:  C3                   ret

; seems like alphanumeric encoding. 0-9 value is '0' indexed ascii, 0xA and up is 'a' indexed ascii
; Hexadecimal nibble to ascii char function. result stored in es:di
GET_ASCII_CHAR:
0x4535:  3C 0A                cmp        al, 0xa
0x4537:  73 05                jae        0x453e
0x4539:  04 30                add        al, 0x30
0x453b:  EB 05                jmp        0x4542
0x453d:  90                   nop        
0x453e:  2C 0A                sub        al, 0xa
0x4540:  04 41                add        al, 0x41
0x4542:  AA                   stosb      byte ptr es:[di], al
0x4543:  C3                   ret


0x4544:  1E                   push       ds
0x4545:  53                   push       bx
0x4546:  51                   push       cx
0x4547:  52                   push       dx
0x4548:  3C 04                cmp        al, 4
0x454a:  76 02                jbe        0x454e
0x454c:  B7 00                mov        bh, 0
0x454e:  8B D8                mov        bx, ax
0x4550:  B9 04 00             mov        cx, 4
0x4553:  80 BF B5 17 FF       cmp        byte ptr [bx + 0x17b5], 0xff
0x4558:  74 11                je         0x456b
0x455a:  83 C3 01             add        bx, 1
0x455d:  E2 F4                loop       0x4553
0x455f:  8B D8                mov        bx, ax
0x4561:  D1 E3                shl        bx, 1
0x4563:  2E 8B 87 5B 28       mov        ax, word ptr cs:[bx + 0x285b]
0x4568:  EB 2B                jmp        0x4595
0x456a:  90                   nop        
0x456b:  33 DB                xor        bx, bx
0x456d:  8B D3                mov        dx, bx
0x456f:  B9 04 00             mov        cx, 4
0x4572:  2E 80 BF B5 17 FF    cmp        byte ptr cs:[bx + 0x17b5], 0xff
0x4578:  74 11                je         0x458b
0x457a:  83 C3 01             add        bx, 1
0x457d:  E2 F3                loop       0x4572
0x457f:  8B DA                mov        bx, dx
0x4581:  D1 E3                shl        bx, 1
0x4583:  2E 8B 87 5B 28       mov        ax, word ptr cs:[bx + 0x285b]
0x4588:  EB 0B                jmp        0x4595
0x458a:  90                   nop        
0x458b:  83 C2 01             add        dx, 1
0x458e:  8B DA                mov        bx, dx
0x4590:  83 FB 04             cmp        bx, 4
0x4593:  76 DA                jbe        0x456f
0x4595:  5A                   pop        dx
0x4596:  59                   pop        cx
0x4597:  5B                   pop        bx
0x4598:  1F                   pop        ds
0x4599:  C3                   ret

FIND_BIOSES:
0x459a:  50                   push       ax
0x459b:  53                   push       bx
0x459c:  B8 00 C0             mov        ax, 0xc000
LOOP_DO_CHECKSUM:
0x459f:  E8 36 00             call       DO_CHECKSUM
0x45a2:  73 2C                jae        FOUND_BIOS
0x45a4:  50                   push       ax
0x45a5:  53                   push       bx
0x45a6:  51                   push       cx
0x45a7:  50                   push       ax
0x45a8:  50                   push       ax
0x45a9:  2D 00 C0             sub        ax, 0xc000
0x45ac:  C1 E8 0A             shr        ax, 0xa
0x45af:  59                   pop        cx
0x45b0:  C1 E1 06             shl        cx, 6
0x45b3:  74 01                je         0x45b6
0x45b5:  40                   inc        ax
0x45b6:  5B                   pop        bx
0x45b7:  2B DA                sub        bx, dx
0x45b9:  81 EB 00 C0          sub        bx, 0xc000
0x45bd:  C1 EB 0A             shr        bx, 0xa
0x45c0:  3B D8                cmp        bx, ax
0x45c2:  73 09                jae        0x45cd
0x45c4:  2E C6 87 B5 17 FF    mov        byte ptr cs:[bx + 0x17b5], 0xff
0x45ca:  43                   inc        bx
0x45cb:  EB F3                jmp        0x45c0
0x45cd:  59                   pop        cx
0x45ce:  5B                   pop        bx
0x45cf:  58                   pop        ax
FOUND_BIOS:
; stop before F000
0x45d0:  3D 80 EF             cmp        ax, 0xef80
0x45d3:  76 CA                jbe        LOOP_DO_CHECKSUM

0x45d5:  5B                   pop        bx
0x45d6:  58                   pop        ax
0x45d7:  C3                   ret


; this checks to see if the segment in AX points to a BIOS.
; return carry flag if it is
DO_CHECKSUM:
0x45d8:  1E                   push       ds
0x45d9:  53                   push       bx
0x45da:  51                   push       cx
0x45db:  56                   push       si
0x45dc:  8E D8                mov        ds, ax
0x45de:  33 DB                xor        bx, bx
0x45e0:  81 3F 55 AA          cmp        word ptr [bx], 0xaa55
0x45e4:  75 1E                jne        RETURN_NO_CARRY_FLAG_2
0x45e6:  33 F6                xor        si, si
0x45e8:  33 C9                xor        cx, cx
0x45ea:  8A 4F 02             mov        cl, byte ptr [bx + 2]
0x45ed:  C1 E1 09             shl        cx, 9
0x45f0:  8B D1                mov        dx, cx
CONTINUE_CHECKSUMMING:
0x45f2:  AC                   lodsb      al, byte ptr [si]
0x45f3:  02 D8                add        bl, al
0x45f5:  E2 FB                loop       CONTINUE_CHECKSUMMING
0x45f7:  75 0B                jne        RETURN_NO_CARRY_FLAG_2
0x45f9:  C1 EA 04             shr        dx, 4
0x45fc:  8C D8                mov        ax, ds
0x45fe:  03 C2                add        ax, dx
RETURN_CARRY_FLAG_2:
0x4600:  F9                   stc        
0x4601:  EB 09                jmp        CONTINUE_RETURN
0x4603:  90                   nop        
RETURN_NO_CARRY_FLAG_2:
0x4604:  BA 80 00             mov        dx, 0x80
0x4607:  8C D8                mov        ax, ds
0x4609:  03 C2                add        ax, dx
0x460b:  F8                   clc        
CONTINUE_RETURN:
0x460c:  5E                   pop        si
0x460d:  59                   pop        cx
0x460e:  5B                   pop        bx
0x460f:  1F                   pop        ds
0x4610:  C3                   ret     