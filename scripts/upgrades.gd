class_name Upgrade
extends Resource

# Contains settings for possible upgrades

@export var texture: Texture
@export var price_exponent: float
@export var price_multiplier: float

@export_enum("rod", "scuba", "inventory") var type: String

signal Upgraded

func upgrade():
	Upgraded.emit()
