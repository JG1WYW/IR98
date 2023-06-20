
	LISTS

	MODULE IR98

;	PROCEDURE LinkVsync( proc: PROC; soff: CARDINAL );

	PSECT
soff:	ds 2
proc:	ds 4
	CSECT
	LABEL LinkVsync
	
	PUSH BP
	MOV	BP, SP
	PUSH DS
	
;	引数で渡されたハンドラデータの埋め込み
	MOV AX, WORD PTR [BP+proc]
	MOV WORD PTR CS:VsyncHandler+1, AX
	MOV AX, WORD PTR [BP+proc+2]
	MOV WORD PTR CS:VsyncHandler+3, AX
	
	MOV AX, SP
	SUB AX, WORD PTR [BP+soff]
	MOV WORD PTR CS:vsoff+1, AX
	MOV AX, SS
	MOV WORD PTR CS:vsseg+1, AX
	
;	既存のＩＶＡ内容の埋め込み
	MOV AX, 0
	MOV DS, AX
	MOV AX, WORD PTR VTYPE*4
	MOV WORD PTR CS:VsyncEntry+1, AX
	MOV AX, WORD PTR VTYPE*4+2
	MOV WORD PTR CS:VsyncEntry+3, AX
	
;	ＩＶＡ内容変更
	MOV AX, VsyncCheck
	MOV BX, CS
	CLI
	MOV WORD PTR VTYPE*4, AX
	MOV WORD PTR VTYPE*4+2, BX
	MOV BYTE PTR CS:Vsemaphore, 0
	STI
;	OUT	64h, AL
	
	MOV DS, DSBASE
	
	MOV WORD PTR NewVsync, AX			;	定義変数への代入
	MOV WORD PTR NewVsync+2, BX
	
	POP DS
	POP BP
	
	RET 6

;	PROCEDURE UnlinkVsync;

	LABEL UnlinkVsync
	
	PUSH DS
	
	MOV AX, 0
	MOV DS, AX
	MOV AX, WORD PTR CS:VsyncEntry+1
	MOV BX, WORD PTR CS:VsyncEntry+3
	CLI
	MOV WORD PTR VTYPE*4, AX
	MOV WORD PTR VTYPE*4+2, BX
	STI
	POP DS
	
	RET

;	割り込みハンドラ

VsyncCheck:
	
	CLI
	
	CMP BYTE PTR CS:Vsemaphore, 0
	JNZ VsyncChain
	
VsyncStart:
	MOV BYTE PTR CS:Vsemaphore, 1
	
	STI
	
	PUSH BP
	
	PUSH ES
	PUSH AX
	PUSH CX
	PUSH DX
	PUSH BX
	PUSH SI
	PUSH DI
	
	MOV CX, SS
	MOV BX, SP
	
vsseg:
	MOV AX, 0			; 0 はダミー
	CLI
vsoff:
	MOV SP, 0			; 0 はダミー
	MOV SS, AX
	STI
	
	PUSH CX
	PUSH BX
	
VsyncHandler:
	CALL LinkVsync		; LinkVsync はダミー CALL far => 9A far
	
	POP BX
	POP CX
	
	CLI
	MOV SS, CX
	MOV SP, BX
	STI
	
	POP DI
	POP SI
	POP BX
	POP DX
	POP CX
	POP AX
	POP ES
	
	POP BP
	
;	OUT	64h, AL
	
	CLI
	
	MOV BYTE PTR CS:Vsemaphore, 0
	
VsyncChain:
	PUSHF
VsyncEntry:
	CALL LinkVsync		; LinkVsync はダミー CALL far => 9A far
	IRET
	
Vsemaphore:
	NOP

;	PROCEDURE LinkBG( proc: PROC; soff: CARDINAL );

	PSECT
soff:	ds 2
proc:	ds 4
	CSECT
	LABEL LinkBG
	
	PUSH BP
	MOV	BP, SP
	PUSH DS
	
;	引数で渡されたハンドラデータの埋め込み
	MOV AX, WORD PTR [BP+proc]
	MOV WORD PTR CS:BGHandler+1, AX
	MOV AX, WORD PTR [BP+proc+2]
	MOV WORD PTR CS:BGHandler+3, AX
	
	MOV AX, SP
	SUB AX, WORD PTR [BP+soff]
	MOV WORD PTR CS:bgoff+1, AX
	MOV AX, SS
	MOV WORD PTR CS:bgseg+1, AX
	
