/*
	* by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
	* Neapolis, 10.2016
	* part of Inhibition SuperCollider code
*/

// reinforcement learning
~rl_handler = Environment.new();
~rl_handler.use{
	~target = 10;
	~possibilities = Dictionary[
		(\duration -> [30,35,42,56,64,88,106,128,140]),
		(\vibRate -> [0.25,0.5,1,2,3,4,6,8]),
		(\density -> [1,2,3,4]),
		(\pan -> [0.06,0.125,0.25,0.5,1,2,3,4,6,8]),
		(\vibRange -> [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7]),
		(\amp -> [0.3,0.4,0.5,0.6,0.7,0.8,0.9]),
		(\morphRate -> [0.25,0.5,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]),
		(\target -> [-2.0, -1.5, -1.0, -0.5, 0.5, 1.0, 1.5, 2.0])
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
	~action = { arg features;
		var possibilities = ~rl_handler[\possibilities];
		var indices = ~rl_handler[\indices];
		var audio_parameters = Dictionary[];
		var pitch = (features[0][\pitch] + features[1][\pitch]) / 2;
		var target = pitch + possibilities[\target][indices[\target]];
		~rl_handler[\target] = target;
		audio_parameters[\target] = target;
		audio_parameters[\duration] = possibilities[\duration][indices[\duration]];
		audio_parameters[\vibRate] = possibilities[\vibRate][indices[\vibRate]] * target;
		audio_parameters[\density] = possibilities[\density][indices[\density]];
		audio_parameters[\pan] = target * possibilities[\pan][indices[\pan]];
		audio_parameters[\vibRange] = possibilities[\vibRange][indices[\vibRange]];
		audio_parameters[\amp] = possibilities[\amp][indices[\amp]];
		audio_parameters[\morphRate] = possibilities[\morphRate][indices[\morphRate]] * target;		
		audio_parameters; // return the audio parameters
	};
	~reset = {
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
		var pitch = (features[0][\pitch] + features[1][\pitch]) / 2;
		var reward = 1 - (~rl_handler[\target] - pitch).abs;
		var indices = ~rl_handler[\indices];
		var possibilities = ~rl_handler[\possibilities];

		
		// set randomly for now until I think of a more clever algorithm
		indices[\duration] = ~rl_handler[\possibilities][\duration].size.rand;
		indices[\vibRate] = ~rl_handler[\possibilities][\virRate].size.rand;
		indices[\density] = ~rl_handler[\possibilities][\density].size.rand;
		indices[\pan] = ~rl_handler[\possibilities][\pan].size.rand;
		indices[\vibRange] = ~rl_handler[\possibilities][\vibRange].size.rand;
		indices[\amp] = ~rl_handler[\possibilities][\amp].size.rand;
		indices[\morphRate] = ~rl_handler[\possibilities][\morphRate].size.rand;
		indices[\target] = ~rl_handler[\possibilities][\target].size.rand;
	};
};