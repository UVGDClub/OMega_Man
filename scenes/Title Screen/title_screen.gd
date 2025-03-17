extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(input_accept()): goto_menu();

func goto_menu():
	#TODO goto main menu
	#for now, go to level select
	var scene = load("res://scenes/level_select/level_select_screen.tscn")
	get_tree().change_scene_to_packed(scene)
	
func input_accept():
	return Input.is_action_pressed("act_jump")
