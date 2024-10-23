extends Node3D

class_name Sword

var damage = 7
var isAttacking : bool = false

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var trail : Node3D = $Trail
var particles : PackedScene = preload("res://Scenes/collection_explosion.tscn")

func _input(event):
	if event.is_action_pressed("WeaponMain"):
		_slash()

func _slash():
	if not anim_player.current_animation == "Slash":
		anim_player.play("Slash")
		isAttacking = true
	await anim_player.animation_finished
	anim_player.set_blend_time("Slash", "Idle", 0.1)
	anim_player.play("Idle")
	isAttacking = false

func _on_area_3d_body_entered(body):
	if body.has_node("Damageable") and not body is playerClass and isAttacking:
		body.get_node("Damageable")._damage(damage)
		_impact(0.04, 0.5)
		var inst = particles.instantiate()
		add_child(inst)

func _impact(timeScale : float, duration : float):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1.0
