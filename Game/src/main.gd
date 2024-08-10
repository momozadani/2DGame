extends Node

const TOKEN: String = "token"
const SESSION_ID: String = "session_id"
const ACTION: String = "action"
const FROM_USER: String = "fromUser"
const TO_USER: String = "toUser"
const GAME_START_PARAMETERS = "gameStartParameters"
const KEY_CHARACTER: String = "character"
const KEY_MAP: String = "map"
const KEY_DIFFICULTY: String = "difficulty"
const KEY_GAMESTATE: String = "gameState"
const KEY_ITEMS: String = "items"
const ACTION_GET_SESSION_ID: String = "GET_SESSION_ID";
const ACTION_SEND_SESSION_ID: String = "SEND_SESSION_ID";
const PARAM_GAME_STATE: String = "gameState";
const PARAM_CHARACTER: String = "character";
const PARAM_DIFFICULTY: String = "difficulty";
const PARAM_ITEMS: String = "items";
const PARAM_MAP: String = "map";

@export var _client: WebSocketClient
@export var _bridge: JavaScriptBridgeWrapper
@export var _ui_lobby: DebugLobbyMenu

var game: Game
var session: GameSession

func _ready() -> void:
	_ui_lobby.button_force_start.pressed.connect(_on_game_game_started)
	_client.data_received.connect(_on_data_received)
	_client.connection_closed.connect(_on_connection_closed)
	_client.connection_established.connect(_on_client_connection_established)
	_bridge.bridge_called.connect(_on_bridge_called)

## build game from backend data
func create_game_from_data(data) -> void:
	Debug.print(typeof(data))
	if not data is Dictionary && not data is String:
		Debug.print("Invalid data type for game creation")
		return

	if not data is Dictionary:
		data = JSON.parse_string(data)

	var player_data: PlayerCharacterData
	var map_data: MapData
	var difficulty: int
	var items: Array

	var dict: = data as Dictionary
	for key in dict.keys():
		match key:
			KEY_CHARACTER:
				player_data = DataService.convert_shop_data_to_id(dict[key])
				continue
			KEY_MAP:
				map_data = DataService.get_map_by_id(1)
				continue
			KEY_DIFFICULTY:
				difficulty = int(dict[key].get("id")) if dict[key] is Dictionary && dict[key].has("id") else 1
				continue
			KEY_ITEMS:
				var shop_items: Array = dict[key]
				if not shop_items is Array || shop_items.is_empty():
					Debug.print("Invalid items data for game creation or empty")
					continue
				items = []
				for item in shop_items:
					var entity = DataService.convert_shop_data_to_id(item)
					if not entity is ItemData || not entity is WeaponData:
						Debug.print("Invalid item data for game creation %s" % str(item))
						continue
					items.append(DataService.convert_shop_data_to_id(item))
				continue
			KEY_GAMESTATE:
				match dict[key]:
					"START":
						if session:
							session.game_state = GameSession.GameState.START
					_:
						Debug.print("Unexpected game state: %s" % dict[key])
						continue
	
	if !player_data or !map_data:
		Debug.print("Invalid data for game creation Player: %s Map %s items %s" % [player_data, map_data, items])
		return
	if OS.is_debug_build():
		await get_tree().create_timer(5.0).timeout
	game = NodeEx.add_child(GameService.create_game(player_data, map_data, items, difficulty), self)
	game.game_closed.connect(_on_game_game_closed)
	_ui_lobby.close()

