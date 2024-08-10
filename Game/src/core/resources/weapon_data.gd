# class_name WeaponData
extends Resource

enum Pattern{ CONE, RANDOM, CIRCLE}
enum Deviation {NONE, SMALL, HIGH}

@export_category("Misc")
@export var id: int = 0
@export var name: String = ""
@export var full_name: String = ""
@export var description: String = ""
@export var thumbnail: Texture

@export_category("Weapon Data")
@export var damage: int
@export var attack_speed: float
@export var cooldown: float
@export var attack_range: float
@export var targets: int
@export var count: int
@export var is_fixed: bool = false
@export var pattern: Pattern = Pattern.CONE
@export var deviation: Deviation = Deviation.NONE

@export_category("Projectile Data")
@export var projectile_speed: int
@export var size_multiplier: float = 1
@export var bounces: int = 0
@export var pierce: int = 0
@export var return_to_player: bool = false


func can_bounce() -> bool:
	return bounces > 0

func can_pierce() -> bool:
	return pierce > 0
