class_name PlayerSystem
extends Node

@export var health_pickup_audio_player: AudioStreamPlayer
@export var level_up_audio_player: AudioStreamPlayer

const PLAYER_DEATH_NOTIFICATION = &"1ef54f27-b05f-4c05-bea1-233c3fbdaaac"
var _stats: GameStats


func _on_game_ready(service: GameService):
	Notifications.subscribe(DeathSystem.get_death_notification(Group.PLAYER), _on_death_system_player_death)
	Notifications.subscribe(GameInventory.ITEM_ADDED_NOTIFICATION, _on_inventory_item_added)
	Notifications.subscribe(GameInventory.ITEM_REMOVED_NOTIFICATION, _on_inventory_item_removed)
	Notifications.subscribe(PlayerExperience.LEVEL_UP_NOTIFICATION, _on_level_up)
	_stats = service.get_stats()	
	Notifications.subscribe(Pickup.PICKED_UP_NOTIFICATION, _on_potion_picked_up)


func _on_death_system_player_death(_arg) -> void:
	# Player died
	Notifications.notify(PLAYER_DEATH_NOTIFICATION)


func _on_inventory_item_added(item: ItemData, amount: int) -> void:
	for mod in item.modifiers:
		var stat := _stats.get_stat(mod.type)
		for i in range(amount):
			stat.add_mod(mod)


func _on_inventory_item_removed(item: ItemData, amount: int) -> void:
	for mod in item.modifiers:
		var stat := _stats.get_stat(mod.type)
		for i in range(amount):
			stat.remove_mod(mod)


func _on_potion_picked_up(heal_amount: int):
	GameService.get_player().health.change_current(heal_amount)
	health_pickup_audio_player.play()


func _on_level_up(level: int, experience: int):
	# Player leveled up
	level_up_audio_player.play()
	GameService.get_player().health.set_maximum(GameService.get_player().health.maximum)
	_stats.get_stat(Enums.StatType.LEVEL).set_base(level)
