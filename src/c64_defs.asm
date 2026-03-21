
; ROM routines

ROM_CLR_SCREEN = $E544

; as the AI said: I’ve got you. Typing out 16 constants is the exact kind of "busy work" 
; that a computer should be doing for you.

; --- C64 Color Constants ---
BLACK       = $00
WHITE       = $01
RED         = $02
CYAN        = $03
PURPLE      = $04
GREEN       = $05
BLUE        = $06
YELLOW      = $07
ORANGE      = $08
BROWN       = $09
LT_RED      = $0a
DK_GRAY     = $0b
MD_GRAY     = $0c
LT_GREEN    = $0d
LT_BLUE     = $0e
LT_GRAY     = $0f

; --- CHars ---
BLANK_SPACE = $20       ; same in PETSCII and screencode!

; --- Screen Size ---
SCREEN_WIDTH    = 320
SCREEN_HEIGHT   = 200
SCREEN_WIDTH_CHARS  = 40 
SCREEN_WIDTH_CHARS_SCROLL  = 38
SCREEN_HEIGHT_CHARS = 25
SCREEN_HEIGHT_CHARS_SCROLL = 24

; --- Common VIC-II Registers ---
BORDER_COL  = $D020
BG_COL      = $D021
BG_COL_1    = $D022
BG_COL_2    = $D023
COLOR_RAM   = $D800

SCREEN_RAM  = $0400
DEFAULT_CHR = $14   ; Value for $D018 to use Uppercase/Graphics
LOWER_CHR   = $16   ; Value for $D018 to use Lower/Upper

SCREEN_HI_BYTE = $0288  ; used for some rom calls

; --- KERNAL JUMP TABLE ---
; PSA: these are all really slow...
SCNKEY  = $ff9f ; Scan keyboard matrix (call manually if not letting system handle everything)
SETLFS  = $ffba ; Set logical file parameters
SETNAM  = $ffbd ; Set filename
OPEN    = $ffc0 ; Open a logical file
CLOSE   = $ffc3 ; Close a logical file
CHKIN   = $ffc6 ; Open channel for input
CHKOUT  = $ffc9 ; Open channel for output
CLRCHN  = $ffcc ; Restore default I/O
CHRIN   = $ffcf ; Get character from input
CHROUT  = $ffd2 ; Output character to screen
LOAD    = $ffd5 ; Load from device
SAVE    = $ffd8 ; Save to device
GETIN   = $ffe4 ; Get character from buffer (call SCNKEY first if taking control from the system)
PLOT    = $fff0 ; Set/Get cursor position


; sprites
SPR_WIDTH       = 24
SPR_COL_WIDTH   = 12
SPR_HEIGHT      = 21



; --- VIC-II MOBs / sprites ---
; ======================================================
; VIC-II Sprite Position Registers
; ======================================================

SPR0_X      = $D000
SPR0_Y      = $D001
SPR1_X      = $D002
SPR1_Y      = $D003
SPR2_X      = $D004
SPR2_Y      = $D005
SPR3_X      = $D006
SPR3_Y      = $D007
SPR4_X      = $D008
SPR4_Y      = $D009
SPR5_X      = $D00A
SPR5_Y      = $D00B
SPR6_X      = $D00C
SPR6_Y      = $D00D
SPR7_X      = $D00E
SPR7_Y      = $D00F

; ======================================================
; Sprite X MSB Register
; Bit 0–7 correspond to sprite 0–7
; ======================================================

SPR_X_MSB   = $D010

; ======================================================
; Sprite Enable Register
; Bit = 1 enables sprite
; ======================================================

SPR_ENABLE  = $D015

; ======================================================
; Sprite Y Expansion (double height)
; ======================================================

SPR_Y_EXP   = $D017

; ======================================================
; Sprite Priority (0=front, 1=behind background)
; ======================================================

SPR_PRIORITY = $D01B

; ======================================================
; Sprite Multicolor Enable
; Bit = 1 enables multicolor for that sprite
; ======================================================

SPR_MC_ENABLE = $D01C

; ======================================================
; Sprite X Expansion (double width)
; ======================================================

SPR_X_EXP   = $D01D

; ======================================================
; Sprite-Sprite Collision Register
; Read to detect, write to clear
; ======================================================

SPR_SPR_COLL = $D01E

; ======================================================
; Sprite-Background Collision Register
; Read to detect, write to clear
; ======================================================

SPR_BG_COLL  = $D01F

; ======================================================
; Sprite Multicolor Shared Colors
; ======================================================

SPR_MC_COLOR0 = $D025
SPR_MC_COLOR1 = $D026

; ======================================================
; Individual Sprite Colors
; ======================================================

SPR0_COLOR  = $D027
SPR1_COLOR  = $D028
SPR2_COLOR  = $D029
SPR3_COLOR  = $D02A
SPR4_COLOR  = $D02B
SPR5_COLOR  = $D02C
SPR6_COLOR  = $D02D
SPR7_COLOR  = $D02E

; ======================================================
; Sprite pointer table (in Screen RAM)
; ======================================================
SPR_PTR0 = $07F8
SPR_PTR1 = $07F9
SPR_PTR2 = $07FA
SPR_PTR3 = $07FB
SPR_PTR4 = $07FC
SPR_PTR5 = $07FD
SPR_PTR6 = $07FE
SPR_PTR7 = $07FF