;	既存のＩＶＡ内容の埋め込み
	MOV AX, 0
	MOV DS, AX
	MOV AX, WORD PTR BTYPE*4
	MOV WORD PTR CS:BGEntry+1, AX
	MOV AX, WORD PTR BTYPE*4+2
	MOV WORD PTR CS:BGEntry+3, AX
	
;	ＩＶＡ内容変更
	MOV AX, BGCheck
	MOV BX, CS
	CLI
	MOV WORD PTR BTYPE*4, AX
	MOV WORD PTR BTYPE*4+2, BX
	MOV BYTE PTR CS:BGsemaphore, 0
	STI
	
	MOV DS, DSBASE
	
	MOV WORD PTR NewBG, AX			;	定義変数への代入
	MOV WORD PTR NewBG+2, BX
	
	POP DS
	POP BP
	
	RET 6

;	PROCEDURE UnlinkBG;

	LABEL UnlinkBG
	
	PUSH DS
	
	MOV AX, 0
	MOV DS, AX
	MOV AX, WORD PTR CS:BGEntry+1
	MOV BX, WORD PTR CS:BGEntry+3
	CLI
	MOV WORD PTR BTYPE*4, AX
	MOV WORD PTR BTYPE*4+2, BX
	STI
	POP DS
	
	RET

;	割り込みハンドラ

BGCheck:
	
	CLI
	
	CMP BYTE PTR CS:BGsemaphore, 0
	JNZ BGChain
	
BGStart:
	MOV BYTE PTR CS:BGsemaphore, 1
	
	STI
	
	PUSH BP
	
	PUSH ES
	PUSH AX
	PUSH CX
	PUSH DX
	PUSH BX
	PUSH SI
	PUSH DI
	
	MOV CX, SS
	MOV BX, SP
	
bgseg:
	MOV AX, 0			; 0 はダミー
	CLI
bgoff:
	MOV SP, 0			; 0 はダミー
	MOV SS, AX
	STI
	
	PUSH CX
	PUSH BX
	
BGHandler:
	CALL LinkBG			; LinkBG はダミー CALL far => 9A far
	
	POP BX
	POP CX
	
	CLI
	MOV SS, CX
	MOV SP, BX
	STI
	
	POP DI
	POP SI
	POP BX
	POP DX
	POP CX
	POP AX
	POP ES
	
	POP BP
	
	CLI
	
	MOV BYTE PTR CS:BGsemaphore, 0
	
BGChain:
	PUSHF
BGEntry:
	CALL LinkBG			; LinkBG はダミー CALL far => 9A far
	IRET
	
BGsemaphore:
	NOP

;	存在確認の為に, プリンタ BIOS (01ah) をフックしている.

;	PROCEDURE LinkExist( id: CARDINAL; proc: IPROC; soff: CARDINAL );

	PSECT
soff:	ds 2
proc:	ds 4
id:		ds 2
	CSECT
	LABEL LinkExist
	
	PUSH BP
	MOV	BP, SP
	PUSH DS
	
;	判定コードの埋め込み
	MOV AX, [BP+id]
	MOV WORD PTR CS:ExistCmp+1, AX
	
;	引数で渡されたハンドラデータの埋め込み
	MOV AX, WORD PTR [BP+proc]
	MOV WORD PTR CS:excoff+1, AX
	MOV AX, WORD PTR [BP+proc+2]
	MOV WORD PTR CS:excseg+1, AX
	
	MOV AX, SP
	SUB AX, WORD PTR [BP+soff]
	MOV WORD PTR CS:exsoff+1, AX
	MOV AX, SS
	MOV WORD PTR CS:exseg+1, AX
	
;	既存のＩＶＡ内容の埋め込み
	MOV AX, 0
	MOV DS, AX
	MOV AX, WORD PTR ETYPE*4
	MOV WORD PTR CS:ExistEntry+1, AX
	MOV AX, WORD PTR ETYPE*4+2
	MOV WORD PTR CS:ExistEntry+3, AX
	
;	ＩＶＡ内容変更
	MOV AX, ExistCheck
	MOV BX, CS
	CLI
	MOV WORD PTR ETYPE*4, AX
	MOV WORD PTR ETYPE*4+2,BX
	MOV BYTE PTR CS:Esemaphore, 0
	STI
	
	MOV DS, DSBASE
	
	MOV WORD PTR NewExist, AX			;	定義変数への代入
	MOV WORD PTR NewExist+2, BX
	
	POP DS
	POP BP
	
	RET 8

