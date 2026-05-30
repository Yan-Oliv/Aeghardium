extends Node2D
class_name DungeonFloor2DController

@onready var player: Player2DController = $Player2D
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var message_label: Label = $CanvasLayer/MessageLabel
@onready var mobile_controls: MobileControls2D = $CanvasLayer/MobileControls2D


func _ready() -> void:
	_configure_render_layers()
	_build_ground_tilemap()
	_apply_scene_theme()
	_hide_placeholder_visuals()
	_decorate_scene()
	player.global_position = player_spawn.global_position
	if not GameManager.player_state.is_empty():
		player.apply_class_visual(str(GameManager.player_state.get("class_id", "mage")))
	elif not GameManager.selected_class_id.is_empty():
		player.apply_class_visual(GameManager.selected_class_id)
	if not mobile_controls.interact_pressed.is_connected(_on_interact_pressed):
		mobile_controls.interact_pressed.connect(_on_interact_pressed)
	var pending: String = GameManager.consume_pending_message()
	if pending.is_empty():
		show_message("Dungeon 2D: explore, evite riscos e derrote o inimigo.")
	else:
		show_message(pending)


func _configure_render_layers() -> void:
	$GroundTileMap.z_index = -20
	player.z_index = 30


func show_message(message: String) -> void:
	if message.is_empty():
		return
	message_label.text = message
	message_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.6)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.35)


func _on_interact_pressed() -> void:
	player.try_interact()


func _build_ground_tilemap() -> void:
	var tile_map: TileMap = $GroundTileMap
	var theme := GameManager.get_visual_biome_for_floor(max(1, int(GameManager.get_player_state().get("floor", 1))))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(16, 16)

	var atlas := TileSetAtlasSource.new()
	atlas.texture = PixelArtFactory.build_tile_atlas(theme)
	atlas.texture_region_size = Vector2i(16, 16)
	for tile_x in range(6):
		atlas.create_tile(Vector2i(tile_x, 0))
	tile_set.add_source(atlas, 0)
	tile_map.tile_set = tile_set

	for y in range(-18, 19):
		for x in range(-28, 29):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(4, 0))

	for y in range(-14, 15):
		for x in range(-24, 25):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))

	for y in range(-12, 15):
		for x in range(-6, 7):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))

	for x in range(-16, -6):
		for y in range(-4, 2):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))

	for x in range(8, 18):
		for y in range(-2, 4):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))

	for y in range(-10, -6):
		for x in range(4, 12):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(3, 0))


func _apply_scene_theme() -> void:
	var theme := GameManager.get_visual_biome_for_floor(max(1, int(GameManager.get_player_state().get("floor", 1))))
	$GroundVisual.color = _with_alpha(theme.get("grass_detail", Color8(42, 76, 52)).darkened(0.55), 0.06)
	$RoomGlow.color = _with_alpha(theme.get("glow_base", Color8(70, 44, 92)), 0.08)
	$MainPath.color = _with_alpha(theme.get("path_base", Color8(100, 78, 50)), 0.10)
	$WaterPuddle/Visual.color = _with_alpha(theme.get("water_base", Color8(42, 118, 162)), 0.76)
	$SwampMud/Visual.color = _with_alpha(theme.get("mud_base", Color8(70, 64, 44)), 0.88)
	$HealingFont/Visual.color = _with_alpha(theme.get("glow", Color8(154, 214, 138)), 0.84)
	$HealingFont/Core.color = _with_alpha(theme.get("water_accent", Color8(82, 176, 212)), 0.94)
	$FirePatch/Visual.color = _with_alpha(theme.get("glow_accent", Color8(242, 172, 92)), 0.80)
	$CollisionObjects/RubbleGate/Runes.color = _with_alpha(theme.get("accent", Color8(176, 110, 214)), 0.72)


func _hide_placeholder_visuals() -> void:
	for node_path in [
		"GroundVisual",
		"RoomGlow",
		"MainPath",
		"FirePatch",
		"WaterPuddle",
		"SwampMud",
		"HealingFont",
		"EnemyTrigger",
		"CollisionObjects/PillarA",
		"CollisionObjects/PillarB",
		"CollisionObjects/RubbleGate"
	]:
		_hide_polygon_children(node_path)


