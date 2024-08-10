@tool
class_name WeaponRig
extends Node2D
# The WeaponRig is a container for weapons that are attached to the player.
# It is responsible for managing the position of the weapons around the player.

# The radius of the circle that the weapons are positioned on.
@export var radius: int
@export var max_weapons: int



# Called when the node enters the scene tree for the first time.
func _ready():
	child_entered_tree.connect(refresh_weapon_positions)
	child_exiting_tree.connect(refresh_weapon_positions)
	Notifications.subscribe(UpgradeSystem.UPGRADED_SELECTED_NOTIFICATION, _on_upgrade_selected)


func _on_upgrade_selected(item: ItemData) -> void:
	if item is WeaponItemData && get_child_count() < GameSettings.MAX_WEAPONS:
		var data: = DataService.get_weapon_by_id(item.weapon) as WeaponData
		if data.scene == null:
			var weapon: = load("res://src/weapons/GenericRangeWeapon/GenericRangeWeapon.tscn").instantiate() as Weapon
			weapon.data = data
			assert(weapon.data)
			add_weapon(weapon)
		else:
			var scene = data.scene.instantiate()
			scene.data = data
			owner.add_child(scene)
			add_weapon(scene)
	elif item is WeaponItemData && get_child_count() >= GameSettings.MAX_WEAPONS:
		var data: = DataService.get_weapon_by_id(item.weapon) as WeaponData
		for old in get_children():
			if old.data.name == data.name && old.data.level +1 == data.level:
				old.data = data
				return

func add_weapon_from_data(data: WeaponData) -> void:
	if get_child_count() < GameSettings.MAX_WEAPONS:
		if data.scene == null:
			var scene: = load("res://src/weapons/GenericRangeWeapon/GenericRangeWeapon.tscn").instantiate() as Weapon
			scene.data = data
			assert(scene.data)
			add_weapon(scene)
		else:
			var scene = data.scene.instantiate()
			scene.data = data
			add_weapon(scene)
				
		#replace_weapon(weapon_instance, weapon_data.slot)
# Add a weapon to the rig.
func add_weapon(weapon: Node2D) -> void:
	if get_child_count() < GameSettings.MAX_WEAPONS:
		add_child(weapon)
		return

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_manual_aim"):
		GameService.get_context().is_manual_aim.set_next(!GameService.get_context().is_manual_aim.value)


# Replace a weapon at a given index with a new weapon.
func replace_weapon(weapon: Weapon, index: int) -> void:
	if index < get_child_count():
		var child = get_child(index)
		remove_child(child)
		add_child(weapon)
		move_child(weapon, index)
		child.queue_free()

# Remove a weapon at a given index.
func remove_weapon(index: int) -> void:
	if index < get_child_count():
		get_child(index).queue_free()

# Order the weapons in a circle around the player
func refresh_weapon_positions(_child: Node) -> void:
	var children = get_children()
	var current = children.size()
	# ! Update the current number of weapons
	var index: int = 0
	for child in children:
		var angle = 2 * PI * index / current;
		angle += PI * ( 1.25 if current == 4 else 1.0);
		child.position = Vector2(radius * cos(angle), radius * sin(angle));
		index += 1
