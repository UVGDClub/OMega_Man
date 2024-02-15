extends Control
@onready var moog_man: MarginContainer = $GridContainer/MoogMan

func _ready():
	moog_man.grab_focus()
