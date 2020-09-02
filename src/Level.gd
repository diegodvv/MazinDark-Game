extends Spatial

onready var monster = $GridMap/Monster
onready var player = $GridMap/Player
onready var orb_container = $GridMap/OrbContainer
var collected_orbs_count = 0
var total_orb_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	monster.set_target(player)

	total_orb_count = orb_container.get_child_count()
	player.connect("orb_collected", self, "on_orb_collected")

func on_orb_collected():
	collected_orbs_count += 1
	if collected_orbs_count >= total_orb_count:
		get_tree().change_scene("res://src/menu_components/MainMenu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
