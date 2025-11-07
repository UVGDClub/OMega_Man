extends Node
#-- scenes:
const PAUSE_MENU = preload("res://General/scenes/pause_menu/pause_menu.tscn")
const WEAPON_SCREEN = preload("res://General/scenes/weapon_screen/weapon_screen.tscn")
#-- music:
const BOSS_THEME = preload("res://General/music/temp/boss_theme_temp.ogg")
#--- game info:
var curr_level: int;
var next_level_name: String;
var level_spawnpoint: int = 0;
var playerLives : int = 2;
#--- useful instances
var camera: OmegaCamera2D;
var player: Player;
#--- toggles
var pause_toggle = false;
var weapon_toggle = false;
var can_pause = false;
var can_weapon_screen = false;
var debug_mode = false;
var slow_mo : bool = false;
var boss_door_anim : bool = false;
#--- signals
signal camera_spawn(camera);
signal player_spawn(player);
signal on_pause_game
signal on_weapon_screen
signal spawn_boss;

var saved_weapons : Array[WeaponResource]

var user_settings:Dictionary = {
	"volume_sfx":100.0,
	"volume_music":100.0,
}

func _ready() -> void:
	add_child(PAUSE_MENU.instantiate()); #add pausemenu as child to global
	add_child(WEAPON_SCREEN.instantiate());
	process_mode = Node.PROCESS_MODE_ALWAYS
	player_spawn.connect(on_player_spawn)
	camera_spawn.connect(on_camera_spawn)

func _process(_delta):
	misc_input();

func toggle_pause():
	if !can_pause: return;
	pause_toggle = !pause_toggle
	weapon_toggle = pause_toggle;
	get_tree().paused = pause_toggle;
	on_pause_game.emit(pause_toggle);

func toggle_weapon_menu():
	if !can_weapon_screen: return;
	weapon_toggle = !weapon_toggle
	pause_toggle = weapon_toggle;
	get_tree().paused = weapon_toggle;
	on_weapon_screen.emit(weapon_toggle)
	pass
	
func misc_input():
	if(Input.is_action_just_pressed("debug_9")):
		get_tree().reload_current_scene();
	if(Input.is_action_just_pressed("debug_8")):
		Global.player.state_forceExit(Global.player.state_Death);
	if(Input.is_action_just_pressed("debug_7")):
		debug_mode = !debug_mode;
	if(Input.is_action_just_pressed("act_start")):
		toggle_pause()
		#get_tree().change_scene_to_file("res://scenes/level_select/level_select_screen.tscn");
	if(Input.is_action_just_pressed("act_select")):
		toggle_weapon_menu();
		
func handle_player_death():
	if(playerLives == 0):
		get_tree().change_scene_to_file("res://General/scenes/game_over/game_over_screen.tscn");
		#gameover screen
	else:
		get_tree().reload_current_scene();
		#restart current level
	playerLives -= 1;
	
func on_player_spawn(p: Player) -> void:
	player = p
	
func on_camera_spawn(c: OmegaCamera2D) -> void:
	camera = c
