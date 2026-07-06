class_name VisualManagement extends Node3D

@onready var THECamera_Node: Camera3D = $"THECamera"
@onready var MouseMarker_Node: Node3D = $"MouseMarker"
@onready var MouseMarkerUnit_Node: Node3D = $"MouseMarkerUnit"
@onready var AimMarker_Node: Node3D = $"AimMarker"

func _ready() -> void:
	GameData.VisualManagement_Node = self

var zoom: float = 1.0
func _process(delta: float) -> void:
	if not is_instance_valid(ClientData.thisPlayer): return
	var player: Player = ClientData.thisPlayer
	var unit: Unit = player.unit_ref
	var valid_unit: bool = is_instance_valid(unit)
	MouseMarker_Node.visible = valid_unit
	MouseMarkerUnit_Node.visible = valid_unit
	AimMarker_Node.visible = valid_unit
	if not valid_unit: return # TODO unitless camera control
	
	var mousePos: Vector2 = ClientData.mousePos
	var xDist: float = mousePos.x / ClientData.viewportSizeX
	var yDist: float = mousePos.y / ClientData.viewportSizeY
	xDist = (xDist * 2.0) - 1.0
	yDist = (yDist * 2.0) - 1.0
	var cam_displacement: Vector3 = Vector3(xDist, 0, yDist) * 2.0
	
	if Input.is_action_just_released("MWD"): zoom = clampf(zoom + 0.2, 0.0, 1.0)
	elif Input.is_action_just_released("MWU"): zoom = clampf(zoom - 0.2, 0.0, 1.0)
	
	var final_pos: Vector3 = Vector3(0,0,1).rotated(Vector3(1,0,0), THECamera_Node.rotation.x)
	final_pos *= 5.0 + (5.0 * zoom)
	final_pos += cam_displacement
	final_pos += unit.position
	var final_vec: Vector3 = final_pos - THECamera_Node.position
	THECamera_Node.position += final_vec * minf(delta * 8.0, 1.0)
	
	var space_state = get_world_3d().direct_space_state
	var from: Vector3 = THECamera_Node.project_ray_origin(mousePos)
	var to: Vector3 = THECamera_Node.global_position + THECamera_Node.project_ray_normal(mousePos) * 200.0
	GameData.rayquery_wall.from = from
	GameData.rayquery_wall.to = to
	var result: Dictionary = space_state.intersect_ray(GameData.rayquery_wall)
	if result:
		player.mouse_worldPos = result.position
	
	MouseMarker_Node.position = player.mouse_worldPos
	MouseMarkerUnit_Node.position = unit.mouse_worldPos
	AimMarker_Node.position = unit.standin_ref.position
	AimMarker_Node.transform = AimMarker_Node.transform.looking_at(player.mouse_worldPos)
	
