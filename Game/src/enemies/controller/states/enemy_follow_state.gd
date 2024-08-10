class_name EnemyFollowState
extends EnemyState

@export var idle_state: EnemyState
@export var deadzone: int = 0


func physics_process(delta: float) -> State:
	var direction: Vector2 = character.navigation.get_direction_to_target()

	if (character.data.acceleration != 0.0):
		character.speed = character.data.acceleration

	if direction == Vector2.INF:
		return self
		
	direction = direction - character.global_position

	if direction.length() <= deadzone:
		return self

	character.direction.set_next(direction.normalized())
	var _velocity = character.velocity.move_toward(character.speed * direction.normalized(), character.speed)
	character.set_velocity(_velocity)
	character.move_and_slide()
	return self
