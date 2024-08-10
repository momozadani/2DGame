class_name Game
extends Node2D
## The main game class. This class is responsible for managing the game state, and the game loop.

# signals
## emitted when the game session is closed (e.g. the player quits, or the game is over)
signal game_closed(victory: bool, items: Array)

var inventory: GameInventory
var stats: GameStats
var context: GameContext
var player: PlayerCharacter
var timer: Timer 
var map: Map
var wave: int = 1
var difficulty: Enums.Difficulty = Enums.Difficulty.EASY

@onready var camera: CameraRig = %CameraRig
@onready var _pause_container: Node2D = %PauseContainer

func _ready():
	Notifications.subscribe(VictorySystem.GAMEOVER_NOTIFICATION, _on_gameover)
	_pause_container.add_child(map,true)
	_pause_container.add_child(player)
	_pause_container.add_child(timer)
	timer.start()
	camera.set_limit(map.camera_rect.position.y, map.camera_rect.end.x , map.camera_rect.end.y, map.camera_rect.position.x)
	camera.set_target(player)
	context.is_game_paused.value_changed.connect(_on_is_game_paused_changed)	
	context.is_started.set_next(true)
	propagate_call("_on_game_ready", [GameService])


func _on_is_game_paused_changed(is_paused: bool, observable) -> void:
	var pause_container: Node = $PauseContainer
	pause_container.process_mode = Node.PROCESS_MODE_DISABLED if is_paused else Node.PROCESS_MODE_INHERIT

# * Process the gameover event
func _on_gameover(is_win: bool) -> void:
	if is_win:
		context.is_gamewon.set_next(true)
	else:
		context.is_gameover.set_next(true)
		timer.paused = true
	await get_tree().create_timer(GameSettings.gameover_wait_time).timeout
	player.set_process_mode(Node.PROCESS_MODE_DISABLED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("magickey_end_game") && OS.is_debug_build():
		_on_death_screen_gameover_processed()

func _on_death_screen_gameover_processed():
	var items: Array = []
	for item in inventory.get_all_items():
		for i in range(item.count.value):
			if item.data is WeaponItemData:
				print(item.data.weapon)
				items.append(DataUtility.entitiy_to_shop_item(DataService.get_weapon_by_id(item.data.weapon)))
			else:
				print(item.data.id)
				items.append(DataUtility.entitiy_to_shop_item(DataService.get_item_by_id(item.data.id)))
	game_closed.emit(context.is_gamewon.value, items)
