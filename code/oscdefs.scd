(
~oscReceive = OSCdef(\receiver, {
	arg msg;
	var idx = msg[1];
	~playNeurons.(idx);
}, '/index')
)