#include <stdio.h>
#include <unistd.h>

int main() {
  int count = 0;

  printf("init_1 started\n");

  while (1) {
    count++;
    printf("init_1 running... sec: %d\n", count);
    sleep(1);
  }

  return 0;
}
