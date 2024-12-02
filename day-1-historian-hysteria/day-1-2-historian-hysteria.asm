include /masm32/include/masm32rt.inc

.data
    leftList  dd 3, 4, 2, 1, 3, 3
    rightList dd 4, 3, 5, 3, 9, 3
    listSize  dd 6
    result    dd 0
    outputMsg db "Similarity Score: ", 0
    resultStr db 255 dup(?)

.code
main proc
               xor    eax, eax                         ; Clear eax: Final result
               xor    edi, edi                         ; Clear edi: Counting
               mov    ecx, listSize
               lea    esi, leftList

    outer_loop:
               mov    ebx, [esi]                       ; Load the current number from the left list
               lea    edx, rightList                   ; Pointer to the start of the right list
               mov    ebp, listSize                    ; Reset inner loop counter
               xor    edi, edi                         ; Reset count for the current number

    inner_loop:
               cmp    ebx, [edx]
               jne    skip_match                       ; If not equal, skip to next
               inc    edi

    skip_match:
               add    edx, 4
               dec    ebp
               jnz    inner_loop

    ; Multiply the current number by its count in the right list
               imul   edi, ebx                         ; edi = count * current left number
               add    eax, edi                         ; Add to total similarity score

               add    esi, 4                           ; Move to the next number in the left list
               loop   outer_loop                       ; Repeat for all numbers in the left list

    ; Similarity score storing
               mov    result, eax

    ; Output
               invoke StdOut, addr outputMsg
               invoke dwtoa, result, addr resultStr
               invoke StdOut, addr resultStr

               invoke ExitProcess, 0

main endp
end main
