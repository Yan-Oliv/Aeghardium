extends Node
class_name SkyController

enum QualityPreset {
	LOW,
	MEDIUM,
	HIGH
}

enum WeatherType {
	CLEAR,
	CLOUDY,
	RAIN,
	FOG,
	STORM
}

@export var day_duration_seconds: float = 900.0
@export var night_duration_seconds: float = 300.0
@export_range(0.0, 1.0, 0.01) var start_cycle_ratio: float = 0.18
@export var quality_preset: QualityPreset = QualityPreset.MEDIUM
@export var enable_weather: bool = true
@export var interior_mode: bool = false
@export var weather_transition_speed: float = 1.8
@export var min_weather_duration: float = 40.0
@export var max_weather_duration: float = 95.0

var time_accumulator: float = 0.0
var _weather_timer: float = 0.0
var _active_weather: WeatherType = WeatherType.CLEAR
var _target_weather: WeatherType = WeatherType.CLEAR
var _weather_state: Dictionary = {
	"cloud_cover": 0.0,
	"rain": 0.0,
	"fog": 0.0,
	"storm": 0.0
}

var _environment: WorldEnvironment = null
var _light: DirectionalLight3D = null
var _player: Node3D = null
var _rain_particles: GPUParticles3D = null
var _ambient_particles: GPUParticles3D = null
var _firefly_particles: GPUParticles3D = null


func _ready() -> void:
	_environment = _resolve_environment()
	_light = _resolve_light()
	_player = _resolve_player()
	var total_cycle: float = _get_total_cycle_duration()
	time_accumulator = total_cycle * start_cycle_ratio
	_target_weather = WeatherType.FOG if interior_mode else WeatherType.CLEAR
	_active_weather = _target_weather
	_weather_state = _weather_profile(_target_weather).duplicate()
	_ensure_particle_nodes()
	_reset_weather_timer()
	_apply_environment(0.0)


func _process(delta: float) -> void:
	if _environment == null or _environment.environment == null:
		return

	if _player == null or not is_instance_valid(_player):
		_player = _resolve_player()

	time_accumulator = fmod(time_accumulator + delta, _get_total_cycle_duration())
	_update_weather(delta)
	_follow_player()
	_apply_environment(delta)


func _get_total_cycle_duration() -> float:
	return maxf(1.0, day_duration_seconds + night_duration_seconds)


func _resolve_environment() -> WorldEnvironment:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null
	for child in parent_node.get_children():
		if child is WorldEnvironment:
			return child as WorldEnvironment
	return null


func _resolve_light() -> DirectionalLight3D:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null
	for child in parent_node.get_children():
		if child is DirectionalLight3D:
			return child as DirectionalLight3D
	return null


func _resolve_player() -> Node3D:
	var parent_node: Node = get_parent()
	if parent_node != null:
		var direct_player: Node = parent_node.get_node_or_null("Player")
		if direct_player is Node3D:
			return direct_player as Node3D
	var from_group: Node = get_tree().get_first_node_in_group("player_controller")
	if from_group is Node3D:
		return from_group as Node3D
	return null


func _update_weather(delta: float) -> void:
	if not enable_weather:
		_target_weather = WeatherType.FOG if interior_mode else WeatherType.CLEAR
	else:
		_weather_timer -= delta
		if _weather_timer <= 0.0:
			_active_weather = _target_weather
			_target_weather = _pick_weather()
			_reset_weather_timer()

	var target_profile: Dictionary = _weather_profile(_target_weather)
	for key in _weather_state.keys():
		var target_value: float = float(target_profile.get(key, 0.0))
		var current_value: float = float(_weather_state.get(key, 0.0))
		_weather_state[key] = move_toward(current_value, target_value, weather_transition_speed * delta)


func _pick_weather() -> WeatherType:
	var roll: float = randf()
	if roll < 0.02:
		return WeatherType.STORM
	if roll < 0.10:
		return WeatherType.FOG
	if roll < 0.20:
		return WeatherType.RAIN
	if roll < 0.35:
		return WeatherType.CLOUDY
	return WeatherType.CLEAR


func _reset_weather_timer() -> void:
	_weather_timer = randf_range(min_weather_duration, max_weather_duration)


