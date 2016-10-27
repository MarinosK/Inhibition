/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
 * Heraklion, 10.2016
 * this is the main program generating audio for the Inhibition piece
 */

// note that this has to be run as root

Server.default.waitForBoot({
	Include.relative("synthdef.scd"); 
	Include.relative("eeg_handler.scd");  
	Include.relative("audio_engine.scd"); 
	Include.relative("sensors_handler.scd");
	Include.relative("rl.scd");
	~rl_handler[\reset].();
	Routine({loop{ // main loop
		if (~sensors_handler[\is_headset_on].()) {
			~audio_engine[\parametrise].(~rl_handler[\action].(~eeg_handler[\get_eeg].())); // select an action and parametrise audio accordingly (this will launch an eeg analysis of course)
			~audio_engine[\run] = true;
			~audio_engine[\update_buffers].().wait; // it reads from eeg_1.wav and eeg_2.wav and waits for the condition
			~rl_handler[\learn].(~eeg_handler[\get_eeg].()); // learn and reset indices
			~audio_engine[\update_buffers].().wait; 
		} { // when headset is off stop sound and reset
			~audio_engine[\run] = false;
			~rl_handler[\reset].();
		};
		0.1.wait; // this is for safety mostly - when headset is on the code will call external commands synchronously - the wait time will be many seconds
	}}).play(AppClock);
	Routine{loop{
		if (~sensors_handler[\is_headset_on].()) {
			~sensors_handler[\led_on].();
			1.wait;
			~sensors_handler[\led_off].();
			1.wait;
		} {
			~sensors_handler[\led_on].();
			1.wait;
		}
	}}.play(AppClock);
	Routine({loop{ // this won't be very responsive unfortunately as all the asynchronous calls of the previous loop will freeze this one too
		~audio_engine[\master_synth].set(\amp, ~sensors_handler[\get_pot_value].()); // that won't be very responsive on purpose
		0.1.wait;
	}}).play(AppClock);
});

