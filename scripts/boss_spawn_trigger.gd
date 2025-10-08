extends Area2D

var spawned_boss:bool = false;

func _ready():
	hide();

func _process(delta):
	if(Global.boss_door_anim):return;
	if(spawned_boss): return;
	var bodies = get_overlapping_bodies();
	for body in bodies:
		if body is Player:
			Global.player.has_control = false; # lock player until boss finished intro
			Global.spawn_boss.emit();
			spawned_boss = true;
			SoundManager.playMusic(Global.BOSS_THEME,0.25)
