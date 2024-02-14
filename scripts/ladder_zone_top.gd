extends StaticBody2D

@onready var platform = $platform
@onready var player_top_detection = $playerTopDetection

var player_inst: CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	platform.disabled = false;
	check_player_climb_down()
	pass



func check_player_climb_down():
	if(player_inst == null):return;
	if(!player_top_detection.overlaps_body(player_inst)): return
	if(player_inst.state == player_inst.state_Ladder): return
	if(player_inst.input_move.y == -1):
		platform.disabled = true;
	

func _on_player_top_detection_body_entered(body):
	if(body.is_in_group("group_player")):
		player_inst = body;
		print("laddur Top")
	
