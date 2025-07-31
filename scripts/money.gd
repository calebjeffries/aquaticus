extends Label

var gc

func _ready():
	gc = get_node("/root/Main")
	update()

func update():
	text = "$" + str(gc.money).pad_decimals(2) # Display number with zeros at the end if needed
