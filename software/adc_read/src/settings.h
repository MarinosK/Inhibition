/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#ifndef SETTINGS_H
#define SETTINGS_H

const unsigned int SAMPLE_RATE {4000};
const unsigned int BLOCK_SIZE_IN_SECONDS {2};
const unsigned int NUMBER_OF_CHANNELS_TO_READ {2}; // the number of eeg channels to read
const unsigned int CHANNEL_OFFSET {1}; // first channel is for the POT so eeg channels start at the 2d

#endif
