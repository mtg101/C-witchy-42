

; RNG uses SID chip's noise generator for really good RNs!

MATHS_SETUP_RNG
    lda #$FF        ; Set frequency high byte to max
    sta $D40E       ; Voice 3 Frequency (High)
    sta $D40F       ; Voice 3 Frequency (Low)
    lda #$80        ; $80 = Noise waveform, no sound output
    sta $D412       ; Voice 3 Control Register
    rts     

MATHS_RNG           = $D41B   


; 0-15 RNG, max is Y 
; if Y is 13, RNG is 0-13
; just keeps retrying...
; A is RNG 
MATHS_RNG_0_Y_15
    sty ZP_PTR_TEMP_1
MATHS_RNG_0_Y_15_LOOP
    lda MATHS_RNG
    and #%00001111       ; 0-15
    cmp ZP_PTR_TEMP_1   ; reject if Y or bigger
    bcs MATHS_RNG_0_Y_15_LOOP
    rts



    