func _decorate_scene() -> void:
	var floor_value := max(1, int(GameManager.get_player_state().get("floor", 1)))
	var theme := GameManager.get_visual_biome_for_floor(floor_value)
	var decoration_layer := _get_or_create_layer("DecorationLayer", 15)
	for child in decoration_layer.get_children():
		child.queue_free()

	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_rubble_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("accent", Color8(176, 110, 214))),
		Vector2(0, -212),
		Vector2(2.6, 2.6)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_status_pool_texture(
			_with_alpha(theme.get("water_base", Color8(42, 118, 162)), 0.96),
			_with_alpha(theme.get("water_accent", Color8(82, 176, 212)), 0.96),
			_with_alpha(theme.get("grass_accent", Color8(74, 122, 72)), 0.95)
		),
		Vector2(96, -122),
		Vector2(2.6, 2.6)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_status_pool_texture(
			_with_alpha(theme.get("mud_base", Color8(70, 64, 44)), 0.96),
			_with_alpha(theme.get("mud_accent", Color8(92, 82, 58)), 0.96),
			_with_alpha(theme.get("grass_detail", Color8(42, 76, 52)), 0.95)
		),
		Vector2(-210, 130),
		Vector2(2.3, 2.3)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_crystal_texture(theme.get("glow", Color8(154, 214, 138)), theme.get("accent", Color8(176, 110, 214)), theme.get("stone_base", Color8(92, 96, 94))),
		Vector2(-250, -114),
		Vector2(2.2, 2.2)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_campfire_texture(Color8(72, 44, 24), theme.get("glow_accent", Color8(242, 172, 92)), Color8(255, 208, 116)),
		Vector2(-72, 124),
		Vector2(2.4, 2.4)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_obelisk_texture(theme.get("stone_accent", Color8(120, 126, 122)), theme.get("accent", Color8(176, 110, 214))),
		Vector2(-170, -64),
		Vector2(2.2, 2.2)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_obelisk_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("glow", Color8(154, 214, 138))),
		Vector2(180, 58),
		Vector2(2.2, 2.2)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_lantern_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("glow_accent", Color8(242, 172, 92))),
		Vector2(-86, -176),
		Vector2(1.8, 1.8)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_lantern_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("glow_accent", Color8(242, 172, 92))),
		Vector2(84, -176),
		Vector2(1.8, 1.8)
	)

	for crystal_position in [Vector2(-284, -118), Vector2(-292, 106), Vector2(280, -108), Vector2(256, 148)]:
		_add_sprite(
			decoration_layer,
			PixelArtFactory.make_crystal_texture(theme.get("accent", Color8(176, 110, 214)), theme.get("glow", Color8(154, 214, 138)), theme.get("stone_base", Color8(92, 96, 94)), Vector2i(24, 34)),
			crystal_position,
			Vector2(1.5, 1.5)
		)

	for rubble_position in [Vector2(-308, 10), Vector2(316, 24), Vector2(-26, 28), Vector2(34, -20)]:
		_add_sprite(
			decoration_layer,
			PixelArtFactory.make_rubble_texture(theme.get("stone_base", Color8(92, 96, 94))),
			rubble_position,
			Vector2(1.5, 1.5)
		)

	for reed_position in [Vector2(60, -108), Vector2(120, -102), Vector2(-248, 144)]:
		_add_sprite(
			decoration_layer,
			PixelArtFactory.make_reed_texture(theme.get("grass_accent", Color8(74, 122, 72)), theme.get("glow_accent", Color8(242, 172, 92))),
			reed_position,
			Vector2(1.5, 1.5)
		)

	var enemy_id := _resolve_enemy_id_for_floor(floor_value)
	var enemy_texture := PixelAssetRegistry.get_enemy_map_texture(enemy_id)
	if enemy_texture == null:
		enemy_texture = PixelArtFactory.make_battle_actor_texture({}, enemy_id, "", true)
	_add_sprite(
		decoration_layer,
		enemy_texture,
		Vector2(218, -96),
		PixelAssetRegistry.get_world_sprite_scale(enemy_texture, 78.0)
	)


func _resolve_enemy_id_for_floor(floor_value: int) -> String:
	match floor_value:
		1:
			return "slime_green"
		2:
			return "young_wolf"
		3:
			return "carnivorous_plant"
		4:
			return "goblin_thief"
		5:
			return "skeletal_guard"
		6:
			return "poison_toad"
		7:
			return "wailing_spirit"
		8:
			return "giant_bee"
		9:
			return "vampire_bat"
		10:
			return "skeletal_guard"
		15:
			return "iron_golem"
		20:
			return "wind_king"
		25:
			return "fallen_necromancer"
		_:
			if floor_value <= 10:
				return "blue_slime" if floor_value % 2 == 0 else "young_wolf"
			if floor_value <= 15:
				return "iron_golem" if floor_value % 3 == 0 else "wailing_spirit"
			if floor_value <= 20:
				return "giant_bee" if floor_value % 2 == 0 else "iron_golem"
			return "fallen_necromancer" if floor_value % 4 == 0 else "skeletal_guard"


func _get_or_create_layer(layer_name: String, z_value: int) -> Node2D:
	var layer := get_node_or_null(layer_name) as Node2D
	if layer == null:
		layer = Node2D.new()
		layer.name = layer_name
		layer.z_index = z_value
		add_child(layer)
	return layer


func _hide_polygon_children(node_path: String) -> void:
	var root := get_node_or_null(node_path)
	if root == null:
		return
	if root is Polygon2D:
		root.visible = false
	for child in root.get_children():
		if child is Polygon2D:
			child.visible = false


func _add_sprite(parent: Node2D, texture: Texture2D, position_value: Vector2, scale_value: Vector2 = Vector2.ONE) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position_value
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = scale_value
	parent.add_child(sprite)


func _with_alpha(color_value: Color, alpha_value: float) -> Color:
	var tinted := color_value
	tinted.a = alpha_value
	return tinted
