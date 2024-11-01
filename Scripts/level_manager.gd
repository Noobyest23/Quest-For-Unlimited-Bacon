extends Node3D

class_name LevelManager

@onready var current_level = get_parent().get_child(0)

func _switch_level(level : PackedScene):
	var inst = level.instantiate()
	get_parent().add_child(inst)
	current_level.queue_free()
	current_level = level