func _on_game_game_started() -> void:
	create_game_from_data({
  "gameState": "START",
  "character": {
	"id": 1,
	"name": "Aurelius",
	"identifier": "01_default_character",
	"price": 0,
	"imageName": "godot-icon.png",
	"itemType": "ITEM_PLAYER",
	"maxBuyCount": 1
  },
  "map": {
	"id": 1,
	"name": "Standard Map",
	"identifier": "default_map",
	"imageName": "godot-icon.png"
  },
  "difficulty": {
	"id": 1,
	"name": "Codename-B",
	"identifier": "codenameb"
  },
  "items": [
	{
	  "id": 1,
	  "name": "Aurelius",
	  "identifier": "01_default_character",
	  "price": 0,
	  "imageName": "godot-icon.png",
	  "itemType": "ITEM_PLAYER",
	  "maxBuyCount": 1
	},
	{
	  "id": 2,
	  "name": "Macht",
	  "identifier": "01_asdasd",
	  "price": 100,
	  "imageName": "stat_deine_mom.png",
	  "itemType": "ITEM_STAT",
	  "maxBuyCount": 10
	},
	{
	  "id": 3,
	  "name": "Feuerball",
	  "identifier": "default_weapon",
	  "price": 0,
	  "imageName": "godot-icon.png",
	  "itemType": "ITEM_WEAPON",
	  "maxBuyCount": 1
	}
  ]
})
	# Replace with actual data from the angular app
	# _ui_lobby.close()
	# var player = 1
	# var map: int = 1
	# var weapon: PackedScene = load("res://src/weapons/WeaponBase.tscn")
	# var weapons: Array[PackedScene] = [weapon]
	# var settings = Node
	# _ui_lobby.hide()
	# var game = NodeEx.add_child(GameService.create_game(DataService.get_character_by_id(player), map, Resource.new(), weapons), self)# 
	# game.game_closed.connect(_on_game_game_closed)

func _on_game_game_closed(is_win: bool, items: Array) -> void:
	#get_tree().quit()
	_ui_lobby.show()


func _on_data_received(data) -> void:
	Debug.print("Data received from Backend: " + data)
	var dataDict: Dictionary = self.parse_backend_session_response(data)
	
	if dataDict[ACTION] == "response_id_created":
		Debug.print("Setting godot session id: " + dataDict[FROM_USER])
		self.session.godotSessionId = dataDict[FROM_USER]
		Debug.print("Responding with the new godotSessionId!")
		_client.send_data(JSON.stringify({
			ACTION: ACTION_SEND_SESSION_ID,
			TOKEN: session.backendToken,
			FROM_USER: session.godotSessionId,
			TO_USER: session.angularSessionId
		}))

	if dataDict[ACTION] == "POST_GAME":
		Debug.print("Posting new game data!")
		if dataDict[TO_USER] == session.godotSessionId and dataDict[FROM_USER] == session.angularSessionId:
			Debug.print("Authenticated message in godot!")
			# self.set_game_session_params(dataDict[GAME_START_PARAMETERS])
	if dataDict.has(GAME_START_PARAMETERS):
		create_game_from_data(dataDict[GAME_START_PARAMETERS])


func _on_connection_closed() -> void:
	print("Connection closed")
 
func _on_bridge_called(session_info: Dictionary) -> void:
	session = GameSession.new()	
	for key in session_info.keys():
		match key:
			TOKEN:
				Debug.print("Token set to: " + str(session_info.get(TOKEN)))
				session.backendToken = session_info.get(key)
			SESSION_ID:
				Debug.print("SessionId set to: " + str(session_info.get(SESSION_ID)))
				session.angularSessionId = session_info.get(key)
			_:
				Debug.print("Undefined key: %s found in session_info" % key)
	
	if session.backendToken == null or session.angularSessionId == null:
		Debug.print("Token or angularSessionId not found in session_info: %s" % session_info)
		return

	_client.connect_to_host()

func _on_client_connection_established():
	Debug.print("Connection established! Sending websocket data!")
	_client.send_data(JSON.stringify({
		ACTION: ACTION_GET_SESSION_ID,
		TOKEN: session.backendToken,
		FROM_USER: ''
	}))
	

func parse_backend_session_response(response: String) -> Dictionary:
	Debug.print("Parsing!")
	var json = JSON.new()
	var error = json.parse(response)
	if error == OK:
		return json.data
	else:
		Debug.print("Error when parsing backend JSON")
		return Dictionary()
		
# func set_game_session_params(data: Dictionary) -> void:
# 	Debug.print("Setting game session parameter!")
# 	var nextStartParams: StartParams = StartParams.new("", Dictionary(), Dictionary(), Dictionary(), [])
# 	nextStartParams.gameState = data[self.PARAM_GAME_STATE]
# 	nextStartParams.character = data[self.PARAM_CHARACTER]
# 	nextStartParams.difficulty = data[self.PARAM_DIFFICULTY]
# 	nextStartParams.map = data[self.PARAM_MAP]
# 	nextStartParams.items = data[self.PARAM_ITEMS]


# private String gameState;
# private ShopItem character;
# private Map map;
# private Difficulty difficulty;
# private List<ShopItem> items;

# func parse_dict_to_shop_item(dict: DictionaVry) -> String:
	# pass
