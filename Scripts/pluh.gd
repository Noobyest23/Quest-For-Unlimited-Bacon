extends CharacterBody3D

class_name enemy

var speed = 2.0
const WALK_SPEED = 2.0
const CHASE_SPEED = 6.0
const JUMP_VELOCITY = 4.5

@onready var pluh : AudioStreamPlayer3D = $pluh
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var player : playerClass = get_parent().get_child(0)
@onready var idleTimer : Timer = $IdleTimer
@onready var playerSeek : RayCast3D = $PlayerSeek
@onready var damageable : Damageable = $Damageable
@onready var navAgent : NavigationAgent3D = $NavigationAgent3D

@export var maxNewPointDistance : float = 15.0
@export var stopChaseDistance : float = 15.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8


const STATE_IDLE = 0
const STATE_WALKING = 1
const STATE_CHASING = 2


var state = STATE_IDLE

enum WEAPON {
	ranged,
	melee,
}

var weapon = WEAPON.melee


func _ready():
	damageable.damageTaken.connect(_enterChase)
	damageable.damageTaken.connect(_pluh.bind(1.5))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	var direction = Vector3(0, 0, 0)
	
	match state:
		STATE_IDLE:
			anim_player.play("Idle")
			if idleTimer.is_stopped():
				navAgent.target_position = _get_next_walk_point()
				state = STATE_WALKING
		STATE_WALKING:
			speed = WALK_SPEED
			anim_player.play("Walk")
			if not navAgent.is_target_reachable():
				navAgent.target_position = _get_next_walk_point()
			var next_path = navAgent.get_next_path_position()
			direction = next_path - global_transform.origin
			
			look_at_from_position(global_position, navAgent.target_position, Vector3.UP)
			rotation.y += deg_to_rad(90)
			rotation.x = 0.0
			rotation.z = 0.0
			if navAgent.is_target_reached():
				state = STATE_IDLE
				idleTimer.start()
		STATE_CHASING:
			speed = CHASE_SPEED
			anim_player.play("Chase")
			
			navAgent.target_position = player.global_transform.origin
			var next_path = navAgent.get_next_path_position()
			direction = next_path - global_transform.origin
			
			look_at_from_position(global_position, next_path, Vector3.UP)
			rotation.y += deg_to_rad(90)
			rotation.x = 0.0
			rotation.z = 0.0
			if global_position.distance_to(player.global_position) > stopChaseDistance:
				state = STATE_IDLE
	
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	if playerSeek.get_collider() is playerClass:
		state = STATE_CHASING

func _pluh(pitch : float = randf_range(0.8, 1.2)):
	pluh.pitch_scale = pitch
	pluh.play()


func _get_next_walk_point() -> Vector3:
	var point : Vector3 = Vector3.ZERO
	
	point.x = randf_range(global_position.x - maxNewPointDistance, global_position.x + maxNewPointDistance)
	point.z = randf_range(global_position.z - maxNewPointDistance, global_position.z + maxNewPointDistance)
	point.y = global_position.y
	
	return point

func _enterChase():
	state = STATE_CHASING
