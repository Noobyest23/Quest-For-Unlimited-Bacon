extends Area3D




func _on_body_entered(body):
	if body.has_node("Damageable"):
		body.get_node("Damageable")._death()
