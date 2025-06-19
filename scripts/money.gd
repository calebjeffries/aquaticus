extends Label

var playernode

func _ready() -> void:
	playernode = get_node("../Player")

func _process(delta: float) -> void:
	text = "$" + str(playernode.money)
