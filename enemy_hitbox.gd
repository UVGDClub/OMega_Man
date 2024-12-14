extends Area2D

@export var damage: int = 1;

enum MODE {CONTACT, PROJECTILE}
@export var hitbox_mode: MODE

var timer = -1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(hitbox_mode == MODE.CONTACT): timer = -1;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func handle_death():
	if(hitbox_mode == MODE.CONTACT):return
	if(timer == -1): return
	if(timer == 0): queue_free()
	timer -= 1;

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("group_player")):
		print("attempt to hit player");
		body.try_damage(damage)
		#body.state_forceExit(body.state_Damage)
