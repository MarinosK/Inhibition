/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#ifndef READ_SPI_H
#define READ_SPI_H

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <array>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <fcntl.h>
#include <linux/types.h>
#include <vector>
#include <thread>
#include <chrono>
#include <stdexcept>
#include <unistd.h>
#include <getopt.h>
#include "settings.h"

#define ARRAY_SIZE(a) sizeof(a) / sizeof((a)[0])

int read_a_cycle(int fd, int line, int bil); 
std::vector<std::vector<int> > read_a_chunk();
int read_a_cycle_and_return(int channel);

class wait_timer {
  using clock = std::chrono::steady_clock;
  clock::duration time_to_wait;
  clock::time_point timeout {clock::now()};
public:
  wait_timer(std::chrono::microseconds us)
    : time_to_wait(us), timeout(clock::now() + us) {}
  inline void wait() {
    std::this_thread::sleep_until(timeout);
    timeout += time_to_wait; 
  }
};

#endif
