;quadrants (030C, 0313, 050C, 0513)
;drop-in (02EF, 02CF, 02F0, 02D0, 02AF, 02B0, 028F)
;$0: Black, $1: White, $2: Red, $3: Cyan, $4: Purple, $5: Green, $6: Blue, $7: Yellow, $8: Orange
;00-07 current coordinates, 08-0B colours, next 0C-13, 14 block (i=00, l=01, h=02, s=03), 15 state (0, 90, 180, 270), 
;16 baseL, 18 unfinal_matchL, 38 final_matchL

define currentL $00
define currentH $01
define nextL $0C
define nextH $0D
define block $14
define state $15
define bottom_leftL $16
define bottom_leftH $17
define bottom_rightL $18
define bottom_rightH $19
define top_leftL $1A
define top_leftH $1B
define top_rightL $1C
define top_rightH $1D
define thisL $1E
define thisH $20
define thatL $21
define thatH $22
define baseL $23
define baseH $24
define unfinal_matchL $25
define unfinal_matchH $26
define final_matchL $4E
define final_matchH $50


init_game:
    JSR load_block
    JSR render_block
    JSR drop
    JSR read_keys


load_block:
    JSR random_number
    CMP #$01
    BEQ load_i_block
    CMP #$02
    BEQ load_l_block
    CMP #$03
    BEQ load_h_block
    CMP #$04
    BEQ load_s_block
    RTS


random_number:
    LDA $fe
    AND #03
    RTS


load_highs:
    LDY $00, X
    INX
    INX
    CPX #$06
    BNE load_highs
    RTS


load_i_block:
    JSR load_highs
    LDY $8F
    STY ($00, X)
    INX
    LDY $AF
    STY ($00, X)
    LDY $CF
    STY ($00, X)
    LDY $EF
    STY ($00, X)
    LDA #00
    STA $2E
    RTS


load_l_block:
    JSR load_highs
    LDY $AF
    STY ($00, X)
    INX
    LDY $CF
    STY ($00, X)
    LDY $EF
    STY ($00, X)
    LDY $F0
    STY ($00, X)
    LDA #01
    STA $2E
    RTS


load_h_block:
    JSR load_highs
    LDY $AF
    STY ($00, X)
    INX
    LDY $CF
    STY ($00, X)
    LDY $D0
    STY ($00, X)
    LDY $F0
    STY ($00, X)
    LDA #02
    STA $2E
    RTS


load_s_block:
    JSR load_highs
    LDY $CF
    STY ($00, X)
    INX
    LDY $D0
    STY ($00, X)
    LDY $EF
    STY ($00, X)
    LDY $F0
    STY ($00, X)
    LDA #03
    STA $2E
    RTS

render_block:
    LDA $08, Y
    STA ($00, X)
    INX
    INX
    INY
    CPX #$06
    BNE generate_block
    RTS

wipe_block:
    LDA #00
    STA ($00, X)
    INX
    INX
    CPX #06
    BNE wipe_block
    RTS


load_colours:
    JSR random_number
    CMP #00
    BNE +#10
    LDY #02 ,red
    STA colours, X
    INX
    CPX #04
    BNE load_colours

    CMP #01
    BNE +#08
    LDY #05 ;green
    STA colours, X
    INX
    CPX #04
    BNE load_colours

    CMP #02
    BNE +#10
    LDY #06 ;blue
    STA colours, X
    INX
    CPX #04
    BNE load_colours

    LDY #07 ;yellow
    STA colours, X
    INX
    CPX #04
    BNE load_colours

    RTS


generate_next_below:
    JSR generate_belowL
    INX
    INX
    CPX #08
    BNE generate_next_below


generate_belowL:
    LDA currentL, X
    ADC #$20
    STA nextL, X
    BCS generate_belowH
    RTS


generate_belowH:
    LDA currentH, X
    STA nextH, X
    INC nextH, X
    RTS


generate_next:
    LDA currentL, X
    STA nextL, X
    DEC nextL, X
    LDA currentH, X
    STA nextH, X
    INX
    INX
    CPX #08
    BNE generate_next


legal_left:
    JSR empty_next
    LDX #00
    JSR unbounded_left
    RTS


empty_next:
    LDA (nextL, X)
    CMP #00
    BNE render_block
    INX
    INX
    CPX #08
    BNE empty_left
    RTS


unbounded_left:
    LDA nextH, X
    AND #$1F
    CMP #$0B
    BEQ render_block
    INX
    INX
    CPX #08
    JSR unbounded_left
    RTS


