extends Node3D

class_name Sword

@onready var player = get_parent().get_parent().get_parent()
@onready var worldEnv : WorldEnvironment = player.get_parent().get_child(1)

var damage = 7
var isAttacking : bool = false
var isBlocking : bool = false
var attackingDirection : Vector3 = Vector3(0, 0, 0)
var attackingMultiplier : float = 2.0

signal endBlock

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var trail : Node3D = $Trail
@onready var parryTimer : Timer = $Parry_timer
var particles : PackedScene = preload("res://Effects/collection_explosion.tscn")

func _input(event):
	if visible == false:
		return
	if event.is_action_pressed("WeaponMain"):
		_slash()
	elif event.is_action_pressed("WeaponAlt"):
		_block()
	elif event.is_action_released("WeaponAlt"):
		endBlock.emit()

func _slash():
	if not anim_player.current_animation == "Slash":
		anim_player.play("Slash")
		isAttacking = true
		attackingDirection = (-player.transform.basis.x + (-player.transform.basis.z / 2)) * attackingMultiplier 
	await anim_player.animation_finished
	anim_player.set_blend_time("Slash", "Idle", 0.1)
	anim_player.play("Idle")
	isAttacking = false

func _block():
	parryTimer.start()
	anim_player.play("block")
	isBlocking = true
	
	await endBlock
	isBlocking = false
	anim_player.play("Idle")

func _on_area_3d_body_entered(body):
	#Damage the body if its an attack
	if body is playerClass:
		return
	if body.has_node("Damageable") and isAttacking:
		body.get_node("Damageable")._damage(damage)
		_impact(0.04, 0.4)
		var inst = particles.instantiate()
		body.add_child(inst)
		if body is RigidBody3D:
			body.apply_impulse(attackingDirection)
	#Destroy Projectiles if blocking
	if isBlocking and not parryTimer.is_stopped():
		body.queue_free()
		_impact(0.04, 0.5)
	elif isBlocking:
		body.queue_free()

func _impact(timeScale : float, duration : float):
	if worldEnv:
		worldEnv.environment.glow_bloom = 1.0
		worldEnv.environment.glow_intensity = 1.4
		worldEnv.environment.tonemap_mode = Environment.TONE_MAPPER_REINHARDT
	
	if anim_player.is_playing():
		anim_player.pause()
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1.0
	
	anim_player.play()
	if worldEnv:
		worldEnv.environment.glow_bloom = 0.5
		worldEnv.environment.glow_intensity = 0.8
		worldEnv.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
