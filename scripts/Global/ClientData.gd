extends Node

var thisPlayer: Player = null

var mousePos: Vector2 = Vector2.ZERO
var mousePos_old: Vector2 = Vector2.ZERO
var mouseVec: Vector2 = Vector2.ZERO

signal viewportSize_changed

var viewportSize: Vector2 = Vector2(100, 100)
var viewportCenter: Vector2 = viewportSize*0.5
var viewportSizeX: float = 100.0
var viewportSizeY: float = 100.0
var viewportScale: float = 1.0
var viewportShortest: float = 1.0
var viewportLongest: float = 1.0

var pauseMenu: bool = false
var mouseInWorld: Vector2 = Vector2.ZERO

enum P_FLAG {
	nothing,
	north, west, south, east,
	actQ, actE, jump, crouch,
	m1, m2, shift, dunno
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	var viewportSize_new: Vector2 = Vector2(get_viewport().size)
	if not viewportSize_new.is_equal_approx(viewportSize):
		viewportSize = viewportSize_new
		viewportCenter = (viewportSize*0.5).floor()
		viewportSizeX = viewportSize.x
		viewportSizeY = viewportSize.y
		viewportShortest = minf(viewportSizeX, viewportSizeY)
		viewportLongest = maxf(viewportSizeX, viewportSizeY)
		viewportScale = viewportShortest/720.0
		viewportSize_changed.emit()
	
	mousePos_old = mousePos
	mousePos = get_viewport().get_mouse_position()
	if mouse_IsOnScreen: mouseVec = mousePos - mousePos_old
	else: mouseVec = Vector2.ZERO
	
	var thiefControl: Control = get_viewport().gui_get_hovered_control()
	mouse_IsOnGUI = is_instance_valid(thiefControl)
	
	m1 = Input.is_action_pressed("M1")
	m2 = Input.is_action_pressed("M2")

var m1: bool = false
var m2: bool = false

var mouse_IsOnGUI: bool = false
var mouse_IsOnScreen: bool = false
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_IsOnScreen = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_IsOnScreen = true

var mouseEvent_relVec: Vector2 = Vector2.ZERO
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseEvent_relVec = event.relative
