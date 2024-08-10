extends Area2D

@export var data: WeaponData

var _icd: float = 0.0

func _on_body_entered(body):
	Notifications.notify(Bullet.HIT_NOTIFICATION, [null, data, body])


func _physics_process(delta):
	if _icd > data.attack_speed:
		_icd = 0.0
		var enemies: = get_overlapping_bodies()
		if enemies.is_empty():
			return
		for body in enemies:
			Notifications.notify(Bullet.HIT_NOTIFICATION, [null, data, body])
			await get_tree().physics_frame
	_icd += delta
		
