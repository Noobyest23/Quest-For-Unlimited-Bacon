extends Camera3D

class_name cameraMovement

@onready var player : playerClass = get_parent().get_parent()

const SENS : float = 0.008

const BOB_FREQ : float = 2
const BOB_HEIGHT : float = 0.1
var t_bob = 0.0

var defaultFOV : float = 90
const FOV_CHANGE : float = 2

const WALL_TILT_AMOUNT : float = 25.0
const WALL_TILT_SPEED : float = 2.0

func _input(event):
	#Normal Mouse Movement Stuff
	if event is InputEventMouseMotion:
		player.rotate_y(-event.relative.x * SENS)
		rotate_x(-event.relative.y * SENS)
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
	
	#Capturing the mouse
	elif event.is_action_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	elif event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	fov = defaultFOV

func _process(delta):
	#Head bob
	if not player.sliding:
		t_bob += delta * player.velocity.length() * float(player.is_on_floor())
		transform.origin = _headBob(t_bob)
	
	#FOV change
	var velocity_clamped = clamp(player.velocity.length(), 0.5, player.WALLRUN_SPEED * 2)
	var target_fov = defaultFOV + FOV_CHANGE * player.velocity.length()
	
	fov = lerp(fov, target_fov, delta * 8.0)
	
	#WallRun Tilt
	if player.is_on_wall_only():
		var wallNormal = player.get_wall_normal()

func _headBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_HEIGHT
	pos.x = cos(time * BOB_FREQ / 2) * BOB_HEIGHT
	return pos

func _tilt(normal : Vector3):
	var approach_dir = player.velocity.normalized()
	
	var dot_product = normal.dot(approach_dir)
	
	var tiltSide = WALL_TILT_AMOUNT
	
	# Flip wall forward if the player approaches from the opposite direction
	if dot_product < 0:
		tiltSide = -tiltSide
	
	
	rotate(Vector3(0, 0, 1), tiltSide)
	await player.endWallRun
	rotate(Vector3(0, 0, 1), -tiltSide)