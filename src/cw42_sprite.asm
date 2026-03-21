

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
    lda #140
    sta SPR0_Y
    lda #140
    sta SPR1_Y

    lda #100
    sta SPR0_X
    lda #100
    sta SPR1_X

    ; sprite pointers
    lda #(witch_sprite_outline / 64)
    sta SPR_PTR0
    lda #(witch_sprite / 64)
    sta SPR_PTR1

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

SPRITE_READ_KEYS_DONE
    rts             ; SPRITE_READ_KEYS

SPRITE_WITCH_X_MIN = 60
SPRITE_WITCH_X_MAX = 200
SPRITE_WITCH_Y_MIN = 130
SPRITE_WITCH_Y_MAX = 190

