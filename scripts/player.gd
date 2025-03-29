class_name Player
extends StateEntity2D
#0  #1  #2...  #8
enum WEAPON { NORMAL, POWER1, POWER2, POWER3, POWER4, POWER5, POWER6, POWER7, POWER8 }
enum ANIM {
	IDLE, INCH, RUN, AIR, LADDER, LADDER_TOP, SLIDE, TELEPORT, TELEPORT_FINISH, DAMAGE, STUN
}

#CONSTANTS
const SPEED = 100.0
const SPEED_LADDER = 1.0
const JUMP_VELOCITY = -300.0
const FRICTION = 45.0
const LADDER_ZONE = preload("res://objects/ladder_zone.tscn")
const BULLET_SOURCE = preload("res://objects/bullet_player_basic.tscn")
#REFERENCES

#debug
var debug_slow_mo = 1

#WEAPON STATE
var weapon_state = WEAPON.NORMAL

# format -- NAME:[MAX AMMOUNT, WEAPON COST, LIMIT]
var weapon_stats: Dictionary = {
	WEAPON.NORMAL: [24, 0, 3],
	WEAPON.POWER1: [24, 1, 1],
	WEAPON.POWER2: [24, 1, 1],
	WEAPON.POWER3: [24, 1, 1],
	WEAPON.POWER4: [24, 1, 1],
	WEAPON.POWER5: [24, 1, 1],
	WEAPON.POWER6: [24, 1, 1],
	WEAPON.POWER7: [24, 1, 1],
	WEAPON.POWER8: [24, 1, 1]
}

#ANIMATION STATE
var anim_state = ANIM.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

#stats
var max_health = 24
var max_ammo = 24
var health = max_health
var ammo = 24
var bullets_left = 3
var bullet_limit = bullets_left

# State Related Variables
var facing = 1
var inch_timer_max = 7
var inch_timer = inch_timer_max
var jump_height_timer_max = 15
var jump_height_timer = jump_height_timer_max
var damage_angle = 0  #radians
var ignore_friction = false
var ignore_gravity = false
var ignore_movement = false
var can_shoot = true
var shoot_anim_timer: int = 0
var shoot_anim_timer_max: int = 15
var detect_ladder = false
var ladder_inst = null
var in_camera_transition_trigger: Area2D = null

#INPUT RELATED
var has_control = true
var input_move: Vector2
var input_shoot: bool
var input_jump: bool
var input_jump_press: bool
var locked_directional_input := Vector2.ZERO

#COOLDOWNS
var i_frames: int = 0
var dash_cooldown_max: int = 30
var dash_cooldown: int = 0
var jump_cooldown: int = 0
var shoot_cooldown_max: int = 5
var shoot_cooldown: int = 0

#OFFSETS
var bullet_offset: Vector2 = Vector2.ZERO

#region STATE LIST
var state_idle = func():
	_stateID = "Idle"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = -1
	stateNext = null  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.IDLE)
		ignore_movement = true
		bullet_offset = Vector2(21, -13)

	main = func():  # run continuously
		if (input_move.x) != 0:
			if inch_timer == inch_timer_max:
				position.x += (input_move.x)
				update_facing()
			inch_timer -= 1
		else:
			inch_timer = inch_timer_max

	onLeave = func():  # run only when the state is changed. may not be necessary
		ignore_movement = false
		inch_timer = inch_timer_max

	exitConditions = func():
		if !is_on_floor():
			state_forceExit(state_air)
		if inch_timer == 0:
			state_forceExit(state_run)
		var slide = ((input_move.y) == -1) && input_jump_press
		if slide:
			state_forceExit(state_slide)
		if try_climb_ladder():
			state_forceExit(state_ladder)

var state_run = func():
	_stateID = "Run"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = -1
	stateNext = null  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.RUN)
		bullet_offset = Vector2(21, -13)

	main = func(): pass  # run continuously

	onLeave = func(): pass  # run only when the state is changed. may not be necessary

	exitConditions = func():
		if !is_on_floor():
			state_forceExit(state_air)
		if (input_move.x) == 0:
			state_forceExit(state_idle)
		var slide = ((input_move.y) == -1) && input_jump_press
		if slide:
			state_forceExit(state_slide)
		if try_climb_ladder():
			state_forceExit(state_ladder)

var state_air = func():
	_stateID = "Air"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = -1
	stateNext = null  # normal exit
	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.AIR)
		bullet_offset = Vector2(18, -16)

	main = func(): pass  # run continuously

	onLeave = func(): pass  # run only when the state is changed. may not be necessary

	exitConditions = func():
		if is_on_floor():
			if (input_move.x) != 0:
				state_forceExit(state_run)
			else:
				state_forceExit(state_idle)
		if try_climb_ladder():
			state_forceExit(state_ladder)

