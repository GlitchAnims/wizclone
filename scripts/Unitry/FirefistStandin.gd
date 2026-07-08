class_name FirefistStandin extends Standin


@onready var Sprite_Node: AnimatedSprite3D = $"GegorSprite"
@onready var FlamethrowerParticles_Node: GPUParticles3D = $"FlamethrowerParticles"
func _ready_standin() -> void: pass

func _process_standin(delta: float) -> void:
	var unit: Firefist = unit_ref as Firefist
	if unit.info_realspeed > 1.0:
		Sprite_Node.animation = &"run"
	else:
		Sprite_Node.animation = &"default"
	
	
	match unit.stance:
		0:
			FlamethrowerParticles_Node.emitting = false
		1:
			FlamethrowerParticles_Node.emitting = true
			var pos: Vector3 = position
			var attack_pos: Vector3 = unit.mouse_worldPos + Vector3(0,0.5,0)
			var attack_vec: Vector3 = attack_pos - pos
			FlamethrowerParticles_Node.process_material.set(&"shader_parameter/direction", attack_vec.normalized())
	
	
	if not unit_ref.skill_using: return
	
	var skl: Skill = unit_ref.skill_selected
	var chrg: float = unit_ref.skill_charge
	
	skl.ProcessVisCharge(delta)
