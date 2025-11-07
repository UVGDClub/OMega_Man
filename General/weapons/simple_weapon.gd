extends Weapon
class_name SimpleWeapon

@export var bullet_scene : PackedScene
##Only use this if your bullet doesn't spawn from the default offset
@export var bonus_offset : Vector2 = Vector2.ZERO
@export var sfx : AudioStream = preload("res://General/sfx/temp/player/shoot.ogg")

func shoot(player : Player) -> bool:
	if !super.shoot(player): return false
	if !bullet_scene: 
		push_error("Weapon has NULL bullet scene.")
		return false
	
	var World : Node2D = get_tree().get_first_node_in_group("World")
	var bullet : Node2D = bullet_scene.instantiate()
	
	if bullet.has_signal("bullet_despawn"):
		bullet.bullet_despawn.connect(bullet_has_despawned)
	else:
		push_warning("No bullet_despawn signal in the bullet scene spawned by current weapon")
	
	if bullet.has_method("set_velocity"):
		bullet.set_velocity(player.facing)
	else:
		push_warning("No bullet set_velocity method in the bullet scene spawned by current weapon")
	
	World.add_child(bullet)
	bullet.global_position = player.global_position + Vector2(player.facing * player.bullet_offset.x, player.bullet_offset.y)
	SoundManager.playSound(sfx)
	return true
