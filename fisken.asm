;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@ @brief Learning ARM assembler
;@
;@ Header section
;@
    ;PRESERVE8
    AREA asm_func, CODE, READONLY
    EXPORT my_asm
    EXPORT ll_init
    EXPORT ll_add
    EXPORT ll_next
    EXPORT ll_free
    IMPORT malloc
    IMPORT free

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@ @brief Random (unexported) assembly function
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
;@ @brief Random assembly function
;@
;@ Calls my other random assembly function as well as looping
;@
;@ @param[in]   value   A number that will be manipulated and returned
;@ @param[out]  buff    uint32_t array (will be slightly populated)
;@
;@ @return      The input value (after beeing manipulated)
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
;@ @brief Allocate and initialize linked list structure
;@
;@ @param[out]  p_ll    Pointer to linked list structure (will be populated)
;@ @param[in]   value   Value to be stored in new LL structure
;@
;@ @return      New linked list node
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
;@ @brief Push value (allocating new node for it) into linked list
;@
;@ @param[in]   ll      Linked list structure
;@ @param[in]   value   Value to be stored in new LL structure
;@
;@ @return      New linked list node
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
;@ @brief Return next linked list entry
;@
;@ @param[in]   ll      Linked list structure
;@
;@ @return      Next linked list node
ll_next
    ldr     r0, [r0]
    bx      lr


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@ @brief Free linked list structure (from input to end)
;@
;@ Loop through linked list, freeing nodes
;@
;@ @param[in]   ll      (Head of) linked list structure
;@
;@ @return      Number of freed elements
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
;@ vim:ft=armv5

    end
