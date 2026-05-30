extends Node2D
class_name BaseVillage2DController

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
	show_message(GameManager.consume_pending_message())


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

	for y in range(-20, 21):
		for x in range(-30, 31):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

	for y in range(-6, 6):
		for x in range(-9, 10):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))

	for y in range(4, 18):
		var half_width: int = 2 + int(absf(float(y - 4)) * 0.18)
		for x in range(-half_width, half_width + 1):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))

	for y in range(6, 11):
		for x in range(9, 22):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(3, 0))


func _apply_scene_theme() -> void:
	var theme := GameManager.get_visual_biome_for_floor(max(1, int(GameManager.get_player_state().get("floor", 1))))
	$GroundVisual.color = _with_alpha(theme.get("grass_base", Color8(42, 78, 48)), 0.04)
	$StonePlaza.color = _with_alpha(theme.get("stone_base", Color8(83, 86, 78)), 0.08)
	$PathToDungeon.color = _with_alpha(theme.get("path_base", Color8(95, 72, 48)), 0.08)
	$WaterPond/WaterVisual.color = _with_alpha(theme.get("water_base", Color8(32, 105, 150)), 0.78)
	$HealingFountain/FountainVisual.color = _with_alpha(theme.get("water_accent", Color8(84, 190, 214)), 0.86)
	$CampfireVisual/Flame.color = theme.get("glow_accent", Color8(255, 128, 32))
	$SaveShrine/Rune.color = theme.get("accent", Color8(92, 194, 255))


func _hide_placeholder_visuals() -> void:
	for node_path in [
		"GroundVisual",
		"StonePlaza",
		"PathToDungeon",
		"CampfireVisual",
		"WaterPond",
		"HealingFountain",
		"SaveShrine",
		"CollisionObjects/HouseA",
		"CollisionObjects/HouseB",
		"CollisionObjects/TreeA",
		"CollisionObjects/TreeB",
		"CollisionObjects/FenceNorthWest",
		"CollisionObjects/FenceNorthEast",
		"CollisionObjects/Crates",
		"CollisionObjects/RockCluster"
	]:
		_hide_polygon_children(node_path)


