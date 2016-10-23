Server.default.waitForBoot{
	"testing the sound..".postln;
	"you should here a train of whitenoise pulses fading to silence".postln; 
	{WhiteNoise.ar(SinOsc.ar(1).abs)!2 * Line.ar(1,0,5,doneAction:2)}.play;
	5.wait;
	0.exit; 
};