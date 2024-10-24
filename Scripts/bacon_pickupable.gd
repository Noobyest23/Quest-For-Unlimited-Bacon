extends Node3D

const explodeParticles = preload("res://Effects/collection_explosion.tscn")
@onready var player : playerClass = get_parent().get_child(0)

func _on_area_3d_body_entered(body):
	if body == player:
		$GPUParticles3D.emitting = false
		var paricleIsnt = explodeParticles.instantiate()
		add_child(paricleIsnt)
		$Node3D.visible = false
		await paricleIsnt.smokeEmitter.finished
		
		queue_free()


