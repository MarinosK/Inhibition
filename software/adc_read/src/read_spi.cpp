/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2009
 * this program reads 2channels of 5seconds of eeg audio from a MPC3008 chip
 * and stores the output into an audio file
 */

#include "read_spi.h"

// static uint8_t mode {};
static uint16_t delay {};
static std::uint8_t bits {8};
static std::uint32_t speed {500000};
static const char* DEVICE {"/dev/spidev32766.0"};


int read_a_cycle(int fd, int line, int bil) {
  
  std::uint8_t tx[] = {1,0,0};
  std::uint8_t rx[] = {1,0,0};
  
  struct spi_ioc_transfer tr = {
    .tx_buf = (unsigned long) tx,
    .rx_buf = (unsigned long) rx,
    .len = ARRAY_SIZE(tx),
    .delay_usecs = delay,
    .speed_hz = speed,
    .bits_per_word = bits
  };

  tx[1] = ((bil & 1)?0x00:0x80) | ((line & 0x7)<< 4);
  int ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr); 

  if (ret < 1)
    throw std::runtime_error("didn't send spi message");
  
  return ((rx[1]&0x3)<<8)+rx[2];
}


std::vector<std::vector<int> > read_a_chunk() {

    int fd = open(DEVICE, O_RDWR);
    if (fd < 0) 
      throw std::runtime_error("didn't open device");
    
    constexpr unsigned int times = SAMPLE_RATE * BLOCK_SIZE_IN_SECONDS;
    constexpr unsigned int wait = 1000000 / SAMPLE_RATE;

    std::vector<std::vector<int> > data;
    wait_timer wt {std::chrono::microseconds(wait)};
    
    for (int j=0; j<times; j++) {
      std::vector<int> pair;
      for(int i=0; i<NUMBER_OF_CHANNELS_TO_READ; i++) 
	pair.emplace_back(read_a_cycle(fd,i+CHANNEL_OFFSET,0)); // eeg is on channels 2 and 3
      data.emplace_back(pair);
      wt.wait();
    }
    
    close(fd);

    return data;
}

int read_a_cycle_and_return(int channel) {

    int fd = open(DEVICE, O_RDWR);
    if (fd < 0) 
      throw std::runtime_error("didn't open device");
    
    int data {read_a_cycle(fd,channel,0)}; 
       
    close(fd);

    return data;
}


