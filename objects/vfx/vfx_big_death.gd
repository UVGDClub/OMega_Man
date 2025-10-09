extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D

var tint:Color = Color.WHITE
var velocity:Vector2;

func _ready():
	animated_sprite_2d.play("default")
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	animated_sprite_2d.modulate = tint;

func _process(delta):
	position += velocity;
