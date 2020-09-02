extends ColorRect

signal fade_finished

onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.connect("animation_finished", self, "on_animation_finished")

func on_animation_finished(anim_name):
	emit_signal("fade_finished")
	
func fade_in():
	animation_player.play("fade_in")
	
func fade_out():
	animation_player.play("fade_out")
	
func set_fade_duration(duration_in_seconds: float):
	animation_player.playback_speed = 0.5 / duration_in_seconds