var state_ladder = func():
	_stateID = "Ladder"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = -1
	stateNext = null  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.LADDER)
		bullet_offset = Vector2(18, -16)
		ignore_gravity = true
		ignore_movement = true
		if is_on_floor():
			position.y -= 4
		position.x = ((ladder_inst.position.x) + 8)

	main = func():  # run continuously
		velocity = (Vector2.ZERO)
		if abs(input_move.x):
			facing = (input_move.x)  #for shooting

		animation_player.speed_scale = 0
		anim_state = (ANIM.LADDER)

		#dont climb when shooting
		if shoot_anim_timer:
			input_move = (Vector2.ZERO)

		if input_move != (Vector2.ZERO):
			#position.x += input_move.x * SPEED_LADDER # subtract cause up in grid is negative
			position.y -= ((input_move.y) * SPEED_LADDER)  # subtract cause up in grid is negative
			animation_player.speed_scale = 1

		if ladder_inst != null:
			var top_dist = abs((position.y) - (ladder_inst.position.y))
			if top_dist < 16:
				anim_state = (ANIM.LADDER_TOP)

	onLeave = func():  # run only when the state is changed. may not be necessary
		animation_player.speed_scale = 1
		ignore_gravity = false
		ignore_movement = false

	exitConditions = func():
		if is_on_floor() && ((input_move.y) == -1):
			state_forceExit(state_idle)
		if input_jump_press:
			state_forceExit(state_air)
		if !detect_ladder:
			state_forceExit(state_air)

var state_slide = func():
	_stateID = "Slide"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 20
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.SLIDE)
		input_jump_press = false  #reset input
		ignore_friction = true
		ignore_movement = true
		jump_cooldown = 5

	main = func():  # run continuously
		velocity.x = (facing * SPEED * 2)
		if stateTime == 1:
			#if there is a ceiling above us
			#increase state time by 1
			pass

	onLeave = func():  # run only when the state is changed. may not be necessary
		ignore_friction = false
		ignore_movement = false

	exitConditions = func():
		var jump = (Input.is_action_just_pressed("act_jump")) && (jump_cooldown == 0)
		if jump || !is_on_floor():
			state_forceExit(state_air)
		if Input.is_action_just_pressed("act_shoot"):
			state_forceExit(state_damage)

var state_teleport_enter = func():
	_stateID = "Teleport_enter"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 4
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.TELEPORT)
		ignore_friction = true
		ignore_gravity = true
		ignore_movement = true
		return

	main = func():  # run continuously
		velocity.x = 0
		if !is_on_floor():
			stateTime = 5
			velocity.y = 490
		else:
			anim_state = (ANIM.TELEPORT_FINISH)
			velocity.y = 0

	onLeave = func():  # run only when the state is changed. may not be necessary
		ignore_friction = false
		ignore_gravity = false
		ignore_movement = false

	exitConditions = func(): pass

var state_teleport_leave = func():
	_stateID = "Teleport_leave"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 6
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.TELEPORT_FINISH)
		ignore_friction = true
		ignore_gravity = true
		ignore_movement = true

	main = func():  # run continuously
		velocity.y = 0
		velocity.x = 0
		if stateTime > 2:
			anim_state = (ANIM.TELEPORT_FINISH)
		else:
			stateTime += 1
			anim_state = (ANIM.TELEPORT)
			position.y -= 20

	onLeave = func():  # run only when the state is changed. may not be necessary
		#should never get here
		ignore_friction = false
		ignore_gravity = false
		ignore_movement = false

	exitConditions = func(): pass

var state_damage = func():
	_stateID = "Damage"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 20
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.DAMAGE)
		has_control = false
		ignore_friction = true

		i_frames = 90
		velocity.y = 0
		var angle = Vector2(1, 0).rotated(damage_angle)
		velocity.x = (SPEED / 2 * angle.x)

	main = func(): pass  # run continuously

	onLeave = func():  # run only when the state is changed. may not be necessary
		has_control = true
		ignore_friction = false
		damage_angle = 0

	exitConditions = func():
		if health <= 0:
			state_forceExit(state_death)

var state_stun = func():
	_stateID = "Stun"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 30
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.STUN)
		has_control = false

	main = func(): pass  # run continuously

	onLeave = func(): has_control = true  # run only when the state is changed. may not be necessary

	exitConditions = func(): pass

var state_death = func():
	_stateID = "Death"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 180
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.STUN)
		has_control = false

	main = func(): pass  # run continuously

	onLeave = func():  # run only when the state is changed. may not be necessary
		Global.handle_player_death()
		has_control = true

	exitConditions = func(): pass

var state_special = func():
	_stateID = "Special"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 61
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.STUN)
		has_control = false

	main = func(): rotation += 15  # run continuously

	onLeave = func():  # run only when the state is changed. may not be necessary
		has_control = true
		rotation = 0

	exitConditions = func():
		if stateTime == 1:
			if (position.y) > 150:
				state_forceExit(state_stun)
			else:
				state_forceExit(state_special2)

