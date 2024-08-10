class_name DataUtility
extends Node

@export_dir var target_directory
@export var rebuild_resources: bool = false

const test: Dictionary = {
  "version": "1",
  "items":  [
	{
	  "name":  "Pistole",
	  "identifier": "weapon_pistol",
	  "description":  "Ich bin eine Pistole",
	  "price":  1500,
	  "imageName":  "godot-icon.png",
	  "itemType": "ITEM_WEAPON",
	  "maxBuyCount": 1
	},
	{
	  "name": "Chronos",
	  "identifier": "player_chronos",
	  "description": "Chronos ist in der griechischen Mythologie die Personifizierung der Zeit. Er wird teilweise mit dem Titanen Kronos identifiziert. Er versinnbildlicht den Ablauf der Zeit und die Lebenszeit.",
	  "price": 10000,
	  "imageName": "godot-icon.png",
	  "itemType": "ITEM_PLAYER",
	  "maxBuyCount": 1
	},
	{
	  "name":  "Damage Boost",
	  "identifier": "stat_damage",
	  "description":  "Durch mich machst du 5% mehr Schaden",
	  "price":  100,
	  "imageName":  "godot-icon.png",
	  "itemType": "ITEM_STAT",
	  "maxBuyCount": 50
	}
  ],
  "maps": [
	{
	  "name": "Standard Map",
	  "identifier": "default_map",
	  "imageName": "godot-icon.png"
	}
  ],
  "difficulties": [
	{
	  "name": "Anfänger",
	  "identifier": "beginner"
	},
	{
	  "name": "Mittel",
	  "identifier": "medium"
	},
	{
	  "name": "Schwer",
	  "identifier": "hard"
	},
	{
	  "name": "Experte",
	  "identifier": "expert"
	},
	{
	  "name": "Codename-B",
	  "identifier": "codenameb"
	}
  ]
}

const ITEM_PLAYER: String = "ITEM_PLAYER"
const ITEM_WEAPON: String = "ITEM_WEAPON"
const ITEM_STAT: String = "ITEM_STAT"


const ITEM_TYPE_STRING: = ["ITEM_PLAYER", "ITEM_WEAPON", "ITEM_STAT"]
const BASE_ITEM: Dictionary = {
  "name": "",
  "identifier": "",
  "description": "",
  "price": 0,
  "imageName": "",
  "itemType": "",
  "maxBuyCount": 0
}

const BASE_MAP: Dictionary = {
	  "name": "",
	  "identifier": "",
	  "imageName": ""
	}

func _get_tool_buttons():
	return [
		export_data
	]

const SHOP_DIR: String = "/shop"
const IMG_DIR: String = "/img"
const SHOP_FILE: String = "shop.json"
const PREFIX_WEAPON: String = "weapon_"
const PREFIX_PLAYER: String = "player_"
const PREFIX_STAT: String = "stat_"


static func entitiy_to_shop_item(entity) -> Dictionary:
	if not entity:
		return {}
	var item = BASE_ITEM.duplicate()
	item["name"] = entity.full_name
	if entity is WeaponData:
		var identifier: String = str(entity.id,"_") + PREFIX_WEAPON
		identifier += entity.name
		item["identifier"] = identifier
		item["itemType"] = ITEM_WEAPON
	elif entity is ItemData:
		var identifier: String = str(entity.id,"_") + PREFIX_STAT
		identifier += entity.name
		item["identifier"] = identifier
		item["itemType"] = ITEM_STAT
	item["description"] = entity.description
	item["price"] = entity.price
	item["imageName"] = IMG_DIR + "/%s.png" % item["identifier"]
	item["maxBuyCount"] = entity.max_count
	return item


func export_upgrades(data_service) -> Array[Dictionary]:
	print("Upgrades")
	var upgrades: Array[Dictionary] = []
	if data_service.item_data.is_empty():
		print("No Upgrades found")
		return []	
	for upgrade in data_service.item_data:
		if upgrade.price ==0:
			continue
		var item = BASE_ITEM.duplicate()
		item["name"] = upgrade.full_name
		var identifier: String = str(upgrade.id,"_") + PREFIX_STAT
		identifier += upgrade.name
		item["identifier"] = identifier
		item["description"] = upgrade.get_description()
		item["price"] = upgrade.price
		item["imageName"] = save_image(upgrade.icon, item["identifier"])
		item["itemType"] = ITEM_TYPE_STRING[2]
		item["maxBuyCount"] = upgrade.max_count
		upgrades.append(item)
	return upgrades as Array[Dictionary]


