extends Node2D


const BOARD_WIDTH = 10
const BOARD_HEIGHT = 20
const CELL_SIZE = 30
@onready var paused_label: Label = $Pausable/UI/PausedLabel

# UI reference
var ui_controller = null

var paused = false

func toggle_pause():
	var tree = get_tree()
	tree.paused = !tree.paused
	paused = !paused
	
	if paused:
		show_paused()
	else:
		hide_paused()

func show_paused():
	if paused_label:
		paused_label.show()
		
func hide_paused():
	if paused_label:
		paused_label.hide()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_controller = get_node("../UI")
	if paused_label:
		paused_label.hide()
	pass # Replace with function body.
	

func _input(event):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
