extends Camera2D


var follow = null;
var lerpToY;

@onready var World = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lerpToY = position.y;
	Global.camera_spawn.emit(self)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	find_player();
	follow_instance_x();
	move_camera_vertical();


func move_camera_vertical():
	if(position.y == lerpToY): return;
	#Global.player.has_control = false;
	position.y = move_toward(position.y,lerpToY,2);
	pass
	
func set_camera_position(newX,newY):
	position.x = newX;
	position.y = newY;
	lerpToY = position.y
	
func camera_move_up():
	lerpToY = position.y - 240;	
	
func follow_instance_x():
	if(follow == null): return;
	position.x = follow.position.x;
	print("follow:" + str(follow));
	
func find_player():
	if(follow != null): return;
	#search for player
	follow = Global.player;
