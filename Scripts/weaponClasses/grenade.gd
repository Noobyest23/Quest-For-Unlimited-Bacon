extends throwableWeapon

class_name grenade

@export var explosionDamage : float
@export var explosionPushForce : float
@export var areaExplosion : Area3D
@export var explosionTimer : Timer
var weapons : weaponManager = null

func _ready() -> void:
	rigidBody.body_entered.connect(_body_entered)
	thrown.connect(_timerStart)
	weapons = get_parent()

func _body_entered(body) -> void:
	if not body is playerClass:
		var damageable : Damageable = body.get_node("Damageable")
		if damageable:
			damageable._damage(damage)
			areaExplosion.monitoring = true
			await get_tree().create_timer(0.2).timeout
			queue_free()
	

func _on_body_entered(body: Node) -> void:
	if not body is playerClass:
		if body is enemy:
			areaExplosion.monitoring = true
			await get_tree().create_timer(0.2).timeout
			queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	var damageable : Damageable = body.get_node("Damageable")
	if damageable:
		damageable._damage(explosionDamage)
	if body is RigidBody3D:
		body.apply_impulse(global_position.direction_to(body.global_position) * explosionPushForce, body.global_position)
	elif body is CharacterBody3D:
		body.velocity += global_position.direction_to(body.global_position) * explosionPushForce

func _timerStart() -> void:
	explosionTimer.start()

func _on_timer_timeout() -> void:
	areaExplosion.monitoring = true
	await get_tree().create_timer(0.2).timeout
	queue_free()
	var index = weapons.weapons.find(grenade)
	weapons.weapons.remove_at(index)
	weapons.weapons.resize(weapons.weapons.size() - 1)
