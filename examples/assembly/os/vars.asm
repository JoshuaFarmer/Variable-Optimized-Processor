	; Variable Handling
	; A == name (A-Z)
	; returns address in a
GetVariableAddress:
	; (ord(name)-65) * 2 + 4096
	sub #65
	ld w0, #2
	ld w1, a
	call %mul
	add %variables
	ret

	; A == Name, W7 == value
SetVariable:
	call %GetVariableAddress
	ld z7, a
	poke w7, .z7
	ret

	; A == Name, A == return val
GetVariable:
	call %GetVariableAddress
	ld z7, a
	peek w1, .z7
	ld a, w1
	ret
