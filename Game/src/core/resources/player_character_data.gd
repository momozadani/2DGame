# class_name PlayerCharacterData
extends Resource


@export var id: int = 0
@export var full_name: String = ""
@export var name: String = ""
@export var description: String = ""
@export var price: int = 0
@export var thumbnail: Texture

@export var base_health: int = 10
@export_file("*.tscn") var scene
@export var base_modifiers: Array[ModifierData] = []
