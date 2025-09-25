extends Node

var global_sound_queue:Array;

func _process(delta):
	cleanup_sound_queue();

## crates a global sound instance and plays the sound
func playSound(_stream, _volume = 1.0, _pitch = 1.0, _pitchRange = 0.0):
	var sound = AudioStreamPlayer.new();
	sound.stream = _stream;
	sound.volume_linear = _volume;
	sound.pitch_scale = _pitch + randf_range(-_pitchRange, _pitchRange);
	sound.set_bus("sfx");
	add_child(sound);
	global_sound_queue.append(sound);
	sound.play();

## iterates and frees global sounds that aren't playing anymore
func cleanup_sound_queue():
	if(global_sound_queue.is_empty()) : return;
	for sound:AudioStreamPlayer in global_sound_queue:
		if sound.playing == false:
			global_sound_queue.erase(sound)
			sound.queue_free()
