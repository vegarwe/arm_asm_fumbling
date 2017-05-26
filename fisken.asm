;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Learning ARM assembler
 ;
 ; Header section
 ;
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    AREA asm_func, CODE, READONLY
    ;ARM                         ; Following code is ARM code
    EXPORT my_asm
    export err_str
    EXPORT ll_init
    EXPORT ll_add
    EXPORT ll_del
    EXPORT ll_next
    EXPORT ll_free
    EXPORT fisk_print
    IMPORT malloc
    IMPORT free
    IMPORT printf
    ;PRESERVE8

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Random (unexported) assembly function
my_other_asm
    ; Do some memory storing
    mov     r2, #0x0000ffff
    add     r2, #0x00ee0000
    add     r2, #0x23000000
    str     r2, [r1]

    add     r1, r1, #4
    mov     r2, #0x00001111
    add     r2, #0x00220000
    add     r2, #0x44000000
    str     r2, [r1]

    add     r1, r1, #4
    mov     r2, #0x00004ee7
    add     r2, #0x000b0000
    add     r2, #0xb0000000
    str     r2, [r1]

    bx      lr


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Random assembly function
 ;
 ; Calls my other random assembly function as well as looping
 ;
 ; @param[in]   value   A number that will be manipulated and returned
 ; @param[out]  buff    uint32_t array (will be slightly populated)
 ;
 ; @return      The input value (after beeing manipulated)
my_asm
    push    {r0-r3, r12, lr}
    bl      my_other_asm
    pop     {r0-r3, r12, lr}

    ; Simple for-loop
    mov     r0, #0
for_start
    ; ...
    add     r0, #1
    cmp     r0, #14
    bne     for_start

    ; Simple while-true loop
    mov     r12, #19
while_start
    add     r0, #1
    subs    r12, #1
    bne     while_start

    add     r0, r0, r0, lsl #1      ; r0 = 3 * r0
    bx      lr

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Allocate and initialize linked list structure
 ;
 ; @param[out]  p_ll    Pointer to linked list structure (will be populated)
 ; @param[in]   value   Value to be stored in new LL structure
 ;
 ; @return      New linked list node
