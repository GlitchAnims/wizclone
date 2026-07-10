class_name Buf extends Node

@export var buf_ID: int = -1

func _ready() -> void:
	GameData.bufDict[buf_ID] = self
func _exit_tree() -> void:
	GameData.bufDict.erase(buf_ID)

func GetBozo() -> void:
	pass
