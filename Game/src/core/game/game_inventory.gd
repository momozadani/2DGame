class_name GameInventory
extends Object

## Notification sent when an item is added to the inventory (ItemData, amount added)
const ITEM_ADDED_NOTIFICATION: StringName = &"31f51f09-b63d-4adc-872b-26f56929d905"
## Notification sent when an item is added to the inventory (ItemData, amount removed)
const ITEM_REMOVED_NOTIFICATION: StringName = &"dd264507-ba25-4496-ab25-ac688f352355"

var _inventory: = {}

#func _init() -> void:
	#Notifications.subscribe(UpgradeSystem.UPGRADED_SELECTED_NOTIFICATION, 
		#func(item: ItemData) -> void:
		#add_item(item))

## Adds an item to the inventory
func add_item(item: ItemData, count: int = 1) -> void:
	var wrapper: = _inventory.get_or_add(item.name, ItemWrapper.new(item)) as ItemWrapper
	wrapper.count.set_next(wrapper.count.value + count)
	Notifications.notify(ITEM_ADDED_NOTIFICATION, [item, count])

# * Currently no need to remove items
# * When added needs confirmation dialog before removing
## Removes an item from the inventory
# func remove_item(item: ItemData, count: int = 1) -> void:
# 	if !_inventory.has(item.name):
# 		return
# 	var wrapper: = _inventory[item.name] as ItemWrapper
# 	# Ensure we don't remove more items than we have
# 	count = mini(wrapper.count, count)
# 	wrapper.count -= count
# 	Notifications.notify(ITEM_REMOVED_NOTIFICATION, [item, count])

# 	if wrapper.count <= 0:
# 		_inventory.erase(item.name)

func get_item_by_name(name: StringName) -> ItemWrapper:
	if !_inventory.has(name):
		return null
	return _inventory.get(name) as ItemWrapper


## Returns the number of items of the given type in the inventory
func get_all_items() -> Array[ItemWrapper]:
	var items: Array[ItemWrapper] = []
	for item in _inventory.values():
		items.append(item as ItemWrapper)
	return items


## Wrapper for an item in the inventory
class ItemWrapper extends RefCounted:
	var data: ItemData
	var count: ObservableInt 

	func _init(item: ItemData) -> void:
		self.data = item
		self.count = ObservableInt.new(0)
