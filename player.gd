extends AnimatedSprite2D

var fishcaught
var fishicon
var fishname
var moneylabel
var inventorynode

var fishinfo
var money = 0
var inventory = []

class Fish:
	var name: String
	var weight: int
	var length: int
	var texture: String
	func _init(fishname: String, fishweight: int, fishlength: int, fishtexture: String):
		name = fishname
		weight = fishweight
		length = fishlength
		texture = fishtexture

func _ready():
	fishcaught = get_node("../FishCaught")
	moneylabel = get_node("../Money")
	inventorynode = get_node("../Inventory")
	fishicon = fishcaught.get_node("Icon")
	fishname = fishcaught.get_node("FishName")
	
	var jsonFile = "res://data/fish.json"
	var jsonFileText = FileAccess.get_file_as_string(jsonFile)
	fishinfo = JSON.parse_string(jsonFileText)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fish"):
		gofishing()
	if event.is_action_pressed("inventory"):
		showinventory()

func gofishing():
	fishcaught.visible = true
	var catch = fishinfo.fish[randi_range(0, len(fishinfo.fish)-1)]
	fishicon.texture = load(catch.texture)
	fishname.text = catch.name.capitalize()
	var weight = randf_range(catch.weightmin, catch.weightmax)
	var length = randf_range(catch.lengthmin, catch.lengthmax)
	#money += round(weight * catch.quality)
	#moneylabel.text = "$" + str(money)
	inventory.append(Fish.new(catch.name, weight, length, catch.texture))

func showinventory():
	if inventorynode.visible == false:
		var fishnum = 0
		inventorynode.visible = true
		for n in inventorynode.get_node("Contents").get_children():
			inventorynode.get_node("Contents").remove_child(n)
			n.queue_free()
		for inventoryfish in inventory:
			var newnode = Sprite2D.new()
			newnode.texture = load(inventoryfish.texture)
			newnode.position.x = 24
			newnode.position.y = 20 + 20 * fishnum
			inventorynode.get_node("Contents").add_child(newnode)
			fishnum += 1
		inventorynode.size.y = 14 + 20 * fishnum
	else:
		inventorynode.visible = false
