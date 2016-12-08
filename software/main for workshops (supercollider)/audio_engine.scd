/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Heraklion, 10.2016
	* part of Inhibition SuperCollider code
*/

// groups
var master_channel = 35;

// 
~audio_engine = Environment.new;
~audio_engine.use{
	~group = Group.new(Server.default);
	~master_synth = Synth(\master, [\in, master_channel],Server.default,\addToTail);
	~master_amp = 1;
	~previous_signal = Signal.newClear(128); 
	~parameters = Dictionary[ // random init values just in case
		(\duration -> 20),
		(\vibRate -> 0),
		(\density -> 1),
		(\pan -> 1),
		(\vibRange -> 0),
		(\amp -> 0.4),
		(\target -> 7),
	];
	~run = false; // flag
	~parametrise = { arg action; // action should be a Dictionary with indices to select among ... plus the detected eeg pitch
		~audio_engine[\parameters] = action;
	};
	~buffer = Buffer.alloc(Server.default, 256, bufnum:0);
	~update_buffers = {
		var condition = Condition.new(false); // a condition is used to guarantee that the buffers are updated synchronously
		var signal = Signal.newClear(128); // just a starting signal
		var buf;
		"updating buffers..".postln;
		// first create fade ins/outs for smoother sound
		buf = Buffer.read(Server.default,"eeg_1.wav", action:{ arg b;
			128.do{arg sample;
				b.get(sample * 31, { // downsample
					arg value; signal[sample] = value;
					if (sample == 127) { // on the last sample
						signal = signal * Signal.welchWindow(128); // smooth it out
						Routine({
							100.do{ // morph with previous contents !!
								if (~sensors_handler[\is_headset_on].()) { // this is a very ugly hack but the truth is that it simplifies the whole architecture a lot... so be it
									~audio_engine[\previous_signal] = ~audio_engine[\previous_signal].blend(signal,0.03);
									~audio_engine[\buffer].sendCollection(~audio_engine[\previous_signal].normalize.asWavetable);
									0.01.wait; // wait a bit to morph it smoothly
								};
							};
							if (i==1) { // eventually free the condition
								condition.test_(true);
								condition.signal;
								buf.free;
							};
						}).play(AppClock);
					};
				}); 
			};
		});
		Server.default.sync;
		condition; // return condition
	};
};

// constantly runing audio loop
Routine({
	// init buffer
	var signal = Signal.hanningWindow(128);
	~audio_engine[\buffer].sendCollection(signal.asWavetable);
	loop{ // loop
		var parameters = ~audio_engine[\parameters];
		var target_frequency = parameters[\target];
		if (~audio_engine[\run]) {
			var wait = parameters[\duration];
			parameters[\density].do{
				var freq;
				var timbre = [\eeg_osc,\osc].wchoose([0.3,0.7]);
				if (target_frequency > 9 ) { 
						freq = target_frequency * [10,100,1000].choose;
					} {
						freq = target_frequency * [40,200,2000].choose;
					};
				if (freq > 120 ) {
					freq = [freq,freq+target_frequency]; // create a beat if possible
				};
				freq.do {arg f;
					Synth(timbre, // randomly choose a vosc or osc
						[   \freq, f, \vibRate, parameters[\vibRate], \dur, wait * 1.4,
								\out, master_channel,\pan, parameters[\pan],
								\vibRange, f * parameters[\vibRange],\amp, parameters[\amp]
							],~audio_engine[\group].asTarget);
				}
			};
			wait.wait;
		} {
			0.2.wait;	
		} 
	}
}).play;


