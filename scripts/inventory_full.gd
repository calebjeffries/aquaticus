extends Label

func _process(delta: float) -> void:
	if modulate.a > 0:
		modulate.a -= 1000 * delta
