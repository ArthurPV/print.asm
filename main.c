#include <sys/types.h>

extern void print_string(const char *s, size_t len);
extern void print_int(ssize_t i);

int main() {
	print_string("Hello\n", 6);
	print_int(5000);
	print_int(300);
	print_int(32);
	print_int(0);
	print_int(-30);
	print_int(36595);
	print_int(-6620);
	print_int(10320);
}
