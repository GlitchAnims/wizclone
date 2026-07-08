class_name Firefist extends Unit

#@onready var Act_Node: AnimationPlayer = $"Act"

var stance: int = 0

var smoothenergyincrease: float = 0
func _physics_process_unit(delta: float) -> void:
	var spawnvisual: bool = not GameData.isDedicated
	
	if stance > 0:
		var pos: Vector3 = position + Vector3(0,0.5,0)
		var attack_pos: Vector3 = mouse_worldPos + Vector3(0,0.5,0)
		var attack_vec: Vector3 = attack_pos - pos
		match stance:
			1:
				smoothenergyincrease += 50 * delta
				if smoothenergyincrease > 0:
					var value: int = floor(smoothenergyincrease)
					smoothenergyincrease -= value
					energy1 += value
				
				if spawnvisual:
					pass

func EnactSkill() -> void:
	
	if GameData.isServer:
		match skill_selected_i:
			0:
				pass
				#Act_Node.play(&"Act_Order")

func CompleteSkill() -> void:
	#Act_Node.stop(false)
	pass

func _ActivateCard_Unit(_card: CardTibia, cardconfig: CardConfig) -> void:
	var card_identifier: StringName = cardconfig.identifier
	match card_identifier:
		&"og_firefist_flamethrow":
			Authority_EnterStance.rpc(1)
		&"og_firefist_firefist":
			Authority_EnterStance.rpc(1)
		&"og_firefist_fuel":
			Authority_EnterStance.rpc(1)

@rpc("authority", "call_local", "reliable")
func Authority_EnterStance(mode: int) -> void:
	stance = mode
