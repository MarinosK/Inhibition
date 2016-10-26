/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#include <iostream>
#include <vector>
#include <stdexcept>
#include "read_spi.h"
#include "save_wav.h"
#include "settings.h"

void scale_data(std::vector<std::vector<int> >& data) {
    for (auto& pair : data)
      for (auto& value : pair) 
	value = ((value) * 64) - 32760; 
}

int main(int argc, char *argv[]) {
  try {
    if (argc < 2)
      throw std::runtime_error("at least one argument is expected (the filename)");
    std::string filename { argv[1] };
    std::vector<std::vector<int> > data {read_a_chunk()};
    scale_data(data);
    save_wav(data, filename, SAMPLE_RATE);
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
