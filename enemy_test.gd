extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health = 3;
const EXPLOSION_PARTICLE = preload("res://scenes/explosion_particle.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ignore_gravity = false;

func _physics_process(delta):
	# Add the gravity.
	handle_gravity(delta);
	handle_death();

	move_and_slide()

func handle_death():
	if(health <= 0): 
		var explode: GPUParticles2D = EXPLOSION_PARTICLE.instantiate()
		explode.one_shot = true;
		explode.position.y -= 8
		
		add_child(explode)
		explode.reparent(get_parent()) #this is fucking stupid
		
		queue_free();
func handle_gravity(delta):
	# Add the gravity.
	if(ignore_gravity): return
	if not is_on_floor():
		velocity.y += gravity * delta

func try_damage(dmg):
	health -= dmg;
	return true;

func _on_tree_exiting():
	pass
