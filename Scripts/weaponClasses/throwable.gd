extends weaponClass

class_name throwableWeapon

@export var throwDirection : Vector3
@export var throwForce : float
@export var rigidBody : RigidBody3D
var isThrown : bool = false
signal thrown

func _ready() -> void:
	rigidBody.body_entered.connect(_body_entered)

func _body_entered(body) -> void:
	var damageable : Damageable = body.get_node("Damageable")
	if damageable:
		damageable._damage(damage)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("WeaponMain") and equipped:
		_throw()

func _throw() -> void:
	rigidBody.freeze = false
	reparent(get_tree().current_scene)
	rigidBody.apply_impulse(-basis.z * throwDirection * throwForce, rigidBody.global_position)
	equipped = false
	thrown.emit()