func _weather_profile(weather: WeatherType) -> Dictionary:
	match weather:
		WeatherType.CLOUDY:
			return {"cloud_cover": 0.45, "rain": 0.0, "fog": 0.10, "storm": 0.0}
		WeatherType.RAIN:
			return {"cloud_cover": 0.60, "rain": 0.75, "fog": 0.20, "storm": 0.0}
		WeatherType.FOG:
			return {"cloud_cover": 0.25, "rain": 0.0, "fog": 0.65, "storm": 0.0}
		WeatherType.STORM:
			return {"cloud_cover": 0.85, "rain": 1.0, "fog": 0.32, "storm": 1.0}
		_:
			return {"cloud_cover": 0.0, "rain": 0.0, "fog": 0.0, "storm": 0.0}


func _follow_player() -> void:
	if _player == null:
		return
	var center: Vector3 = _player.global_position
	if _rain_particles != null:
		_rain_particles.global_position = center + Vector3(0.0, 10.0, 0.0)
	if _ambient_particles != null:
		_ambient_particles.global_position = center + Vector3(0.0, 2.5, 0.0)
	if _firefly_particles != null:
		_firefly_particles.global_position = center + Vector3(0.0, 1.4, 0.0)


func _apply_environment(delta: float) -> void:
	var env: Environment = _environment.environment
	var night_ratio: float = _get_night_ratio()
	var day_factor: float = 1.0 - night_ratio
	var cloud_cover: float = float(_weather_state.get("cloud_cover", 0.0))
	var rain_factor: float = float(_weather_state.get("rain", 0.0))
	var fog_factor: float = float(_weather_state.get("fog", 0.0))
	var storm_factor: float = float(_weather_state.get("storm", 0.0))

	var day_sky: Color = Color(0.50, 0.72, 0.90)
	var night_sky: Color = Color(0.05, 0.09, 0.18)
	if interior_mode:
		day_sky = Color(0.18, 0.23, 0.20)
		night_sky = Color(0.05, 0.08, 0.09)

	var sky_color: Color = night_sky.lerp(day_sky, day_factor)
	sky_color = sky_color.darkened(cloud_cover * 0.24 + storm_factor * 0.15)
	env.background_color = sky_color
	env.ambient_light_energy = lerpf(0.22, 0.72, day_factor)
	if interior_mode:
		env.ambient_light_energy = lerpf(0.16, 0.34, day_factor)
	env.fog_enabled = true
	env.fog_density = 0.010 + fog_factor * 0.026 + rain_factor * 0.010
	if interior_mode:
		env.fog_density += 0.012
	env.fog_light_color = sky_color.lerp(Color(0.76, 0.84, 0.88), 0.18 + fog_factor * 0.18)
	env.volumetric_fog_enabled = quality_preset != QualityPreset.LOW
	env.volumetric_fog_density = 0.02 + fog_factor * 0.05 + rain_factor * 0.015

	if _light != null:
		var light_energy: float = lerpf(0.28, 1.18, day_factor)
		if interior_mode:
			light_energy = lerpf(0.35, 0.75, day_factor)
		light_energy *= 1.0 - cloud_cover * 0.28
		light_energy *= 1.0 - storm_factor * 0.18
		_light.light_energy = light_energy
		_light.light_color = Color(0.58, 0.68, 0.84).lerp(Color(1.0, 0.95, 0.82), day_factor)
		if interior_mode:
			_light.light_color = Color(0.62, 0.74, 0.78).lerp(Color(0.86, 0.82, 0.72), day_factor * 0.4)
		var cycle_ratio: float = time_accumulator / _get_total_cycle_duration()
		var base_rotation: float = lerpf(-35.0, 220.0, cycle_ratio)
		if interior_mode:
			base_rotation = lerpf(-52.0, -26.0, day_factor)
		_light.rotation_degrees.x = base_rotation

	_update_particles(delta, day_factor, rain_factor, fog_factor, storm_factor)


func _get_night_ratio() -> float:
	if interior_mode:
		return 0.72
	if time_accumulator < day_duration_seconds:
		var daylight_progress: float = time_accumulator / maxf(1.0, day_duration_seconds)
		var sun_curve: float = sin(daylight_progress * PI)
		return 1.0 - clampf(sun_curve, 0.0, 1.0)
	var night_progress: float = (time_accumulator - day_duration_seconds) / maxf(1.0, night_duration_seconds)
	return clampf(0.7 + sin(night_progress * PI) * 0.3, 0.0, 1.0)


