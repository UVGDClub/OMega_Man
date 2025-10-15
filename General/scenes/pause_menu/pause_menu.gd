extends CanvasLayer

@onready var resume = $menu/resume
@onready var options = $menu/options
@onready var quit = $menu/quit

func _ready():
	hide();
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.on_pause_game.connect(_on_pause);
	pass;

func _on_pause(paused):
	visible = paused;
	resume.grab_focus();

func _on_resume_pressed():
	Global.toggle_pause();
	pass # Replace with function body.

func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	SoundManager.stop_music()
	get_tree().change_scene_to_file("res://General/scenes/level_select/level_select_screen.tscn")
	Global.toggle_pause();
