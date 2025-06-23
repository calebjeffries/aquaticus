extends Label

var rootnode

func _ready() -> void:
	rootnode = get_node("../..")

func _process(_delta: float) -> void:
	text = "$" + str(rootnode.money).pad_decimals(2)
