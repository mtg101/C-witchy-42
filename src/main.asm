;
; VS64 generated Example was the starting point...
;

*=$0801
!byte $0c,$08,$b5,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00

    jmp MAIN

; data in memory includes
!source "src/cw42_sprite_data.asm"

; all the code (no location specific data) in bank 1 full 16k to use
*=$4000

!source "src/c64_defs.asm"
!source "src/c64_maths.asm"
!source "src/c64_screen.asm"
!source "src/c64_system.asm"
!source "src/cw42_raster.asm"
!source "src/cw42_sprite.asm"
!source "src/cw42_tile_bg.asm"

!source "rsc/c-witchy-42 map.asm"


MAIN
    lda #%00000111          ; msb rasterline = 0, ecm off = 0, bitmap off = 0, screen off = 0, 24 rows for scroll = 0, v_scroll max 111
    sta VIC_CR1
    lda #%11011111          ; 110 static, mcm on = 1, col 40 wide = 1, x-scroll max = 111
    sta VIC_CR2
    jsr ROM_CLR_SCREEN
    jsr MATHS_SETUP_RNG
    jsr SCREEN_CHAR_COPY_FROM_MAP
    jsr SCREEN_CHAR_SET_3000

    jmp SYS_NO_BASIC_NO_KERNEL_ROM  ; also does raster irq setup - jmp as it's reclaiming the stack
SYS_NO_BASIC_NO_KERNEL_ROM_DONE    
    
    jsr SPRITE_INIT
    jsr TILE_BG_SETUP
    jsr SCREEN_ON

MAIN_LOOP
    ; is raster flag set?
    lda RASTER_CHASE_BEAM
    beq MAIN_LOOP           ; not time yet...

    inc FRAME_COUNTER       ; inc first, start with frame 1 procgen
    lda FRAME_COUNTER
    and #%00000111           ; 0-7

    ; are jump tables worth it?
    beq FRAME_0
    cmp #%00000001
    beq FRAME_1
    cmp #%00000010
    beq FRAME_2
    cmp #%00000011
    beq FRAME_3
    cmp #%00000100
    beq FRAME_4
    cmp #%00000101
    beq FRAME_5
    cmp #%00000110
    beq FRAME_6
    cmp #%00000111       ; we know it's 7... but keep code clean and constant
    beq FRAME_7         ; don't fall through, cleaner code, and constant

FRAME_DONE
    ; clear raster flag
    lda #$00
    sta RASTER_CHASE_BEAM
    jmp MAIN_LOOP

FRAME_0 
    lda #CW4_CR2_0                   
    sta TILE_BG_CR2
    jsr TILE_BG_SCROLL_SMC
    jmp FRAME_DONE

FRAME_1
    lda #CW4_CR2_1
    sta TILE_BG_CR2
    jmp FRAME_DONE

FRAME_2
    lda #CW4_CR2_2
    sta TILE_BG_CR2
    jmp FRAME_DONE

FRAME_3
    lda #CW4_CR2_3
    sta TILE_BG_CR2
    jmp FRAME_DONE

FRAME_4
    lda #CW4_CR2_4
    sta TILE_BG_CR2
    jmp FRAME_DONE

FRAME_5
    lda #CW4_CR2_5
    sta TILE_BG_CR2
    jmp FRAME_DONE

FRAME_6
    lda #CW4_CR2_6
    sta TILE_BG_CR2
    jmp FRAME_DONE

FRAME_7
    lda #CW4_CR2_7
    sta TILE_BG_CR2
    jmp FRAME_DONE

; all options jumped back


CW4_CR2_0 = %11000111
CW4_CR2_1 = %11000110
CW4_CR2_2 = %11000101
CW4_CR2_3 = %11000100
CW4_CR2_4 = %11000011
CW4_CR2_5 = %11000010
CW4_CR2_6 = %11000001
CW4_CR2_7 = %11000000


FRAME_COUNTER
    !byte   $00


; --- End of code section ---

!ifndef PASS1 {
;    !warn "Pass 1"
    PASS1 = 1
} else {
    !ifndef PASS2 {
;        !warn "Pass 2"
        PASS2 = 1
    } else {
        !ifndef PASS3 {
;            !warn "Pass 3"
            !warn "Code size is ", $7FFF-*, " of max 16383 (0x3FFF) (ending at ", *, " of max 32767 (0x7FFF))"
            !if * > $7FFF {
                !error "Code has hit the bank 1 boundary!"
            }
            PASS3 = 1
        }
    }
}

