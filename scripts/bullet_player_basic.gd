extends Area2D

# no need for anything fancy on the movement
var SPEED_DEFAULT = 200;
var SPEED = 0;
var velocity := Vector2.ZERO
var direction = 1;
var damage = 1;
var deathTimer = 120; # how long the instance will last in frames


# Called when the node enters the scene tree for the first time.
func _ready():
	set_velocity(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_movement(delta)
	handle_lifetime()


func set_velocity(dir, speed = SPEED_DEFAULT):
	direction = dir
	SPEED = speed
	velocity.x = direction * SPEED;

func handle_lifetime():
	if (deathTimer <= 0): handle_queue_free()
	deathTimer -= 1;
	pass

func handle_movement(delta):
	position += velocity * delta;

func handle_queue_free():
	Global.player.bullets_left += 1; 
	queue_free();
	

func _on_body_entered(body):
	if(body.is_in_group("enemy")):
		if(body.try_damage(damage)):
			handle_queue_free();
	#apply damage to enemy

func _on_screen_exited():
	handle_queue_free();
