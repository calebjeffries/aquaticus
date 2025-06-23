extends Node2D

var fishcaught
var fishcaughticon
var fishcaughtname
var fishcaughtweight
var fishcaughtlength
var moneylabel
var inventorynode
var inventoryselector
var inventorycontents
var inventoryemptytext
var inventoryfull
var storenode
var storeleveltext
var storepricetext
var playernode
var actionsbar
var actionsbartext

@export var money = 0
var fishinfo
var inventory = []
var selectedinventoryfish = 0
var rodlevel = 1
var locationmode = ""

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
	fishcaught = get_node("Camera2D/FishCaught")
	fishcaughticon = fishcaught.get_node("Icon")
	fishcaughtname = fishcaught.get_node("FishName")
	fishcaughtweight = fishcaught.get_node("Weight")
	fishcaughtlength = fishcaught.get_node("Length")
	moneylabel = get_node("Camera2D/Money")
	inventorynode = get_node("Camera2D/Inventory")
	inventoryselector = inventorynode.get_node("Selector")
	inventorycontents = inventorynode.get_node("Contents")
	inventoryemptytext = inventorynode.get_node("Empty")
	inventoryfull = get_node("Camera2D/InventoryFull")
	storenode = get_node("Camera2D/Store")
	storeleveltext = storenode.get_node("Level")
	storepricetext = storenode.get_node("Price")
	playernode = get_node("Camera2D/Player/Sprite")
	actionsbar = get_node("Camera2D/ActionsBar")
	actionsbartext = get_node("Camera2D/ActionsBar/Label")
	
	var jsonFile = "res://data/fish.json"
	var jsonFileText = FileAccess.get_file_as_string(jsonFile)
	fishinfo = JSON.parse_string(jsonFileText)
	
	inventoryfull.modulate.a = 0
	fishcaught.modulate.a = 0

func _input(event: InputEvent) -> void:
	if inventorynode.visible == true:
		if event.is_action_pressed("down"):
			if selectedinventoryfish < len(inventory)-1:
				inventoryselector.position.y += 20
				selectedinventoryfish += 1
		elif event.is_action_pressed("up"):
			if selectedinventoryfish > 0:
				inventoryselector.position.y -= 20
				selectedinventoryfish -= 1
		elif event.is_action_pressed("select") and len(inventory) > 0:
			money += snapped(inventory[selectedinventoryfish].weight * inventory[selectedinventoryfish].quality, 0.01)
			moneylabel.text = "$" + str(money)
			inventory.remove_at(selectedinventoryfish)
			renderinventory()
		elif event.is_action_pressed("quit"):
			inventorynode.visible = false
			playernode.enabled = true
			actionsbartext.text = "[E] sell fish"
	elif storenode.visible == true:
		if event.is_action_pressed("select") and rodlevel < len(fishinfo.fish) and money >= getrodprice(rodlevel + 1):
			money -= getrodprice(rodlevel + 1)
			money = snapped(money, 0.01)
			rodlevel += 1
			renderstore()
		elif event.is_action_pressed("quit"):
			storenode.visible = false
			playernode.enabled = true
			actionsbartext.text = "[E] enter store"
	else:
		if event.is_action_pressed("select"):
			if locationmode == "fishing":
				gofishing()
			elif locationmode == "store":
				renderstore()
			elif locationmode == "market":
				renderinventory()

func gofishing():
	if len(inventory) < 5:
		fishcaught.visible = true
		var catch = fishinfo.fish[randi_range(0, rodlevel-1)]
		fishcaughticon.texture = load(catch.texture)
		fishcaughtname.text = catch.name.capitalize()
		var weight = randf_range(catch.weightmin, catch.weightmax)
		var length = randf_range(catch.lengthmin, catch.lengthmax)
		if weight >= 1:
			fishcaughtweight.text = str(round(weight)) + "kg"
		else:
			fishcaughtweight.text = str(round(weight * 1000)) + "g"
		fishcaughtlength.text = str(round(length)) + "cm"
		inventory.append(Fish.new(catch.name, weight, length, catch.quality, catch.texture))
		fishcaught.get_node("AnimationPlayer").stop()
		fishcaught.get_node("AnimationPlayer").play("fade_out")
	else:
		inventoryfull.get_node("AnimationPlayer").play("fade_out")

func renderinventory():
	inventorynode.visible = true
	playernode.enabled = false
	actionsbartext.text = "[E] sell : [Q] exit"
	var fishnum = 0
	inventoryselector.position.y = 24
	selectedinventoryfish = 0
	for n in inventorycontents.get_children():
		inventorycontents.remove_child(n)
		n.queue_free()
	if len(inventory) == 0:
		inventoryemptytext.visible = true
		inventoryselector.visible = false
		inventorynode.size.y = 32
	else:
		inventoryemptytext.visible = false
		inventoryselector.visible = true
		for inventoryfish in inventory:
			var newnode = Sprite2D.new()
			newnode.texture = load(inventoryfish.texture)
			newnode.position.x = 26
			newnode.position.y = 24 + 20 * fishnum
			inventorycontents.add_child(newnode)
			fishnum += 1
		inventorynode.size.y = 18 + 20 * fishnum

func renderstore():
	storenode.visible = true
	playernode.enabled = false
	actionsbartext.text = "[E] upgrade : [Q] exit"
	storeleveltext.text = "lvl. " + str(rodlevel) + " > lvl. " + str(rodlevel + 1)
	if rodlevel == len(fishinfo.fish):
		storeleveltext.text = "lvl. " + str(rodlevel)
		storepricetext.text = "MAX"
		storepricetext.label_settings.font_color = Color(1, 0, 0, 1)
	else:
		var rodprice = getrodprice(rodlevel + 1)
		storeleveltext.text = "lvl. " + str(rodlevel) + " > lvl. " + str(rodlevel + 1)
		storepricetext.text = "$" + str(rodprice)
		if money >= rodprice:
			storepricetext.label_settings.font_color = Color(0, 1, 0, 1)
		else:
			storepricetext.label_settings.font_color = Color(1, 0, 0, 1)

func getrodprice(level) -> int:
	return 10  * (level - 1) ** 2

func enter_store_mode(_body: Node2D):
	locationmode = "store"
	actionsbar.visible = true
	actionsbartext.text = "[E] enter store"

func enter_market_mode(_body: Node2D):
	locationmode = "market"
	actionsbar.visible = true
	actionsbartext.text = "[E] sell fish"

func enter_fishing_mode(_body: Node2D):
	locationmode = "fishing"
	actionsbar.visible = true
	actionsbartext.text = "[E] go fishing"

func clear_mode(_body: Node2D):
	locationmode = ""
	actionsbar.visible = false
