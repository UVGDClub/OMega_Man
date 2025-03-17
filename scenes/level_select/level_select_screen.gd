extends Control
@onready var omega = $GridContainer/Omega
@onready var grid_container = $GridContainer
@onready var white_flash = $WhiteFlash

var flash_timer = 60;
var flash_visible = false;
var next_level;
var level_selected = false;

#TODO
	#make screen flash DONE
	#do robot master intro for level 

func _ready():
	omega.grab_focus()
	white_flash.visible = false;
	
func _process(delta):
	if(!level_selected): return
	flash_screen();
	if(flash_timer == 0): goto_boss_intro();
	
func flash_screen():
	if((flash_timer % 5) == 0):
		flash_visible = !flash_visible;
		white_flash.visible = flash_visible
	flash_timer -= 1;

func goto_boss_intro():
	get_tree().change_scene_to_file("res://scenes/boss_intro/boss_intro.tscn")

#used by level containers
func enter_level(level, boss_name):
	level_selected = true;
	Global.next_level_warp = level;
	Global.next_level_name = boss_name;