;	PROCEDURE UnlinkExist;

	LABEL UnlinkExist
	
	PUSH DS
	
	MOV AX, 0
	MOV DS, AX
	MOV AX, WORD PTR CS:ExistEntry+1
	MOV BX, WORD PTR CS:ExistEntry+3
	CLI
	MOV WORD PTR ETYPE*4, AX
	MOV WORD PTR ETYPE*4+2, BX
	STI
	POP DS
	
	RET

;	割り込みハンドラ

ExistCheck:
	
	CLI
	
	CMP BYTE PTR CS:Esemaphore, 0
	JNZ ExistChain
	
ExistCmp:
	CMP AX, 0			; 0 はダミー CMP AX, i => 3D i
	JNZ ExistChain
	
ExistStart:
	MOV BYTE PTR CS:Esemaphore, 1
	
	STI
	
	MOV AX, EXIST		; EXIST は存在確認コード MOV AX, i => B8 i
excseg:
	MOV BX, 0			; ダミー. コードセグメント
	MOV ES, BX
excoff:
	MOV BX, 0			; ダミー. コードオフセット
exseg:
	MOV DX, 0			; ダミー. スタックセグメント
	MOV DS, DX
exsoff:
	MOV DX, 0			; ダミー. スタックオフセット
	
	MOV BYTE PTR CS:Esemaphore, 0
	
	IRET
	
ExistChain:
	PUSHF
ExistEntry:
	CALL LinkVsync		; LinkVsync はダミー CALL far => 9A far
	
	IRET
	
Esemaphore:
	NOP

;	以下 Icall
;	コメントで潰してある部分は Icall の返値が ADDRESS 型の場合

AXOFF	EQU	0
CXOFF	EQU	2
DXOFF	EQU	4
BXOFF	EQU	6
SIOFF	EQU	8
DIOFF	EQU	10
ESOFF	EQU	12
DSOFF	EQU	14
FLAGS	EQU	16

	PSECT
par2	DS	2
par1	DS	4
res		DS  2
;res		DS  4
	CSECT
	LABEL Icall
	
	PUSH BP
	MOV BP,SP
	PUSH DS
	
	MOV DX, WORD PTR [BP+par2]
	LES SI, WORD PTR [BP+par1]
	
	MOV AX, SS
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	
	MOV AX, ES:WORD PTR [SI+DSOFF]
	MOV BX, ES:WORD PTR [SI+DXOFF]
	
	CLI
	MOV SS, AX
	MOV SP, BX
	STI
	
;	PUSH DX
	PUSH DX
	PUSH DX
	PUSH ES:WORD PTR [SI+ESOFF]
	PUSH ES:WORD PTR [SI+BXOFF]
	PUSH CS
	
	CALL FarCall
	
	POP DX
;	POP BX
	
	MOV AX, DS
	CLI
	MOV SS, AX
	MOV SP, BP
	STI
	POP BP
	
	MOV WORD PTR [BP+res], DX
;	MOV WORD PTR [BP+res+2], BX
	
	POP DS
	POP BP
	
	RET 6

FarCall:							; FAR CARLL 手続き
	POP AX
	POP BX							; ここには NEAR で飛んでくる
	POP CX
	POP DX
	PUSH BX
	PUSH AX
	PUSH DX
	PUSH CX
	RETF							; この RETF は FAR CALL

;	PROCEDURE Free( psp: CARDINAL );

	PSECT
par0:	DS	2
	CSECT
	LABEL Free
	
	PUSH BP
	MOV BP,SP
	
	MOV ES, WORD PTR [BP+par0]
	MOV ES, ES:[2ch]				; 環境領域 PSP オフセット 2ch
	MOV AH, 49h
	INT 21h							; DOS ファンクション 49h 領域解放
	
	MOV ES, WORD PTR [BP+par0]		; 本体領域
	MOV AH, 49h
	INT 21h							; DOS ファンクション 49h 領域解放
	
	POP BP
	
	RET 2
	
;	PROCEDURE GetINDOS(): ADDRESS;

	PSECT
FPTR:	DS	4
	CSECT
	LABEL GetINDOS
	
	PUSH BP
	MOV BP,SP
	
	MOV AH, 34h
	INT 21h
	
	MOV WORD PTR [BP+FPTR], BX
	MOV WORD PTR [BP+FPTR+2], ES
	
	POP BP
	RET

;	PROCEDURE GetMCB(): ADDRESS;

	PSECT
FPTR:	DS	4
	CSECT
	LABEL GetMCB
	
	PUSH BP
	MOV BP,SP
	
	MOV AH, 52h
	INT 21h
	
	MOV WORD PTR [BP+FPTR], BX
	MOV WORD PTR [BP+FPTR+2], ES
	
	POP BP
	RET
	
	END

