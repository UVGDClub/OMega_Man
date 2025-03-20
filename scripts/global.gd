extends Node

var player: Player;
var playerLives : int = 2;
signal player_spawn(player);

var camera: OmegaCamera2D;
signal camera_spawn(camera);

var next_level_warp: int;
var next_level_name: String;

func _ready() -> void:
	player_spawn.connect(on_player_spawn)
	camera_spawn.connect(on_camera_spawn)

func _process(_delta):
	handle_pause()
		
func handle_pause():
	if(Input.is_action_just_pressed("act_start")):
		get_tree().change_scene_to_file("res://scenes/level_select/level_select_screen.tscn");
		
func handle_player_death():
	if(playerLives == 0):
		get_tree().change_scene_to_file("res://scenes/game_over/game_over_screen.tscn");
		#gameover screen
	else:
		get_tree().reload_current_scene();
		#restart current level
	playerLives -= 1;
	
func on_player_spawn(p: Player) -> void:
	player = p
	
func on_camera_spawn(c: OmegaCamera2D) -> void:
	camera = c
