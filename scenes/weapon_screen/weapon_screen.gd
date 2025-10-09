extends CanvasLayer

@onready var weapon_normal = $border/inside/page_1/weapon_O
@onready var weapon_1 = $border/inside/page_1/weapon_1
@onready var weapon_2 = $border/inside/page_1/weapon_2
@onready var weapon_3 = $border/inside/page_1/weapon_3
@onready var weapon_4 = $border/inside/page_1/weapon_4
@onready var weapon_5 = $border/inside/page_1/weapon_5
@onready var weapon_6 = $border/inside/page_2/weapon_6
@onready var weapon_7 = $border/inside/page_2/weapon_7
@onready var weapon_8 = $border/inside/page_2/weapon_8

@onready var page_1 = $border/inside/page_1
@onready var page_2 = $border/inside/page_2

@onready var next = $border/inside/next

var weapons:Array;
var pages:Array;
var page:int = 0;
var page_max:int = 2;

func _ready():
	hide();
	process_mode = Node.PROCESS_MODE_ALWAYS;
	Global.on_weapon_screen.connect(_on_weapon_toggle);
	weapons = [weapon_normal, weapon_1, weapon_2, weapon_3, weapon_4, 
				weapon_5, weapon_6, weapon_7, weapon_8];
	pages = [page_1, page_2];

func update_screen():
	#set ammo count for all weapons
	for i in range(len(weapons)):
		var tint = Global.player.weapon_stats[i][3];
		var value = Global.player.weapon_stats[i][0];
		#set the P weapon to be player health
		if(i==0):
			weapon_normal.set_ammo(Global.player.health,tint);
			continue;
		var unlocked = Global.player_weapon_unlocks[i][0];
		if(!unlocked): 
			weapons[i].hide();
			continue;
		weapons[i].show();
		weapons[i].set_ammo(value,tint);
	
func goto_next_page():
	for i in page_max:
		pages[i].hide();
		if(i == page):
			pages[i].show()
			#pages[i].get_child(0).grab_focus();

func _on_weapon_toggle(toggle):
	visible = toggle;
	if(toggle == true):
		update_screen()
		next.grab_focus();
	
func _on_next_pressed():
	page = (page + 1) % page_max;
	goto_next_page();
