extends Node

var player;
signal player_spawn(player);

var camera;
signal camera_spawn(camera);

func _ready() -> void:
	player_spawn.connect(on_player_spawn)
	camera_spawn.connect(on_camera_spawn)
	
func on_player_spawn(p) -> void:
	player = p
	
func on_camera_spawn(c) -> void:
	camera = c
