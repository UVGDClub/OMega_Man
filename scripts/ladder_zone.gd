extends Area2D

const LADDER_ZONE_TOP = preload("res://scenes/ladder_zone_top.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var ladder_top = LADDER_ZONE_TOP.instantiate()
	#note: call_deferred necessary otherwise it fails
	add_sibling.call_deferred(ladder_top)
	ladder_top.position = position
	assert(ladder_top.position == position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	print("Body: " + str(body))
	if(body.is_in_group("group_player")):
		print("laddur")
		body.detect_ladder = true;
		body.ladder_inst = self; #pass a reference to this ladder so the player can snap to its center
		
func _on_body_exited(body):
	if(body.is_in_group("group_player")):
		body.detect_ladder = false;
		body.ladder_inst = null;
