/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#include "save_wav.h"

void save_wav( std::vector<std::vector<int> >& data, std::string filename, unsigned int rate ) {
  std::ofstream f ( filename, std::ios::binary );
  // Write the file header
  f << "RIFF----WAVEfmt ";     // (chunk size to be filled in later)
  write_word( f,     16, 4 );  // no extension data
  write_word( f,      1, 2 );  // PCM - integer samples
  write_word( f,      2, 2 );  // two channels (stereo file)
  write_word( f,  4000, 4 );   // samples per second (Hz)
  write_word( f,  16000, 4 );  // (Sample Rate * BitsPerSample * Channels) / 8
  write_word( f,      4, 2 );  // data block size (size of two integer samples, one for each channel, in bytes)
  write_word( f,     16, 2 );  // number of bits per sample (use a multiple of 8)

  size_t data_chunk_pos = f.tellp();
  f << "data----";  // (chunk size to be filled in later)

  // write data
  for (auto& pair : data)
    for (auto& value : pair)
      write_word( f, value, 2 );
  
  // (We'll need the final file size to fix the chunk sizes above)
  size_t file_length = f.tellp();
  // Fix the data chunk header to contain the data size
  f.seekp( data_chunk_pos + 4 );
  write_word( f, file_length - data_chunk_pos + 8 );
  // Fix the file header to contain the proper RIFF chunk size, which is (file size - 8) bytes
  f.seekp( 0 + 4 );
  write_word( f, file_length - 8, 4 ); 
}
