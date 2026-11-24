extends Node3D

const DEFAULT_STATUS := "Shape: Box  |  Size: 1.00  |  Rot: 0 deg  |  Placed: 0"

const CONTROLS_TEXT := """1 / 2 / 3 - select: Box / Sphere / Cylinder
Left click - place shape
Mouse wheel - grow / shrink
R - rotate 45 deg
Right click - delete shape under crosshair

WASD - move   Shift - sprint   Space - jump
Mouse - look   Esc - release / capture cursor"""

@onready var spawner: Camera3D = $Player/Camera3D
@onready var status_label: Label = $HUD/Status

func _ready() -> void:
	spawner.status_changed.connect(func(text: String) -> void: status_label.text = text)
	status_label.text = DEFAULT_STATUS
