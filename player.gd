extends AnimatedSprite2D

var fishcaught
var fishicon
var fishname
var moneylabel

var fishinfo
var money = 0

func _ready():
	fishcaught = get_node("../FishCaught")
	moneylabel = get_node("../Money")
	fishicon = fishcaught.get_node("Icon")
	fishname = fishcaught.get_node("FishName")
	
	var jsonFile = "res://data/fish.json"
	var jsonFileText = FileAccess.get_file_as_string(jsonFile)
	fishinfo = JSON.parse_string(jsonFileText)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fish"):
		fish()

func fish():
	fishcaught.visible = true
	var catch = fishinfo.fish[randi_range(0, len(fishinfo.fish)-1)]
	fishicon.texture = load(catch.texture)
	fishname.text = catch.name.capitalize()
	var weight = randf_range(catch.weightmin, catch.weightmax)
	var length = randf_range(catch.lengthmin, catch.lengthmax)
	money += round(weight * catch.quality)
	moneylabel.text = "$" + str(money)
