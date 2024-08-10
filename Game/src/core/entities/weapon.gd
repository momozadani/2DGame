class_name Weapon
extends Area2D

signal shot(_rotation: float, _data: WeaponData)

@export var data: WeaponData
@export var is_manual_shooting: bool = false :
	set(value):
		is_manual_shooting = value
		set_process(value)
		set_physics_process(!value)
		print("is_manual_shooting")
				
@export var aim_range: CollisionShape2D
@export var audio_player: AudioStreamPlayer

var attack_speed_binding: float
var attack_speed_multi: float :
	get:
		return maxf(data.attack_speed / ((100 + attack_speed_binding)/100), 0.02)

var delay_multi: float :
	get:
		return maxf(data.delay / ((attack_speed_binding + 100)/100), 0.01)

@onready var _reload: Timer = %Reload
@onready var _delay: Timer = %Delay


func _ready() -> void:
	GameService.get_context().is_manual_aim.bind(self,&"is_manual_shooting")
	aim_range = get_node_or_null("Range")
	if aim_range == null:
		aim_range = get_node_or_null("ThrowRange")
	if data:
		(aim_range.shape as CircleShape2D).radius = data.attack_range + GameService.get_stats().get_stat(Enums.StatType.RANGE).value

	GameService.get_stats().get_stat(Enums.StatType.ACTION_SPEED).bind(self, &"attack_speed_binding")	
	GameService.get_stats().get_stat(Enums.StatType.RANGE).value_changed.connect(func(value: float) -> void:
		aim_range.shape.radius = data.attack_range + GameService.get_stats().get_stat(Enums.StatType.RANGE).value
	)	

	set_process(is_manual_shooting)
	set_physics_process(!is_manual_shooting)


func _physics_process(delta):
	if !can_shot():
		return
	var processing: bool = false
	if data.pattern == WeaponData.Pattern.CONE:
		var closest_enemy: Node2D
		var enemies_in_range: = get_overlapping_bodies()
		# if only one enemy in range, look at it
		if enemies_in_range.size() == 1:
			closest_enemy = enemies_in_range[0]
		# if more than one enemy in range, get the nearest one
		elif !enemies_in_range.is_empty():
			# distance to the nearest enemy squared
			var distance_squared: float = Vector2.INF.x
			for enemy in enemies_in_range:
				# the first enemy is the nearest one
				if !closest_enemy:
					closest_enemy = enemy
					distance_squared = enemy.global_position.distance_squared_to(global_position)
					continue

				var distance = enemy.global_position.distance_squared_to(global_position)
				if distance < distance_squared:
					distance_squared = distance
					closest_enemy = enemy

		if is_instance_valid(closest_enemy):
			# _pivot.look_at(closest_enemy.global_position)
			# flip the weapon sprite if the enemy is behind the weapon
			# _weapon.flip_v= _pivot.global_rotation_degrees > 90 or _pivot.global_rotation_degrees < -90	
			if can_shot(): 
					shoot(global_position.angle_to_point(closest_enemy.global_position + Vector2(0,33)))
	elif data.pattern == WeaponData.Pattern.CIRCLE:
		shoot(0.0)
	
	elif data.pattern == WeaponData.Pattern.RANDOM:
		if get_overlapping_bodies().is_empty():
			return
		shoot(0.0)
		#Notifications.notify(ProjectileEmitter.EMIT_NOTIFICATION, [global_position, 0.0, data])
		

func _process(delta):
	if Input.is_action_pressed("left_mouse"):
		if !can_shot():
			return
	
		var angle: float
		if data.pattern == WeaponData.Pattern.CONE:
			shoot(global_position.angle_to_point(get_global_mouse_position()))
		elif data.pattern == WeaponData.Pattern.CIRCLE:
			shoot(0.0)
		else:		
			var bodies: = get_overlapping_bodies()	
			for i in range(data.targets):
				shoot(0.0)


func shoot(angle: float):		
	shot.emit(angle, data)
	print("Weapon" + str(global_position))
	Notifications.notify(ProjectileEmitter.EMIT_NOTIFICATION, [global_position, angle, data])
	_reload.start(attack_speed_multi)
	audio_player.play()
	if is_manual_shooting:
		set_process(false)
	else:
		set_physics_process(false)


func _on_timer_timeout():
	_reload.stop()
	if is_manual_shooting:
		set_process(true)
	else:
		set_physics_process(true)
	
func can_shot():
	return _reload.is_stopped() && _delay.is_stopped()

		

