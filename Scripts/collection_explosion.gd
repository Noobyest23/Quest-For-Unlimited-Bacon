extends GPUParticles3D

@onready var smokeEmitter : GPUParticles3D = get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	smokeEmitter.one_shot = true
	one_shot = true
	smokeEmitter.emitting = true
	emitting = true

func _on_smoke_finished():
	queue_free()
