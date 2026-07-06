class_name Firefist extends Unit

#@onready var Act_Node: AnimationPlayer = $"Act"

func _physics_process_unit(_delta: float) -> void:
	
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

func PsychBlast() -> void:
	print("BOOM")
