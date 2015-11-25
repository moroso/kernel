// Stubs for doing mixed 32-bit/64-bit multiplication and division

#include <stdint.h>

#define MAKE(a, b) (((uint64_t)a << 32) | (uint64_t)b)
#define TOP(n) ((uint32_t)((n) >> 32))
#define BOT(n) ((uint32_t)(n))
#define BREAK(n, t, b) do { (t) = TOP(n); (b) = BOT(n); } while (0)

void __smul_32_32(int32_t a, int32_t b, int32_t *top_out, uint32_t *bot_out) {
	int64_t res = (int64_t)a * (int64_t)b;
	BREAK(res, *top_out, *bot_out);
}
// XXX: doesn't actually generate the div I wanted...
int32_t __sdiv_64_32(int32_t ntop, uint32_t nbot, int32_t d) {
	int64_t n = MAKE(ntop, nbot);
	return (int32_t)(n / d);
}
void __umul_32_32(uint32_t a, uint32_t b,
                  uint32_t *top_out, uint32_t *bot_out) {
	uint64_t res = (uint64_t)a * (uint64_t)b;
	BREAK(res, *top_out, *bot_out);
}
// XXX: doesn't actually generate the idiv I wanted...
uint64_t __udiv_64_32(uint32_t ntop, uint32_t nbot, uint32_t d) {
	uint64_t n = MAKE(ntop, nbot);
	return (uint32_t)(n / d);
}
