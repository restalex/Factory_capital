extends SceneTree


func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var errors: Array[String] = []

	var scene: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	current_scene = scene

	for i in 5:
		await physics_frame

	var spawner: Camera3D = scene.get_node("CameraRig/Camera3D")
	if scene.get_script() == null:
		errors.append("Main scene script missing")
	if spawner == null:
		errors.append("Spawner camera not found")
		_fail(errors)
	var rig: Node3D = scene.get_node("CameraRig")
	if rig == null:
		errors.append("Camera rig not found")
		_fail(errors)
	if not is_instance_valid(rig) or rig.get_script() == null:
		errors.append("Camera rig script missing")

	if not spawner._ghost.visible:
		errors.append("Ghost did not become visible after raycast (expected ground hit)")

	spawner._place_shape()
	await physics_frame
	var placed := get_nodes_in_group("placeable")
	if placed.size() != 1:
		errors.append("Expected 1 placed shape, got %d" % placed.size())
	if placed.size() == 1:
		var shape: Node = placed[0]
		if shape.get_child_count() < 2:
			errors.append("Placed shape is missing mesh or collider child")
		if shape.get_child(0).mesh == null:
			errors.append("Placed shape has no mesh")
		if shape.get_child(1).shape == null:
			errors.append("Placed shape has no collision shape")

	var key_event := InputEventKey.new()
	key_event.physical_keycode = KEY_2
	key_event.pressed = true
	Input.parse_input_event(key_event)
	await physics_frame
	await physics_frame
	if spawner.current_shape != spawner.ShapeType.SPHERE:
		errors.append("Key 2 did not select sphere shape")

	spawner.current_shape = spawner.ShapeType.CYLINDER
	spawner.shape_size = 2.0
	spawner._build_ghost_mesh()
	spawner._place_shape()
	await physics_frame
	if get_nodes_in_group("placeable").size() != 2:
		errors.append("Cylinder placement failed, placed=%d" % get_nodes_in_group("placeable").size())

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_RIGHT
	press.pressed = true
	Input.parse_input_event(press)
	var drag := InputEventMouseMotion.new()
	drag.relative = Vector2(100, 30)
	Input.parse_input_event(drag)
	await process_frame
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_RIGHT
	release.pressed = false
	Input.parse_input_event(release)
	if rig.rotation.y >= 0.0 or rig.get_node("Camera3D").rotation.x >= -0.55:
		errors.append("Right-drag orbit did not move the camera")

	rig.rotation.y = 0.0
	rig.get_node("Camera3D").rotation.x = -0.55
	for i in 2:
		await physics_frame
	spawner._delete_shape_under_crosshair()
	await physics_frame
	await physics_frame
	if spawner.shape_count != 1:
		errors.append("Delete did not decrement count, count=%d" % spawner.shape_count)

	_fail(errors)

func _fail(errors: Array[String]) -> void:
	for error in errors:
		push_error("SMOKE FAILED: " + error)
	if errors.is_empty():
		print("SMOKE OK")
		quit(0)
	else:
		print("SMOKE FAILED: %d error(s)" % errors.size())
		quit(1)
