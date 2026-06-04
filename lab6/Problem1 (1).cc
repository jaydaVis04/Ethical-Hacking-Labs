#include <stdio.h>

int main()
{
	int i;
	for (int i=-65536; i<=65535; i++){
		printf("%d 0x%08x\n", i, i);
	}

	return 0;

}
