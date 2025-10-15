extends Node2D

@onready var enemy_hitbox = $enemy_hitbox

var velocity:Vector2
var damage:int = 1;

func _ready():
	enemy_hitbox.damage = damage;
	
func _process(delta) -> void:
	position += velocity*delta;

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free();
