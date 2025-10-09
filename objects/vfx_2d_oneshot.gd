extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.animation_finished.connect(on_finished);
	animated_sprite_2d.play("default");

func on_finished():
	queue_free()
