extends Control

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("intro");
	animation_player.animation_finished.connect(animation_done);

func animation_done(anim_name):
	get_tree().change_scene_to_file("res://General/scenes/Title Screen/title_screen.tscn")
