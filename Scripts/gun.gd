extends Node3D

class_name Gun

@export var bullet : PackedScene
@export var shellCase : PackedScene
@export var raycast : RayCast3D

@onready var front = $Front

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _input(event):
	if visible == false:
		return
	if event.is_action_pressed("WeaponMain"):
		_fire()
	

func _fire():
	if anim_player.current_animation != "Fire":
		anim_player.play("Fire")
		
		
		
		var inst : Projectile = bullet.instantiate()
		if raycast.is_colliding():
			inst.target = raycast.get_collision_point()
		else:
			inst.target = $target.global_position
		front.add_child(inst)
		


	
	await anim_player.animation_finished
	anim_player.play("Idle")
