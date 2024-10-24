/*
"PROTONOESIS 1.1"

Ryan Millett

Follow the numbers to setup the code.

Place your cursor anywhere inside the parenthesis (do not highlight) and press "ctrl/cmd" + "enter/return" to execute the code block.

*/

(
// 1
// Display output devices.
// Find you output device and copy/paste below
ServerOptions.devices.do{ |item| item.postln; };
)

(
// 2
// Set number of channels
~nChans = 4; // <- change to whatever
)

(
// 3
// Boot the server with correct output device
Server.killAll;
Buffer.freeAll;
s = Server.local;
s.options.outDevice_(
	"YOUR OUTPUT DEVICE NAME HERE (in quotes, just like this)"
	// "MacBook Pro Speakers"
);
// s.options.inDevice_("Built-in Microph");
s.options.numInputBusChannels_(0);
s.options.numOutputBusChannels_(~nChans);
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20));
s.reboot;
)

(
// 4
// Load SynthDefs and functions
~projectPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(~projectPath ++ "synthdefs.scd").load;
(~projectPath ++ "functions.scd").load;
)

(
// 5
// speakers test (press "ctrl/cmd" + "." to stop)
~speakerTest.value(nChans: ~nChans);
)

(
// 6
// load buffers (this may take a minute)
(~projectPath ++ "loadbuffers.scd").load;
)

(
// 7
// Sanity checks
// If the output is wrong, wait another minute and run this block again, it should be fine.
Routine({                                                                       // CORRECT VALUES
	("Labels size:     " ++ ~labels.size).postln;                               // 131
	("Rates size:      " ++ ~rates.size ++ ", " ++ ~rates[0].size).postln;      // 131, 180000
	("Spikes size:     " ++ ~spikes.size  ++ ", " ++ ~spikes[0].size).postln;   // 131, 180000
	("Density size:    " ++ ~density.size).postln;                              // 180000
	("Avg. Rates size: " ++ ~avgRates.size).postln;                             // 180000
}).play;
)

// 8
// Open UDP Ports
// Change this port number or add any additional ports
(
thisProcess.openUDPPort(1234); // <- you can change this number if needed
thisProcess.openPorts;
)

// 9
// Activate
(
(~projectPath ++ "oscdefs.scd").load;
Routine({
	s.bind { ~fx = Synth.tail(nil, \reverb); };
	s.bind { ~droneSynth = Synth(\drone, [\amp, -8.dbamp]); };
}).play;
)


// ----------------------------------------------------------

// OPTIONAL SANITY/LEVEL CHECK
// Test without OSC
// Press "ctrl/cmd" + "." to stop
(
Routine({
	var fx;
	s.bind { fx = Synth.tail(nil, \reverb); };
	s.bind { ~droneSynth = Synth(\drone, [\amp, -8.dbamp]); };
	180000.do { |i|
		~playNeurons.(i);
		(32/1000).wait;
	};
	s.bind { ~droneSynth.set(\gate, 0); };
	s.bind { fx.free; ~droneSynth.free};
}).play;
)
