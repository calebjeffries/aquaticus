extends Area2D

@export var scene: String # Scene to switch to
var gc

func _ready() -> void:
	gc = get_node("/root/Main")

# When the Area is entered, go to a different scene
func _on_body_entered(body: Node2D):
	if body.name == "Player":
		gc.switch_scene(scene)
