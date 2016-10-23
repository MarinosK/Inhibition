/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Heraklion, 10.2016
	* part of Inhibition SuperCollider code
*/

~eeg_handler = Environment.new; 
~eeg_handler.use{
	~data = Dictionary[(\pitch->[]),(\centroid->[]),(\complexity->[]),(\weightedspectralmaximum->[]),
		(\sharpness->[]),(\dissonance->[]),(\spread->[]),(\slope->[])]!2; // an array of two dictionaries
	//	~buffers = Array.fill(2,{Buffer.new(Server.default)});
	~get_eeg = { // get and analyse eeg signal
		var dcshift = Array.newClear(2);
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
				~eeg_handler[\data][i][\pitch] = ~eeg_handler[\data][i][\pitch].add(data[0][0]);
				~eeg_handler[\data][i][\centroid] = ~eeg_handler[\data][i][\centroid].add(data[2][0]);
				~eeg_handler[\data][i][\complexity] = ~eeg_handler[\data][i][\complexity].add(data[3][0]);
				~eeg_handler[\data][i][\weightedspectralmaximum] = ~eeg_handler[\data][i][\weightedspectralmaximum].add(data[4][0]);
				~eeg_handler[\data][i][\sharpness] = ~eeg_handler[\data][i][\sharpness].add(data[5][0]);
				~eeg_handler[\data][i][\dissonance] = ~eeg_handler[\data][i][\dissonance].add(data[6][0]);
				~eeg_handler[\data][i][\spread] = ~eeg_handler[\data][i][\spread].add(data[7][0]);
				~eeg_handler[\data][i][\slope] = ~eeg_handler[\data][i][\slope].add(data[8][0]);
			}, delimiter:";",startRow:1);
		};
		"rm *csv".unixCmd;
		// clean temporaries
		"rm temp*".unixCmd;
	};
	~get_audio_parameters = {
		// for now only return target frequency
		var target = (~eeg_handler[\data][0][\pitch].last + ~eeg_handler[\data][1][\pitch].last) / 2;
		target = target + [rrand(0.7,1.7),rrand(-0.7,-1.7)].choose;
		target;
	};
	~assess_and_learn = {
		
	};
	~reset = {
		~eeg_handler[\data] = Dictionary[(\pitch->[]),(\centroid->[]),(\complexity->[]),(\weightedspectralmaximum->[]),
			(\sharpness->[]),(\dissonance->[]),(\spread->[]),(\slope->[])]!2; // an array of two dictionaries
	};
};
