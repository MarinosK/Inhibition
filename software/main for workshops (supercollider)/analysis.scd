/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Athens, 11.2016
	* this is the main program generating audio for the Inhibition piece
*/

~analysis = Environment.new; 
~analysis.use{
	~run = { arg filePath;
		var analysisBuffer;
		var condition = Condition.new(false);
		var score = Score([
			[0, (analysisBuffer = Buffer.new(Server.default, 2, 4)).allocMsg ], // a 4-channel Buffer
			//then the SynthDefs
			[0, [\d_recv, SynthDef(\analysis, {
				var sig = SoundIn.ar(0); // will come from NRT input file
				var fft = FFT(LocalBuf(1024, 1), sig); // fft analysis
				var pulseCount = PulseCount.kr(Impulse.kr(1.8.reciprocal)); // triggers (every timeInterval)
				var pitch,hasPitch, analysis; 
				# pitch, hasPitch = Pitch.kr(sig);
				analysis = [ // analysis UGens herein
					pitch,
					SpecCentroid.kr(fft), // spectral centroid
					SpecFlatness.kr(fft), // spectral flatness
					SpecPcile.kr(fft,0.8) // 80-SpecPcile
					//FFTCrest.kr(fft), // spectral crest
					// SensoryDissonance.kr(fft), // Sensory Dissonance
					// FFTSpread.kr(fft) * 0.000001,
					// FFTSlope.kr(fft)
				];
				BufWr.kr(analysis, analysisBuffer, pulseCount, loop: 0); // write analysis data
				BufWr.kr(pulseCount, analysisBuffer, DC.kr(0), 0); // at index 0 write the pulse count so that the number of measurements is known
			}).asBytes]],

			// start the Synth
			[0, Synth.basicNew(\analysis, Server.default, 2).newMsg], 
			// write analysis data to temporary files
			[2, analysisBuffer.writeMsg("temp_analysis.aiff", headerFormat: "AIFF", sampleFormat: "float")]
		]);

		score.recordNRT("temp_analysis.osc", "/dev/null", filePath, sampleRate: 4000,
			options: ServerOptions.new
			.verbosity_(-1)
			.numInputBusChannels_(1)
			.numOutputBusChannels_(4)
			.sampleRate_(4000),
			action: { condition.test_(true).signal;} // update Condition
		);

		condition;
	};
	~getResults = {
		var data;
		var soundFile = SoundFile.openRead("temp_analysis.aiff");
		var size = FloatArray.newClear(4); // an empty FloatArray
		soundFile.readData(size); // read data to array
		size = size[0] * 4; // because there are 4 channels
		// read data from file
		data = FloatArray.newClear(size); // an empty FloatArray
		soundFile.readData(data); // read data into the array
		soundFile.close; // close soundFile
		// preprocess and re-structure dataset
		data = data.as(Array);  // convert to Array
		data = data.collect(_.round(0.01)); // round to the second decimal
		data = data.reshape( (data.size/4).asInteger, 4).flop; // re-organize data
		data;
	};
}




