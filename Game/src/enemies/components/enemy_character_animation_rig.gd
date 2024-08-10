class_name EnemyCharacterAnimationRig
extends Node2D

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite
@onready var _effect_animations: AnimationPlayer = %AnimationPlayer

func setup(character: EnemyCharacter) -> void:
	character.direction.value_changed.connect(_on_character_direction_value_changed)
	character.health.health_changed.connect(_on_health_health_changed)

func _on_health_health_changed(value):
	_effect_animations.play(&"enemy_character_damage")

func _on_character_direction_value_changed(value: Vector2, _oberservable) -> void:
	if !_sprite:
		return

	if value.is_zero_approx():
		_sprite.stop()
		return

	var axis = value.abs().max_axis_index()
	if is_equal_approx(value.x, value.y):
		axis = 0
	
	if axis == 0:
		var axis_value: float = value[axis]
		if axis_value > 0:
			_sprite_play(&"east")
		else:
			_sprite_play(&"west")

	if axis == 1:
		var axis_value: float = value[axis]
		if axis_value > 0:
			_sprite_play(&"south")
		else:
			_sprite_play(&"north")

func _sprite_play(animation_name: StringName) -> void:
	if _sprite.animation == animation_name or !_sprite.sprite_frames.has_animation(animation_name):
		return
	_sprite.play(animation_name)