legal_right:
    JSR empty_next
    LDX #00
    JSR unbounded_right
    RTS


unbounded_right:
    LDA nextL, X
    AND #$1F
    CMP #$14
    BEQ render_block
    INX
    INX
    CPX #08
    JSR unbounded_right
    RTS


legal_below:
    JSR empty_next
    LDX #00
    JSR unbounded_below
    RTS

empty_below:
    LDA (nextL, X)
    CMP #00
    BNE render_block
    INX
    INX
    CPX #08
    BNE empty_below
    RTS


unbounded_below:
    JSR maybe_unbounded_below
    LDA #00
    JSR unbounded_below


JSR maybe_unbounded_below:
    LDA nextH, X
    CMP #05
    BPL render_block
    CMP #04
    BMI drop
    BEQ unbounded_below
    INX
    INX
    CPX #08
    JSR maybe_unbounded_below
    RTS

JSR unbounded_below:
    LDA nextL, X
    CMP #$13
    BPL render_block
    RTS


move:
    LDA nextL, X
    STA currentL, X
    INX
    CPX #08
    BNE move
    RTS


read_keys:

    LDA $ff
    CMP #$77       ;(W)
    BEQ morph
    CMP #$64 	;(D)
    BEQ move_left
    CMP #$73	;(S)
    BEQ rotate
    CMP #$61       ;(A)
    BEQ move_right
    RTS

  
morph:
    LDA $08, X
    PHA 
    CPX #04
    BNE morph
    PLA $08
    PLA $0B
    PLA $0A
    PLA $09
    RTS


rotate:
    JSR generate_next_rotate
    JSR empty_next
    JSR unbounded_left
    JSR unbounded_right
    JSR unbounded_below
    JSR move
    RTS


generate_next_rotate:
    LDA block
    CMP #00
    BEQ rotate_i
    CMP #01
    BEQ rotate_l
    CMP #02
    BEQ rotate_h
    CMP #03
    BEQ rotate_s


rotate_i:
    LDA state
    CMP #00
    BEQ rotate_i_90
    CMP #01
    BEQ rotate_i_0


rotate_l:
    LDA state
    CMP #00
    BEQ rotate_l_90
    CMP #01
    BEQ rotate_l_180
    CMP #02
    BEQ rotate_l_270
    CMP #03
    BEQ rotate_l_0


rotate_h:
    LDA state
    CMP #00
    BEQ rotate_h_90
    CMP #01
    BEQ rotate_h_180
    CMP #02
    BEQ rotate_h_270
    CMP #03
    BEQ rotate_h_0


rotate_s:
    NOP
    RTS

rotate_i_90:
    JSR rotate_W
    INX
    INX
    INX
    INX
    JSR rotate_E
    INX
    INX
    JSR rotate_E2
    INX
    INX
    LDA #01
    STA state


rotate_i_0:
    JSR rotate_E
    INX
    INX
    INX
    INX
    JSR rotate_W
    INX
    INX
    JSR rotate_W2
    INX
    INX
    LDA #00
    STA state


rotate_l_90:
    JSR rotate_E
    INX
    INX
    INX
    INX
    JSR rotate_W
    INX
    INX
    JSR rotate_SW
    INX
    INX
    LDA #01
    STA state


rotate_l_180:
    JSR rotate_S
    INX
    INX
    INX
    INX
    JSR rotate_N
    INX
    INX
    JSR rotate_NW
    INX
    INX
    LDA #02
    STA state


rotate_l_270:
    JSR rotate_W
    INX
    INX
    INX
    INX
    JSR rotate_E
    INX
    INX
    JSR rotate_NE
    INX
    INX
    LDA #03
    STA state


rotate_l_0:
    JSR rotate_N
    INX
    INX
    INX
    INX
    JSR rotate_S
    INX
    INX
    JSR rotate_SE
    INX
    INX
    LDA #00
    STA state


rotate_h_90:
    JSR rotate_E
    INX
    INX
    INX
    INX
    JSR rotate_S
    INX
    INX
    JSR rotate_SW
    INX
    INX
    LDA #01
    STA state


rotate_h_180:
    JSR rotate_S
    INX
    INX
    INX
    INX
    JSR rotate_W
    INX
    INX
    JSR rotate_NW
    INX
    INX
    LDA #02
    STA state


rotate_h_270:
    JSR rotate_W
    INX
    INX
    INX
    INX
    JSR rotate_N
    INX
    INX
    JSR rotate_NE
    INX
    INX
    LDA #03
    STA state