func _decorate_scene() -> void:
	var theme := GameManager.get_visual_biome_for_floor(max(1, int(GameManager.get_player_state().get("floor", 1))))
	var decoration_layer := _get_or_create_layer("DecorationLayer", 15)
	for child in decoration_layer.get_children():
		child.queue_free()

	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_building_texture(Color8(98, 84, 68), Color8(128, 58, 38), Color8(150, 112, 72), Color8(246, 212, 124), Vector2i(88, 84)),
		Vector2(-270, -138),
		Vector2(2.1, 2.1)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_building_texture(Color8(86, 96, 108), Color8(102, 58, 32), Color8(156, 134, 84), Color8(242, 214, 120), Vector2i(84, 80)),
		Vector2(260, -124),
		Vector2(2.0, 2.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_stall_texture(
			Color8(114, 84, 54),
			theme.get("accent", Color8(90, 180, 122)),
			Color8(78, 54, 34),
			[Color8(212, 78, 64), Color8(236, 192, 84), Color8(88, 176, 118)]
		),
		Vector2(260, -48),
		Vector2(2.0, 2.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_stall_texture(
			Color8(92, 84, 80),
			Color8(188, 98, 52),
			Color8(64, 52, 46),
			[Color8(170, 182, 196), Color8(122, 134, 150), Color8(214, 172, 84)]
		),
		Vector2(318, 26),
		Vector2(1.8, 1.8)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_tree_texture(theme.get("grass_accent", Color8(74, 122, 72)), Color8(92, 58, 34), Color8(224, 84, 68)),
		Vector2(-335, 96),
		Vector2(2.0, 2.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_tree_texture(theme.get("grass_base", Color8(54, 92, 56)).darkened(0.08), Color8(82, 48, 28), Color8(246, 198, 82)),
		Vector2(355, 92),
		Vector2(2.0, 2.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_shrine_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("accent", Color8(92, 194, 255)), Color8(255, 206, 122)),
		Vector2(-35, -60),
		Vector2(2.2, 2.2)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_campfire_texture(Color8(92, 54, 24), Color8(255, 118, 28), Color8(255, 186, 78)),
		Vector2(-122, 64),
		Vector2(2.2, 2.2)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_status_pool_texture(
			_with_alpha(theme.get("water_base", Color8(42, 118, 162)), 0.96),
			_with_alpha(theme.get("water_accent", Color8(82, 176, 212)), 0.96),
			_with_alpha(theme.get("grass_accent", Color8(74, 122, 72)), 0.95)
		),
		Vector2(214, 118),
		Vector2(2.7, 2.7)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_portal_texture(theme.get("glow_accent", Color8(88, 194, 255)), theme.get("stone_base", Color8(92, 96, 94))),
		Vector2(0, 236),
		Vector2(2.4, 2.4)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_obelisk_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("accent", Color8(92, 194, 255))),
		Vector2(95, -18),
		Vector2(1.9, 1.9)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_rubble_texture(theme.get("stone_base", Color8(92, 96, 94)), theme.get("accent", Color8(92, 194, 255))),
		Vector2(172, -74),
		Vector2(1.8, 1.8)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_lantern_texture(Color8(74, 58, 42), theme.get("glow_accent", Color8(246, 212, 124))),
		Vector2(-270, -64),
		Vector2(2.0, 2.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_lantern_texture(Color8(74, 58, 42), theme.get("glow_accent", Color8(246, 212, 124))),
		Vector2(250, -58),
		Vector2(2.0, 2.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_banner_texture(
			_with_alpha(theme.get("grass_detail", Color8(38, 56, 44)), 0.94),
			_with_alpha(theme.get("stone_detail", Color8(46, 50, 56)), 0.98),
			_with_alpha(theme.get("accent", Color8(92, 194, 255)), 0.98)
		),
		Vector2(-92, -154),
		Vector2(1.0, 1.0)
	)
	_add_sprite(
		decoration_layer,
		PixelArtFactory.make_banner_texture(
			_with_alpha(theme.get("stone_detail", Color8(46, 50, 56)), 0.94),
			_with_alpha(theme.get("stone_base", Color8(92, 96, 94)), 0.98),
			_with_alpha(theme.get("glow_accent", Color8(246, 212, 124)), 0.98)
		),
		Vector2(88, -154),
		Vector2(1.0, 1.0)
	)

	for bush_position in [Vector2(-164, -10), Vector2(-208, 120), Vector2(292, 126), Vector2(180, 146)]:
		_add_sprite(
			decoration_layer,
			PixelArtFactory.make_bush_texture(theme.get("grass_accent", Color8(74, 122, 72)), theme.get("glow", Color8(114, 214, 166)), Color8(228, 92, 78)),
			bush_position,
			Vector2(1.8, 1.8)
		)

	for flower_position in [Vector2(-82, -118), Vector2(22, -126), Vector2(164, 28), Vector2(-16, 156), Vector2(112, 164)]:
		_add_sprite(
			decoration_layer,
			PixelArtFactory.make_flower_patch_texture(theme.get("grass_accent", Color8(74, 122, 72)), theme.get("glow", Color8(114, 214, 166)), Color8(250, 240, 164)),
			flower_position,
			Vector2(1.8, 1.8)
		)

	for reed_position in [Vector2(150, 144), Vector2(184, 154), Vector2(246, 158)]:
		_add_sprite(
			decoration_layer,
			PixelArtFactory.make_reed_texture(theme.get("grass_base", Color8(54, 92, 56)).lightened(0.12), Color8(186, 132, 72)),
			reed_position,
			Vector2(1.8, 1.8)
		)


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
