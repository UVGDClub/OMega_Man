class_name Enemy extends StateEntity2D

const EXPLOSION_PARTICLE = preload("res://objects/explosion_particle.tscn")

const DEATH_SMALL = preload("res://sfx/temp/enemy/death_small.ogg")
const DEFLECT = preload("res://sfx/temp/enemy/deflect.ogg")
const HIT = preload("res://sfx/temp/enemy/hit.ogg")

@export var detection_area:Area2D = null;
@export var sprite:Sprite2D = null;

var health = 3;
var facing = -1;
var SPAWNER_INSTANCE:int = -1;

## handles the death particle and drop item logic.
func handle_death():
	if(health <= 0): 
		SoundManager.playSound(DEATH_SMALL);
		#do explosion
		var explode: GPUParticles2D = EXPLOSION_PARTICLE.instantiate()
		explode.one_shot = true;
		explode.position.y -= 8
		add_sibling(explode)
		explode.position = position + Vector2(0,-8)
		
		#drop item maybe
		var item_chance = randi_range(1,100);
		if(item_chance <= 25):
			var item_type = randi_range(0,2);
			var size = randi_range(0,1);
			var item = ITEM_PICKUP.instantiate()
			item.item_type = item_type;
			item.size = size;
			item.onTimer = true;
			add_sibling(item);
			item.position = position + Vector2(0,-8);
			
		handle_despawn();

## adds gravity to velocity when airborne	
func handle_gravity(delta):
	# Add the gravity.
	if(ignore_gravity): return
	if not is_on_floor():
		velocity.y += gravity * delta

## When called, automatically updates facing to point in the direction of the player.
## If a valid Sprite2D is passed, this will automatically flip the sprite to face the player. 
func face_player():
	if(Global.player == null): return
	if(Global.player.position.x > position.x):
		facing = 1;		
	else: facing = -1;
	if(sprite != null):
		sprite.flip_h = facing < 0;
	
	
## returns true if the player is inside the Area2d provided for Detection Area.
## returns false otherwise, or if there is no area2d provided.
func detect_player():
	if (detection_area == null): 
		printerr("Detection Area is null! Provide a valid Area2D!!")
		return false
	var detect = detection_area.get_overlapping_bodies()
	for body:Node2D in detect:
		if body.is_in_group("player"): 
			return true
	return false;

#TODO logic for weapon immunity and return false
func try_damage(dmg):
	health -= dmg;
	SoundManager.playSound(HIT)
	return true;

##called by enemy_spawner
func connect_with_spawner(spawner_ID):
	SPAWNER_INSTANCE = spawner_ID;
	var test = instance_from_id(SPAWNER_INSTANCE);
	assert(test.ENEMY_INST_ID == self.get_instance_id())
	pass

##frees the enemy, and handles any spawner communication if needed
func handle_despawn():
	if(is_instance_id_valid(SPAWNER_INSTANCE)):
		var spawner = instance_from_id(SPAWNER_INSTANCE);
		assert(is_instance_valid(spawner))
		#spawner.ENEMY_INST_ID = -1; #not needed
	queue_free();

func _on_tree_exiting():
	pass
