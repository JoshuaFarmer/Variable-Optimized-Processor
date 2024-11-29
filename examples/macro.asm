; theoretically you can use macros to retarget the assembler (lmao)

; MACRO NAME <ARGS>
macro jne x y addr
	ld a, $x
	cmp $y
	bnz $addr
end

macro inf
	__inf:
	jmp %__inf
end

	org 1024
init:
	inc w0
	jne w0, #1, %init
	inf