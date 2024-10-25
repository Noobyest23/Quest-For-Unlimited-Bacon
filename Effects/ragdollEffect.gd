extends Node3D

@onready var skeletonPhys : PhysicalBoneSimulator3D = $"pluh guy/Armature/Skeleton3D/PhysicalBoneSimulator3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reparent(get_parent().get_parent())
	global_position.y += 0.8
	skeletonPhys.physical_bones_start_simulation()

func _on_remove_timer_timeout() -> void:
	queue_free()