rotate_h_0:
    JSR rotate_N
    INX
    INX
    INX
    INX
    JSR rotate_E
    INX
    INX
    JSR rotate_SE
    INX
    INX
    LDA #00
    STA state


rotate_N:
    JSR plusL
    SBC #$20
    BCC minusH
    RTS


rotate_E:
    JSR plusL
    ADC #$20
    BCS plusH
    RTS


rotate_S:
    JSR minusL
    ADC #$20
    BCS plusH
    RTS



rotate_W:
    JSR minusL
    SBC #$20
    BCC minusH
    RTS


rotate_NE:
    JSR plusL
    INC nextL, X
    RTS


rotate_SW:
    JSR minusL
    DEC nextL, X
    RTS


rotate_SE:
    LDA currentL, X
    ADC #$40
    BCS plusH
    RTS


rotate_NW:
    LDA currentL, X
    SBC #$40
    BCS minusH
    RTS


JSR rotate_W2:
    JSR minusL2
    SBC #$40
    BCC minusH
    RTS


JSR rotate_E2:
    JSR plusL2
    ADC #$40
    BCS plusH
    RTS


plusL:
    LDA currentL, X
    STA nextL, X
    INC nextL, X
    RTS


minusL:
    LDA currentL, X
    STA nextL, X
    DEC nextL, X
    RTS


minusH:
    LDA currentH, X
    STA nextH, X
    DEC nextH, X
    RTS


plusH:
    LDA currentH, X
    STA nextH, X
    INC nextH, X
    RTS


plusL2:
    LDA currentL, X
    STA nextL, X
    INC nextL, X
    INC nextL, X
    RTS


minusL2:
    LDA currentL, X
    STA nextL, X
    DEC nextL, X
    DEC nextL, X
    RTS


load_defs:
    LDA #05
    STA $17
    STA $19
    STA $24
    LDA #03
    STA $1B
    STA $1D
    LDA #$0C
    STA $16
    STA $1A
    STA $23
    LDA #13
    STA $18
    STA $1C


check_game_over:
    LDA ($02EC, X)
    CMP #00
    BNE reset
    INX
    CPX #07
    BNE check_game_over

reset:
    LDA #00
    STA $FF
    JSR _reset
    RTS


_reset:
    LDA $FF
    CMP #00
    BNE init_game
    BEQ _reset
    RTS


    LDX #00

load_verticals:

    ; load base, this, that

    LDA baseH
    STA firstH
    STA secondH
    LDA baseL
    STA firstL
    SBC #$20
    DEC secondH
    STA secondL

JSR load_vertical
    ; call for 8 values of X
    INX
    CPX #08
    BNE load_verticals

    RTS


load_vertical:
    LDA (firstL, X)
    CMP (secondL, X)

    BEQ load_unfinal_match
    LDA secondL
    STA firstL
    LDA secondH
    STA firstH
    LDA secondL

    SBC #$20
    BCC +#04

    DEC secondH
    JSR load_final_match
    LDA #$10
    BNE load_vertical
    RTS



load_horizontals:


load_horizontal:


load_down_diagonals:


load_down_diagonal:


load_up_diagonals:


load_up_diagonal:


unfinal_match:




explode:
    LDA (final_matchL, X)
    CMP #00
    BEQ collapse_line
    LDA #01
    STA (final_matchL, X)
    INX
    INX
    JMP explode


collapse_lines:
    JSR collapse_line
    INX
    INX
    INC baseL
    JSR copy_base_to_this
    CPX #16
    BNE collapse_lines
    RTS


load_first:
    LDA baseL
    STA thisL
    LDA baseH
    STA thisH
    RTS


copy_second_to_first:
    LDA baseL
    STA thisL
    LDA baseH
    STA thisH
    RTS


copy_load_second:
    LDA baseL
    STA thisL
    LDA baseH
    STA thisH
    RTS


collapse_line:
    JSR copy_base_to_this
    LDA (baseL, X)
    CMP #01 ;check for white and turn to zero if true, keeping count of the amount of whites encountered
    BEQ cl_turn_to_zero
    ;otherwise leave unchanged and count upwards
    CMP #01
    BPL cl_drop_down
    SBC #$20
    BCS cl_change_high
    ;drop block down according to count

    RTS


cl_turn_to_zero:
    LDA #00
    STA (thisL, X)
    INY
    RTS


cl_change_high:
    DEC thisH
    RTS


cl_drop_down:
    DEY
    CPY #00
    BNE cl_drop_down
    RTS