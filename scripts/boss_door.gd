extends Node2D
@onready var trigger = $TriggerCameraPan
@onready var door_defualt = $DoorDefualt


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.camera.end_pan.connect(_on_camera_end_pan)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_camera_end_pan():
	door_defualt.visible = true;

func _on_trigger_camera_pan_player_entered(velocity):
	var nudgeX = trigger.player_center_to_trigger_center() + 8
	Global.camera.camera_page_screen_horizontally(sign(velocity.x),nudgeX)
	door_defualt.visible = false;
