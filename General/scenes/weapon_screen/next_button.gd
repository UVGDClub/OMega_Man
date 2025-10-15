extends Button

@onready var label = $Label
@onready var blinker = $blinker

const MENU_MOVE = preload("res://General/sfx/temp/menu/menu_move.ogg")
const MENU_SELECT = preload("res://General/sfx/temp/menu/menu_select.ogg")

func _ready():
	pass

func _on_pressed():
	SoundManager.playSound(MENU_SELECT)
	
func _on_focus_entered():
	SoundManager.playSound(MENU_MOVE)
	blinker.start();
	pass # Replace with function body.

func _on_focus_exited():
	blinker.stop()
	label.visible = true;
	pass # Replace with function body.

func _on_blinker_timeout():
	label.visible = !label.visible
