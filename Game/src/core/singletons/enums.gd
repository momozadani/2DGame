class_name Enums

enum StatType {
	HEALTH,
	MAX_HEALTH,
	DAMAGE,
	DEFENSE,
	DODGE,
	ACTION_SPEED,
	MOVE_SPEED,
	LEVEL,
	ENEMY_DAMAGE,
	ENEMY_DEFENSE,
	CRITICAL_CHANCE,
	AREA,
	LUCK,
	RANGE,
	THORNS,
}

enum ModType { MULITPLICATIVE, ADDITIVE}

enum Rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

static func get_chance(rarity: Rarity, wave: int, luck:int = 0) -> float:
	match rarity:
		Rarity.COMMON:
			return 1.0
		Rarity.RARE:
			return ((0.16*(wave - 1) + 0.0) * (luck * 0.01))
		Rarity.EPIC:
			return ((0.09*(wave - 3) + 0.0) * (luck * 0.01))
		_:
			return 0.0

## Standard sizes for objects and ranges
enum Size {
	POINT = 30,
	SMALL = 50,
	MEDIUM = 100,
	LARGE = 150,
	GIANT = 250,
}

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	INSANE,
	BALLERN,
}

static func get_difficulty_dmg_multi(difficulty: Difficulty) -> float:
	match difficulty:
		Difficulty.HARD:
			return 1.12
		Difficulty.INSANE:
			return 1.24
		Difficulty.BALLERN:
			return 1.4
		_:
			return 1.0

enum ItemType{
	CHARACTER = 0,
	WEAPON = 1,
	UPGRADE = 2,
}
