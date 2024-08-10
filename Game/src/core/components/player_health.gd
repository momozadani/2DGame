class_name PlayerHealth
extends Health

signal max_health_changed(current: int, maximum: int)

@onready var _chp_stat: = GameService.get_stats().get_stat(Enums.StatType.HEALTH)
@onready var _mhp_stat: = GameService.get_stats().get_stat(Enums.StatType.MAX_HEALTH)

func _ready():
	current = maximum
	_chp_stat.set_base(current)
	_mhp_stat.value_changed.connect(set_maximum)
	
func set_current(value: int):
	current = mini(maximum, value)
	_chp_stat.set_base(current)
	health_changed.emit(current)

func set_maximum(value: int):
	maximum = value
	if current > maximum:
		current = maximum
		_chp_stat.set_base(current)
	max_health_changed.emit(current, maximum)
