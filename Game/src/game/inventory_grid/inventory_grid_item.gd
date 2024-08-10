class_name InventoryGridItem 
extends Control

var id: int = -1

@onready var _icon: TextureRect = %Icon
@onready var _count: Label = %LabelCount

func refresh(item: GameInventory.ItemWrapper) -> void:
	var data: ItemData = item.data
	_icon.texture = data.icon
	_icon.show()
	_count.text = str(item.count.value)
	item.count.value_changed.connect(_set_item_count)


func _set_item_count(count: int, _sender) -> void:
	_count.text = str(count)
