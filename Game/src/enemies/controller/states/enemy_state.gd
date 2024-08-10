class_name EnemyState
extends State

var character : EnemyCharacter :
	get:
		return (get_parent() as EnemyController).character
