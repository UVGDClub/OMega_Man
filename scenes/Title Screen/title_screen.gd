extends Control
@onready var press_start = $Margin/Label
@onready var goto_timer = $goto_timer
@onready var flash_timer = $flash_timer
@onready var select = $select

var is_start_pressed:bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.can_pause = false;
	goto_timer.timeout.connect(goto_menu)
	pass # Replace with function body.

func _process(_delta):
	if(input_accept()): start_pressed();

##animation when start is pressed
func start_pressed():
	if(is_start_pressed):return
	is_start_pressed = true;
	goto_timer.start()
	flash_timer.start(0.1);
	select.play()

func goto_menu():
	#TODO goto main menu
	#for now, go to level select
	var scene = load("res://scenes/level_select/level_select_screen.tscn")
	Global.can_pause = true;
	get_tree().change_scene_to_packed(scene)
	
func input_accept():
	return Input.is_action_pressed("act_jump")

##flash text
func _on_timer_timeout():
	press_start.visible = !press_start.visible;
