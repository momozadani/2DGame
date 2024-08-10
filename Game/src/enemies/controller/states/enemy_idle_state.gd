class_name EnemyIdleState
extends EnemyState

@export var idle_time_seconds : float = 1.0;
@export var move_state: EnemyState
@onready var timer : = Timer.new()

func _ready() -> void:
	character.get_node("Collision").disabled = true
	add_child(timer)
	timer.one_shot = true

func enter() -> void:
	character.animation_rig.visible = false
	character.get_node("AnimatedSprite2D").visible = true
	character.get_node("AnimatedSprite2D").play(&"portal")
	super.enter()
	timer.start(randf_range(idle_time_seconds, 1.3))
	timer.timeout.connect(_on_timeout)

func exit() -> void:
	super.exit()
	character.get_node("Collision").disabled = false
	timer.timeout.disconnect(_on_timeout)
	character.get_node("AnimatedSprite2D").visible = false
	character.animation_rig.visible = true

func _on_timeout() -> void:
	var controller: = get_parent() as EnemyController
	if !controller || !move_state:
		return

	controller._change_state(move_state)
