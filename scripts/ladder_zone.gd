extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