var state_special2 = func():
	_stateID = "Special"
	# how long should the state run for. set to -1 if the state does not have a timed end
	stateTime = 20
	stateNext = state_idle  # normal exit

	onEnter = func():  # run once, on entering the state. may not be necessary
		anim_state = (ANIM.STUN)
		has_control = false

	main = func(): position.y -= 15  # run continuously

	onLeave = func(): has_control = true  # run only when the state is changed. may not be necessary

	exitConditions = func(): pass
#endregion

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var center = $center

@onready var world = $"../.."


func _ready():
	state = state_teleport_enter
	state.call()
	Global.player_spawn.emit(self)


func _physics_process(delta: float) -> void:
	debug_handle_slowmo()
	if camera_is_scrolling():
		pass  #dont update if camera transition
	handle_cooldowns()

	get_input()
	stateDriver()

	#print(state.hash())
	handle_weapon_swtich()
	handle_gravity(delta)
	handle_movement()
	handle_friction()
	handle_jump(delta)
	handle_shoot()

	update_animation()

	move_and_slide()  # necessary to update the character body
	#position = position.round()
	queue_redraw()  # necessary for updating draws calls in-script


func _draw():
	sprite_2d.visible = true
	if i_frames > 0:
		if i_frames % 2:
			sprite_2d.visible = false
	#draw_circle(Vector2.ZERO,50,Color.RED);


func update_facing(override: int = 0):
	if override != 0:
		facing = override
		return
	facing = (input_move.x)


func handle_movement():
	if ignore_movement:
		return
	if input_move.x:
		update_facing()
		if _stateID == "Slide":
			return
		velocity.x = (facing * SPEED)


func debug_handle_slowmo():
	if Input.is_action_just_pressed("debug_slowmo"):
		debug_slow_mo *= -1
		print("AH")
	if debug_slow_mo == 1:
		Engine.set_time_scale(1)
		Engine.max_fps = 60
	else:
		var guh: float = 1.0 / 60.0
		Engine.max_fps = 1
		Engine.set_time_scale(guh)


func handle_friction():
	if ignore_friction:
		return
	if input_move.x:
		return
	velocity.x = move_toward(velocity.x, 0, FRICTION)


func get_input():
	if has_control:
		input_move.x = (Input.get_axis("move_left", "move_right"))
		input_move.y = (Input.get_axis("move_down", "move_up"))
		input_shoot = (Input.is_action_just_pressed("act_shoot"))
		input_jump = (Input.is_action_pressed("act_jump"))
		input_jump_press = (Input.is_action_just_pressed("act_jump"))
		# Objects such as the Camera Panner may lock one input temporarily
		# to prevent bugs from occuring.
		if locked_directional_input != (Vector2.ZERO):
			match locked_directional_input:
				(Vector2.UP):
					if (input_move.y) > 0:
						input_move.y = 0
				(Vector2.DOWN):
					if (input_move.y) < 0:
						input_move.y = 0
				(Vector2.LEFT):
					if (input_move.x) < 0:
						input_move.x = 0
				(Vector2.RIGHT):
					if (input_move.x) > 0:
						input_move.x = 0
	else:
		input_move.x = 0
		input_move.y = 0
		input_shoot = false
		input_jump = false
		input_jump_press = false


func handle_gravity(delta):
	# Add the gravity.
	if ignore_gravity:
		return
	if not is_on_floor():
		velocity.y += (gravity * delta)


func handle_weapon_swtich(menu_target = null):
	if menu_target != null:
		if (menu_target < 0) || (menu_target > 8):
			weapon_state = menu_target
			return

	var input_switch = (
		int(Input.is_action_just_pressed("weapon_switch_right"))
		- int(Input.is_action_just_pressed("weapon_switch_left"))
	)

	if input_switch == 0:
		return

	var next_weapon = weapon_state + input_switch
	#roll_over
	if next_weapon > 8:
		next_weapon = 0
	if next_weapon < 0:
		next_weapon = 8
	#save current ammo
	weapon_stats[weapon_state][0] = ammo

	# use a while loop to scroll the next available unlocked weapon
	while (Global.player_weapon_unlocks[next_weapon]) == false:
		next_weapon += input_switch
		#roll_over
		if next_weapon > 8:
			next_weapon = 0
		if next_weapon < 0:
			next_weapon = 8
		if next_weapon == weapon_state:
			# edgecase: scrolled through every weapon, and we didnt find a new one
			# should only happen when we have one weapon
			print("you got nothing, son")
			return

	#load new weapon ammo and limit
	weapon_state = next_weapon
	ammo = weapon_stats[weapon_state][0]
	bullet_limit = weapon_stats[weapon_state][2]
	bullets_left = bullet_limit


