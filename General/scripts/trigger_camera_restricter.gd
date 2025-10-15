extends Area2D

@onready var label = $Label
@export var restrict_to_area:= Vector2(-1,-1);
# Called when the node enters the scene tree for the first time.
func _ready():
	label.visible = get_tree().debug_collisions_hint
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if(not body.is_in_group("player")): return
	Global.camera.restrict_x = restrict_to_area
