/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#ifndef SAVE_WAV_H
#define SAVE_WAV_H

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include "settings.h"

void save_wav(std::vector<std::vector<int> >& data, std::string filename, unsigned int rate);

template <typename Word>
  std::ostream& write_word( std::ostream& outs, Word value, unsigned size = sizeof( Word ) ) {
    for (; size; --size, value >>= 8)
      outs.put( static_cast <char> (value & 0xFF) );
    return outs;
  }

#endif