func handle_shoot():
	if shoot_cooldown != 0:
		return
	if !input_shoot:
		return
	if bullets_left <= 0:
		return
	shoot_cooldown = shoot_cooldown_max
	shoot_anim_timer = shoot_anim_timer_max

	match weapon_state:
		WEAPON.NORMAL:
			# shoot projectile
			var bullet = BULLET_SOURCE.instantiate()
			bullets_left -= 1
			bullet.set_velocity(facing)
			bullet.position = (position + Vector2(facing * (bullet_offset.x), bullet_offset.y))
			world.add_child(bullet)
		_:
			if ammo == 0:
				return
			ammo -= weapon_stats[weapon_state][1]
			#TODO shoot whatever weapon projectile is needed


func handle_jump(_delta):
	# Handle jump.
	if jump_cooldown:
		return
	if is_on_floor() && input_jump_press:
		jump_height_timer = jump_height_timer_max
		velocity.y = JUMP_VELOCITY
	#if(jump_height_timer > jump_height_timer_max-5):
	#velocity.y = JUMP_VELOCITY * (jump_height_timer_max-jump_height_timer+9)/jump_height_timer_max
	if !is_on_floor() && jump_height_timer:
		#if jumped, and released the jump button quick enough, stop ascending
		if Input.is_action_just_released("act_jump"):
			velocity.y = 0
			jump_height_timer = 0
			return


func try_climb_ladder() -> bool:
	if detect_ladder:
		if is_on_floor():
			if (input_move.y) == 1:
				return true
			return false
		if abs(input_move.y):
			return true
	return false


func try_damage(dmg, _angle = 0):
	if i_frames != 0:
		return
	print("+++ player took damage +++")
	damage_angle = (PI * facing * -1)
	health -= dmg
	state_forceExit(state_damage)


#TODO make the health and ammo gain incremental like classic megaman
func try_gain_health(amt):
	if health == max_health:
		return
	health += amt
	if health > max_health:
		health = max_health


func try_gain_ammo(amt):
	if ammo == max_ammo:
		return
	ammo += amt
	if ammo > max_ammo:
		ammo = max_ammo


## used by projectiles when they destroy themselves
func try_restock_bullet(type: WEAPON):
	if type != weapon_state:
		return
	if bullets_left == bullet_limit:
		return
	bullets_left += 1


func gain_extra_life():
	Global.playerLives += 1


#kill player
func event_death():
	#TODO
	# spawn some particle system to get the same death effect
	state_forceExit(state_death)


func camera_is_scrolling():
	return Global.camera.camera_page_screen_active


func handle_cooldowns():
	if i_frames:
		i_frames -= 1
	if shoot_cooldown > 0:
		shoot_cooldown -= 1
	if shoot_anim_timer:
		shoot_anim_timer -= 1
	if jump_cooldown:
		jump_cooldown -= 1
	if jump_height_timer:
		jump_height_timer -= 1


func leave_stage():
	has_control = false
	await (get_tree().create_timer(2.0).timeout)
	state_forceExit(state_teleport_leave)
	await (get_tree().create_timer(2.0).timeout)
	get_tree().change_scene_to_file("res://scenes/weapon_unlock/weapon_unlock.tscn")


func update_animation():
	sprite_2d.scale.x = facing
	match anim_state:
		ANIM.IDLE:
			if shoot_anim_timer:
				match weapon_state:
					(WEAPON.NORMAL):
						animation_player.play("idle_shoot")
					_:
						animation_player.play("idle_shoot_palm")
			elif (input_move.x) != 0:
				animation_player.play("run_inch")
			else:
				animation_player.play("idle")
		ANIM.RUN:
			if shoot_anim_timer:
				animation_player.play("run_shoot")
			else:
				animation_player.play("run")
		ANIM.AIR:
			if shoot_anim_timer:
				match weapon_state:
					(WEAPON.NORMAL):
						animation_player.play("air_shoot")
					_:
						animation_player.play("air_shoot_palm")
			else:
				animation_player.play("air_neutral")
		ANIM.LADDER:
			if shoot_anim_timer:
				match weapon_state:
					(WEAPON.NORMAL):
						animation_player.play("ladder_shoot")
					_:
						animation_player.play("ladder_shoot_palm")
			else:
				animation_player.play("ladder")
		(ANIM.LADDER_TOP):
			animation_player.play("ladder_top")
		ANIM.SLIDE:
			animation_player.play("slide")
		ANIM.TELEPORT:
			animation_player.play("teleport")
		(ANIM.TELEPORT_FINISH):
			animation_player.play("teleport_finish")
		ANIM.DAMAGE:
			animation_player.play("damage")
		ANIM.STUN:
			animation_player.play("stun")
		_:
			animation_player.play("idle")
