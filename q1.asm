.model small
.stack 100h

.data
array dw 10 dup(?)           ; מערך בגודל 10 לתאים מסוג מילה (מספרים שלמים)
msg db 'Enter number: $'     ; הודעת קלט למשתמש
newline db 13, 10, '$'       ; ירידת שורה
invalid db 'Invalid input!$' ; הודעה על קלט לא תקין
sum_msg db 13,10,'Sum of even numbers: $' ; הודעה לפני הצגת הסכום
sum_result db '0', 13, 10, '$' ; מקום להדפסת הספרה הבודדת (נניח סכום קטן מ-10)

.code
main:
    ; אתחול סגמנט הנתונים
    mov ax, @data
    mov ds, ax

    ; הגדרת מונה ל-10 מספרים ואתחול מצביע למערך
    mov cx, 10
    mov si, 0

; לולאת קלט: קולטת מספר אחד בכל איטרציה
input_loop:
    mov ah, 09h
    lea dx, msg              ; הדפסת ההודעה "Enter number:"
    int 21h

    mov ah, 01h              ; קריאת תו בודד
    int 21h
    cmp al, '0'              ; בדיקה אם קטן מ-'0'
    jb invalid_input
    cmp al, '9'              ; בדיקה אם גדול מ-'9'
    ja invalid_input

    sub al, '0'              ; המרת ASCII למספר רגיל
    mov ah, 0
    mov [array + si], ax     ; שמירת המספר במערך

    add si, 2                ; קידום המצביע למיקום הבא במערך
    loop input_loop          ; המשך בלולאה עד שקלטנו 10 מספרים
    jmp calc_sum             ; מעבר לחישוב הסכום

; טיפול בקלט לא תקין
invalid_input:
    mov ah, 09h
    lea dx, invalid
    int 21h
    jmp input_loop

; חישוב סכום המספרים הזוגיים
calc_sum:
    xor si, si               ; איפוס המצביע להתחלת המערך
    xor ax, ax               ; איפוס הסכום
    mov cx, 10               ; ספירת 10 איברים

sum_loop:
    mov bx, [array + si]     ; טעינת מספר אחד מתוך המערך
    test bl, 1               ; בדיקת זוגיות – אם הביט התחתון = 1 → אי זוגי
    jnz skip                 ; אם אי זוגי – דלג לסיום האיטרציה
    add ax, bx               ; אם זוגי – הוסף את המספר לסכום

skip:
    add si, 2                ; מעבר לאיבר הבא
    loop sum_loop            ; חזרה עד סיום כל המספרים

    ; הדפסת ההודעה לפני התוצאה
    mov ah, 09h
    lea dx, sum_msg
    int 21h

    ; הנחה: סכום קטן מ-10 ולכן נדרש רק תו אחד
    add al, '0'              ; המרת המספר לתו ASCII
    mov sum_result, al
    lea dx, sum_result
    mov ah, 09h
    int 21h

    ; סיום התוכנית
    mov ah, 4Ch
    int 21h
end main