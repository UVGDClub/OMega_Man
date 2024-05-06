extends Control
@onready var omega = $GridContainer/Omega
@onready var grid_container = $GridContainer


func _ready():
	omega.grab_focus()

func enter_level(level):
	#TODO
	#make screen flash
	#do robot master intro for level
	#this assumes it's passed good input!!
	var next_level;
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
	get_tree().change_scene_to_packed(next_level)