ll_init
    ; Allocate memory
    push    {r0-r1, r12, lr}    ; Store registers (including params)
    mov     r0, #8              ; Need 8 bytes of data for new node
    bl.w    malloc              ; Allocate memory for new node
    pop     {r2-r3, r12, lr}    ; Pop params ll and value into r2 and r3
    mov     r1, #0              ; Zero initialize new node
    str     r0, [r2]            ; Store pointer to new memory in input param
    str     r1, [r0, #0]        ; Next should not point anywhere
    str     r3, [r0, #4]        ; Store value of new node
    bx      lr                  ; Return new node (already in r0)


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Put value (allocating new node for it) into linked list
 ;
 ; @param[in]   ll      Linked list structure
 ; @param[in]   value   Value to be stored in new LL structure
 ;
 ; @return      New linked list node
ll_add
    push    {r0-r1, r12, lr}    ; Store registers (including params)
    mov     r0, #8              ; Need 8 bytes of data for new node
    bl.w    malloc              ; Allocate memory for new node
    pop     {r2-r3, r12, lr}    ; Pop params ll and value into r2 and r3
    ldr     r1, [r2]            ; Fetch current next (if any)
    str     r0, [r2]            ; Store pointer to new memory in input param
    str     r1, [r0, #0]        ; Store old next in new node
    str     r3, [r0, #4]        ; Store value of new node
    bx      lr                  ; Return new node (already in r0)


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Find first node with given value and remove it
 ;
 ; @param[in]   ll      Linked list (head) structure
 ; @param[in]   value   Value of node to be removed
 ;
 ; @return      True if found otherwise false
ll_del
    mov     r3, r1              ; r3 holds value to look for
    mov     r1, r0              ; r1 holds current node
del_loop
    cmp     r1, #0              ; Check if next is NULL
    moveq   r0, #0              ;   Set return value 'false'
    bxeq    lr                  ;   Return
    mov     r0, r1              ; Setup node to be freed
    ldr     r1, [r0, #4]        ; Read in value
    cmp     r3, r1              ; Check value against target
    beq     del_node
    ldr     r1, [r0]            ; Read in 'next'
    b       del_loop            ; Loop
del_node
    ; What if this is the last node?
    ldr     r1, [r0]            ; Read in 'next'
    ldr     r2, [r1, #4]        ; Read in 'next' value
    str     r2, [r0, #4]        ; Move value to current node
    ldr     r2, [r1, #0]        ; Read in 'next' value
    str     r2, [r0, #0]        ; Move 'next' next pointer
    ;push    {r1-r2, r12, lr}    ; Store registers
    ;bl.w    free                ; Free current
    ;pop     {r1-r2, r12, lr}    ; Restore registers
    mov     r0, #1              ; Set return value 'true'
    bx      lr                  ; Return


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Return next linked list entry
 ;
 ; @param[in]   ll      Linked list structure
 ;
 ; @return      Next linked list node
ll_next
    ldr     r0, [r0]
    bx      lr


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Free linked list structure (from input to end)
 ;
 ; Loop through linked list, freeing nodes
 ;
 ; @param[in]   ll      (Head of) linked list structure
 ;
 ; @return      Number of freed elements
ll_free
    mov     r2, #0              ; r2 holds freed count
    mov     r1, r0              ; r1 holds current node
free_loop
    cmp     r1, #0              ; Check if next is NULL
    moveq   r0, r2              ;   Return freed count
    bxeq    lr                  ;   Return
    mov     r0, r1              ; Setup node to be freed
    ldr     r1, [r1]            ; Read in 'next'
    push    {r1-r2, r12, lr}    ; Store registers
    bl.w    free                ; Free current
    pop     {r1-r2, r12, lr}    ; Restore registers
    add     r2, #1              ; Increment freed count
    b       free_loop           ; Loop

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Some error strings used by err_str
error1
    dcb     "General purpose some shit when down error", 0
error2
    dcb     "This is some weird shit error", 0
error1_old
    dcw     0x6547, 0x656e, 0x6172, 0x206c, 0x7570, 0x7072, 0x736f, 0x2065, 0x6f73, 0x656d, 0x7320, 0x6968, 0x2074, 0x6877, 0x6e65, 0x6420, 0x776f, 0x206e, 0x7265, 0x6f72, 0x0072
    align   4
error_table
    dcd     0, error1, error2       ; Start index at 1 (not zero)
    ;DCI.W   .error1
    ;DCI.W   0xf3af8000

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Get error string from err code
 ;
 ; @param[in]   errno   Error code number
 ;
 ; @return      Descriptive error string
err_str
    ;@ TODO: Should now size of error_table, only look up valid indexes
    adr     r1, error_table         ; Read in start of error table
    ldr     r0, [r1, r0, lsl #2]    ; Look up r0 (*4) in r1, store in r0
    bx      lr                      ; Return pointer to error string


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;.ascii "Hello Worldn"
;error
;            sets "General purpose some shit when down error"
;MSG    DB      'Press A Key To Continue', 0
;pool
;            SPACE 8
;    LDR     r1, =0x20026
;    LDR     r1, =0x20027
;    nop

; c = lambda b: ', '.join(['0x%02x%02x' % (ord(b1), ord(b0)) for b0, b1 in zip(b[0::2], b[1::2])]) + ', 0'
; def c(b):
;   blen = len(b)
;   plen = int(math.ceil(len(b) / 2.) * 2) - len(b)
;   b   += '\x00' * plen
;   retv = ', '.join(['0x%02x%02x' % (ord(b1), ord(b0)) for b0, b1 in zip(b[0::2], b[1::2])])
;   return retv if plen > 0 else retv + ', 0x0000'


print_string1 dcb     "Hello my friend, from ASM\n", 0
    align   4
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 ; @brief Play with outputing stuff to stdout
 ;
 ; @param[in]   str     Some output string presumably?
 ;
 ; @return      Nothing what so ever
fisk_print
    push    {r0-r1, r12, lr}    ; Store registers (including params)
    adr     r0, print_string1
    bl.w    printf              ; Allocate memory for new node
    pop     {r0-r1, r12, lr}    ; Pop params ll and value into r2 and r3
    bx      lr                      ; Return pointer to error string



;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; vim:ft=armv5
    END
