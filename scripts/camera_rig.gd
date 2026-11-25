extends Node3D

const ORBIT_SENSITIVITY := 0.005
const MOVE_SPEED := 10.0
const SPRINT_FACTOR := 2.0
const ZOOM_STEP := 1.5
const PITCH_LIMIT := deg_to_rad(89.0)

@onready var camera: Camera3D = $Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotation.y -= event.relative.x * ORBIT_SENSITIVITY
		camera.rotation.x = clampf(
			camera.rotation.x - event.relative.y * ORBIT_SENSITIVITY,
			-PITCH_LIMIT,
			PITCH_LIMIT
		)
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				global_position -= camera.global_transform.basis.z * ZOOM_STEP
			MOUSE_BUTTON_WHEEL_DOWN:
				global_position += camera.global_transform.basis.z * ZOOM_STEP

func _process(delta: float) -> void:
	var speed := MOVE_SPEED * (SPRINT_FACTOR if Input.is_key_pressed(KEY_SHIFT) else 1.0) * delta
	var flat := global_transform.basis
	var forward := flat.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := flat.x
	var move := right * Input.get_axis("move_left", "move_right")
	move += forward * Input.get_axis("move_forward", "move_back")
	move += Vector3.UP * (float(Input.is_key_pressed(KEY_E)) - float(Input.is_key_pressed(KEY_Q)))
	if move.length_squared() > 0.0:
		global_position += move.normalized() * speed
