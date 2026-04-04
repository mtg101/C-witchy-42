

SPRITE_INIT
    ; setup key ports
    lda #$ff        ; all bits output
    sta CIA1_DDRA

    lda #$00        ; all bits input
    sta CIA1_DDRB

    ; sprite colours
    lda #BLACK
    sta SPR0_COLOR
    lda #PURPLE
    sta SPR1_COLOR

    ; sprite locations
    lda #160
    sta SPR0_Y
    sta SPR1_Y

    sta SPR0_X
    sta SPR1_X

    ; sprite pointers
    lda #(witch_sprite_outline / 64)
    sta SPR_PTR0
    lda #(witch_sprite / 64)
    sta SPR_PTR1

    ; start all large sprites
    lda #$FF
    sta SPR_Y_EXP
    sta SPR_X_EXP

    ; start all over bg
    lda #$00
    sta SPR_PRIORITY

    ; enable sprites
    lda #%00000011
    sta SPR_ENABLE 

    rts


SPRITE_UPDATE_WITCH
    ; a - left
    lda #KEY_A_ROW
    sta CIA1_PRA

    lda CIA1_PRB
    and #KEY_A_COL

    bne SPRITE_MOVE_LEFT_DONE
SPRITE_MOVE_LEFT
    lda SPR0_X
    cmp #SPRITE_WITCH_X_MIN
    beq SPRITE_MOVE_LEFT_DONE

    dec SPR0_X
    dec SPR1_X
    
SPRITE_MOVE_LEFT_DONE
    ; d - right
    lda #KEY_D_ROW
    sta CIA1_PRA

    lda CIA1_PRB
    and #KEY_D_COL

    bne SPRITE_MOVE_RIGHT_DONE
SPRITE_MOVE_RIGHT
    lda SPR0_X
    cmp #SPRITE_WITCH_X_MAX
    beq SPRITE_MOVE_RIGHT_DONE

    inc SPR0_X
    inc SPR1_X
SPRITE_MOVE_RIGHT_DONE
    ; w - up
    lda #KEY_W_ROW
    sta CIA1_PRA

    lda CIA1_PRB
    and #KEY_W_COL

    bne SPRITE_MOVE_UP_DONE
SPRITE_MOVE_UP
    lda SPR0_Y
    cmp #SPRITE_WITCH_Y_MIN
    beq SPRITE_MOVE_UP_DONE

    dec SPR0_Y
    dec SPR1_Y
SPRITE_MOVE_UP_DONE
    ; s - down
    lda #KEY_S_ROW
    sta CIA1_PRA

    lda CIA1_PRB
    and #KEY_S_COL

    bne SPRITE_MOVE_DOWN_DONE
SPRITE_MOVE_DOWN
    lda SPR0_Y
    cmp #SPRITE_WITCH_Y_MAX
    beq SPRITE_MOVE_DOWN_DONE

    inc SPR0_Y
    inc SPR1_Y
SPRITE_MOVE_DOWN_DONE
    ; space - over/under flip
    lda #KEY_SPACE_ROW
    sta CIA1_PRA

    lda CIA1_PRB
    and #KEY_SPACE_COL

    bne SPRITE_OVER_UNDER_DONE
SPRITE_OVER_UNDER
    ; wait for not pressed to flip again
    lda FLIP_PRESSED
    bne SPRITE_OVER_UNDER_DONE_PRESSED

    ; note key pressed
    lda #$01
    sta FLIP_PRESSED

    ; flip size
    lda SPR_Y_EXP
    eor #$FF
    sta SPR_Y_EXP
    sta SPR_X_EXP

    ; offset for size
    beq SPRITE_OVER_UNDER_FLIP_SMALL

SPRITE_OVER_UNDER_FLIP_BIG
    ; sub half sprite width
    lda SPR0_X
    sec                 ; Prepare for subtraction
    sbc #(SPR_WIDTH / 2)
    sta SPR0_X
    sta SPR1_X

    ; sub half sprite height
    lda SPR0_Y
    sec                 ; Prepare for subtraction
    sbc #(SPR_HEIGHT / 2)
    sta SPR0_Y
    sta SPR1_Y

    jmp SPRITE_OVER_UNDER_FLIP_BIG_DONE

SPRITE_OVER_UNDER_FLIP_SMALL
    ; add half sprite width
    lda SPR0_X
    clc                 ; Prepare for addition
    adc #(SPR_WIDTH / 2)
    sta SPR0_X
    sta SPR1_X

    ; add half sprite height
    lda SPR0_Y
    clc                 ; Prepare for subtraction
    adc #(SPR_HEIGHT / 2)
    sta SPR0_Y
    sta SPR1_Y

SPRITE_OVER_UNDER_FLIP_BIG_DONE
    ; flip priority of sprite 1 (0 is outline)
    lda SPR_PRIORITY
    eor #%00000010
    sta SPR_PRIORITY

    jmp SPRITE_OVER_UNDER_DONE_PRESSED

SPRITE_OVER_UNDER_DONE
    ; not pressed to reset pressed
    lda #$00
    sta FLIP_PRESSED

SPRITE_OVER_UNDER_DONE_PRESSED

SPRITE_READ_KEYS_DONE
    rts             ; SPRITE_READ_KEYS

SPRITE_WITCH_X_MIN = SPR_MIN_X 
SPRITE_WITCH_X_MAX = 255
SPRITE_WITCH_Y_MIN = SPR_MIN_Y +4 ; hiding for scrolling
SPRITE_WITCH_Y_MAX = 204

FLIP_PRESSED
!byte $00