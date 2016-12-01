/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Neapolis, 10.2016
	* part of Inhibition SuperCollider code
*/

// reinforcement learning
~rl_handler = Environment.new();
~rl_handler.use{
	~target = 10;
	~previous_pitch = 10;
	~previous_features =  Dictionary[(\pitch->10),(\centroid->0),(\complexity->0),(\weightedspectralmaximum->0),(\sharpness->0),(\dissonance->0),(\spread->0),(\slope->0)]!2; 
	~possibilities = Dictionary[
		(\duration -> [25,28,30,36,40,47,50,55,60,67,74]),
		(\vibRate -> [0.25,0.5,1,2,3,4,6,8,16]),
		(\density -> [1,2,3,4]),
		(\pan -> [0.015,0.03,0.06,0.125,0.25,0.5,1,2,3,4]),
		(\vibRange -> [0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4]),
		(\amp -> [0.4,0.5,0.6,0.7,0.8]),
		(\morphRate -> [0.25,0.5,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]),
		(\target -> [-2.0, -1.5, -1.0, 1.0, 1.5, 2.0])
	];
	~indices = Dictionary[
		(\duration -> ~possibilities[\duration].size.rand),
		(\vibRate -> ~possibilities[\vibRate].size.rand),
		(\density -> ~possibilities[\density].size.rand),
		(\pan -> ~possibilities[\pan].size.rand),
		(\vibRange -> ~possibilities[\vibRange].size.rand),
		(\amp -> ~possibilities[\amp].size.rand),
		(\morphRate -> ~possibilities[\morphRate].size.rand),
		(\target -> ~possibilities[\target].size.rand)
	];
	~create_data_file = { arg features, actions;
		var f = "";
		var a = "";
		var possibilities = ~rl_handler[\possibilities];
		"creating training data".postln;
		"rm train.data".systemCmd;
		"echo 1 8 8 >> train.data".systemCmd;
		// map to a 0,1 range
		// double check that the ranges are correct
		f = f ++
		ControlSpec(0,30).unmap(features[\pitch]) ++ " " ++ 
		ControlSpec(0,30).unmap(features[\centroid]) ++ " " ++ 
		features[\complexity] ++ " " ++ 
		ControlSpec(2,60).unmap(features[\weightedspectralmaximum]) ++ " " ++ 
		ControlSpec(0,700).unmap(features[\sharpness]) ++ " " ++ 
		features[\dissonance] ++ " " ++ 
		ControlSpec(-15,15).unmap(features[\spread]) ++ " " ++ 
		ControlSpec(-15,15).unmap(features[\slope]) ++ " ";
		("echo " ++ f ++ " >> train.data").systemCmd;
		a = a ++
		ControlSpec(0,possibilities[\duration].size).unmap(actions[\duration]) ++ " " ++
		ControlSpec(0,possibilities[\vibRate].size).unmap(actions[\vibRate]) ++ " " ++
		ControlSpec(0,possibilities[\density].size).unmap(actions[\density]) ++ " " ++
		ControlSpec(0,possibilities[\pan].size).unmap(actions[\pan]) ++ " " ++
		ControlSpec(0,possibilities[\vibRange].size).unmap(actions[\vibRange]) ++ " " ++
		ControlSpec(0,possibilities[\amp].size).unmap(actions[\amp]) ++ " " ++
		ControlSpec(0,possibilities[\morphRate].size).unmap(actions[\morphRate]) ++ " " ++
		ControlSpec(0,possibilities[\target].size).unmap(actions[\target]) ++ " ";
		("echo " ++ a ++ " >> train.data").systemCmd;
	};
	~action = { arg features;
		var possibilities = ~rl_handler[\possibilities];
		var indices = ~rl_handler[\indices];
		var audio_parameters = Dictionary[];
		var pitch = features[\pitch];
		var target = pitch + possibilities[\target][indices[\target]];
		~rl_handler[\previous_pitch] = pitch;
		~rl_handler[\target] = target;
		audio_parameters[\target] = target;
		audio_parameters[\duration] = possibilities[\duration][indices[\duration]];
		audio_parameters[\vibRate] = possibilities[\vibRate][indices[\vibRate]] * target;
		audio_parameters[\density] = possibilities[\density][indices[\density]];
		audio_parameters[\pan] = target * possibilities[\pan][indices[\pan]];
		audio_parameters[\vibRange] = possibilities[\vibRange][indices[\vibRange]];
		audio_parameters[\amp] = possibilities[\amp][indices[\amp]];
		audio_parameters[\morphRate] = possibilities[\morphRate][indices[\morphRate]] * target;
		audio_parameters.postln;
		audio_parameters; // return the audio parameters
	};
	~reset = {
		"reseting".postln;
		"./neural_net create".systemCmd; // createa the neural network using a utility program
		~rl_handler[\indices] = Dictionary[
			(\duration -> ~rl_handler[\possibilities][\duration].size.rand),
			(\vibRate -> ~rl_handler[\possibilities][\virRate].size.rand),
			(\density -> ~rl_handler[\possibilities][\density].size.rand),
			(\pan -> ~rl_handler[\possibilities][\pan].size.rand),
			(\vibRange -> ~rl_handler[\possibilities][\vibRange].size.rand),
			(\amp -> ~rl_handler[\possibilities][\amp].size.rand),
			(\morphRate -> ~rl_handler[\possibilities][\morphRate].size.rand),
			(\target -> ~rl_handler[\possibilities][\target].size.rand)
		];
	};
	~learn = { arg features;
		var pitch = features[\pitch];
		// not sure if I want to measure performance with respect to the target frequency or simply with respect to whether any change has been achieved
		// var reward = 0.6 - (~rl_handler[\target] - pitch).abs; // if performance is better than 0.6Hz then we can go on train the network
		var reward = (~rl_handler[\previous_pitch] - pitch).abs - 0.5; // if performance is better than 0.5Hz then we can go on train the network
		var indices = ~rl_handler[\indices];
		var possibilities = ~rl_handler[\possibilities];
		var actions, output, parsing_indices;
		var argument = "";
		("previous_pitch is: " ++ ~rl_handler[\previous_pitch]).postln;
		("current pitch is: " ++ pitch).postln;
		("the performance of the system has been (the greater the better): " ++ reward).postln;
		~rl_handler[\previous_pitch] = pitch; // update previous pitch
		// if reward is positive then train the network accordingly
		if (reward > 0) { // if reward is good train the network
			"learning".postln;
			~rl_handler[\create_data_file].(~rl_handler[\previous_features],~rl_handler[\indices]); // here I use the previous features, the ones valid when the actions had been chosen
			"./neural_net train train.data".systemCmd;
		};
		"updating indices".postln;
		features.do{arg feat; argument = argument ++ feat ++ " "; }; // here I use the current features
		~rl_handler[\previous_features] = features; // update previous features 
		output = ("./neural_net use " ++ argument).unixCmdGetStdOut;
		// parse output
		parsing_indices = output.findAll(",").insert(0,-2);
		8.do{arg i;
			actions = actions.add(output[(parsing_indices[i]+2)..(parsing_indices[i+1]-1)].interpret)
		};
		if (reward > 0) { // if reward is good rely primarily on the network
			indices.keysDo{ arg k,i;
				if (0.9.coin) { // normally update them using the neural net, but everynow and then proceed randomly to bring forth some indeterminacy
					indices[k] = ControlSpec(0,possibilities[k].size - 1,step:1).map(actions[i]);
				} {
					indices[k] = possibilities[k].size.rand;
				};
			};	
		} { // if the reward is not very good rely primarily on random values
			indices.keysDo{ arg k,i;
				if (0.4.coin) { 
					indices[k] = ControlSpec(0,possibilities[k].size - 1,step:1).map(actions[i]);
				} {
					indices[k] = possibilities[k].size.rand;
				};
			};	
		};
	}; 
};
