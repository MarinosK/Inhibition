/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Heraklion, 10.2016
	* part of Inhibition SuperCollider code
*/

~eeg_handler = Environment.new; 
~eeg_handler.use{
	//	~buffers = Array.fill(2,{Buffer.new(Server.default)});
	~get_eeg = { // get and analyse eeg signal
		var dcshift = Array.newClear(2);
		var features = Dictionary[(\pitch->0),(\centroid->0),(\complexity->0),(\weightedspectralmaximum->0),
			(\sharpness->0),(\dissonance->0),(\spread->0),(\slope->0)];
		// var condition = Condition(false);
		// clean previous results and get new data
		"rm *wav".systemCmd;
		"reading eeg data over spi..".postln;
		"./read_eeg temp_eeg.wav".systemCmd;
		// split
		"sox temp_eeg.wav temp_eeg_1.wav remix 1".systemCmd;
		// calculate DC OFFSET
		"sox temp_eeg_1.wav -n stats 2> temp_eeg_1.stats".systemCmd;
		1.do{ arg i; // this is stupid code to be refactored in the future, I simply changed the stereo version to a mono one directly here
			var file = File("temp_eeg_" ++ (i + 1) ++".wav","r");
			var offset = file.getLine(1024);
			var data;
			offset = offset[offset.find("0")..].asFloat * (-1);
			dcshift[i] = offset;
			file.close;
			// remove dc, filter and create fades 
			("sox temp_eeg_"++(i+1)++".wav eeg_"++(i+1)++".wav" ++" lowpass 25 fade 0.1 0 0.1 dcshift "++dcshift[i]).systemCmd;
			// analyse
			~analysis[\run].value("eeg_"++(i+1)++".wav").wait;
			data = ~analysis[\getResults].value();
			features[\pitch] = data[0][0];
			features[\centroid] = data[1][0];
			features[\complexity] = data[2][0];
			features[\weightedspectralmaximum] = data[3][0];
			// features[\sharpness] = data[4][0];
			// features[\dissonance] = data[5][0];
			// features[\spread] = data[6][0];
			// features[\slope] = data[7][0];
		};
		// condition.wait;
		// clean temporaries
		"rm temp*".unixCmd;
		features; // return features
	};
};
