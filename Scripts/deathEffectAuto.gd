extends GPUParticles3D

@onready var subParticles = get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	reparent(get_parent().get_parent())
	
	finished.connect(_kill)
	
	if not subParticles.is_empty():
		for i in range(0, subParticles.size()):
			subParticles.emitting = true
	
	emitting = true

func _kill():
	queue_free()
