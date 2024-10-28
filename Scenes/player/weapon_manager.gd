extends Node3D

class_name weaponManager

@export var weapons : Array[weaponClass]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, weapons.size()):
			if weapons[i] is Sword:
				weapons[i].equipped = true
				weapons[i].visible = true
			else:
				weapons[i].equipped = false
				weapons[i].visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Equip Sword"):
		for i in range(0, weapons.size()):
			if weapons[i] is Sword:
				weapons[i].equipped = true
				weapons[i].visible = true
			else:
				weapons[i].equipped = false
				weapons[i].visible = false
	elif event.is_action_pressed("Equip Gun"):
		for i in range(0, weapons.size()):
			if weapons[i] is Gun:
				weapons[i].equipped = true
				weapons[i].visible = true
			else:
				weapons[i].equipped = false
				weapons[i].visible = false
	elif event.is_action_pressed("Equip Grenade"):
		for i in range(0, weapons.size()):
			if weapons[i] is grenade:
				weapons[i].equipped = true
				weapons[i].visible = true
			else:
				weapons[i].equipped = false
				weapons[i].visible = false
