extends Control

@onready var weapon_name = $weapon_name

var next_level:PackedScene;
var weapon_to_type:String = "ASS BLASTER";
var charTimer = 4;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if(Global.curr_level > 0 && Global.curr_level < 9):
		weapon_to_type = Global.player_weapon_unlocks[Global.curr_level][1];
	weapon_name.text = weapon_to_type;
	weapon_name.visible = false; #HACK see hack_adjust_boss_name()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hack_adjust_weapon_name();
	type_weapon_name()
	
func type_weapon_name():
	if(charTimer):
		charTimer -=1;
		return;
	if(weapon_name.text.length() != weapon_to_type.length()):
		var index = weapon_name.text.length()
		weapon_name.text += weapon_to_type.substr(index,1)
		charTimer = 4;

#identical to hack_adjust_boss_name from boss_intro.gd
func hack_adjust_weapon_name():
	#NOTE for this to work properly, the label anchor must be on the LEFT
	if(weapon_name.visible == true): return; #do this only once
	weapon_name.position.x -= weapon_name.size.x/2;
	weapon_name.text = ""
	weapon_name.visible = true;

#go to level select
func _on_timer_timeout():
	print("guh")
	get_tree().change_scene_to_file("res://scenes/level_select/level_select_screen.tscn");
