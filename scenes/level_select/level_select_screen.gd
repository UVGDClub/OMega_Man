extends Control
@onready var omega = $GridContainer/Omega

func _ready():
	omega.grab_focus()
