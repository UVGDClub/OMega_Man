extends MarginContainer

@export var menuMaster: Node = null;
@export var level: int = 0;

func _process(delta: float) -> void:
	if (!has_focus()):
		modulate = Color.DARK_GRAY;
		return;
		
	modulate = Color.WHITE
	if(input_accept()):
		signal_enter_level(level);
	
func input_accept():
	return Input.is_action_pressed("act_jump")
	
func signal_enter_level(level):
	#check if level valid
	if level < 1 or level > 9: return;
	#signal level transition
	if (menuMaster == null): return
	print("signal_enter_level");
	menuMaster.enter_level(level);
	
