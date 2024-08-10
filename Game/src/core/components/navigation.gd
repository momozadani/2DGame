@icon("res://src/core/shared/flag_triangle.svg")
class_name Navigation
extends Node
# This is a simple script that returns the direction to the player.

## If true, the enemy will follow the global player
@export var follow_global_player: bool = true
## range at which the enemy will stop moving
@export var deadzone: int = 100 :
	set(value):
		deadzone = value
		_deadzone_squared = deadzone * deadzone
	get:
		return deadzone
var _deadzone_squared: int = deadzone * deadzone
@onready var character = owner if owner != null else null

func get_direction_to_target() -> Vector2:
	if !follow_global_player:
		return Vector2.INF
	var player := get_tree().get_first_node_in_group(Group.PLAYER) as Node2D
	assert(player)
	#! If the player is within the deadzone, return infinity to stop the character
	#! Use dista	nce_squared_to to avoid the expensive square root operation
	if owner.global_position.distance_squared_to(player.global_position) < _deadzone_squared:
		return Vector2.INF
	return player.position
