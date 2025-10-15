extends CanvasLayer

signal ready_spawn_player

func _ready():
	pass

func _on_lifetime_timeout():
	ready_spawn_player.emit()
	queue_free()

func _on_blink_timeout():
	visible = !visible;
