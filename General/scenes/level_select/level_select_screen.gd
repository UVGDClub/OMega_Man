extends Control
@onready var omega = $GridContainer/Omega
@onready var grid_container:GridContainer = $GridContainer
@onready var white_flash = $WhiteFlash

@onready var music_intro = $music_intro
@onready var music:AudioStreamPlayer = $music


var flash_timer = 60;
var flash_visible = false;
var next_level;
var level_selected = false;

#TODO
	#make screen flash DONE
	#do robot master intro for level 

func _ready():
	Global.on_pause_game.connect(_on_pause);
	omega.grab_focus()
	white_flash.visible = false;
	music_intro.play();
	
func _process(_delta):
	if(!level_selected): return
	flash_screen();
	if(flash_timer == 0): goto_boss_intro();
	
	if(!music.playing && !music_intro.playing):
		music.play(); #loops music
	
func flash_screen():
	if((flash_timer % 5) == 0):
		flash_visible = !flash_visible;
		white_flash.visible = flash_visible
	flash_timer -= 1;

func goto_boss_intro():
	get_tree().change_scene_to_file("res://General/scenes/boss_intro/boss_intro.tscn")

#used by level containers
func enter_level(level, boss_name):
	level_selected = true;
	Global.can_pause = false;
	Global.curr_level = level;
	Global.next_level_name = boss_name;

func _on_pause(paused):
	if !paused: omega.grab_focus();
	
func _on_music_intro_finished():
	music.play()
