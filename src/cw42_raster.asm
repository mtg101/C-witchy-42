

!macro ACK_IRQ {
    asl VIC_INTER
}

!macro SET_IRQ .irq_name {
    lda #<.irq_name         ; Low byte
    sta SELF_INT_PTR_LOW    
    lda #>.irq_name         ; High byte
    sta SELF_INT_PTR_HI     
}

; only up to 255... !TODO
!macro RASTER_INTERRUPT_SET_ROW .row {
    lda #.row
    sta RASTER_LINE      
    lda VIC_CR1 
    and #$7f        ; Ensure the 8th bit of the raster line is 0 (for lines < 256)
    sta VIC_CR1
}

!macro PUSH_ALL {
    pha         ; Push Accumulator to stack
    txa         ; Transfer X to Accumulator...
    pha         ; ...then push it
    tya         ; Transfer Y to Accumulator...
    pha         ; ...then push it
}

!macro PULL_ALL {
    pla         ; Pull Y from stack into Accumulator
    tay         ; Transfer it back to Y
    pla         ; Pull X from stack into Accumulator
    tax         ; Transfer it back to X
    pla         ; Pull original Accumulator from stack
}


; SEI before called as we're in process of turning off kernel... (and re-anable after)
RASTER_INTERRUPT_SETUP
    ; Disable the CIA "Timer" interrupts (the 60Hz system tick)
    lda #$7F
    sta VIC_ICR_CIA_1       ; Clear CIA 1 interrupt control
    sta VIC_ICR_CIA_2       ; Clear CIA 2 interrupt control
    lda VIC_ICR_CIA_1       ; Acknowledge any pending CIA interrupts
    lda VIC_ICR_CIA_2       ; Acknowledge any pending CIA interrupts

    ; Setup VIC-II to trigger a Raster Interrupt
    lda #$01
    sta VIC_IMASK   ; Enable Raster Interrupts only

    ; Set the line number where the interrupt triggers
    ; default to row 0
    +RASTER_INTERRUPT_SET_ROW 54

    ; Point the Vector to our custom routine
    +SET_IRQ RASTER_IRQ_MAIN_SCREEN
    rts             


; --- INTERRUPT ROUTINES ---

RASTER_IRQ_MAIN_SCREEN
    nop             ; on real c64 can get away with triggering on real raster
    nop             ; TV doesn't show full border so you don't notice the glitching
    nop             ; for EMU... you see it - so we go early and pad
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
    +PUSH_ALL

    jsr SPRITE_UPDATE_WITCH    ; wand to move every frame

    +RASTER_INTERRUPT_SET_ROW 246
    +ACK_IRQ
    +SET_IRQ RASTER_IRQ_BOTTOM_BORDER
    +PULL_ALL
    rti

RASTER_IRQ_BOTTOM_BORDER
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    +PUSH_ALL

    +RASTER_INTERRUPT_SET_ROW 54
    +ACK_IRQ
    +SET_IRQ RASTER_IRQ_MAIN_SCREEN
    +PULL_ALL
    rti

; raster flags go 1 when they're ready for main loop (which will need to clear)
RASTER_CHASE_BEAM
    !byte   $00