func _ensure_particle_nodes() -> void:
	_rain_particles = _create_particles(
		"RainParticles",
		18 if quality_preset == QualityPreset.LOW else 42 if quality_preset == QualityPreset.MEDIUM else 70,
		2.1,
		_create_rain_material(),
		_create_rain_mesh()
	)
	_ambient_particles = _create_particles(
		"AmbientParticles",
		16 if quality_preset == QualityPreset.LOW else 34 if quality_preset == QualityPreset.MEDIUM else 56,
		6.5,
		_create_ambient_material(),
		_create_ambient_mesh()
	)
	_firefly_particles = _create_particles(
		"FireflyParticles",
		8 if quality_preset == QualityPreset.LOW else 14 if quality_preset == QualityPreset.MEDIUM else 22,
		4.0,
		_create_firefly_material(),
		_create_firefly_mesh()
	)
	if interior_mode and _firefly_particles != null:
		_firefly_particles.visible = false


func _create_particles(
	node_name: String,
	amount: int,
	lifetime: float,
	process_material: ParticleProcessMaterial,
	mesh: Mesh
) -> GPUParticles3D:
	var existing: Node = get_node_or_null(node_name)
	if existing is GPUParticles3D:
		return existing as GPUParticles3D

	var particles := GPUParticles3D.new()
	particles.name = node_name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.draw_pass_1 = mesh
	particles.process_material = process_material
	particles.emitting = true
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	particles.visibility_aabb = AABB(Vector3(-12.0, -4.0, -12.0), Vector3(24.0, 20.0, 24.0))
	add_child(particles)
	return particles


func _create_rain_material() -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(7.0, 0.5, 7.0)
	material.direction = Vector3(0.0, -1.0, 0.0)
	material.spread = 5.0
	material.gravity = Vector3(0.0, -22.0, 0.0)
	material.initial_velocity_min = 10.0
	material.initial_velocity_max = 13.0
	material.scale_min = 0.02
	material.scale_max = 0.04
	material.color = Color(0.76, 0.84, 0.95, 0.65)
	return material


func _create_rain_mesh() -> Mesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.015
	mesh.mid_height = 0.18
	return mesh


func _create_ambient_material() -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(8.0, 1.6, 8.0)
	material.direction = Vector3(0.0, 1.0, 0.0)
	material.spread = 28.0
	material.gravity = Vector3(0.0, 0.15, 0.0)
	material.initial_velocity_min = 0.15
	material.initial_velocity_max = 0.45
	material.angular_velocity_min = -0.7
	material.angular_velocity_max = 0.7
	material.scale_min = 0.05
	material.scale_max = 0.11
	material.color = Color(0.90, 0.92, 0.85, 0.24) if not interior_mode else Color(0.74, 0.82, 0.80, 0.18)
	return material


func _create_ambient_mesh() -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.10
	return mesh


func _create_firefly_material() -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(6.0, 1.2, 6.0)
	material.direction = Vector3(0.0, 1.0, 0.0)
	material.spread = 45.0
	material.gravity = Vector3(0.0, 0.02, 0.0)
	material.initial_velocity_min = 0.08
	material.initial_velocity_max = 0.22
	material.scale_min = 0.05
	material.scale_max = 0.08
	material.color = Color(0.96, 0.94, 0.48, 0.78)
	return material


func _create_firefly_mesh() -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.12
	return mesh


func _update_particles(delta: float, day_factor: float, rain_factor: float, fog_factor: float, storm_factor: float) -> void:
	if _rain_particles != null:
		_rain_particles.amount_ratio = clampf(rain_factor + storm_factor * 0.2, 0.0, 1.0)
		_rain_particles.visible = _rain_particles.amount_ratio > 0.02 and not interior_mode

	if _ambient_particles != null:
		var ambient_ratio: float = 0.30 + fog_factor * 0.45
		if not interior_mode:
			ambient_ratio += (1.0 - day_factor) * 0.10
		_ambient_particles.amount_ratio = clampf(ambient_ratio, 0.0, 1.0)
		var ambient_rotation: Vector3 = _ambient_particles.rotation_degrees
		ambient_rotation.y = fmod(ambient_rotation.y + delta * 8.0, 360.0)
		_ambient_particles.rotation_degrees = ambient_rotation

	if _firefly_particles != null:
		var firefly_ratio: float = clampf((1.0 - day_factor) * (1.0 - rain_factor) * (1.0 - storm_factor), 0.0, 1.0)
		_firefly_particles.amount_ratio = firefly_ratio
		_firefly_particles.visible = firefly_ratio > 0.08 and not interior_mode
