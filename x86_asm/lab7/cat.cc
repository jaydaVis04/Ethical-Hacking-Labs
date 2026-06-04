#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main(){
  char *args[] = {"/bin/cat", "/etc/passwd", NULL};
  char *envs[] = {NULL};
  execve("/bin/cat", args, envs); 
}
