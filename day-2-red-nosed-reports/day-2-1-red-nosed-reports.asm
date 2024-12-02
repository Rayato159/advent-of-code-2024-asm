include /masm32/include/masm32rt.inc

.data
    numbersList dd 7, 6, 4, 2, 1, 0                 ; Safe
                dd 1, 2, 7, 8, 9, 0                 ; Unsafe
                dd 9, 7, 6, 2, 1, 0                 ; Unsafe
                dd 1, 3, 2, 4, 5, 0                 ; Unsafe
                dd 8, 6, 4, 4, 1, 0                 ; Unsafe
                dd 1, 3, 6, 7, 9, 0                 ; Safe
                dd 0                                ; End of all reports
    result      dd 0
    outputMsg   db "Number of Safe Reports: ", 0
    resultStr   db 64 dup(?)

.code
main proc
    ; Variables
                     lea    esi, numbersList              ; Start of numbers list
                     xor    ecx, ecx                      ; Safe report counter

    process_reports: 
                     mov    eax, [esi]                    ; Load the first number
                     cmp    eax, 0
                     je     finished                      ; End of all reports
                     push   esi                           ; Save current position
                     call   analyze_report                ; Analyze the report
                     add    esp, 4                        ; Restore stack
                     add    esi, 24                       ; Move to the next report (6 elements * 4 bytes each)
                     jmp    process_reports

    finished:        
    ; Output the result
                     mov    eax, result
                     invoke dwtoa, eax, addr resultStr
                     invoke StdOut, addr outputMsg
                     invoke StdOut, addr resultStr

                     invoke ExitProcess, 0
main endp

analyze_report proc uses esi edi
    ; Analyze a single report for safety
                     xor    edi, edi                      ; Direction: 0 = unset, 1 = increasing, -1 = decreasing
                     xor    ebx, ebx                      ; Safe flag
                     mov    ebx, 1                        ; Assume the report is safe
                     xor    ecx, ecx                      ; Index counter

    next_number:     
                     mov    eax, [esi + ecx * 4]          ; Current number
                     cmp    eax, 0
                     je     finish_report                 ; End of report if 0 found
                     mov    edx, [esi + ecx * 4 + 4]      ; Next number
                     cmp    edx, 0
                     je     finish_report                 ; End of report if 0 found

    ; Calculate difference
                     sub    eax, edx                      ; Difference = current - next
                     mov    edx, eax                      ; Save difference
                     test   edx, edx
                     jz     mark_unsafe                   ; Difference == 0, unsafe
                     cmp    edx, -3
                     jl     mark_unsafe                   ; Difference < -3, unsafe
                     cmp    edx, 3
                     jg     mark_unsafe                   ; Difference > 3, unsafe

    ; Determine direction
                     test   edi, edi
                     jz     set_direction                 ; If unset, set direction
                     cmp    edi, 1
                     je     check_increasing
                     cmp    edi, -1
                     je     check_decreasing

    set_direction:   
                     test   edx, edx
                     jg     set_increasing
                     jl     set_decreasing

    set_increasing:  
                     mov    edi, 1
                     jmp    next_iteration

    set_decreasing:  
                     mov    edi, -1
                     jmp    next_iteration

    check_increasing:
                     test   edx, edx
                     jle    mark_unsafe                   ; Direction mismatch or no increase, unsafe
                     jmp    next_iteration

    check_decreasing:
                     test   edx, edx
                     jge    mark_unsafe                   ; Direction mismatch or no decrease, unsafe
                     jmp    next_iteration

    next_iteration:  
                     inc    ecx                           ; Move to the next pair
                     jmp    next_number

    mark_unsafe:     
                     xor    ebx, ebx                      ; Mark as unsafe
                     jmp    finish_report

    finish_report:   
                     test   ebx, ebx
                     jz     skip_increment
                     inc    result                        ; Increment safe report counter

    skip_increment:  
                     ret
analyze_report endp

end main
