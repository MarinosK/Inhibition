/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this is the main program generating audio for the Inhibition piece
 */

// note that this has to be run as root

Server.default.waitForBoot({
	// alter some settings to reduce a bit the CPU load
	// Server.default.options.blockSize_(512);
	// Server.default.options.inputStreamsEnabled_("00");	
	// Server.default.options.loadDefs_(false);	
	// Server.default.options.maxNodes_(100);	
	// Server.default.options.maxSynthDefs_(20);	
	// Server.default.options.numAudioBusChannels_(40);	
	// Server.default.options.numBuffers_(10);	
	// Server.default.options.numControlBusChannels_(10);	
	// Server.default.options.numInputBusChannels_(0);	
	// Server.default.options.numRGens_(8);	
	// Server.default.options.numRGens_(8);	
	// load the various modules
	Include.relative("synthdef.scd"); 
	Include.relative("eeg_handler.scd");  
	Include.relative("audio_engine.scd"); 
	Include.relative("sensors_handler.scd");
	Routine({loop{ // main loop
		if (~sensors_handler[\is_headset_on].()) {
			~eeg_handler[\get_eeg].(); 
			~audio_engine[\run] = true;
			~audio_engine[\update_buffers].().wait; // it reads from eeg_1.wav and eeg_2.wav and waits for the condition
			~audio_engine[\parametrise].(~eeg_handler[\get_audio_parameters].());
			// eeg_handler[\assess_and_learn].();
		} {
			~audio_engine[\run] = false;
			~eeg_handler[\reset];
		};
		0.1.wait; // this is for safety mostly - when headset is on the code will call external commands synchronously - the wait time will be many seconds
	}}).play(AppClock);
	Routine({loop{ // this won't be very responsive unfortunately as all the asynchronous calls of the previous loop will freeze this one too
		~audio_engine[\master_synth].set(\amp, ~sensors_handler[\get_pot_value].()); // that won't be very responsive on purpose
		0.1.wait;
	}}).play(AppClock);
});

