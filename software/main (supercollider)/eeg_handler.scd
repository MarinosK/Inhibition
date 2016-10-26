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
			(\sharpness->0),(\dissonance->0),(\spread->0),(\slope->0)]!2; // an array of two dictionaries
		// var condition = Condition(false);
		// clean previous results and get new data
		"rm *wav".systemCmd;
		"reading eeg data over spi..".postln;
		"./read_eeg temp_eeg.wav".systemCmd;
		// split
		"sox temp_eeg.wav temp_eeg_1.wav remix 1".systemCmd;
		"sox temp_eeg.wav temp_eeg_2.wav remix 2".systemCmd;
		// calculate DC OFFSET
		"sox temp_eeg_1.wav -n stats 2> temp_eeg_1.stats".systemCmd;
		"sox temp_eeg_2.wav -n stats 2> temp_eeg_2.stats".systemCmd;
		2.do{ arg i;
			var file = File("temp_eeg_" ++ (i + 1) ++".wav","r");
			var offset = file.getLine(1024);
			var data;
			offset = offset[offset.find("0")..].asFloat * (-1);
			dcshift[i] = offset;
			file.close;
			// remove dc, filter and create fades 
			("sox temp_eeg_"++(i+1)++".wav eeg_"++(i+1)++".wav" ++" lowpass 25 fade 0.1 0 0.1 dcshift "++dcshift[i]).systemCmd;
			// analyse
			FEUtil.analyze("eeg_"++(i+1)++".wav",1.8).wait; // it returns a condition
			// parse csv and append to data
			CSVFileReader.read("eeg_"++(i+1)++".wav.csv",func:{
				arg d;
				var data = [d.findAll("["), d.findAll("]")].flop.collect{arg pair;
					d[pair[0]..pair[1]].interpret;
				};
				features[i][\pitch] = data[0][0];
				features[i][\centroid] = data[2][0];
				features[i][\complexity] = data[3][0];
				features[i][\weightedspectralmaximum] = data[4][0];
				features[i][\sharpness] = data[5][0];
				features[i][\dissonance] = data[6][0];
				features[i][\spread] = data[7][0];
				features[i][\slope] = data[8][0];
				// if (i==1) {
				// 	condition.test_(true);
				// 	condition.signal;
				// };
			}, delimiter:";",startRow:1);
		};
		// condition.wait;
		"rm *csv".unixCmd;
		// clean temporaries
		"rm temp*".unixCmd;
		features; // return features
	};
};
