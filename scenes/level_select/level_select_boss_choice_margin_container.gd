extends Control

@export var menuMaster: Node = null;
@export var level: int = 0;
@onready var hovering_sprite = $Portrait/Selected

var inputLock: bool = false;
var selection_hover = false;
var hover_timer = 0;
var hover_timer_max = 8;

func _ready():
	hovering_sprite.visible = false;

func _process(delta: float) -> void:
	if(inputLock): grab_focus() #really bad way of doing this
	
	if (!has_focus()):
		modulate = Color.DARK_GRAY;
		hover_timer = 0;
		hovering_sprite.visible = false;
		selection_hover = false;
		return;
	
	modulate = Color.WHITE
	flash_border();
	if(input_accept()):
		signal_enter_level(level);
	
func flash_border():
	if(hover_timer == 0):
		selection_hover = !selection_hover;
		hovering_sprite.visible = selection_hover
	hover_timer = (hover_timer + 1) % hover_timer_max
	
func input_accept():
	return Input.is_action_pressed("act_jump")
	
func signal_enter_level(level):
	#check if level valid
	if level < 1 or level > 9: return;
	#signal level transition
	if (menuMaster == null): return
	print("signal_enter_level");
	inputLock = true;
	menuMaster.enter_level(level);
	
