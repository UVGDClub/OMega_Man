extends Control

@onready var boss_sprite:Sprite2D = $BossSprite
@onready var boss_marker = $BossMarker
@onready var boss_name:Label = $"Boss Name"
@onready var stars = $stars

var next_level:PackedScene;
var name_to_type:String = "MAN MAN THE GREAT";
var drop_speed = 4.0;
var charTimer = 4;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	boss_sprite.offset.y = -boss_sprite.texture.get_size().y/2 #snap anchor to bottom center
	if(!Global.next_level_name.is_empty()):
		name_to_type = Global.next_level_name;
	boss_name.text = name_to_type;
	boss_name.visible = false; #HACK see hack_adjust_boss_name()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hack_adjust_boss_name();
	
	move_boss_to_marker();
	if(abs(boss_sprite.position.y - boss_marker.position.y) < 0.001):
		reveal_stars();
	if(abs(stars.modulate.a - 1.0) < 0.001):
		do_boss_animation()
		type_boss_name()

func move_boss_to_marker():
	boss_sprite.position.y = move_toward(boss_sprite.position.y, boss_marker.position.y, drop_speed)
	
func reveal_stars():
	stars.modulate.a = move_toward(stars.modulate.a, 1.0, 0.05)

func do_boss_animation():
	#boss does an animation that looks cool
	pass
	
func type_boss_name():
	if(charTimer):
		charTimer -=1;
		return;
	if(boss_name.text.length() != name_to_type.length()):
		var index = boss_name.text.length()
		boss_name.text += name_to_type.substr(index,1)
		charTimer = 4;

#this is really dumb but here we go:
#megaman 2 style intros have the name centered, but type from left to right.
#and every boss is going to have a different name of potentially different lengh.
#So we pass label what the name is going to be in _ready(),
#but we can't adjust it until its size updates, which you can't do through code
#so we set visible to fasle, it renders after _ready(), and it updates its size automatically
#we can now move the label over half its length
#so that the name will type perfectly centered, from left ot right
func hack_adjust_boss_name():
	#NOTE for this to work properly, the label anchor must be on the LEFT
	if(boss_name.visible == true): return; #do this only once
	#boss_name.update_minimum_size() #doesnt work
	#boss_name.force_update_transform() #doesnt work!
	boss_name.position.x -= boss_name.size.x/2;
	boss_name.text = ""
	boss_name.visible = true;


func load_level(level):
	#this assumes it's passed good input!!
	match(level):
		1: next_level = load("res://scenes/level_1.tscn");
		2: pass;
		3: pass;
		4: pass;
		5: pass;
		6: pass;
		7: pass;
		8: pass;
		9: pass;
		10: next_level = load("res://scenes/level_test.tscn");

#go to level
func _on_timer_timeout():
	load_level(Global.curr_level)
	if(next_level == null):
		printerr("next_level is INVALID!")
		return;
	get_tree().change_scene_to_packed(next_level)
