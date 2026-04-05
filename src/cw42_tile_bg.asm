
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

    ; load chars from map
    lda #<map_data      ; from map
    sta ZP_PTR_1
    lda #>map_data
    sta ZP_PTR_1_PAIR

    lda #<SCREEN_RAM    ; to main screen
    sta ZP_PTR_2
    lda #>SCREEN_RAM
    sta ZP_PTR_2_PAIR

    lda #25
    sta ZP_PTR_TEMP_0   ; all 25 rows

    jsr TILE_BG_LOAD_MAP_TO_SCREEN


    ; load colours
    ; from main screen
    lda #<SCREEN_RAM
    sta ZP_PTR_1
    lda #>SCREEN_RAM
    sta ZP_PTR_1_PAIR

    jsr TILE_BG_COLOUR_FROM_SCREEN

    rts


TILE_BG_NEXT_FRAME_TO_OFF_SCREEN
    ; 2 pass copy from map to off screen

    rts


TILE_BG_LOAD_MAP_TO_SCREEN
    ; caller puts source into ZP_PTR_1 pair
    ; caller puts dest into ZP_PTR_2 pair
    ; caller puts number of rows in ZP_PTR_TEMP_0


    ldx #0    ; row counter

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
    cpx ZP_PTR_TEMP_0
    bne TILE_BG_CHAR_ROW_LOOP


    rts


TILE_BG_COLOUR_FROM_OFF_SCREEN
    ; work out which off screen

    ; set zp_ptr
    ; lda #<
    ; sta ZP_PTR_1
    ; lda #>
    ; sta ZP_PTR_1_PAIR

    ; call to copy
;    jsr TILE_BG_COLOUR_FROM_SCREEN

    rts

TILE_BG_COLOUR_FROM_SCREEN
    ; read from screen, lookup colour, write to colour ram (chasing beam)

    ; caller puts source into ZP_PTR_1 pair
    ; lda #<SCREEN_RAM
    ; sta ZP_PTR_1
    ; lda #>SCREEN_RAM
    ; sta ZP_PTR_1_PAIR

    ; load colours
    ; 25 rows of 40 cols
    ; src: off screen
    ; lookup col from char and charset_attrib_data
    ; dest: COLOR_RAM

    ; zero page setup - always colour ram
    lda #<COLOR_RAM
    sta ZP_PTR_2
    lda #>COLOR_RAM
    sta ZP_PTR_2_PAIR

    lda #<charset_attrib_data
    sta ZP_PTR_TEMP_0
    lda #>charset_attrib_data
    sta ZP_PTR_TEMP_0_PAIR

    ldx #0    ; 25 rows

TILE_BG_COL_SCR_ROW_LOOP
    ldy #0    ; 40 cols

TILE_BG_COL_SCR_COL_LOOP
    lda (ZP_PTR_1), y           ; char

    sty ZP_PTR_TEMP_1           ; save y
    tay                         ; char index to y
    lda (ZP_PTR_TEMP_0), y      ; lookup color from table

    ldy ZP_PTR_TEMP_1           ; restore y
    sta (ZP_PTR_2), y           ; save color

    iny
    cpy #40
    bne TILE_BG_COL_SCR_COL_LOOP

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
    bne TILE_BG_COL_SCR_ROW_LOOP



    rts





TILE_BG_CR1
    !byte   $00

TILE_BG_MEM_SETUP
    !byte   $00

TILE_BG_MAP_INDEX
    !byte   $00


