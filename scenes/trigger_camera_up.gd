extends Area2D


var activated = false
@onready var World = $"../.."

enum AXIS {Y_AXIS, X_AXIS}
@export var transition_axis: AXIS


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if(!body.is_in_group("group_player")): return;
	if(activated): return;
	var direction = body.velocity
	var input = body.input_move;
	#when we hit a volue, check velocity, and lerp that way.
	#if no velocity, check for input and imply velocity
	if(transition_axis == AXIS.Y_AXIS):
		if(sign(direction.y) != 0):
			Global.camera.camera_lerp_Y(sign(direction.y));
		elif(sign(input.y) != 0):
			Global.camera.camera_lerp_Y(sign(-input.y));
	if(transition_axis == AXIS.X_AXIS):
		if(sign(direction.x) != 0):
			Global.camera.camera_lerp_X(sign(direction.x));
		elif(sign(input.x) != 0):
			Global.camera.camera_lerp_X(sign(input.x));
			
	activated = true;


func _on_body_exited(body):
	if(!body.is_in_group("group_player")): return;
	activated = false
