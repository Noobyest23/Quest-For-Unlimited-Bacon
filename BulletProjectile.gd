extends RigidBody3D

class_name Projectile

@export var speed : float = 8.0
@export var drop : float = 0.0
@export var damage : float = 5.0

@export var impactFx : PackedScene

var target = Vector3(0, 0, 0)

func _ready():
	reparent(get_parent().get_parent().get_parent().get_parent().get_parent().get_parent())
	look_at(target)

func _process(delta):
	linear_velocity = -transform.basis.z * speed
	linear_velocity = -transform.basis.y * drop
	
	var collisions = get_colliding_bodies()
	if not collisions.is_empty():
		for i in range(0, collisions.size()):
			if collisions[i] is playerClass:
				return
		
			var damageable : Damageable = collisions[i].get_node("Damageable")
			if damageable:
				damageable._damage(damage)
			if impactFx:
				var inst = impactFx.instantiate()
				add_child(inst)
		queue_free()

func _on_life_time_timeout():
	queue_free()
