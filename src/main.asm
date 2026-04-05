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
    lda #%11011000          ; 110 static, mcm on = 1, col 40 wide = 1, x-scroll min = 000
    sta VIC_CR2
    jsr ROM_CLR_SCREEN
    jsr MATHS_SETUP_RNG
    jsr SCREEN_CHAR_COPY_FROM_MAP

    jmp SYS_NO_BASIC_NO_KERNEL_ROM  ; also does raster irq setup - jmp as it's reclaiming the stack
SYS_NO_BASIC_NO_KERNEL_ROM_DONE    
    
    jsr SPRITE_INIT
    jsr TILE_BG_SETUP
    jsr SCREEN_ON

MAIN_LOOP
    ; is raster flag set?
    lda RASTER_CHASE_BEAM
    beq MAIN_LOOP           ; not time yet...

    inc FRAME_COUNTER       ; inc first, start with frame 1, will display properly come frame 0 after map & colour setup
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
    lda #CW42_CR1_0                   
    sta TILE_BG_CR1

    jsr TILE_BG_COLOUR_FROM_OFF_SCREEN
    jsr TILE_BG_FLIP_SCREEN

    jmp FRAME_DONE

FRAME_1
    lda #CW42_CR1_1
    sta TILE_BG_CR1
    jmp FRAME_DONE

FRAME_2
    lda #CW42_CR1_2
    sta TILE_BG_CR1
    jmp FRAME_DONE

FRAME_3
    lda #CW42_CR1_3
    sta TILE_BG_CR1
    jmp FRAME_DONE

FRAME_4
    lda #CW42_CR1_4
    sta TILE_BG_CR1
    jmp FRAME_DONE

FRAME_5
    lda #CW42_CR1_5
    sta TILE_BG_CR1
    jmp FRAME_DONE

FRAME_6
    lda #CW42_CR1_6
    sta TILE_BG_CR1
    jmp FRAME_DONE

FRAME_7
    lda #CW42_CR1_7
    sta TILE_BG_CR1
    jsr TILE_BG_NEXT_FRAME_TO_OFF_SCREEN
    jmp FRAME_DONE

; all options jumped back

CW42_CR1_7 = %00010111
CW42_CR1_6 = %00010110
CW42_CR1_5 = %00010101
CW42_CR1_4 = %00010100
CW42_CR1_3 = %00010011
CW42_CR1_2 = %00010010
CW42_CR1_1 = %00010001
CW42_CR1_0 = %00010000


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
            !warn "Code size is ", *-$4000, " of max 16383 (0x3fff) (ending at ", *, " of max 32767 (0x7fff))"
            !if * > $7FFF {
                !error "Code has hit the bank 1 boundary!"
            }
            PASS3 = 1
        }
    }
}

