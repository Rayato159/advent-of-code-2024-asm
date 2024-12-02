include /masm32/include/masm32rt.inc

.data
    leftList      dd 3, 4, 2, 1, 3, 3
    rightList     dd 4, 3, 5, 3, 9, 3
    listSize      dd 6
    totalDistance dd 0
    outputMsg     db "Total Distance: ", 0
    resultStr     db 255 dup(?)

.code
main proc
    ; Sort list
                       mov    ecx, listSize
                       lea    esi, leftList
                       call   SortList

                       mov    ecx, listSize
                       lea    esi, rightList
                       call   SortList

    ; Calculate the total distance
                       xor    eax, eax                                ; Reset to 0 with xor
                       mov    ecx, listSize                           ; Loop counter
                       lea    esi, leftList                           ; Point to address of leftList
                       lea    edi, rightList                          ; Point to address of rightList

    calculate_distance:
                       mov    ebx, [esi]                              ; Load value from left list
                       mov    edx, [edi]                              ; Load value from right list
                       sub    ebx, edx                                ; Calculate difference
                       jns    no_negation                             ; Skip negation if result non-negative
                       neg    ebx                                     ; Negate to get absolute value, Example: -5 -> 5
    no_negation:       
                       add    eax, ebx                                ; Add absolute difference to total
                       add    esi, 4                                  ; Move to next element within 4 bytes
                       add    edi, 4                                  ; Move to next element within 4 bytes
                       loop   calculate_distance                      ; Repeat until all elements processed
                       mov    totalDistance, eax                      ; Store the total distance

    ; Output total distance
                       invoke StdOut, addr outputMsg                  ; Print the message
                       invoke dwtoa, totalDistance, addr resultStr
                       invoke StdOut, addr resultStr                  ; Print the result

                       invoke ExitProcess, 0
main endp

SortList proc
                       push   esi
                       push   edi
                       push   ecx

                       mov    edi, esi                                ; Set edi to point to the list
                       mov    ecx, listSize                           ; Outer loop counter

    sort_outer:        
                       dec    ecx                                     ; Decrement outer loop counter
                       mov    esi, edi                                ; Reset esi to point to the list
                       mov    edx, ecx                                ; Inner loop counter

    sort_inner:        
                       mov    eax, [esi]                              ; Load current element
                       mov    ebx, [esi+4]                            ; Load next element
                       cmp    eax, ebx
                       jle    no_swap                                 ; Skip swap if already ordered
                       mov    [esi], ebx                              ; Swap current and next element
                       mov    [esi+4], eax
    no_swap:           
                       add    esi, 4                                  ; Move to next pair
                       dec    edx                                     ; Decrement inner loop counter
                       jnz    sort_inner                              ; Continue inner loop if not zero
                       cmp    ecx, 1
                       ja     sort_outer                              ; Continue outer loop if more iterations needed

                       pop    ecx
                       pop    edi
                       pop    esi
                       ret
SortList endp

end main
