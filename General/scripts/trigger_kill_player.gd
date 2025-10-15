extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	print("Body: " + str(body))
	if(body.is_in_group("player")):
		print("kill player")
		body.event_death();
