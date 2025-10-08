extends Node

var global_sound_queue:Array;
var current_music:AudioStreamPlayer = AudioStreamPlayer.new();
var music_stopped:bool = false;

func _ready():
	add_child(current_music);
	current_music.set_bus("music");

func _process(delta):
	cleanup_sound_queue();
	loop_current_music();

func playMusic(_stream, _volume = 1.0):
	current_music.stream = _stream;
	current_music.volume_linear = _volume;
	music_stopped = false;
	current_music.play();

func loop_current_music():
	if music_stopped: return;
	if !current_music.playing:
		current_music.play();

func stop_music():
	current_music.stop();
	music_stopped = true;

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
