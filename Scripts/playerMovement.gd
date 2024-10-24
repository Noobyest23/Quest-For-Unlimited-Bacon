extends CharacterBody3D

class_name playerClass

@onready var collisionShape : CollisionShape3D = $CollisionShape3D
@onready var camera : cameraMovement = $MeshInstance3D/Camera3D

const WALK_SPEED = 7.0
const CROUCH_SPEED = 3.0
const WALLRUN_SPEED = 10.0

const JUMP_VELOCITY = 5.0


var speed = WALK_SPEED

var gravity = 9.8
var wallRunTimer = 1.0

var sliding = false
var wallrunning = false

signal endWallRun

@onready var damageable : Damageable = $Damageable

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Get the input direction and handle the movement/deceleration.

	var input_dir = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor() and not is_on_wall_only() and not sliding:
		#If the player is on the floor then Move if an input button is pressed
		wallrunning = false
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
		
	elif is_on_wall_only(): #Handle Wall run Logic
		var collision : KinematicCollision3D = get_slide_collision(0)
		var collider = collision.get_collider(0)
		if collider.get_collision_mask_value(2):
			
			
			
			
			wallRunTimer -= 0.02
			
			# Get wall normal and calculate the wall's forward direction
			var wall_normal = get_wall_normal()
			var wall_forward = wall_normal.cross(Vector3.UP).normalized()  # Forward direction relative to the wall
			
			# Determine if the player is on the left or right side of the wall
			var approach_dir = velocity.normalized()
			
			print(approach_dir)
			
			var dot_product = wall_forward.dot(approach_dir)
			
			# Flip wall forward if the player approaches from the opposite direction
			if dot_product < 0:
				wall_forward = -wall_forward
			
			if not wallrunning:
				velocity.x += direction.x * 4.0
				velocity.z += direction.z * 4.0
				wallrunning = true
				
			
			#Same stuff as other movement But if the player jumps ignore it
			if direction and not Input.is_action_just_pressed("Jump"):
				#velocity.x = lerp(velocity.x, direction.x * WALLRUN_SPEED, delta * 1.0)
				#velocity.z = lerp(velocity.z, direction.z * WALLRUN_SPEED, delta * 1.0)
				velocity -= get_wall_normal() * 1.0
			
			gravity = 0.0
			#Vertical Movement on the wall
			#
			#If the wall run timer is 0 or less than stop the wall run and go down
			if wallRunTimer <= 0 or direction.x == 0.0 and direction.z == 0.0:
				gravity = 9.8
				endWallRun.emit()
			else: #lerp Velocity.y to 0 to stop the player from continuesly going up
				velocity.y = lerp(velocity.y, 0.0, delta * 4.0)
				rotation_degrees.z = lerp(rotation_degrees.z, sign(dot_product) * 25.0, delta * 4.0)
	
	elif sliding and is_on_floor():
		#velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		#velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		pass
	else:
		#Not on the floor and not on the wall and not sliding
		
		if Input.is_action_pressed("Move Back"):
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		elif direction:
			velocity.x = lerp(velocity.x, velocity.x + direction.x, delta * 5.0)
			velocity.z = lerp(velocity.z, velocity.z + direction.z, delta * 5.0)
		gravity = 9.8
		wallRunTimer = 1.0
		rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta * 4.0)
	
	if not wallrunning:
		rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta * 4.0)
	move_and_slide()
	
	# after calling move_and_slide()
	var push_force = 1.0
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			print(push_force)
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func _input(event):
	#Handle Jump
	if event is InputEventKey:
		if event.is_action_pressed("Jump") and is_on_floor() or event.is_action_pressed("Jump") and is_on_wall_only():
			if is_on_wall_only():
				var collision : KinematicCollision3D = get_slide_collision(0)
				var collider = collision.get_collider(0)
				if collider.get_collision_mask_value(2):
					velocity += get_wall_normal() * JUMP_VELOCITY * 1.5
					velocity.y = 2.0
					endWallRun.emit()
			else:
				velocity.y = JUMP_VELOCITY
		if event.is_action_pressed("Crouch") and velocity == Vector3.ZERO:
			#Begin Crouching
			_startCrouch()
		elif event.is_action_pressed("Crouch"):
			_startSlide()
		elif event.is_action_released("Crouch"):
			_endCrouch()

func _startCrouch() -> void:
	if is_on_floor():
		velocity.y = -10.0
	speed = CROUCH_SPEED
	collisionShape.shape.height /= 2

func _startSlide() -> void:
	collisionShape.shape.height /= 2
	var input_dir = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		velocity.y = -5.0
		velocity.x += direction.x * 4.0
		velocity.z += direction.z * 4.0
	sliding = true

func _endCrouch() -> void:
	speed = WALK_SPEED
	collisionShape.shape.height *= 2
	sliding = false
