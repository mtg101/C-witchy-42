

SCREEN_SET_MULTI_COLOR_CHARACTER_MODE
    lda VIC_CR2
    ora #H_MULTICOLOR 
    sta VIC_CR2
    rts

SCREEN_SET_HI_RES_CHARACTER_MODE
    lda VIC_CR2
    and #H_HI_RES 
    sta VIC_CR2
    rts

SCREEN_SET_HOZ_SCROLLING_38
    lda VIC_CR2
    and #H_COL_38  
    sta VIC_CR2
    rts

SCREEN_SET_HOZ_STATIC_40
    lda VIC_CR2
    ora #H_COL_40
    sta VIC_CR2
    rts

SCREEN_OFF
    lda VIC_CR1
    and #%11101111 ; Clear Bit 4 
    sta VIC_CR1
    rts

SCREEN_ON
    lda VIC_CR1
    ora #%00010000 ; Set Bit 4 
    sta VIC_CR1
    rts    

SCREEN_RESET_SCROLL_X
    lda VIC_CR2
    ora #%00000111  ; set 7 (no scroll)
    sta VIC_CR2
    rts

SCREEN_DEC_SCROLL_X    
    lda VIC_CR2
    pha                 ; Push a copy to the stack to keep the "high bits" safe
    
    ; 1. Isolate and decrement the scroll
    and #%00000111  ; Keep only bits 0-2
    sec                 ; Prepare for subtraction
    sbc #$01        ; Subtract 1
    and #%00000111  ; "Wrap" the value (if it was 0, it becomes 7)
    sta ZP_PTR_1    ; Store this new scroll value in a temp Zero Page address
    
    ; 2. Combine with original high bits
    pla                 ; Pull the original register value back
    and #%11111000  ; Clear the old scroll bits (keep width/multi-color)
    ora ZP_PTR_1    ; Merge in the new scroll value
    sta VIC_CR2
    rts


SCREEN_RESET_SCROLL_Y
    lda VIC_CR1
    and #%00000111 ; set 7 (no scroll)
    sta VIC_CR1
    rts

SCREEN_CHAR_COPY_ROM_3000
     sei          ; Disable interrupts to prevent the Kernal 
                  ; from trying to read I/O while we hide it.

     lda $01      ; Save current memory configuration
     pha
     lda #$33     ; Map Character ROM at $D000-$DFFF
     sta $01

    ; --- Setup Pointers in Zero Page ---
    lda #$00
    sta ZP_PTR_1       ; Source Low ($D000)
    sta ZP_PTR_2       ; Destination Low ($2800)
    
    lda #$d0      ; Source High
    sta ZP_PTR_1_PAIR
    lda #$30      ; Destination High
    sta ZP_PTR_2_PAIR

    ; --- The 512byte Copy Loop (first 64 chars chars, udgs beyond) ---
    ldx #$02      ; only first 64 chars: 2 pages of 256 bytes = 512 bytes
    ldy #$00      ; Clear Y index
    
copy_loop:
    lda (ZP_PTR_1),y   ; Grab byte from ROM
    sta (ZP_PTR_2),y   ; Write byte to RAM
    iny           ; Next byte
    bne copy_loop ; Loop until Y wraps to 0 (256 bytes)
    
    inc ZP_PTR_1_PAIR       ; Move source to next page
    inc ZP_PTR_2_PAIR       ; Move destination to next page
    dex           ; Decrease page count
    bne copy_loop ; Repeat for all 8 pages

     ; --- Restore Memory Map ---
     pla
     sta $01
     cli          ; Re-enable interrupts

    rts
SCREEN_CHAR_SET_3000
    lda MEM_SETUP      ; Get current Screen/Char settings
    and #%11110001     ; Clear bits 1, 2, and 3 (Keep the Screen pointer)
    ora #%00001100     ; Set bits 1-3 to %101 (Binary 6)
    sta MEM_SETUP      ; Apply changes
    rts