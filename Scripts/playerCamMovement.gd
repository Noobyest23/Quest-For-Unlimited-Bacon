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
	var target_fov = defaultFOV + FOV_CHANGE * player.velocity.length()
	
	fov = lerp(fov, target_fov, delta * 8.0)
	

func _headBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_HEIGHT
	pos.x = cos(time * BOB_FREQ / 2) * BOB_HEIGHT
	return pos
