class_name UpgradeSystem
extends Node

signal upgrades_changed(upgrades: Array[ItemData])

@export var upgrade_selected_audio_player: AudioStreamPlayer

const UPGRADED_SELECTED_NOTIFICATION: StringName = &"f38b2ba3-6f57-4439-b7c4-36d98ea6ad02"

var remaining_level_ups: ObservableInt = ObservableInt.new(0)
var levelup_waves: Array = []
var upgrades: Array[ItemData] = []
var weapon_shop: = GameService.get_shop_weapons()

@onready var luck_stat: =GameService.get_stats().get_stat(Enums.StatType.LUCK)

func _on_game_ready(service: GameService) -> void:
	Notifications.subscribe(PlayerExperience.LEVEL_UP_NOTIFICATION, _on_level_up)


func _on_level_up(level: int, _experience: int) -> void:
	remaining_level_ups.set_next(remaining_level_ups.value + 1)
	if remaining_level_ups.value > 1:
		levelup_waves.append(GameService.get_game().wave)
		return
	var wave = GameService.get_game().wave
	upgrades = _get_upgrades(GameSettings.DEFAULT_UPGRADE_COUNT, wave)
	upgrades_changed.emit(upgrades)


func select_upgrade(index: int) -> void:
	GameService.get_game().inventory.add_item(upgrades[index])
	Notifications.notify(UPGRADED_SELECTED_NOTIFICATION, [upgrades[index]])
	upgrade_selected_audio_player.play()
	if remaining_level_ups.value <= 0:
		upgrades.clear()
		return

	remaining_level_ups.set_next(remaining_level_ups.value - 1)
	if remaining_level_ups.value > 0:
		var wave = levelup_waves.pop_front()
		upgrades = _get_upgrades(GameSettings.DEFAULT_UPGRADE_COUNT, wave)
		upgrades_changed.emit(upgrades)

func get_rarity_roll(roll: float, wave: int) -> Enums.Rarity:
	if roll < Enums.get_chance(Enums.Rarity.LEGENDARY, wave, luck_stat.value):
		return Enums.Rarity.LEGENDARY
	elif roll < Enums.get_chance(Enums.Rarity.EPIC,wave, luck_stat.value):
		return Enums.Rarity.EPIC
	elif roll < Enums.get_chance(Enums.Rarity.RARE, wave, luck_stat.value):
		return Enums.Rarity.RARE
	return Enums.Rarity.COMMON


func _get_upgrades(count: int, wave: int) -> Array[ItemData]:
	var new_upgrades: Array[ItemData] = []
	var weapon_count = GameService.get_player().weapon_rig.get_child_count()
	
	if wave < 3 && weapon_count < GameSettings.MAX_WEAPONS - 1:
		while new_upgrades.size() < 2:
			var item: = weapon_shop.get(Enums.Rarity.COMMON + 1).pick_random() as ItemData
			assert(item != null)
			if new_upgrades.size() == 0:
				new_upgrades.append(item)
				continue
			if item.name == new_upgrades[0].name:
				continue
			new_upgrades.append(item)


		assert(new_upgrades.size() != 0)

	elif weapon_count < GameSettings.MAX_WEAPONS && wave < 6:
		var rarity: = get_rarity_roll(randf(), wave)
		new_upgrades.append(weapon_shop.get(rarity +1).pick_random())

	elif weapon_count == GameSettings.MAX_WEAPONS:
		var rarity: = get_rarity_roll(randf(), wave)
		if rarity == Enums.Rarity.RARE:
			for child in GameService.get_player().weapon_rig.get_children():
				assert(child is Weapon)
				assert(child.data)
				var data: = child.data as WeaponData
				if data.level == 1:
					new_upgrades.append(WeaponItemData.new(DataService.get_weapon_by_id(data.id + 1), 1))
					break
		elif rarity == Enums.Rarity.EPIC:
			for child in GameService.get_player().weapon_rig.get_children():
				assert(child is Weapon)
				assert(child.data)
				var data: = child.data as WeaponData
				if data.level == 2 :
					new_upgrades.append(WeaponItemData.new(DataService.get_weapon_by_id(data.id + 1), 1))
					break

	while new_upgrades.size() < count:
		var upgrade = DataService.item_data.pick_random()
		if !upgrade || new_upgrades.has(upgrade):
			continue
		new_upgrades.append(upgrade)
	if OS.is_debug_build():
		for upgrade in new_upgrades:
			assert(upgrade != null, "Upgrade is null")
	return new_upgrades

