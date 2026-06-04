#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

int main(int argc,char *argv[]){
	char str[9999];
	fgets(str,9998,stdin);
	for(int i=0;i<9999;i++){
		if(str[i]==';' || str[i]=='|'){
			str[i]=0;
		}
	}
	setuid(0);
	printf("str to execute is: ------------<br />\n%s\n<br />--------<br />", str);
	system(str);
	return 0;
}
