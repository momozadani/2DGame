extends Node

var _shop: Dictionary = {}
var _game: Game
var _map_id: int
var d
var _is_game_active: bool = false

func create_game(player_data: PlayerCharacterData, map_data: MapData, start_items: Array, difficulty: int) -> Game:
	_game = (load("res://src/game/Game.tscn")).instantiate()
	_is_game_active = true
	for value in Enums.Rarity.values():
		_shop[value] = []
		for weapon in DataService.weapon_data:
			if weapon == null || weapon.price != 0:
				continue
			if Enums.Rarity.values()[weapon.level] == value:
				_shop[value].append(WeaponItemData.new(weapon, 1))
		
	
	_game.player = _create_player(player_data)
	_game.stats = _game.player.stats
	_game.inventory = GameInventory.new()
	_game.timer = Timer.new() 
	_game.timer.wait_time = GameSettings.DEFAULT_ROUND_TIME
	_game.timer.one_shot = true
	_game.context = GameContext.new() 
	_game.map = load(map_data.scene).instantiate() as Map
	_game.difficulty = Enums.Difficulty.values()[difficulty - 1]
	for item in start_items:
		if item.modifiers.is_empty():
			continue
		for mod in item.modifiers:
			if mod is WeaponData:
				_shop.get(mod.level - 1).append(WeaponItemData.new(mod, 1))
				continue
			_game.stats.add_mod(mod)
	_shop.get(player_data.base_weapon.level).append(WeaponItemData.new(player_data.base_weapon, 1))		
	

	_game.game_closed.connect(_on_game_close)
	
		

	return _game

func _on_game_close(a,b) -> void:
	_game.player.free()
	_game.stats.free()
	_game.inventory.free()
	_game.map.queue_free()
	_game.queue_free()
	_is_game_active = false


func _create_player(player_data: PlayerCharacterData) -> PlayerCharacter:
	var stats: = GameStats.new()
	stats.set_stat(Enums.StatType.LEVEL, GameSettings.BASE_LEVEL)
	stats.set_stat(Enums.StatType.MAX_HEALTH, player_data.base_health)
	if !player_data.base_modifiers.is_empty():
		for mod in player_data.base_modifiers:
			stats.add_mod(mod)
			
	var _player: = load(player_data.scene).instantiate() as PlayerCharacter
	_player.stats = stats
	_player.weapon_rig.add_weapon_from_data(player_data.base_weapon)

	return _player

func get_game() -> Game:
	return _game

func get_player() -> PlayerCharacter:
	return _game.player

func get_enemies() -> Array[Node]:
	if OS.is_debug_build():
		for enemy in get_tree().get_nodes_in_group(Group.ENEMY):
			assert(enemy is EnemyCharacter, "Enemy is type of %s" % str(typeof(enemy)))
	return get_tree().get_nodes_in_group(Group.ENEMY)

func get_context() -> GameContext:
	return _game.context

func get_stats() -> GameStats:
	return _game.stats if _game && _game.stats else null
	
func get_timer() -> Timer:
	return _game.timer

func get_map() -> MapData:
	return DataService.get_map_by_id(_map_id)



func get_shop_weapons() -> Dictionary:
	return _shop
