class_name BossDoor extends StaticBody2D
@onready var trigger = $TriggerCameraPan
@onready var door_defualt = $DoorDefualt
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D
@export var last_door:bool = false;

var player_direction;
var active:bool = false;
var locked:bool = false;

##flow:
## player touches door, player freezes
## door plays open animation
## camera pans into room
## door closes
## player unfreezes

func _ready():
	Global.camera.end_pan.connect(_close_door)
	collision_shape_2d.disabled = true;
	pass # Replace with function body.

func _process(_delta):
	pass

func _on_trigger_camera_pan_player_entered(velocity):
	if(locked):return;
	active = true;
	Global.boss_door_anim = true; #locks player until anim finished.
	player_direction = velocity
	_open_door();

func do_camera_pan(velocity):
	var nudgeX = trigger.player_center_to_trigger_center() + 8
	Global.camera.camera_page_screen_horizontally(sign(velocity.x),nudgeX)

func _open_door():
	animation_player.play("door_open");
	pass

##done when the pan ends
func _close_door():
	if(!active):return #dont play if im not the door that was touched.
	animation_player.play("door_close")
	if last_door: 
		collision_shape_2d.disabled = false;
		locked = true;
	pass

func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "door_open"):
		do_camera_pan(player_direction);
	if(anim_name == "door_close"):
		Global.boss_door_anim = false;
		active = false;
			
