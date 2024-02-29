extends MarginContainer

@onready var portrait_curr = $VBoxContainer/Portrait

func _process(delta: float) -> void:
	if has_focus():
		modulate = Color.WHITE
	else:
		modulate = Color.DARK_GRAY
