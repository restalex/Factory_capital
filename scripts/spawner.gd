extends Camera3D

signal status_changed(text: String)

enum ShapeType { BOX, SPHERE, CYLINDER }

const SHAPE_NAMES := {
	ShapeType.BOX: "Box",
	ShapeType.SPHERE: "Sphere",
	ShapeType.CYLINDER: "Cylinder",
}

const SHAPE_COLORS := {
	ShapeType.BOX: Color(0.85, 0.85, 0.85),
	ShapeType.SPHERE: Color(0.35, 0.55, 0.95),
	ShapeType.CYLINDER: Color(0.95, 0.6, 0.25),
}

const MIN_SIZE := 0.2
const MAX_SIZE := 5.0
const SCALE_STEP := 1.1
const ROTATION_STEP := PI / 4.0
const RAY_LENGTH := 200.0

var current_shape: ShapeType = ShapeType.BOX
var shape_size := 1.0
var rotation_y := 0.0
var shape_count := 0

var _ghost: MeshInstance3D
var _ghost_material: StandardMaterial3D

func _ready() -> void:
	_ghost_material = StandardMaterial3D.new()
	_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost_material.albedo_color = Color(1.0, 1.0, 1.0, 0.4)
	_ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost_material.no_depth_test = true

	_ghost = MeshInstance3D.new()
	_ghost.name = "Ghost"
	_ghost.material_override = _ghost_material
	_ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ghost)

	_build_ghost_mesh()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				_select_shape(ShapeType.BOX)
			KEY_2:
				_select_shape(ShapeType.SPHERE)
			KEY_3:
				_select_shape(ShapeType.CYLINDER)
			KEY_R:
				rotation_y += ROTATION_STEP
				_update_status()
			KEY_EQUAL:
				shape_size = clampf(shape_size * SCALE_STEP, MIN_SIZE, MAX_SIZE)
				_build_ghost_mesh()
				_update_status()
			KEY_MINUS:
				shape_size = clampf(shape_size / SCALE_STEP, MIN_SIZE, MAX_SIZE)
				_build_ghost_mesh()
				_update_status()
			KEY_X:
				_delete_shape_under_crosshair()
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_place_shape()

func _physics_process(_delta: float) -> void:
	if _ghost.mesh == null:
		_ghost.visible = false
		return
	var hit := _raycast()
	if hit.is_empty():
		_ghost.visible = false
		return
	_ghost.visible = true
	var up := Vector3.UP
	var normal: Vector3 = hit["normal"]
	if normal.length_squared() > 0.0:
		up = normal
	var align := Basis(Quaternion(Vector3.UP, up))
	if up.is_equal_approx(Vector3.DOWN):
		align = Basis(Vector3.RIGHT, PI)
	var spin := Basis(Quaternion(Vector3.UP, rotation_y))
	var basis := align * spin
	_ghost.global_basis = basis
	_ghost.global_position = hit["position"] + basis.y * (_ghost.mesh.get_aabb().size.y * 0.5)

func _raycast() -> Dictionary:
	var from := global_position
	var to := from - global_transform.basis.z * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	return get_world_3d().direct_space_state.intersect_ray(query)

func _build_ghost_mesh() -> void:
	_ghost.mesh = _make_mesh(current_shape)
	_update_status()

func _select_shape(shape: ShapeType) -> void:
	current_shape = shape
	_build_ghost_mesh()

func _place_shape() -> void:
	if _ghost.mesh == null or not _ghost.visible:
		return

	var body := StaticBody3D.new()
	body.name = "Shape%d" % (shape_count + 1)
	body.add_to_group("placeable")

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _make_mesh(current_shape)
	mesh_instance.material_override = _make_material()
	body.add_child(mesh_instance)

	var collider := CollisionShape3D.new()
	collider.shape = _make_collision_shape(current_shape)
	body.add_child(collider)

	get_tree().current_scene.add_child(body)
	body.global_transform = _ghost.global_transform
	shape_count += 1
	_update_status()

func _delete_shape_under_crosshair() -> void:
	var hit := _raycast()
	if hit.is_empty():
		return
	var collider = hit["collider"]
	if collider is Node and (collider as Node).is_in_group("placeable"):
		(collider as Node).queue_free()
		shape_count = maxi(0, shape_count - 1)
		_update_status()

func _make_mesh(shape: ShapeType) -> Mesh:
	match shape:
		ShapeType.BOX:
			var box := BoxMesh.new()
			box.size = Vector3.ONE * 1.2 * shape_size
			return box
		ShapeType.SPHERE:
			var sphere := SphereMesh.new()
			sphere.radius = 0.6 * shape_size
			sphere.height = 1.2 * shape_size
			return sphere
		ShapeType.CYLINDER:
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.5 * shape_size
			cylinder.bottom_radius = 0.5 * shape_size
			cylinder.height = 1.2 * shape_size
			return cylinder
	return BoxMesh.new()

func _make_collision_shape(shape: ShapeType) -> Shape3D:
	match shape:
		ShapeType.BOX:
			var box := BoxShape3D.new()
			box.size = Vector3.ONE * 1.2 * shape_size
			return box
		ShapeType.SPHERE:
			var sphere := SphereShape3D.new()
			sphere.radius = 0.6 * shape_size
			return sphere
		ShapeType.CYLINDER:
			var cylinder := CylinderShape3D.new()
			cylinder.radius = 0.5 * shape_size
			cylinder.height = 1.2 * shape_size
			return cylinder
	return BoxShape3D.new()

func _make_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var base: Color = SHAPE_COLORS[current_shape]
	material.albedo_color = base.lightened(randf() * 0.25)
	material.roughness = 0.7
	return material

func _update_status() -> void:
	status_changed.emit("Shape: %s  |  Size: %.2f  |  Rot: %d deg  |  Placed: %d" % [
		SHAPE_NAMES[current_shape],
		shape_size,
		wrapped_rot_deg(),
		shape_count,
	])

func wrapped_rot_deg() -> int:
	return wrapi(roundi(rad_to_deg(rotation_y)), 0, 360)
