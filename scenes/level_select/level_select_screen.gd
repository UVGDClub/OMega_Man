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
	#TODO do intro
	#just warps to level for now
	get_tree().change_scene_to_packed(next_level)

func enter_level(level):
	#this assumes it's passed good input!!
	level_selected = true;
	match(level):
		1: next_level = load("res://scenes/level_1.tscn");
		2: pass;
		3: pass;
		4: pass;
		5: pass;
		6: pass;
		7: pass;
		8: pass;
		9: pass;
	
