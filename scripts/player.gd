extends AnimatedSprite2D

var fishcaught
var fishicon
var fishname
var moneylabel
var inventorynode
var storenode

var fishinfo
var money = 0
var inventory = []
var selectedinventoryfish = 0
var rodlevel = 1

class Fish:
	var name: String
	var weight: float
	var length: float
	var quality: int
	var texture: String
	func _init(fishname: String, fishweight: float, fishlength: float, fishquality: int, fishtexture: String):
		name = fishname
		weight = fishweight
		length = fishlength
		quality = fishquality
		texture = fishtexture

func _ready():
	fishcaught = get_node("../FishCaught")
	moneylabel = get_node("../Money")
	inventorynode = get_node("../Inventory")
	storenode = get_node("../Store")
	fishicon = fishcaught.get_node("Icon")
	fishname = fishcaught.get_node("FishName")
	
	var jsonFile = "res://data/fish.json"
	var jsonFileText = FileAccess.get_file_as_string(jsonFile)
	fishinfo = JSON.parse_string(jsonFileText)

func _input(event: InputEvent) -> void:
	if inventorynode.visible == true:
		if event.is_action_pressed("down"):
			if selectedinventoryfish < len(inventory)-1:
				inventorynode.get_node("Selector").position.y += 20
				selectedinventoryfish += 1
		elif event.is_action_pressed("up"):
			if selectedinventoryfish > 0:
				inventorynode.get_node("Selector").position.y -= 20
				selectedinventoryfish -= 1
		elif event.is_action_pressed("select") and len(inventory) > 0:
			money += round(inventory[selectedinventoryfish].weight * inventory[selectedinventoryfish].quality)
			moneylabel.text = "$" + str(money)
			inventory.remove_at(selectedinventoryfish)
			renderinventory()
		elif event.is_action_pressed("menu-cycle"):
			inventorynode.visible = false
			storenode.visible = true
			renderstore()
	elif storenode.visible == true:
		if event.is_action_pressed("select") and rodlevel < len(fishinfo.fish) and money >= getrodprice(rodlevel + 1):
			money -= getrodprice(rodlevel + 1)
			rodlevel += 1
			renderstore()
		elif event.is_action_pressed("menu-cycle"):
			storenode.visible = false
	else:
		if event.is_action_pressed("select"):
			gofishing()
		if event.is_action_pressed("menu-cycle"):
			inventorynode.visible = true
			renderinventory()

func gofishing():
	if len(inventory) < 5:
		fishcaught.visible = true
		var catch = fishinfo.fish[randi_range(0, rodlevel-1)]
		fishicon.texture = load(catch.texture)
		fishname.text = catch.name.capitalize()
		var weight = randf_range(catch.weightmin, catch.weightmax)
		var length = randf_range(catch.lengthmin, catch.lengthmax)
		inventory.append(Fish.new(catch.name, weight, length, catch.quality, catch.texture))
	else:
		get_node("../InventoryFull").modulate.a = 255

func renderinventory():
	var fishnum = 0
	inventorynode.get_node("Selector").position.y = 24
	selectedinventoryfish = 0
	for n in inventorynode.get_node("Contents").get_children():
		inventorynode.get_node("Contents").remove_child(n)
		n.queue_free()
	if len(inventory) == 0:
		inventorynode.get_node("Empty").visible = true
		inventorynode.get_node("Selector").visible = false
		inventorynode.size.y = 32
	else:
		inventorynode.get_node("Empty").visible = false
		inventorynode.get_node("Selector").visible = true
		for inventoryfish in inventory:
			var newnode = Sprite2D.new()
			newnode.texture = load(inventoryfish.texture)
			newnode.position.x = 26
			newnode.position.y = 24 + 20 * fishnum
			inventorynode.get_node("Contents").add_child(newnode)
			fishnum += 1
		inventorynode.size.y = 18 + 20 * fishnum

func renderstore():
	storenode.get_node("Level").text = "lvl. " + str(rodlevel) + " > lvl. " + str(rodlevel + 1)
	if rodlevel == len(fishinfo.fish):
		storenode.get_node("Level").text = "lvl. " + str(rodlevel)
		storenode.get_node("Price").text = "MAX"
		storenode.get_node("Price").label_settings.font_color = Color(1, 0, 0, 1)
	else:
		var rodprice = getrodprice(rodlevel + 1)
		storenode.get_node("Level").text = "lvl. " + str(rodlevel) + " > lvl. " + str(rodlevel + 1)
		storenode.get_node("Price").text = "$" + str(rodprice)
		if money >= rodprice:
			storenode.get_node("Price").label_settings.font_color = Color(0, 1, 0, 1)
		else:
			storenode.get_node("Price").label_settings.font_color = Color(1, 0, 0, 1)

func getrodprice(level) -> int:
	return 10  * (level - 1) ** 4
