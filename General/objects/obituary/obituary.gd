extends CanvasLayer

@onready var sprite_2d = $Sprite2D
@onready var fadeout = $fadeout
var alpha = 0.0;
var alpha_delta = 1;
var music:AudioStreamPlayer;

var DEATHS = [
			preload("res://General/objects/obituary/obituary_sfx/death1.ogg"),
			preload("res://General/objects/obituary/obituary_sfx/death2.ogg"),
			preload("res://General/objects/obituary/obituary_sfx/death3.ogg"),
			preload("res://General/objects/obituary/obituary_sfx/death4.ogg")
			]

func _ready():
	var choose = randi_range(0,3);
	music = SoundManager.playSound(DEATHS[choose]);
	fadeout.start()
	sprite_2d.modulate.a = alpha

func _process(delta):
	sprite_2d.modulate.a = alpha
	if(alpha_delta == -1):
		music.volume_linear = alpha-0.1;
		if(alpha < 0.00001):
			get_tree().change_scene_to_file("res://General/scenes/Title Screen/title_screen.tscn")
	handle_transparency(delta);

func handle_transparency(delta):
	alpha = move_toward(alpha, 1.0*alpha_delta, delta);

func _on_fadeout_timeout():
	alpha_delta = -1;
	pass # Replace with function body.
