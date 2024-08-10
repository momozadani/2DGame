class_name EnemyCharacter
extends CharacterBody2D

@export var animation_rig: EnemyCharacterAnimationRig
@export var data: EnemyData

var direction: ObservableVector2 = ObservableVector2.new(Vector2.ZERO)

@onready var health: Health = $%Health
@onready var navigation: Navigation= $%Navigation
@onready var audio_player: AudioStreamPlayer = %SfxDeath


var speed: float = 0.0

func _ready() -> void:
	if(data.speed == data.max_speed || sign(data.acceleration) > 0):
		speed = data.speed
	else:
		speed = randf_range(data.speed, data.max_speed)

	health.maximum = data.health + (data.health_per_wave * GameService.get_game().wave)
	health.current = health.maximum

	Notifications.subscribe(VictorySystem.GAMEOVER_NOTIFICATION, die)
	animation_rig.setup(self)


func die(_arg) -> void:
	var tween: = get_tree().create_tween()
	if !GameService.get_context().is_gameover.value && !GameService.get_context().is_gamewon.value:
		audio_player.play()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(func(): queue_free())
