	; expressions

	; return value of literal or var in A
	; ptr == s0
FETCH_VALUE:
	peek a, s0
	and #255
	cmp #36
	bz %FETCH_VALUE_VAR
	call %string_to_hex
	inc s0
	jmp %FETCH_VALUE_END
FETCH_VALUE_VAR:
	inc s0
	peek a, s0
	and #255
	call %GetVariable
	inc s0
	inc s0
FETCH_VALUE_END:
	ret

	; S0 as ptr
_EXPR_IS:
	ld s0, x5
EXPR_IS:
	xc a, s0
	add #3
	xc a, s0
	call %EXPR_TWO_ARGS

	cmp w7, x3
	bz %EXPR_IS_EQUAL
	ld a, #0
	ret
EXPR_IS_EQUAL:
	ld a, #1
	ret

EXPR_TWO_ARGS:
	call %FETCH_VALUE
	ld z6, a
	call %FETCH_VALUE
	ld w7, z6
	ld x3, a
	ret

_EXPR_ADD:
	ld s0, x5
EXPR_ADD:
	xc a, s0
	add #4
	xc a, s0
	call %EXPR_TWO_ARGS
	add w7, x3
	ld a, w7
	ret

_EXPR_SUB:
	ld s0, x5
EXPR_SUB:
	xc a, s0
	add #4
	xc a, s0
	call %EXPR_TWO_ARGS
	sub w7, x3
	ld a, w7
	ret

_EXPR_MUL:
	ld s0, x5
EXPR_MUL:
	xc a, s0
	add #4
	xc a, s0
	call %EXPR_TWO_ARGS
	ld w0, w7
	ld w1, x3
	call %mul
	ret

_EXPR_JUMP:
	ld s0, x5
EXPR_JUMP:
	xc a, s0
	add #5
	xc a, s0
	call %FETCH_VALUE
	ld x1, a
	ret

_EXPR_IF:
	ld s0, x5
EXPR_IF:
	xc a, s0
	add #3
	xc a, s0
	; evaluate expression
	call %EXPR
	ld w7, a
	; if zero
	cmp #0
	bnz %EXPR
	ret

EXPR:
	ld x5, s0

	ld s0, x5
	ld s1, %cmd_add
	call %strcmp
	cmp #1
	bz %_EXPR_ADD

	ld s0, x5
	ld s1, %cmd_sub
	call %strcmp
	cmp #1
	bz %_EXPR_SUB

	ld s0, x5
	ld s1, %cmd_mul
	call %strcmp
	cmp #1
	bz %_EXPR_MUL

	ld s0, x5
	ld s1, %cmd_is
	call %strcmp
	cmp #1
	bz %_EXPR_IS

	ld s0, x5
	ld s1, %cmd_jump
	call %strcmp
	cmp #1
	bz %_EXPR_JUMP

	ld s0, x5
	ld s1, %cmd_if
	call %strcmp
	cmp #1
	bz %_EXPR_IF

	ld s0, x5
	ld s1, %cmd_assign
	call %strcmp
	cmp #1
	bz %_EXPR_ASSIGN
	ret

	;; ASSIGN A ADD 0001 0001
proc_assign:
	ld x5, %keyboard
_EXPR_ASSIGN:
	ld s0, x5
EXPR_ASSIGN:
	xc a, s0
	add #7
	xc a, s0
	; get name
	peek a, s0
	and #255
	ld x7, a
	inc s0
	inc s0

	; evaluate
	call %EXPR
	ld w7, a
	ld a, x7
	call %SetVariable
	ret

	; a == line_num
get_line:
	ld w0, a
	ld w1, %line_len
	call %mul
	add %lines
	ld z7, a
	ret
	; s0 == src
	; a == line_num
copy_to_line:
	; save
	ld x6, s0
	call %get_line
	ld w7, %line_len
copy_to_line_l0:
	peek w1, .s0
	poke w1, .z7
	inc z7
	inc s0
	dec w7
	bnz %copy_to_line_l0
	; restore
	ld s0, x6
	ret