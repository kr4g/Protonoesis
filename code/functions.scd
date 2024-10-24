// Playback and interaction function(s)
(
~playNeurons = {
	arg index = 0;
	var density = ~density[index];
	var avgRate = ~avgRates[index];
	var weights = [2+density,5,3+density].normalizeSum;
	// NetAddr("192.168.50.253", 10000).sendMsg("/avgRate", avgRate);
	// NetAddr("192.168.50.253", 10000).sendMsg("/density", density);
	s.bind { ~droneSynth.set(\lpfFreq, density.linexp(0,1,8000,200), \amp, density.linlin(0,1,-6.dbamp,-28.dbamp)); };
	131.do { |j|
		if ( ~spikes[j][index] * (1.0 - ~labels[j]) > 0.0,
			{
				var val = linlin(~rates[j][index], 0, 1, 3.4375, 27.5);
				var scale = linlin(~rates[j][index], 0, 1, exprand(1, avgRate.linlin(0,1,5,2)), 0.5);
				var amp = density.linexp(0, 1, -6.dbamp, -18.dbamp);
				var synth = [\neuron1, \neuron2, \neuron3].wchoose(weights);
				var freq = ~rates[j][index].linlin(0,1,36,linexp(density,0,1,2304,4608));
				var out = rrand(0,~nChans);
				// if (freq < 576,
				// 	{
				// 		if (freq < 108,
				// 			{out = rrand(16,17)},
				// 			{out = rrand(0,~nChans)}
				// 		);
				// 	},
				// 	{
				// 		out = rrand(8,15);
				// 		if (freq > 3000,
				// 			{
				// 				("Neuron " ++ j.asString ++ " at maximum rate, " ++ (~rates[j][index]).asString ++ " Hz").postln;
				// 			}
				// 		);
				// 	}
				// );
				s.bind { Synth(synth, [
					\ampRate, val,
					\dur, density.linlin(0,1,1,2)*scale,
					\freq, freq,
					\amp, amp,
					\out, out
				]); };
			},
			{}
		);
	};
	if ( density > 0.1,
		{ s.bind { ~droneSynth.set(\bpfMaxRate, exprand(0.001,0.1+avgRate), \wdtRate, avgRate.linexp(0,1,0.001,0.1+density)); }; }
	);
	if ( density > 0.6,
		{
			("Neural Density: " ++ density.asString ++ ", " ++ index.asString ++ " ms").postln;
			if ( density > 0.7,
				{("Critical Spike Activity: " ++ index.asString ++ " ms").postln;}
			);
		},
	);
};

~speakerTest = {
	arg dur = 0.5, nChans = 2;
	Routine({
		inf.do { |i|
			Synth(\pinkTest, [\duration, dur, \out, i % nChans]);
			dur.wait;
		}
	}).play;
};
)