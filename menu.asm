;Patricia Figueroa 
;CSCI 2525 Assembly Language for x86 Processors
;Programming Assignment 05

TITLE menu.asm

include irvine32.inc

clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>

.data
prompt1 byte 'MAIN MENU', 0ah, 0dh,
             '---------', 0ah, 0dh,
             '1. Enter a string', 0Ah, 0Dh,
             '2. Convert the string to lower case', 0Ah, 0Dh,
             '3. Remove all non-letter elements', 0Ah, 0Dh,
             '4. Is the string a palindrome?', 0Ah, 0Dh,
             '5. Print the string', 0Ah, 0Dh,
             '6. Quit', 0Ah, 0Dh, 0h
			 

oops byte 'Invalid Entry.  Please try again.', 0h

UserInput byte 0h

theString byte 50 dup(0h),0h
theStringlen byte 0h

op1picked byte 0h

errPrompt byte "You must pick option 1 first so that we have a string to work with", 0

.code
main PROC
clearEAX
clearEBX
clearECX
clearEDX
clearESI
clearEDI


starthere:                           	; MAIN LOOP
	call clrscr	
	startthere_alt:	
	push edx				
	mov edx, OFFSET prompt1
	call WriteString
	pop edx
	call ReadDec
	mov userinput, al


opt1: 								 	; option 1 : Enter a string
	cmp userinput, 1
	jne opt2
	mov edx, OFFSET theString
	mov ecx, LENGTHOF theString
	call option1
	mov theStringLen, al
	jmp starthere

;Menu options 

opt2:  									; option 2: Convert the string to lower case
	cmp op1picked, 1                    ; user cannot go to other options if option 1 was not picked first
	jne err
	cmp userinput, 2
	jne opt3
	mov edx, OFFSET theString 			; offset of the string for option 2, the length of user input string 
	movzx ecx, theStringLen   			; length of string
	call option2
	jmp starthere

opt3: 									; option 3: Remove all non-letter elements
	cmp userinput, 3
	jne opt4							; if not option 3 go to option 4
	mov edx, OFFSET theString 			; offset of string 
	movzx ecx, theStringLen   			; length of string 
	call option3		
	jmp starthere

opt4: 									; option 4: Is it a palindrome
	cmp userinput, 4		
	jne opt5							; if not option 4 go to option 5
	mov edx, OFFSET theString 			; offset of string 
	movzx ecx, theStringLen   			; length of string 
	call option4
	jmp starthere

opt5:									; option 5: Print the String 
	cmp userinput, 5					
	jne opt6							; if not option 5 got to option 6
	mov edx, OFFSET theString 			;offset of string to play with
	call WriteString
	call crlf
	call WaitMsg
	jmp starthere

opt6:									; option 6: Quit
	cmp userinput, 6				
	je  theEnd2							; jump if equal 
	mov edx, OFFSET oops				; if user enters an invalid entry from not in the menu options 
	call WriteString
	call Waitmsg
	jmp starthere

err:
	cmp userinput, 6
	je opt6
	mov edx, OFFSET errPrompt
	call WriteString
	call crlf
	jmp startthere_alt

theEnd:
	call WaitMsg
theEnd2:
exit
main ENDP


;====================================================
option1 PROC uses EDX ECX
;Desc:  Prompts the user to enter a string.
;       User entered string will be stored in 
;       the array passed in EDX
;Receives: edx - offset of the string 
;          ecx - max length of the string
;Returns:  eax - number of chars entered by the user
;=====================================================
.data

opt1prompt byte "Please enter a string.", 0Ah, 0Dh, "------>  ", 0h

.code
	push edx							
	mov edx, offset opt1prompt
	call WriteString
	pop edx
	call ReadString
	mov op1picked, 1
ret
option1 ENDP

;====================================================
option2 PROC												
;Desc:  Converts the string to lowercase 
;       User entered string will be stored in 
;       the array passed in EDX
;Receives: edx - offset of the string 
;          ecx - max length of the string
;Returns: string in lowercase 
;=====================================================
.data
.code 

mov ebx, 0

ConvertString:
mov al, BYTE PTR [edx]
cmp al, 97
jl Convert
nevermind:
mov theString[ebx], al
resume:
inc edx
inc ebx
loop ConvertString
mov ecx, edi
jmp ExitProc

Convert:
cmp al, 65
jl nevermind
cmp al, 90
jg handler
add al, 32
mov theString[ebx], al
jmp resume

handler:
cmp al, 97
jl nevermind
cmp al, 122
jg nevermind
	
ExitProc:														
ret
option2 ENDP


;====================================================
option3 PROC
;Desc:  Removes all non-letter elements
;        check ascii value
;=====================================================
.data 
newString byte 50 dup(0h),0h

.code 

mov edi, ecx
mov ebx, 0
mov eax, 0
Looper:
mov al, BYTE PTR [edx]
cmp al, 65
jl endloop
cmp al, 122
jg endloop
cmp al, 90
jg handler1
ItsAChar:
mov newString[ebx], al
inc ebx
inc eax
endloop:
inc edx
loop Looper
jmp transferString

handler1:
cmp al, 97
jl endloop
jmp ItsAChar

transferString:
mov ecx, edi
mov ebx, 0
doTransfer:
cmp ebx, eax
jg finish
mov al, newString[ebx]
mov theString[ebx], al
inc ebx
loop doTransfer
	
finish:
mov theString[ebx], 0

ExitProc1:														
ret
option3 ENDP


;====================================================
option4 PROC
;Desc:  Is it a palindrome?
;=====================================================
.data
newString1 byte 50 dup(0h),0h
nopeStr byte "We're sorry, this string is not a palindrome", 0
yepStr byte "Congratulations, this string is a palindrome", 0
stringLength dword 0h

.code
mov stringLength, ecx
mov ebx, 0
mov edi, ecx

push edx
Looper2:
mov al, BYTE PTR [edx]
mov newString1[ebx], al
inc edx
inc ebx
loop Looper2
pop edx

mov ecx, edi

mov eax, 0
mov ebx, stringLength
dec ebx

Looper3:
mov al, BYTE PTR [edx]
mov ah, newString1[ebx]
cmp al, ah
jne NOPE
inc edx
dec ebx
loop Looper3
jmp YEP

NOPE:
mov edx, OFFSET nopeStr
call WriteString
CALL Crlf
call WaitMsg
jmp ExitThis

YEP:
mov edx, OFFSET yepStr
call WriteString
call Crlf
call WaitMsg

ExitThis:
ret
option4 ENDP

end main        
