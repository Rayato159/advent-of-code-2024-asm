include /masm32/include/masm32rt.inc

.data
    filename  db "day-2-red-nosed-reports-input.txt", 0    ; Input file name
    buffer    db 65536 dup(0)                              ; Buffer for file content
    bytesRead dd 0                                         ; Bytes read from file
    result    dd 0                                         ; Count of safe reports
    outputMsg db "Number of Safe Reports: ", 0             ; Output message
    resultStr db 255 dup(?)                                ; Buffer for result string

.code
main proc
    ; Open the file
         invoke CreateFile, addr filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
.if eax == INVALID_HANDLE_VALUE
         invoke StdOut, chr$("Error: Cannot open file.", 13, 10)
         jmp    exit_program
.endif
          mov    esi, eax                                                           ; Store file handle

    ; Read the file into buffer
          invoke ReadFile, esi, addr buffer, sizeof buffer, addr bytesRead, NULL
.if eax == 0
          invoke StdOut, chr$("Error: Cannot read file.", 13, 10)
          jmp    close_file
.endif

    ; Parse and analyze the reports
                     mov    edi, offset buffer               ; Use `offset` to get the memory address of `buffer`
                     xor    ecx, ecx                         ; Initialize safe report counter

    parse_reports:   
                     mov    ebx, edi                         ; Start of current line
    find_line_end:   
                     cmp    byte ptr [ebx], 13               ; Look for carriage return (\r)
                     je     process_line
                     cmp    byte ptr [ebx], 0                ; Null terminator (end of buffer)
                     je     finish_analysis
                     inc    ebx
                     jmp    find_line_end

    process_line:    
                     push   ebx                              ; Save line end
                     push   edi                              ; Save line start
                     call   analyze_report                   ; Analyze the current line
                     add    esp, 8                           ; Restore stack (line start and end)
                     add    ebx, 1                           ; Skip carriage return
                     cmp    byte ptr [ebx], 10               ; Look for line feed (\n)
                     je     skip_line_feed
                     jmp    parse_reports

    skip_line_feed:  
                     inc    ebx                              ; Skip line feed
                     mov    edi, ebx                         ; Move to the start of the next line
                     jmp    parse_reports

    finish_analysis: 
                     mov    result, ecx                      ; Store the safe report count

    ; Output the result
                     invoke dwtoa, result, addr resultStr
                     invoke StdOut, addr outputMsg
                     invoke StdOut, addr resultStr
                     invoke StdOut, chr$(13, 10)

    close_file:      
                     invoke CloseHandle, esi

    exit_program:    
                     invoke ExitProcess, 0

main endp

    ; Analyze a single report line
analyze_report proc uses esi edi
                     xor    esi, esi                         ; Difference tracker (+1 for increasing, -1 for decreasing, 0 unset)
                     mov    eax, 1                           ; Safe flag (assume safe until proven otherwise)
                     mov    ecx, edi                         ; Start analyzing from the first number in the line

    ; Parse the first number
                     invoke atodw, ecx                       ; Parse the first number
                     mov    ebx, eax                         ; Store the first number

    next_level:      
                     call   find_next_number                 ; Get the next number
                     cmp    eax, 0                           ; If no more numbers, finish the line
                     je     finish_analysis
                     mov    ecx, eax                         ; Move to the next number
                     invoke atodw, ecx                       ; Parse the number
                     mov    edi, eax                         ; Current number

    ; Calculate the difference
                     sub    edi, ebx                         ; Difference = current - previous
                     cmp    edi, 0
                     je     mark_unsafe                      ; No change (unsafe)

    ; Check if difference is within range
                     cmp    edi, 1
                     jl     mark_unsafe                      ; Too small (unsafe)
                     cmp    edi, 3
                     jg     mark_unsafe                      ; Too large (unsafe)

    ; Check for consistent direction (increasing or decreasing)
                     test   esi, esi
                     jz     set_direction                    ; Set direction if not set
                     cmp    esi, 1
                     je     check_increasing                 ; Check if increasing
                     cmp    edi, 0
                     jg     mark_unsafe                      ; Not decreasing as expected
                     jmp    store_current

    check_increasing:
                     cmp    edi, 0
                     jl     mark_unsafe                      ; Not increasing as expected

    store_current:   
                     mov    ebx, eax                         ; Update the previous number
                     jmp    next_level                       ; Continue to the next level

    set_direction:   
                     cmp    edi, 0
                     jg     set_increasing
                     jl     set_decreasing

    set_increasing:  
                     mov    esi, 1
                     jmp    store_current

    set_decreasing:  
                     mov    esi, -1
                     jmp    store_current

    mark_unsafe:     
                     xor    eax, eax                         ; Mark as unsafe
                     jmp    finish_analysis

    finish_analysis: 
                     test   eax, eax                         ; Check if the report is safe
                     jz     skip_increment                   ; Skip incrementing if not safe
                     inc    ecx                              ; Increment safe report counter

    skip_increment:  
                     ret
analyze_report endp

    ; Locate the next number in the line
find_next_number proc uses edi esi
    ; Locate the next number and return its address in eax, or 0 if none
    find_next_loop:  
                     cmp    byte ptr [esi], 32               ; Check for space
                     je     skip_space
                     inc    esi
                     jmp    find_next_loop
    skip_space:      
                     cmp    byte ptr [esi], 13               ; Check for carriage return
                     je     no_next_number
                     mov    eax, esi                         ; Return the address
                     ret
    no_next_number:  
                     xor    eax, eax                         ; No next number
                     ret
find_next_number endp

end main
