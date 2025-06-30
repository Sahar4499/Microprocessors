.model small
.stack 100h

.data
input_buffer db 21
             db ?
             db 20 dup(?)

output_buffer db 21 dup('$')     ; מחרוזת חדשה לאותיות בלבד (כוללת $ כ-terminator)
msg_input db 'Enter up to 20 characters: $'
msg_output db 13, 10, 'Modified: $'
msg_sum db 13, 10, 'numbers sum: $'
msg_other db 13, 10, 'other chars amount: $'

sum db 0   ; סכום ספרות שנקלטו
other_count db 0    ; ספירת תווים אחרים (לא אותיות או ספרות)
   
.code
main:
    mov ax, @data
    mov ds, ax

    ; הדפסת הודעת קלט
    mov ah, 09h
    lea dx, msg_input
    int 21h

    ; קריאת קלט למחרוזת
    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    ; אתחול מצביעים ולולאה
    lea si, input_buffer + 2        ; מצביע לתו הראשון בקלט
    lea di, output_buffer           ; מצביע לתחילת המחרוזת המתוקנת
    mov cl, [input_buffer + 1]
    xor ch, ch

process_loop:
    mov al, [si]

    ; אות קטנה a–z → הפוך לגדולה
    cmp al, 'a'
    jb check_upper
    cmp al, 'z'
    ja check_upper
    sub al, 20h
    mov [di], al
    inc di
    jmp next_char

check_upper:
    ; אות גדולה A–Z → הפוך לקטנה
    cmp al, 'A'
    jb check_digit
    cmp al, 'Z'
    ja check_digit
    add al, 20h
    mov [di], al
    inc di
    jmp next_char

check_digit:
    ; ספרה 0–9 → סכום בלבד, לא לשמור
    cmp al, '0'
    jb count_other
    cmp al, '9'
    ja count_other
    sub al, '0'
    add [sum], al
    jmp next_char

count_other:
    inc byte ptr [other_count]
    ; לא מוסיפים ל־output_buffer

next_char:
    inc si
    loop process_loop

    ; סיום מחרוזת מתוקנת ב-$
    mov byte ptr [di], '$'

    ; הדפסת "Modified:"
    mov ah, 09h
    lea dx, msg_output
    int 21h

    ; הדפסת המחרוזת המתוקנת
    lea dx, output_buffer
    mov ah, 09h
    int 21h

    ; הדפסת סכום ספרות
    mov ah, 09h
    lea dx, msg_sum
    int 21h

    mov al, [sum]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    ; הדפסת כמות תווים אחרים
    mov ah, 09h
    lea dx, msg_other
    int 21h

    mov al, [other_count]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    ; יציאה
    mov ah, 4Ch
    int 21h
end main