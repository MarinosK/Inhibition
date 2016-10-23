/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#include <iostream>
#include <stdexcept>
#include "read_spi.h"

int main(int argc, char *argv[]) {
  try {
    int data {read_a_cycle_and_return(0)}; // read from channel 0
    std::cout << data << std::endl;
    return 0;
  }
  catch (const std::runtime_error& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }
  catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 2;
  }
  catch (...) {
    std::cerr << "uknown exception" << std::endl;
    return 3;
  }
}
