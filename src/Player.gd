extends KinematicBody

signal orb_collected

const GRAVITY = -24.8
const MAX_SPEED = 7
const ACCEL = 3.5
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

onready var collider = $Collider
onready var flashlight: SpotLight = $CameraPivot/Flashlight
onready var footsteps_player: AudioStreamPlayer = $Footsteps

var vel = Vector3()
var dir = Vector3()
var camera: Camera
var rotation_helper
var walking = false
var shake_amount = 0.01
var is_dying = false

var MOUSE_SENSITIVITY = 0.05

func _ready():
	randomize()
	camera = $CameraPivot/Camera
	rotation_helper = $CameraPivot
	
	collider.connect("area_entered", self, "on_area_entered")
	$Fader.connect("fade_finished", self, "_on_fade_finished")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if is_dying:
		shake_amount += 0.02 * delta
		camera.h_offset = rand_range(-1, 1) * shake_amount
		camera.v_offset = rand_range(-1, 1) * shake_amount
		return
		
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight.visible = !flashlight.visible

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	if input_movement_vector != Vector2.ZERO:
		walking = true
	else:
		walking = false

	if walking and !footsteps_player.playing:
		footsteps_player.play()

	if !walking and footsteps_player.playing:
		footsteps_player.stop()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func on_area_entered(area):
	if area.is_in_group("Orb"):
		area.queue_free()
		emit_signal("orb_collected")

func die():
	is_dying = true
	$Fader.set_fade_duration(5.0)
	$Fader.fade_out()

func _on_fade_finished():
	get_tree().change_scene("res://src/menu_components/MainMenu.tscn")
