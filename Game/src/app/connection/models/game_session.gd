class_name GameSession
extends RefCounted

enum GameState{
	START,
	RUNNING,
	END
}

var godotSessionId: String = ""
var angularSessionId: String = ""
var backendToken: String = ""
var game_state: GameState
