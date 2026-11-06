#include <stdio.h>
#include <stdint.h>
typedef long long v2di __attribute__((vector_size(16)));
int main(void) {
    v2di a = {5, -3}, b = {2, -7};
    long long o[2];
    printf("testing SSE4.2 pcmpgtq ... "); fflush(stdout);
    __asm__ volatile("pcmpgtq %1, %0" : "+x"(a) : "x"(b));
    __builtin_memcpy(o, &a, 16);
    printf("OK (result %lld %lld, expected -1 -1)\n", o[0], o[1]); fflush(stdout);
    uint64_t v = 0xF0F0F0F0F0F0F0F0ULL, c;
    printf("testing POPCNT ... "); fflush(stdout);
    __asm__ volatile("popcntq %1, %0" : "=r"(c) : "r"(v));
    printf("OK (%llu, expected 32)\n", (unsigned long long)c);
    return 0;
}