; --- VIC-II Control Registers ---
VIC_CR1         = $D011 ; CR1 Vertical scroll, Screen On/Off, Bitmap mode, Raster Bit 8
; 0-2	YSCROLL	Vertical Fine Scroll. (0-7 pixels)
; 3	RSEL	Row Select. 1 = 25 rows (standard), 0 = 24 rows.
; 4	DEN	Display Enable. 1 = Screen ON, 0 = Screen OFF (Border only).
; 5	BMM	Bitmap Mode. 1 = On, 0 = Text mode.
; 6	ECM	Extended Color Mode. 1 = On, 0 = Off.
; 7	RST8	9th Bit of Raster Line. Used for lines 256–311.
VIC_CR2         = $D016 ; CR2 Horizontal scroll, Multi-color mode, 40/38 column switch
; 0-2	XSCROLL	Horizontal Fine Scroll. (0–7 pixels)
; 3	CSEL	Column Select. 1 = 40 columns (standard), 0 = 38 columns.
; 4	MCM	Multi-Color Mode. 1 = ON, 0 = OFF (Hi-Res).
; 5	RES	Reset - always 0!
; 6-7	Unused	Not connected. Leave as 1
RASTER_LINE     = $D012 ; Current scanline (Read) / Trigger line (Write)
MEM_SETUP       = $D018 ; high nibble: screen 1kb block, bits 1-3 char set 2kb block, bit 0 unused
VIC_INTER       = $D019 ; Interrupt Status (ACK)
VIC_IMASK       = $D01A ; Interrupt Control (Which ones are enabled?)
VIC_ICR_CIA_1   = $DC0D ; int control reg - set to #$7F to disable timers (read to clear)
VIC_ICR_CIA_2   = $DC0D ; int control reg - set to #$7F to disable NMIs (read to clear)



; --- $D011 (Vertical & Mode) Masks ---
V_TEXT_MODE    = %00000000   ; Standard Text
V_BITMAP_MODE  = %00100000   ; Turn on Bitmaps
V_ECM_MODE     = %01000000   ; Extended Color Mode
V_SCREEN_ON    = %00010000   ; Show the screen
V_SCREEN_OFF   = %11101111   ; Hide the screen (use with AND)
V_ROW_25       = %00001000   ; 25 row mode (Standard)
V_ROW_24       = %11110111   ; 24 row mode (For scrolling)
V_RASTER_MSB   = %10000000   ; The 9th bit (Bit 7) of the raster position

; --- $D016 (Horizontal & Multi) Masks ---
H_MULTICOLOR   = %00010000   ; Enable 4-color mode
H_HI_RES       = %11101111
H_COL_40       = %00001000   ; 40 Column mode (Standard)
H_COL_38       = %11110111   ; 38 Column mode (For scrolling)


; --- Zero Page Pointers ---
; the safe ones if you've not disabled all the ROMs
ZP_PTR_1        = $FB  ; Safe Zero Page Uses $FB and $FC
ZP_PTR_1_PAIR   = $FC  ; Safe Zero Page Uses $FB and $FC

ZP_PTR_2        = $FD  ; Safe Zero Page Uses $FD and $FE
ZP_PTR_2_PAIR   = $FE  ; Safe Zero Page Uses $FD and $FE

ZP_PTR_TEMP_0        = $1B  
ZP_PTR_TEMP_0_PAIR   = $1C  

ZP_PTR_TEMP_1        = $1D  
ZP_PTR_TEMP_1_PAIR   = $1E  


; --- Interrupts ---
KERNEL_INT_PTR_LOW = $0314
KERNEL_INT_PTR_HI = $0315
KERNEL_FULL_EXIT = $EA31 ; jmp to exit kernel-based irq, does all the stuff like KB and clocks the Kernel handles
KERNEL_FAST_EXIT = $FEB1 ; jmp to exit kernel-based irq, just pops the pushed registers that the interrupt system pushed automatically
SELF_INT_PTR_LOW = $FFFE
SELF_INT_PTR_HI = $FFFF

ROM_DEFAULTS = %00110111    ; Default - BASIC, Kernal, and I/O all visible - ($37)
ROM_NO_BASIC = %00110110    ; BASIC off, Kernal on, I/O on ($36)
ROM_JUST_IO  = %00110101     ; BASIC off, Kernal off, I/O on ($35)



; key values

; CIA1_PRA rows
KEY_SPACE_ROW   = %01111111
KEY_Q_ROW       = %11111011
KEY_A_ROW       = %11111101
KEY_O_ROW       = %11011111
KEY_P_ROW       = %11011111
KEY_W_ROW       = %11111101
KEY_S_ROW       = %11111101
KEY_D_ROW       = %11111011
KEY_ENTER_ROW   = %11111110


; CIA1_PRB cols
KEY_SPACE_COL   = %00010000
KEY_Q_COL       = %01000000
KEY_A_COL       = %00000100
KEY_O_COL       = %01000000
KEY_P_COL       = %00000010
KEY_W_COL       = %00000010
KEY_S_COL       = %00100000
KEY_D_COL       = %00000100
KEY_ENTER_COL   = %00000010

; --- CIA 1 Registers ---
CIA1_PRA = $DC00    ; Port A (Rows)
CIA1_PRB = $DC01    ; Port B (Columns)
CIA1_DDRA = $DC02   ; data direction A (set all bits output $ff)
CIA1_DDRB = $DC03   ; data direction A (set all bits input $00)