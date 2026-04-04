
TILE_BG_SETUP
    lda #DK_GRAY
    sta BORDER_COL

    lda #BROWN
    sta BG_COL

    lda #GREEN
    sta BG_COL_1

    lda #LT_GREEN
    sta BG_COL_2

    jsr TILE_BG_STATIC_LOAD

    rts


TILE_BG_STATIC_LOAD

    ; load chars
    ; 25 rows of 40 cols
    ; src: map_data
    ; dest: SCREEN_RAM


    ; zero page setup
    lda #<map_data
    sta ZP_PTR_1
    lda #>map_data
    sta ZP_PTR_1_PAIR

    lda #<SCREEN_RAM
    sta ZP_PTR_2
    lda #>SCREEN_RAM
    sta ZP_PTR_2_PAIR

    ldx #0    ; 25 rows

TILE_BG_CHAR_ROW_LOOP
    ldy #0    ; 40 cols

TILE_BG_CHAR_COL_LOOP
    ; copy map to screen, zero page
    lda (ZP_PTR_1), y
    sta (ZP_PTR_2), y

    iny
    cpy #40
    bne TILE_BG_CHAR_COL_LOOP

    ; move pointers to next row
    ; We need to add 40 to our Screen and Map pointers
    clc
    lda ZP_PTR_1
    adc #40             ; Add 40 to Map Low Byte
    sta ZP_PTR_1
    bcc +               ; If no carry, skip high byte inc
    inc ZP_PTR_1_PAIR
+   
    clc
    lda ZP_PTR_2
    adc #40             ; Add 40 to Screen Low Byte
    sta ZP_PTR_2
    bcc +
    inc ZP_PTR_2_PAIR
+

    inx
    cpx #25
    bne TILE_BG_CHAR_ROW_LOOP


    ; load cols
    ; 25 rows of 40 cols
    ; src: map_data plus lookup
    ; lookup col from char and charset_attrib_data
    ; dest: COLOR_RAM


    ; zero page setup
    lda #<map_data
    sta ZP_PTR_1
    lda #>map_data
    sta ZP_PTR_1_PAIR

    lda #<COLOR_RAM
    sta ZP_PTR_2
    lda #>COLOR_RAM
    sta ZP_PTR_2_PAIR

    lda #<charset_attrib_data
    sta ZP_PTR_TEMP_0
    lda #>charset_attrib_data
    sta ZP_PTR_TEMP_0_PAIR

    ldx #0    ; 25 rows

TILE_BG_COL_ROW_LOOP
    ldy #0    ; 40 cols

TILE_BG_COL_COL_LOOP
    lda (ZP_PTR_1), y           ; char

    sty ZP_PTR_TEMP_1           ; save y
    tay                         ; char index to y
    lda (ZP_PTR_TEMP_0), y      ; lookup color from table

    ldy ZP_PTR_TEMP_1           ; restore y
    sta (ZP_PTR_2), y           ; save color

    iny
    cpy #40
    bne TILE_BG_COL_COL_LOOP

    ; move pointers to next row
    ; We need to add 40 to our Screen and Map pointers
    clc
    lda ZP_PTR_1
    adc #40             ; Add 40 to Map Low Byte
    sta ZP_PTR_1
    bcc +               ; If no carry, skip high byte inc
    inc ZP_PTR_1_PAIR
+   
    clc
    lda ZP_PTR_2
    adc #40             ; Add 40 to Screen Low Byte
    sta ZP_PTR_2
    bcc +
    inc ZP_PTR_2_PAIR
+

    inx
    cpx #25
    bne TILE_BG_COL_ROW_LOOP



    rts



TILE_BG_CR1
    !byte   $00

