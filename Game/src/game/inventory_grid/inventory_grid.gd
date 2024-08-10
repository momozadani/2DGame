class_name InventoryGrid
extends Control
# * Inventory window inside the pause menu

var _register: Dictionary = {}
var _max_slots: int
@onready var grid: GridContainer = %GridContainer

func _ready() -> void:
	_max_slots = grid.get_children().size()
	Notifications.subscribe(GameInventory.ITEM_ADDED_NOTIFICATION, _on_inventory_item_added)


func _on_inventory_item_added(item: ItemData, added_count) -> void:
	if _register.has(item.id):
		return

	var index = _register.values().size()
	if index >= _max_slots:
		printerr("maximum slots reached")
		return

	var grid_item: = grid.get_children()[index] as InventoryGridItem
	assert(grid_item.id == -1, "Slot is not empty!")
	
	_register.get_or_add(item.id, grid_item)
	
	# build tooltip
	var tooltip: String = item.name + "\n"
	tooltip += item.get_description() + "\n"
	for mods in item.modifiers:
		tooltip += mods.get_value_string() + " " + DataService.get_stat_by_id(mods.type).name + "\n"
	tooltip += "ID: " + str(item.id) + "\n"
	grid_item.tooltip_text = tooltip

	grid_item.id = item.id
	grid_item.refresh(GameService.get_game().inventory.get_item_by_name(item.name))

