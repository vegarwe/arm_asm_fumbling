#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unity.h>


// Output on different platforms
#if defined ( __CC_ARM )
#include "nrf.h"
#include "core_cm4.h"
int fputc(int c, FILE *f) {
  return(ITM_SendChar(c));
}
#endif // __CC_ARM


// Tests
void setUp(void)
{
}

void tearDown(void) { }

int my_asm(int, uint32_t*);

void test_fisk_1(void)
{
    int k = 7;
    uint32_t data[7] = {0};
    k = my_asm(4, data);
    printf("hei %d\r\n", k);

    printf("data \r\n");
    for (int i = 0; i < sizeof(data)/sizeof(data[0]); i++) {
        printf(" %08x\r\n", data[i]);
    }

}

void create_buffer(char** pp_buf)
{
    *pp_buf = malloc(5);

    (*pp_buf)[0] = 'a';
    (*pp_buf)[1] = 'b';
    (*pp_buf)[2] = 'c';
    (*pp_buf)[3] = 'g';
    (*pp_buf)[4] = '\0';
}

void free_buffer(char* p_buf)
{
    free(p_buf);
}

void test_fisk_malloc(void)
{
    char* buff1;
    char* buff2;
    char* buff3;

    create_buffer(&buff1);
    create_buffer(&buff2);
    printf("buff1: %p %s\n", buff1, buff1);
    printf("buff2: %p %s\n", buff2, buff2);
    free_buffer(buff1);
    free_buffer(buff2);

    create_buffer(&buff3);
    printf("buff3: %p %s\n", buff3, buff3);
    free_buffer(buff3);

}

void*   ll_init(void** ll, uint32_t value);
void*   ll_add( void*  ll, uint32_t value);
int     ll_del( void*  ll, uint32_t value);
void*   ll_next(void*  ll);
int     ll_free(void*  ll);

void test_fisk_ll(void)
{
    void* head = NULL;
    void* ll = ll_init(&head, 1);

    //printf("head: %p %p %p %d\n", &head, head, (void*)*(((uint32_t*)head)+0), *(((uint32_t*)head)+1));
    //printf("ll  : %p %p %p %d\n", &ll, ll, (void*)*(((uint32_t*)ll)+0), *(((uint32_t*)ll)+1));
    //ll_add(ll, 0x03);
    //printf("ll  : %p %p %p %d\n", &ll, ll, (void*)*(((uint32_t*)ll)+0), *(((uint32_t*)ll)+1));
    //ll = (void*)*((uint32_t*)ll);
    //printf("ll  : %p %p %p %d\n", &ll, ll, (void*)*(((uint32_t*)ll)+0), *(((uint32_t*)ll)+1));

    ll = ll_add(ll, 2);
    ll = ll_add(ll, 3);
    ll = ll_add(ll, 4);
    ll = ll_add(ll, 5);
    ll_add(head,    6);
    ll = ll_add(ll, 7);

    printf("hei %d\n", ll_del(head, 3));
    //if (! ll_del(head, 3)) {
    //    printf("Node not found");
    //}

    printf("Iterate\n");
    ll = head;
    do {
        printf("ll  : %p %p %p %d\n", &ll, ll, (void*)*(((uint32_t*)ll)+0), *(((uint32_t*)ll)+1));
    } while ((ll = ll_next(ll)) != NULL);

    // TODO: Implement remove by value

    int count = ll_free(head);
    printf("head freed %d\n", count);

    count = ll_free(NULL);
    printf("NULL freed %d\n", count);
}

char* err_str(int32_t err_code);

void test_fisk_vars(void)
{
    char* error;

    error = err_str(1);
    printf("error %p %s\r\n", error, error);

    error = err_str(2);
    printf("error %p %s\r\n", error, error);
}

void fisk_print(void);

void test_fisk_printf(void)
{
    fisk_print();
}

int main(void)
{
    UNITY_BEGIN();
    RUN_TEST(test_fisk_1);
    RUN_TEST(test_fisk_malloc);
    RUN_TEST(test_fisk_ll);
    RUN_TEST(test_fisk_vars);
    RUN_TEST(test_fisk_printf);
    int result = UNITY_END();

    return result;
}
