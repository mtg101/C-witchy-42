
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

    ; load colours from main screen
    jsr TILE_BG_COLOUR_FROM_SCREEN_400

    rts


TILE_BG_NEXT_FRAME_TO_OFF_SCREEN
    ; 2 pass copy from map to off screen

    ; inc index
    dec TILE_BG_MAP_INDEX

    bpl +
    lda #49      ; reset to 49
    sta TILE_BG_MAP_INDEX
+

    ; source map_data + offset
    ldx TILE_BG_MAP_INDEX    ; X = 0 to 49
    lda row_low,x
    sta ZP_PTR_1          ; Offset Low
    lda row_high,x
    sta ZP_PTR_1_PAIR          ; Offset High
    
    ; Now add the base address of your map
    clc
    lda ZP_PTR_1
    adc #<map_data
    sta ZP_PTR_1
    lda ZP_PTR_1_PAIR
    adc #>map_data
    sta ZP_PTR_1_PAIR
    
    ; ZP_PTR_1 pair now points exactly to the start of correct map row

    ; which screen is dest?
    ; assume default 400 is off
    lda #<SCREEN_RAM
    sta ZP_PTR_2
    lda #>SCREEN_RAM
    sta ZP_PTR_2_PAIR

    lda #TILE_BG_SCREEN_400     ; default screen
    cmp MEM_SETUP

    bne +
    ; current showing screen 400, so off is 800
    lda #<SCREEN_RAM_800
    sta ZP_PTR_2
    lda #>SCREEN_RAM_800
    sta ZP_PTR_2_PAIR
+

    ; how many rows? 50 - TILE_BG_MAP_INDEX, max 25
    lda #50
    sec                     ; Prepare for subtraction
    sbc TILE_BG_MAP_INDEX   ; a is now 1-50

    cmp #25
    bcc +                   ; if a < 25, carry is clear, so jump
    lda #25                 ; max 25
+
    sta ZP_PTR_TEMP_0       ; 1-25 rows

    ; render 
    jsr TILE_BG_LOAD_MAP_TO_SCREEN


    ; how many extra rows?
    lda #25
    sec                     ; Prepare for subtraction
    sbc ZP_PTR_TEMP_0       ; 1-25 rows -- so a now has 0-24 rows

    beq +                   ; 0 rows, so skip

    sta ZP_PTR_TEMP_0       ; num rows

    ; start addr is start of map - easy
    lda #<map_data
    sta ZP_PTR_1
    lda #>map_data
    sta ZP_PTR_1_PAIR

    ; screen addr - already ready in ZP_PTR_2 pair from previous render

    ; render    
    jsr TILE_BG_LOAD_MAP_TO_SCREEN

+
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

    lda #TILE_BG_SCREEN_400     ; default screen
    cmp MEM_SETUP

    bne TILE_BG_COLOUR_FROM_OFF_SCREEN_400

    ; current showing screen 400, so off is 800
    jsr TILE_BG_COLOUR_FROM_SCREEN_800
    jmp TILE_BG_COLOUR_FROM_OFF_SCREEN_DONE

TILE_BG_COLOUR_FROM_OFF_SCREEN_400
    ; current showing screen 800, so off is 400
    jsr TILE_BG_COLOUR_FROM_SCREEN_400

TILE_BG_COLOUR_FROM_OFF_SCREEN_DONE
    rts

TILE_BG_COLOUR_FROM_SCREEN_400
    ; read from screen, lookup colour, write to colour ram (chasing beam)

    ; first 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+
    ; second 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM+250, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM+250, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    ; third 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM+500, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM+500, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    ; fourth 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM+750, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM+750, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    rts

TILE_BG_COLOUR_FROM_SCREEN_800
    ; read from screen, lookup colour, write to colour ram (chasing beam)

    ; first 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM_800, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    ; second 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM_800+250, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM+250, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    ; third 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM_800+500, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM+500, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    ; fourth 250 chars
    ldy #0 
-
    !for i, 1, 50 {
        ldx SCREEN_RAM_800+750, y           ; char
        lda charset_attrib_data, x  ; lookup color from table
        sta COLOR_RAM+750, y            ; save color
        iny
    }

    cpy #250
    beq +
    jmp -
+

    rts


TILE_BG_FLIP_SCREEN
    ; only flips value, actual flip occurs during top border raster

    ; which is active?
    lda TILE_BG_MEM_SETUP
    cmp #TILE_BG_SCREEN_400

    beq TILE_BG_FLIP_SCREEN_TO_800
TILE_BG_FLIP_SCREEN_TO_400
    lda #TILE_BG_SCREEN_400
    jmp TILE_BG_FLIP_SCREEN_DONE
TILE_BG_FLIP_SCREEN_TO_800
    lda #TILE_BG_SCREEN_800
TILE_BG_FLIP_SCREEN_DONE
    sta TILE_BG_MEM_SETUP

    rts


TILE_BG_SCREEN_400 = %00011101      ; default
TILE_BG_SCREEN_800 = %00101101      ; other


TILE_BG_CR1
    !byte CW42_CR1_0

TILE_BG_MEM_SETUP
    !byte TILE_BG_SCREEN_400     ; $0400 screen (default), chars at 3000 (6), 1 always set

TILE_BG_MAP_INDEX
    !byte $00

; lookup table for mem offsets

; usage
;     ldx row_index    ; X = 0 to 49
;     lda row_low,x
;     sta $fb          ; Offset Low
;     lda row_high,x
;     sta $fc          ; Offset High
    
;     ; Now add the base address of your map
;     clc
;     lda $fb
;     adc #<map_data
;     sta $fb
;     lda $fc
;     adc #>map_data
;     sta $fc
    
;     ; $fb/$fc now points exactly to the start of that row!

row_low:
    !for i, 0, 49 { !byte <(i*40) }
row_high:
    !for i, 0, 49 { !byte >(i*40) }

