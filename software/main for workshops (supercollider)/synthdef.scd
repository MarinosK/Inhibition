/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Heraklion, 10.2016
	* part of Inhibition SuperCollider code
*/

// synthdefs
SynthDef(\eeg_osc, { // a simple wavetable oscillator
	arg amp = 0.2, freq = 100, dur = 1, buf = 0, out = 0, pan = 1;
	var signal = Osc.ar( buf, freq);  
	signal = LeakDC.ar(signal);
	signal = signal * EnvGen.kr(Env([0,1,1,0],[dur/4,dur/2,dur/4],[4,0,-4]),doneAction:2);
	signal = Pan2.ar(signal, SinOsc.kr(pan, Rand(0,pi))); 
	Out.ar(out, signal * 0.5);
}).add;

Server.default.sync;

SynthDef(\osc, { // modulated sine
	arg amp = 0.2, freq = 100, vibRate = 1, vibRange = 0, dur = 1,  out = 0, pan = 1;
	var modulator = SinOsc.ar(vibRate, mul:vibRange); 
	var carrier =  SinOsc.ar( freq + modulator );
	var signal = carrier;
	signal = LeakDC.ar(signal);
	signal = signal * EnvGen.kr(Env([0,1,1,0],[dur/4,dur/2,dur/4],[4,0,-4]),doneAction:2);
	signal = Pan2.ar(signal, SinOsc.kr(pan, Rand(0,pi))); 
	Out.ar(out, signal * 0.5);
}).add;

Server.default.sync;

SynthDef(\master, { arg amp = 0.15, in = 0;
	var sound = In.ar(in,2) * amp;
	Out.ar(0, sound);
}).add;

Server.default.sync;
