extends Node

@export var cycle_duration := 90.0

@onready var light: DirectionalLight3D = $"../SunLight"
@onready var environment: WorldEnvironment = $"../WorldEnvironment"

var time_accumulator := 0.0

func _process(delta: float) -> void:
	time_accumulator = fmod(time_accumulator + delta, cycle_duration)
	var phase := time_accumulator / cycle_duration
	var energy := 0.3 + maxf(0.0, sin(phase * TAU)) * 1.1
	light.light_energy = energy
	light.rotation_degrees.x = lerpf(-35.0, 210.0, phase)
	var sky_tint := Color(0.07, 0.12, 0.22).lerp(Color(0.56, 0.68, 0.88), maxf(0.0, sin(phase * TAU)))
	environment.environment.background_color = sky_tint
	environment.environment.fog_light_color = sky_tint
	environment.environment.volumetric_fog_density = lerpf(0.04, 0.12, 1.0 - maxf(0.0, sin(phase * TAU)))

