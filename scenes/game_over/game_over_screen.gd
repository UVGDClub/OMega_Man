extends Control

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	Global.playerLives = 2;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/Title Screen/title_screen.tscn")
