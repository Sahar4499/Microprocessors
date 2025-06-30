.model small
.stack 100h

.data
msg_error db 'You can''t divide by zero!!!$', 13, 10, '$'

old_int0_off dw ?        ; offset של הפסיקה המקורית
old_int0_seg dw ?        ; segment של הפסיקה המקורית

msg_input db 'Enter number to divide 100 by: $'
newline db 13, 10, '$'

.code
main:
    mov ax, @data
    mov ds, ax

    ; שמירת וקטור הפסיקה המקורי (INT 0)
    mov ah, 35h           ; get interrupt vector
    mov al, 0             ; interrupt number 0
    int 21h
    mov [old_int0_off], bx
    mov [old_int0_seg], es

    ; הגדרת הפסיקה החדשה – מחליפים את INT 0 ל־ divide_by_zero_handler
    mov dx, offset divide_by_zero_handler
    mov ax, seg divide_by_zero_handler
    mov ds, ax
    mov ah, 25h           ; set interrupt vector
    mov al, 0
    int 21h

    ; חזרה לסגמנט הנתונים
    mov ax, @data
    mov ds, ax

    ; הצגת הודעה ובקשת קלט למספר
    mov ah, 09h
    lea dx, msg_input
    int 21h

    ; קלט תו (מספר בין 0–9)
    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, al            ; שמירה ב־BL כמחלק

    ; ניסיון חלוקה
    mov ax, 100
    div bl                ; אם BL=0 → תתרחש INT 0 אוטומטית

    ; מעבר שורה
    mov ah, 09h
    lea dx, newline
    int 21h

    ; סיום
    mov ah, 4Ch
    int 21h

; === פונקציית טיפול בחלוקה ב־0 ===
; מופעלת אוטומטית כשמתבצעת div 0

divide_by_zero_handler proc
    push ax
    push dx

    mov ah, 09h
    lea dx, msg_error
    int 21h

    pop dx
    pop ax

    iret                 ; חזרה מ־interrupt
divide_by_zero_handler endp

end main