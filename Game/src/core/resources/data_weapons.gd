class_name WeaponData
extends Resource

enum Pattern{ CONE, RANDOM, CIRCLE}
enum Deviation {NONE, SMALL, HIGH}

const NO_DEVIATION: = 0.0
const LOW_DEVIATION: = 0.0174533
const HIGH_DEVIATION: = 0.0349066

@export_category("Misc")
@export var id := 0
@export var name := ""
@export var full_name := ""
@export var description := ""
@export var price := 0
@export var icon : AtlasTexture
@export var level := 0
@export var max_count := 1

@export_category("Weapon Data")
@export var damage := 0
@export var targets := 0
@export var attack_range := 0
## how often the weapon can fire a sequence
@export var attack_speed := 0.0
## how often the weapon fires in one sequence
@export var repeat := 0
## time between each bullet in a sequence
@export var delay := 0.0
@export var is_fixed := false : 
	set(value):
		if !value && is_rotating:
			# rotating projectiles need to be fixed
			return
		is_fixed = value
			
@export var terrain_bounce := false
@export var is_random_dir := false
@export var pattern : Pattern= Pattern.CONE
@export var _deviation: Deviation = Deviation.NONE
var deviation: float  :
	get:
		if _deviation == Deviation.SMALL:
			return LOW_DEVIATION
		elif _deviation == Deviation.HIGH:
			return HIGH_DEVIATION
		else:
			return NO_DEVIATION

@export_category("Projectile Data")
@export var projectile_speed := 0
@export var size_multiplier := 1.0
@export var bounces := 0
@export var pierce := 0
@export var return_to_player := false
## how many bullets are fired at once
@export var count := 0
@export var color: Color = Color(1, 1, 1, 1)
@export var scene : Resource
@export var is_rotating: bool = false :
	set(value):
		if value:
			is_fixed = true
		is_rotating = value
@export var rotation_speed: int = 1
@export var sprite_scale: float = 1.0
@export var hitbox_scale: float = 1.0
@export_enum("default", "ice", "spark", "bat", "tornado", "portal", "sword", "dagger") var animations: String = "default"

func can_bounce() -> bool:
	return bounces > 0

func can_pierce() -> bool:
	return pierce > 0
