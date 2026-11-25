extends Node3D

const DEFAULT_STATUS := "Shape: Box  |  Size: 1.00  |  Rot: 0 deg  |  Placed: 0"

@onready var spawner: Camera3D = $CameraRig/Camera3D
@onready var status_label: Label = $HUD/Status

func _ready() -> void:
	spawner.status_changed.connect(func(text: String) -> void: status_label.text = text)
	status_label.text = DEFAULT_STATUS
