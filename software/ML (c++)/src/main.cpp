/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this program implements a neural network to use with the main SC code
 */

#include <fann.h>
#include <iostream>
#include <stdexcept>
#include <string>
#include <cstring>

// settings
const float desired_error = (const float) 0.01;
const unsigned int max_epochs = 10000;
const unsigned int epochs_between_reports = 100;

int main(int argc, char *argv[]) {
  try {
    if ( std::string(argv[1]) == "create") { // e.g. neural_net create
      unsigned int layers[5] = {16, 8, 24, 16, 8}; // the layers of the network
      struct fann *ann {fann_create_shortcut_array(5, layers)};
      fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC);
      fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC);
      fann_randomize_weights(ann,0,1);
      fann_save(ann, "network.net");
      fann_destroy(ann);
    } else if ( std::string(argv[1]) == "train") { // e.g. neural_net train data_file
      struct fann *ann  {fann_create_from_file("network.net")};
      fann_train_on_file(ann, argv[2], max_epochs, epochs_between_reports, desired_error);
      fann_save(ann, "network.net");
      fann_destroy(ann);
    } else if ( std::string(argv[1]) == "use") { // e.g. neural_net use 1 0 1 .. 1 (all the 16 features should be the input)
      struct fann *ann {fann_create_from_file("network.net")};
      fann_type input[16];
      for (int i=0; i<16; i++)
	input[i] = std::atof(argv[i+2]);
      fann_type *calc_out {fann_run(ann, input)};
      for (int i=0; i<8; i++)
	std::cout << calc_out[i] << ", ";
      std::cout << std::endl;
      fann_destroy(ann);
    }
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
