/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Heraklion, 10.2016
	* part of Inhibition SuperCollider code
*/

// synthdefs
SynthDef(\vosc, { // will morph 3 consequtive tables
	arg amp = 0.2, freq = 100, vibRate = 1, vibRange = 0, morphRate = 10, dur = 1,
	bufOffset = 0, out = 0, pan = 1;
	var modulator = VOsc.ar( bufOffset + SinOsc.ar(morphRate, pi).range(0,2),vibRate, mul:vibRange); 
	var carrier =  VOsc.ar( bufOffset + SinOsc.ar(morphRate).range(0,2),freq + modulator );  
	var signal = LPF.ar(carrier * amp, Rand(3000,15000)); // band-limit
	signal = LeakDC.ar(signal);
	signal = signal * EnvGen.kr(Env([0,1,1,0],[dur/4,dur/2,dur/4],[4,0,-4]),doneAction:2);
	signal = FreeVerb.ar(signal,0.1,Rand(0.1,0.4),Rand(0.1,0.5));
	signal = Pan2.ar(signal, SinOsc.kr(pan, Rand(0,pi))); 
	Out.ar(out, signal * 0.6);
}).add;

Server.default.sync;

SynthDef(\osc, { // smoother version
	arg amp = 0.2, freq = 100, vibRate = 1, vibRange = 0, dur = 1,  out = 0, pan = 1;
	var modulator = SinOsc.ar(vibRate, mul:vibRange); 
	var carrier =  SinOsc.ar( freq + modulator );  
	var signal = LPF.ar(carrier * amp, Rand(3000,15000)); // band-limit
	signal = LeakDC.ar(signal);
	signal = signal * EnvGen.kr(Env([0,1,1,0],[dur/4,dur/2,dur/4],[4,0,-4]),doneAction:2);
	signal = FreeVerb.ar(signal,0.1,Rand(0.1,0.4),Rand(0.1,0.5));
	signal = Pan2.ar(signal, SinOsc.kr(pan, Rand(0,pi))); 
	Out.ar(out, signal * 0.6);
}).add;

Server.default.sync;

SynthDef(\master, { arg amp = 0.5, in = 0;
	var sound = In.ar(in,2) * amp;
	Out.ar(0, sound);
}).add;

Server.default.sync;