func export_characters(data_service) -> Array[Dictionary]:
	print("Characters")
	var characters: Array[Dictionary] = []
	if data_service.character_data.is_empty():
		print("No Characters found")
		return []
	for character in data_service.character_data:
		var item = BASE_ITEM.duplicate()
		item["name"] = character.full_name
		var identifier: String = str(character.id,"_") + PREFIX_PLAYER
		identifier += character.name
		item["identifier"] = identifier
		item["description"] = character.description
		item["price"] = character.price if character.id > 1	else 0
		var thumbnail: Texture = load(character.thumbnail)
		item["imageName"] = save_image(thumbnail, item["identifier"])
		item["itemType"] = ITEM_TYPE_STRING[0]
		item["maxBuyCount"] = 1
		characters.append(item)
	return characters as Array[Dictionary]


func export_weapons(data_service) -> Array[Dictionary]:
	print("Weapons")
	var weapons: Array[Dictionary] = []
	if data_service.weapon_data.is_empty():
		print("No Weapons found")
		return []
	for weapon in data_service.weapon_data:
		if weapon.price == 0:
			continue
		var item = BASE_ITEM.duplicate()
		item["name"] = weapon.full_name
		var identifier: String = str(weapon.id,"_") + PREFIX_WEAPON
		identifier += weapon.name
		item["identifier"] = identifier
		item["description"] = weapon.description 
		item["price"] = weapon.price
		item["imageName"] = save_image(weapon.icon, item["identifier"])
		item["itemType"] = ITEM_TYPE_STRING[1]
		item["maxBuyCount"] = 1
		weapons.append(item)
	return weapons as Array[Dictionary]


func export_maps(data_service) -> Array[Dictionary]:
	print("Maps")
	var maps: Array[Dictionary] = []
	if data_service.map_data.is_empty():
		print("No Maps found")
		return []
	for map in data_service.map_data:
		var item = BASE_MAP.duplicate()
		item["name"] = map.name
		var identifier: String = str(map.id,"_") + "map_"
		identifier += item["name"]
		item["identifier"] = identifier
		item["imageName"] = save_image(map.thumbnail, item["identifier"])
		maps.append(item)
	return maps as Array[Dictionary]


func save_image(texture: Texture2D, identifier: String) -> String:
	if texture == null:
		return ""
	var image: Image = texture.get_image()
	var path: String = "res://build%s/%s" % [SHOP_DIR, IMG_DIR]
	path += "/%s.png" % identifier
	image.save_png(path)
	print("Export image from id: %s to %s" %[identifier, path])
	#print("Error %d" % image.get_error())
	return "/img/%s.png" % identifier

func _ready():
	export_data()


var files: Array[String]

func add_files(dir: String):
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() == "tscn" or file.get_extension() == "tres":
			files.append(dir.path_join(file))
	
	for dr in DirAccess.get_directories_at(dir):
		if dr == "addons" || dr == ".godot"  || dr == ".vscode":
			continue
		add_files(dir.path_join(dr))

func export_data():
	if !Engine.is_editor_hint() || rebuild_resources:
		files = []
		
		add_files("res://")
		
		for file in files:
			print("Loading File: %s" % file)
			var res = load(file)
			print("Resaving File: %s" % file)
			var error = ResourceSaver.save(res)
			if error != OK:
				printerr("Error resaving file: %s CODE: %d MESSAGE:" % [file, error, error_string(error)])

		print("Rebuilding Database")
		var error = DataService.build_db()
		if error != OK:
			printerr("Error rebuilding database: %d %s" % [error, error_string(error)])
		else:
			print("Database rebuilded")

	print("Start")
	var data_service = load("res://src/core/singletons/data_service/data_service.tscn").instantiate() if Engine.is_editor_hint() else DataService
	if Engine.is_editor_hint():
		add_child(data_service)
		data_service.owner = self
		
	var dir: = DirAccess.open(target_directory)
	print(dir)
	print(dir.dir_exists(target_directory+SHOP_DIR))
	if dir.dir_exists(target_directory+SHOP_DIR):
		print("DirExists")
		dir.remove(SHOP_DIR)
		print("Removed old shop directory")
	print("MakeDir")
	dir.make_dir_recursive(target_directory + SHOP_DIR + IMG_DIR)
	dir.change_dir(SHOP_DIR)
	print(dir.change_dir("shop"))
	
	var path: String = "res://build%s/%s" % [SHOP_DIR, SHOP_FILE]
	print("Open File: %s" % path)
	var gdignore: = FileAccess.open("res://build%s/%s" % [SHOP_DIR, ".gdignore"], FileAccess.WRITE)
	gdignore.close()
	
	var file: = FileAccess.open(path, FileAccess.WRITE)

	var data: = test.duplicate()
	data["items"] = []
	data["items"] += export_characters(data_service)
	data["items"] += export_weapons(data_service)
	data["items"] += export_upgrades(data_service)
	data["maps"] = export_maps(data_service)

	file.store_string(JSON.stringify(data))
	file.close()

	if Engine.is_editor_hint():
		remove_child(data_service)
		data_service.free()
		
	print("Export Done")
	await get_tree().create_timer(1).timeout
	await get_tree().create_timer(10).timeout
	get_tree().quit()
