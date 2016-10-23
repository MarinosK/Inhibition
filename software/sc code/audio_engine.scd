/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Heraklion, 10.2016
	* part of Inhibition SuperCollider code
*/

// groups
var group = Group.new(Server.default);
var master_channel = 35;

// 
~audio_engine = Environment.new;
~audio_engine.use{
	~master_synth = Synth(\master, [\in, master_channel],Server.default,\addToTail);
	~target_frequency = 10;
	~master_amp = 1;
	~previous_signal = Signal.newClear(128)!2; // an array holding the two previous eeg wavetables
	~parameters = Dictionary[ (\duration -> [30,35,42,56,64,88,106,128]), (\vibRate -> [0.25,0.5,1,2,4,8,16]),
		(\density -> [1,2,3]), (\pan -> [0.5,1,2,4,8]), (\vibRange -> [0.1,0.2,0.3,0.4,0.5]), (\amp -> [0.1,0.3,0.5,0.7,0.9]),
		(\morphRate -> [0.25,0.5,1,2,4,8,16])
	]; 
	~run = false; // flag
	~parametrise = { arg parameters;
		~audio_engine[\target_frequency] = parameters;
	};
	~buffers = Buffer.allocConsecutive(4, Server.default, 256, bufnum:0); // the synthDef will only consider bufnum 0! 
	~update_buffers = {
		var condition = Condition.new(false); // a condition is used to guarantee that the buffers are updated synchronously
		"updating buffers..".postln;
		2.do{ arg i;
			var signal = Signal.newClear(128); // just a starting signal
			var buf = Buffer.read(Server.default,"eeg_"++(i+1)++".wav",action:{ arg b;
				128.do{arg sample;
					b.get(sample * 31, { // downsample
						arg value; signal[sample] = value;
						if (sample == 127) { // on the last sample
							signal = signal * Signal.welchWindow(128); // smooth it out
							Routine({
								100.do{ // morph with previous contents !!
									~audio_engine[\previous_signal][i] = ~audio_engine[\previous_signal][i].blend(signal,0.03);
									~audio_engine[\buffers][i+1].sendCollection(~audio_engine[\previous_signal][i].normalize.asWavetable);
									0.01.wait; // wait a bit to morph it smoothly
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
		};
		condition; // return condition
	};
};

// constantly runing audio loop
Routine({
	// init buffers
	var signal = Signal.hanningWindow(128);
	~audio_engine[\buffers].do{arg b; b.sendCollection(signal.asWavetable);};
	loop{ // loop
		var target_frequency = ~audio_engine[\target_frequency];
		var parameters = ~audio_engine[\parameters];
		if (~audio_engine[\run]) {
			var wait = parameters[\duration].choose;
			parameters[\density].choose.do{
				var freq;
				var switch = [1,2,3].wchoose([0.4,0.5,0.1]); // 3 frequency registers 
				case
				{switch == 1} { // the lowest region is just harmonics of the target 
					if (target_frequency > 6 ) { 
						freq = target_frequency * (7..11).choose;
					} {
						freq = target_frequency * (20..30).choose;
					}
				}
				{switch == 2} {freq = rrand(100,600.0);}
				{switch == 3} {freq = rrand(1000,6000);};
				if (freq < 120 ) {
					freq = [freq];
				} {
					freq = [freq, freq + target_frequency]; // when possible create beats
				};
				freq.do {arg f;
					Synth([\vosc,\osc].wchoose([0.6,0.4]), [
						\freq, f, \vibRate, parameters[\vibRate].choose, \dur, wait * rrand(1.1,3), \out, master_channel,
						\pan, target_frequency / parameters[\pan].choose, \vibRange, f * parameters[\vibRange].choose,
						\amp, parameters[\amp].choose, \morphRate, parameters[\morphRate].choose * target_frequency
					],group.asTarget);
				}
			};
			wait.wait;
		} {
			0.2.wait;	
		} 
	}
}).play(AppClock);
