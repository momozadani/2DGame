#class_name ItemData
extends Resource


@export var id: int
@export var name: StringName
@export var description: String
@export var icon: Texture
@export var modifiers: Array[ModifierData]
@export var rarity: Enums.Rarity

static func get_rarity_string(rarity: Enums.Rarity) -> String:
	return str(Enums.Rarity.keys()[rarity]).capitalize()

