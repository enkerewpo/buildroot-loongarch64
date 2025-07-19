#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/sysinfo.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

void print_system_info() {
    printf("=== System Information ===\n");
    
    // Get system uptime
    struct sysinfo si;
    if (sysinfo(&si) == 0) {
        printf("System uptime: %ld seconds\n", si.uptime);
        printf("Load averages: 1min=%ld, 5min=%ld, 15min=%ld\n", 
               si.loads[0], si.loads[1], si.loads[2]);
    }
    
    // Get current real time
    time_t now = time(NULL);
    printf("Current real time: %s", ctime(&now));
    
    // Get monotonic clock resolution
    struct timespec res;
    if (clock_getres(CLOCK_MONOTONIC, &res) == 0) {
        printf("CLOCK_MONOTONIC resolution: %ld.%09ld seconds\n", 
               res.tv_sec, res.tv_nsec);
    }
    
    // Get realtime clock resolution
    if (clock_getres(CLOCK_REALTIME, &res) == 0) {
        printf("CLOCK_REALTIME resolution: %ld.%09ld seconds\n", 
               res.tv_sec, res.tv_nsec);
    }
    
    // print clock frequency
    printf("_SC_CLK_TCKfrequency from sysconf: %ld Hz\n", sysconf(_SC_CLK_TCK));
    printf("\n");
}

void test_different_clocks() {
    printf("=== Testing Different Clock Sources ===\n");
    
    struct timespec start_mono, end_mono;
    struct timespec start_real, end_real;
    struct timeval start_gettimeofday, end_gettimeofday;
    
    // Test CLOCK_MONOTONIC
    clock_gettime(CLOCK_MONOTONIC, &start_mono);
    sleep(1);
    clock_gettime(CLOCK_MONOTONIC, &end_mono);
    
    // Test CLOCK_REALTIME
    clock_gettime(CLOCK_REALTIME, &start_real);
    sleep(1);
    clock_gettime(CLOCK_REALTIME, &end_real);
    
    // Test gettimeofday
    gettimeofday(&start_gettimeofday, NULL);
    sleep(1);
    gettimeofday(&end_gettimeofday, NULL);
    
    // Calculate differences
    double mono_diff = (end_mono.tv_sec - start_mono.tv_sec) + 
                      (end_mono.tv_nsec - start_mono.tv_nsec) / 1e9;
    
    double real_diff = (end_real.tv_sec - start_real.tv_sec) + 
                      (end_real.tv_nsec - start_real.tv_nsec) / 1e9;
    
    double gettimeofday_diff = (end_gettimeofday.tv_sec - start_gettimeofday.tv_sec) + 
                              (end_gettimeofday.tv_usec - start_gettimeofday.tv_usec) / 1e6;
    
    printf("CLOCK_MONOTONIC interval: %.6f seconds\n", mono_diff);
    printf("CLOCK_REALTIME interval: %.6f seconds\n", real_diff);
    printf("gettimeofday interval: %.6f seconds\n", gettimeofday_diff);
    printf("\n");
}

void test_sleep_accuracy() {
    printf("=== Testing Sleep Accuracy ===\n");
    
    for (int i = 1; i <= 3; i++) {
        struct timespec start, end;
        clock_gettime(CLOCK_MONOTONIC, &start);
        
        printf("Sleep %d second(s)...\n", i);
        sleep(i);
        
        clock_gettime(CLOCK_MONOTONIC, &end);
        
        double actual_time = (end.tv_sec - start.tv_sec) + 
                           (end.tv_nsec - start.tv_nsec) / 1e9;
        
        printf("  Requested: %d second(s)\n", i);
        printf("  Actual: %.6f second(s)\n", actual_time);
        printf("  Difference: %.6f second(s)\n", actual_time - i);
        printf("\n");
    }
}

void test_jiffies_consistency() {
    printf("=== Testing Jiffies Consistency ===\n");
    
    struct timespec start, end;
    clock_t start_jiffies, end_jiffies;
    
    for (int i = 0; i < 3; i++) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        start_jiffies = times(NULL);
        
        usleep(1000000); // Sleep 1s (microseconds)
        
        clock_gettime(CLOCK_MONOTONIC, &end);
        end_jiffies = times(NULL);
        
        double time_diff = (end.tv_sec - start.tv_sec) + 
                          (end.tv_nsec - start.tv_nsec) / 1e9;
        clock_t jiffies_diff = end_jiffies - start_jiffies;
        
        printf("Test %d:\n", i + 1);
        printf("  Time interval: %.6f seconds\n", time_diff);
        printf("  Jiffies interval: %ld\n", jiffies_diff);
        printf("  Calculated frequency: %.2f Hz\n", jiffies_diff / time_diff);
        printf("\n");
    }
}

int main() {
    printf("=== Enhanced Timer Test for Time Investigation ===\n\n");
    
    print_system_info();
    test_different_clocks();
    test_sleep_accuracy();
    test_jiffies_consistency();

    return 0;
} 