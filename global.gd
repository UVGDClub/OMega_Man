extends Node

var player: Player;
signal player_spawn(player);

var camera: OmegaCamera2D;
signal camera_spawn(camera);

func _ready() -> void:
	player_spawn.connect(on_player_spawn)
	camera_spawn.connect(on_camera_spawn)
	
func on_player_spawn(p: Player) -> void:
	player = p
	
func on_camera_spawn(c: OmegaCamera2D) -> void:
	camera = c
