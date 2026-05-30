extends RefCounted
class_name PixelArtFactory

const OUTLINE := Color8(16, 18, 24)
const SHADOW := Color8(18, 16, 20, 150)


static func build_tile_atlas(theme: Dictionary) -> ImageTexture:
	var image := Image.create(96, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_fill_tile(image, 0, theme.get("grass_base", Color8(52, 96, 58)), theme.get("grass_accent", Color8(68, 122, 72)), theme.get("grass_detail", Color8(42, 76, 52)))
	_fill_tile(image, 1, theme.get("stone_base", Color8(84, 88, 96)), theme.get("stone_accent", Color8(106, 112, 120)), theme.get("stone_detail", Color8(68, 72, 78)))
	_fill_tile(image, 2, theme.get("path_base", Color8(100, 78, 50)), theme.get("path_accent", Color8(126, 98, 66)), theme.get("path_detail", Color8(82, 60, 40)))
	_fill_tile(image, 3, theme.get("water_base", Color8(40, 110, 150)), theme.get("water_accent", Color8(66, 160, 206)), theme.get("water_detail", Color8(24, 86, 126)))
	_fill_tile(image, 4, theme.get("mud_base", Color8(70, 64, 44)), theme.get("mud_accent", Color8(92, 82, 58)), theme.get("mud_detail", Color8(56, 50, 35)))
	_fill_tile(image, 5, theme.get("glow_base", Color8(70, 44, 92)), theme.get("glow_accent", Color8(114, 86, 154)), theme.get("glow_detail", Color8(52, 32, 70)))
	return ImageTexture.create_from_image(image)


static func make_tree_texture(leaf: Color, trunk: Color, berry: Color = Color.TRANSPARENT) -> ImageTexture:
	var image := Image.create(48, 56, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(10, 46, 28, 6))
	_draw_rect(image, Rect2i(21, 28, 6, 18), trunk)
	_draw_rect(image, Rect2i(19, 18, 10, 12), trunk.lightened(0.08))
	_draw_blob(image, Rect2i(8, 4, 32, 28), leaf, leaf.lightened(0.08), leaf.darkened(0.22))
	_draw_blob(image, Rect2i(4, 14, 18, 16), leaf.darkened(0.06), leaf.lightened(0.08), leaf.darkened(0.24))
	_draw_blob(image, Rect2i(26, 13, 18, 16), leaf.darkened(0.10), leaf.lightened(0.08), leaf.darkened(0.24))
	if berry.a > 0.0:
		_draw_rect(image, Rect2i(13, 22, 2, 2), berry)
		_draw_rect(image, Rect2i(31, 17, 2, 2), berry)
		_draw_rect(image, Rect2i(26, 27, 2, 2), berry)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_building_texture(wall: Color, roof: Color, trim: Color, lit_window: Color, size: Vector2i = Vector2i(80, 80)) -> ImageTexture:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(8, size.y - 10, size.x - 16, 6))
	_draw_rect(image, Rect2i(14, 30, size.x - 28, size.y - 40), wall)
	_draw_rect(image, Rect2i(18, 34, size.x - 36, size.y - 48), wall.lightened(0.06))
	_draw_rect(image, Rect2i(10, 22, size.x - 20, 12), trim)
	_draw_roof(image, Rect2i(6, 0, size.x - 12, 34), roof, roof.darkened(0.18))
	_draw_rect(image, Rect2i(int(size.x * 0.25), 44, 10, 10), lit_window)
	_draw_rect(image, Rect2i(int(size.x * 0.60), 44, 10, 10), lit_window)
	_draw_rect(image, Rect2i(int(size.x * 0.46), 52, 12, size.y - 62), trim.darkened(0.12))
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_stall_texture(main: Color, awning: Color, support: Color, goods: Array[Color]) -> ImageTexture:
	var image := Image.create(64, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(8, 40, 48, 5))
	_draw_rect(image, Rect2i(8, 24, 48, 10), main)
	_draw_rect(image, Rect2i(10, 10, 44, 12), awning)
	_draw_rect(image, Rect2i(12, 10, 6, 28), support)
	_draw_rect(image, Rect2i(46, 10, 6, 28), support)
	var x := 13
	for color in goods:
		_draw_rect(image, Rect2i(x, 26, 6, 6), color)
		x += 9
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_bush_texture(base: Color, accent: Color, berry: Color = Color.TRANSPARENT) -> ImageTexture:
	var image := Image.create(34, 26, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(4, 20, 24, 4))
	_draw_blob(image, Rect2i(3, 6, 16, 14), base, accent, base.darkened(0.22))
	_draw_blob(image, Rect2i(13, 4, 18, 16), base.darkened(0.05), accent.lightened(0.06), base.darkened(0.26))
	if berry.a > 0.0:
		_draw_rect(image, Rect2i(11, 11, 2, 2), berry)
		_draw_rect(image, Rect2i(21, 9, 2, 2), berry)
		_draw_rect(image, Rect2i(19, 15, 2, 2), berry)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_flower_patch_texture(grass: Color, petal: Color, center: Color) -> ImageTexture:
	var image := Image.create(24, 18, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for stem_x in [4, 9, 14, 18]:
		_draw_rect(image, Rect2i(stem_x, 7, 1, 8), grass)
		_draw_rect(image, Rect2i(stem_x - 1, 5, 3, 3), petal)
		_draw_rect(image, Rect2i(stem_x, 6, 1, 1), center)
	_draw_rect(image, Rect2i(2, 14, 20, 2), grass.darkened(0.18))
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_lantern_texture(frame: Color, glow: Color) -> ImageTexture:
	var image := Image.create(20, 38, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_rect(image, Rect2i(9, 2, 2, 26), frame)
	_draw_rect(image, Rect2i(5, 10, 10, 12), glow)
	_draw_rect(image, Rect2i(6, 11, 8, 10), glow.lightened(0.18))
	_draw_rect(image, Rect2i(4, 9, 12, 1), frame)
	_draw_rect(image, Rect2i(4, 22, 12, 1), frame)
	_draw_rect(image, Rect2i(6, 28, 8, 6), frame.darkened(0.12))
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_obelisk_texture(stone: Color, rune: Color) -> ImageTexture:
	var image := Image.create(34, 54, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(5, 46, 24, 5))
	_draw_polygon(image, PackedVector2Array([Vector2(17, 2), Vector2(27, 12), Vector2(24, 44), Vector2(10, 44), Vector2(7, 12)]), stone)
	_draw_polygon(image, PackedVector2Array([Vector2(17, 10), Vector2(22, 20), Vector2(17, 30), Vector2(12, 20)]), rune)
	_draw_rect(image, Rect2i(8, 44, 18, 4), stone.darkened(0.24))
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_crystal_texture(core: Color, glow: Color, base_color: Color, size: Vector2i = Vector2i(32, 44)) -> ImageTexture:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(5, size.y - 6, size.x - 10, 4))
	_draw_polygon(image, PackedVector2Array([Vector2(size.x / 2, 2), Vector2(size.x - 6, 14), Vector2(size.x - 8, size.y - 12), Vector2(size.x / 2, size.y - 2), Vector2(8, size.y - 12), Vector2(6, 14)]), glow)
	_draw_polygon(image, PackedVector2Array([Vector2(size.x / 2, 6), Vector2(size.x - 10, 16), Vector2(size.x - 12, size.y - 14), Vector2(size.x / 2, size.y - 6), Vector2(12, size.y - 14), Vector2(10, 16)]), core)
	_draw_polygon(image, PackedVector2Array([Vector2(size.x / 2, 10), Vector2(size.x - 14, 20), Vector2(size.x / 2, size.y - 10), Vector2(14, 20)]), base_color)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_portal_texture(primary: Color, secondary: Color) -> ImageTexture:
	var image := Image.create(64, 72, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(10, 62, 44, 6))
	_draw_rect(image, Rect2i(8, 56, 48, 6), secondary.darkened(0.3))
	_draw_rect(image, Rect2i(16, 12, 32, 40), secondary.darkened(0.18))
	_draw_rect(image, Rect2i(20, 16, 24, 32), primary)
	_draw_rect(image, Rect2i(24, 22, 16, 20), primary.lightened(0.18))
	_draw_rect(image, Rect2i(12, 10, 8, 44), secondary)
	_draw_rect(image, Rect2i(44, 10, 8, 44), secondary)
	_draw_rect(image, Rect2i(16, 4, 32, 10), secondary)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_campfire_texture(log_color: Color, flame: Color, ember: Color) -> ImageTexture:
	var image := Image.create(36, 36, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(4, 28, 28, 4))
	_draw_rect(image, Rect2i(6, 22, 9, 4), log_color)
	_draw_rect(image, Rect2i(20, 22, 9, 4), log_color)
	_draw_polygon(image, PackedVector2Array([Vector2(18, 6), Vector2(26, 18), Vector2(18, 28), Vector2(10, 18)]), flame)
	_draw_polygon(image, PackedVector2Array([Vector2(18, 10), Vector2(22, 18), Vector2(18, 24), Vector2(14, 18)]), ember)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_shrine_texture(stone: Color, rune: Color, candle: Color) -> ImageTexture:
	var image := Image.create(40, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(4, 40, 32, 5))
	_draw_blob(image, Rect2i(8, 8, 24, 28), stone, stone.lightened(0.08), stone.darkened(0.22))
	_draw_polygon(image, PackedVector2Array([Vector2(20, 12), Vector2(26, 22), Vector2(20, 32), Vector2(14, 22)]), rune)
	_draw_rect(image, Rect2i(5, 28, 4, 10), candle)
	_draw_rect(image, Rect2i(31, 28, 4, 10), candle)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_battle_actor_texture(actor: Dictionary, enemy_id: String = "", class_id: String = "", facing_left: bool = false) -> ImageTexture:
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(22, 80, 52, 8))
	if not enemy_id.is_empty():
		_draw_enemy_actor(image, enemy_id)
	else:
		_draw_player_actor(image, class_id)
	if facing_left:
		image.flip_x()
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_banner_texture(fill: Color, line: Color, accent: Color) -> ImageTexture:
	var image := Image.create(96, 72, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	for y in range(0, 72, 6):
		for x in range(0, 96, 8):
			if (x / 8 + y / 6) % 2 == 0:
				image.set_pixel(x, y, line)
	_draw_rect(image, Rect2i(0, 0, 96, 4), accent)
	_draw_rect(image, Rect2i(0, 68, 96, 4), accent)
	_draw_rect(image, Rect2i(8, 10, 14, 50), accent.darkened(0.22))
	_draw_rect(image, Rect2i(74, 10, 14, 50), accent.darkened(0.22))
	return ImageTexture.create_from_image(image)


static func make_firefly_texture(color: Color) -> ImageTexture:
	var image := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_rect(image, Rect2i(2, 2, 2, 2), color)
	_draw_rect(image, Rect2i(1, 2, 1, 2), color.darkened(0.15))
	_draw_rect(image, Rect2i(4, 2, 1, 2), color.darkened(0.15))
	return ImageTexture.create_from_image(image)


static func make_reed_texture(stem: Color, tip: Color) -> ImageTexture:
	var image := Image.create(24, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for x in [6, 11, 16]:
		_draw_rect(image, Rect2i(x, 8, 1, 18), stem)
		_draw_rect(image, Rect2i(x - 1, 4, 3, 5), tip)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_rubble_texture(stone: Color, rune: Color = Color.TRANSPARENT) -> ImageTexture:
	var image := Image.create(56, 40, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_shadow(image, Rect2i(6, 32, 44, 5))
	_draw_blob(image, Rect2i(6, 10, 18, 16), stone, stone.lightened(0.06), stone.darkened(0.22))
	_draw_blob(image, Rect2i(20, 6, 14, 20), stone.darkened(0.06), stone.lightened(0.06), stone.darkened(0.24))
	_draw_blob(image, Rect2i(30, 12, 18, 14), stone.lightened(0.04), stone.lightened(0.08), stone.darkened(0.20))
	if rune.a > 0.0:
		_draw_rect(image, Rect2i(25, 10, 4, 6), rune)
		_draw_rect(image, Rect2i(37, 16, 4, 4), rune)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_status_pool_texture(base: Color, ripple: Color, moss: Color = Color.TRANSPARENT) -> ImageTexture:
	var image := Image.create(80, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_polygon(image, PackedVector2Array([Vector2(8, 16), Vector2(70, 10), Vector2(76, 24), Vector2(60, 40), Vector2(14, 42), Vector2(4, 28)]), base)
	_draw_polygon(image, PackedVector2Array([Vector2(16, 20), Vector2(64, 16), Vector2(68, 24), Vector2(52, 34), Vector2(18, 36), Vector2(12, 28)]), ripple)
	if moss.a > 0.0:
		_draw_rect(image, Rect2i(9, 18, 8, 5), moss)
		_draw_rect(image, Rect2i(56, 31, 10, 4), moss)
	_outline(image)
	return ImageTexture.create_from_image(image)


static func make_pixel_panel_texture(size: Vector2i, fill: Color, border: Color, accent: Color) -> ImageTexture:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	_draw_rect(image, Rect2i(0, 0, size.x, 2), border)
	_draw_rect(image, Rect2i(0, size.y - 2, size.x, 2), border)
	_draw_rect(image, Rect2i(0, 0, 2, size.y), border)
	_draw_rect(image, Rect2i(size.x - 2, 0, 2, size.y), border)
	for x in range(4, size.x - 4, 10):
		_draw_rect(image, Rect2i(x, 4, 4, 2), accent)
		_draw_rect(image, Rect2i(x, size.y - 6, 4, 2), accent)
	return ImageTexture.create_from_image(image)


static func _fill_tile(image: Image, tile_x: int, base: Color, accent: Color, detail: Color) -> void:
	var start_x := tile_x * 16
	for y in range(16):
		for x in range(16):
			var use_accent := ((x + y) % 5) == 0 or (x % 7 == 0 and y % 3 == 0)
			var use_detail := ((x * 3 + y) % 11) == 0
			var color := detail if use_detail else (accent if use_accent else base)
			image.set_pixel(start_x + x, y, color)


static func _draw_player_actor(image: Image, class_id: String) -> void:
	var palette := {
		"mage": [Color8(58, 52, 150), Color8(110, 185, 255), Color8(206, 181, 141), Color8(38, 30, 76), Color8(104, 74, 38)],
		"necromancer": [Color8(36, 26, 52), Color8(156, 82, 224), Color8(214, 206, 220), Color8(78, 54, 118), Color8(62, 40, 74)],
		"warrior": [Color8(96, 104, 114), Color8(210, 178, 80), Color8(206, 162, 128), Color8(160, 170, 182), Color8(186, 196, 214)],
		"assassin": [Color8(34, 40, 46), Color8(66, 122, 126), Color8(192, 146, 108), Color8(28, 28, 34), Color8(172, 182, 196)],
		"paladin": [Color8(220, 214, 190), Color8(238, 202, 82), Color8(214, 178, 136), Color8(206, 214, 220), Color8(220, 228, 234)],
		"archer": [Color8(68, 102, 54), Color8(162, 108, 52), Color8(204, 166, 118), Color8(92, 128, 80), Color8(118, 74, 36)],
		"berserker": [Color8(140, 56, 44), Color8(96, 54, 36), Color8(174, 116, 86), Color8(178, 52, 38), Color8(168, 170, 176)],
		"druid": [Color8(78, 120, 60), Color8(132, 176, 82), Color8(182, 132, 88), Color8(82, 58, 38), Color8(88, 58, 30)],
		"cleric": [Color8(218, 212, 190), Color8(230, 198, 94), Color8(216, 178, 138), Color8(236, 228, 200), Color8(170, 148, 86)]
	}.get(class_id, [Color8(58, 52, 150), Color8(110, 185, 255), Color8(206, 181, 141), Color8(38, 30, 76), Color8(104, 74, 38)])
	var robe: Color = palette[0]
	var accent: Color = palette[1]
	var skin: Color = palette[2]
	var hair: Color = palette[3]
	var weapon: Color = palette[4]
	_draw_rect(image, Rect2i(39, 22, 18, 16), skin)
	_draw_rect(image, Rect2i(36, 16, 24, 10), hair)
	_draw_rect(image, Rect2i(36, 36, 24, 28), robe)
	_draw_rect(image, Rect2i(46, 38, 4, 26), accent)
	_draw_rect(image, Rect2i(34, 38, 4, 18), robe.darkened(0.18))
	_draw_rect(image, Rect2i(60, 40, 4, 18), robe.darkened(0.18))
	_draw_rect(image, Rect2i(39, 64, 6, 14), robe.darkened(0.25))
	_draw_rect(image, Rect2i(51, 64, 6, 14), robe.darkened(0.25))
	_draw_rect(image, Rect2i(28, 24, 4, 52), weapon)
	_draw_rect(image, Rect2i(24, 20, 12, 8), accent)
	if class_id in ["paladin", "warrior"]:
		_draw_rect(image, Rect2i(62, 42, 10, 18), accent)
		_draw_rect(image, Rect2i(64, 46, 6, 10), robe.darkened(0.18))
	if class_id == "necromancer":
		_draw_rect(image, Rect2i(64, 24, 8, 8), accent)
	if class_id == "archer":
		_draw_rect(image, Rect2i(62, 26, 2, 38), weapon)
		_draw_rect(image, Rect2i(64, 30, 1, 30), accent)


static func _draw_enemy_actor(image: Image, enemy_id: String) -> void:
	match enemy_id:
		"slime_green":
			_draw_polygon(image, PackedVector2Array([Vector2(24, 66), Vector2(34, 38), Vector2(62, 34), Vector2(72, 66), Vector2(60, 76), Vector2(36, 78)]), Color8(76, 196, 94))
			_draw_polygon(image, PackedVector2Array([Vector2(30, 60), Vector2(38, 42), Vector2(58, 40), Vector2(66, 62), Vector2(56, 70), Vector2(38, 72)]), Color8(132, 240, 146))
		"blue_slime":
			_draw_polygon(image, PackedVector2Array([Vector2(24, 66), Vector2(34, 38), Vector2(62, 34), Vector2(72, 66), Vector2(60, 76), Vector2(36, 78)]), Color8(70, 160, 230))
			_draw_polygon(image, PackedVector2Array([Vector2(30, 60), Vector2(38, 42), Vector2(58, 40), Vector2(66, 62), Vector2(56, 70), Vector2(38, 72)]), Color8(126, 214, 255))
		"young_wolf":
			_draw_rect(image, Rect2i(26, 42, 38, 18), Color8(114, 86, 56))
			_draw_rect(image, Rect2i(52, 34, 20, 16), Color8(126, 94, 62))
			_draw_polygon(image, PackedVector2Array([Vector2(56, 34), Vector2(60, 24), Vector2(64, 34)]), Color8(88, 62, 38))
			_draw_polygon(image, PackedVector2Array([Vector2(66, 34), Vector2(70, 24), Vector2(74, 34)]), Color8(88, 62, 38))
			_draw_rect(image, Rect2i(28, 56, 4, 16), Color8(88, 62, 40))
			_draw_rect(image, Rect2i(38, 56, 4, 16), Color8(88, 62, 40))
			_draw_rect(image, Rect2i(52, 56, 4, 16), Color8(88, 62, 40))
			_draw_rect(image, Rect2i(60, 56, 4, 16), Color8(88, 62, 40))
		"carnivorous_plant":
			_draw_rect(image, Rect2i(46, 40, 4, 28), Color8(64, 122, 60))
			_draw_polygon(image, PackedVector2Array([Vector2(48, 18), Vector2(66, 32), Vector2(48, 46), Vector2(30, 32)]), Color8(178, 54, 76))
			_draw_polygon(image, PackedVector2Array([Vector2(48, 24), Vector2(60, 32), Vector2(48, 40), Vector2(36, 32)]), Color8(236, 210, 180))
			_draw_rect(image, Rect2i(34, 48, 10, 6), Color8(74, 150, 68))
			_draw_rect(image, Rect2i(52, 48, 10, 6), Color8(74, 150, 68))
		"giant_bee":
			_draw_rect(image, Rect2i(34, 36, 28, 18), Color8(224, 186, 40))
			_draw_rect(image, Rect2i(38, 36, 4, 18), Color8(42, 40, 42))
			_draw_rect(image, Rect2i(48, 36, 4, 18), Color8(42, 40, 42))
			_draw_rect(image, Rect2i(58, 36, 4, 18), Color8(42, 40, 42))
			_draw_polygon(image, PackedVector2Array([Vector2(34, 38), Vector2(20, 26), Vector2(26, 50)]), Color(0.70, 0.88, 1.0, 0.7))
			_draw_polygon(image, PackedVector2Array([Vector2(62, 38), Vector2(76, 26), Vector2(70, 50)]), Color(0.70, 0.88, 1.0, 0.7))
		"goblin_thief":
			_draw_rect(image, Rect2i(40, 24, 16, 14), Color8(126, 166, 74))
			_draw_rect(image, Rect2i(36, 18, 24, 10), Color8(76, 112, 46))
			_draw_rect(image, Rect2i(36, 38, 24, 24), Color8(88, 72, 42))
			_draw_rect(image, Rect2i(34, 42, 4, 16), Color8(64, 92, 36))
			_draw_rect(image, Rect2i(60, 42, 4, 16), Color8(64, 92, 36))
			_draw_rect(image, Rect2i(30, 30, 4, 34), Color8(184, 184, 194))
		"vampire_bat":
			_draw_polygon(image, PackedVector2Array([Vector2(26, 38), Vector2(48, 48), Vector2(70, 38), Vector2(56, 66), Vector2(40, 66)]), Color8(82, 48, 72))
			_draw_polygon(image, PackedVector2Array([Vector2(48, 30), Vector2(58, 42), Vector2(48, 54), Vector2(38, 42)]), Color8(122, 72, 98))
		"skeletal_guard":
			_draw_rect(image, Rect2i(40, 20, 16, 16), Color8(220, 216, 198))
			_draw_rect(image, Rect2i(36, 36, 24, 28), Color8(112, 104, 96))
			_draw_rect(image, Rect2i(32, 28, 8, 42), Color8(146, 98, 56))
			_draw_rect(image, Rect2i(58, 36, 12, 20), Color8(128, 134, 148))
			_draw_rect(image, Rect2i(60, 40, 8, 12), Color8(188, 54, 42))
		"poison_toad":
			_draw_polygon(image, PackedVector2Array([Vector2(24, 62), Vector2(34, 38), Vector2(62, 38), Vector2(72, 62), Vector2(60, 76), Vector2(36, 76)]), Color8(104, 138, 74))
			_draw_rect(image, Rect2i(31, 58, 10, 8), Color8(86, 112, 58))
			_draw_rect(image, Rect2i(55, 58, 10, 8), Color8(86, 112, 58))
			_draw_rect(image, Rect2i(32, 28, 12, 10), Color8(214, 226, 152))
			_draw_rect(image, Rect2i(52, 28, 12, 10), Color8(214, 226, 152))
			_draw_rect(image, Rect2i(36, 31, 5, 5), Color8(40, 42, 34))
			_draw_rect(image, Rect2i(56, 31, 5, 5), Color8(40, 42, 34))
		"wailing_spirit":
			_draw_polygon(image, PackedVector2Array([Vector2(48, 16), Vector2(68, 30), Vector2(66, 62), Vector2(48, 78), Vector2(30, 62), Vector2(28, 30)]), Color(0.68, 0.80, 1.0, 0.85))
			_draw_polygon(image, PackedVector2Array([Vector2(48, 24), Vector2(60, 32), Vector2(58, 54), Vector2(48, 68), Vector2(38, 54), Vector2(36, 32)]), Color(0.92, 0.98, 1.0, 0.95))
			_draw_rect(image, Rect2i(40, 28, 4, 4), Color8(92, 194, 255))
			_draw_rect(image, Rect2i(52, 28, 4, 4), Color8(92, 194, 255))
		"iron_golem":
			_draw_rect(image, Rect2i(34, 16, 28, 18), Color8(116, 96, 76))
			_draw_rect(image, Rect2i(30, 34, 36, 26), Color8(94, 80, 68))
			_draw_rect(image, Rect2i(24, 36, 8, 24), Color8(110, 94, 78))
			_draw_rect(image, Rect2i(64, 36, 8, 24), Color8(110, 94, 78))
			_draw_rect(image, Rect2i(36, 60, 10, 18), Color8(84, 70, 58))
			_draw_rect(image, Rect2i(50, 60, 10, 18), Color8(84, 70, 58))
			_draw_rect(image, Rect2i(38, 24, 6, 6), Color8(232, 112, 72))
			_draw_rect(image, Rect2i(52, 24, 6, 6), Color8(232, 112, 72))
			_draw_rect(image, Rect2i(44, 42, 8, 8), Color8(206, 86, 54))
		"wind_king":
			_draw_rect(image, Rect2i(42, 18, 12, 16), Color8(220, 228, 236))
			_draw_rect(image, Rect2i(36, 34, 24, 24), Color8(124, 164, 206))
			_draw_polygon(image, PackedVector2Array([Vector2(36, 34), Vector2(18, 22), Vector2(22, 54)]), Color(0.72, 0.86, 1.0, 0.65))
			_draw_polygon(image, PackedVector2Array([Vector2(60, 34), Vector2(78, 22), Vector2(74, 54)]), Color(0.72, 0.86, 1.0, 0.65))
			_draw_rect(image, Rect2i(44, 58, 4, 16), Color8(196, 208, 220))
			_draw_rect(image, Rect2i(50, 58, 4, 16), Color8(196, 208, 220))
			_draw_rect(image, Rect2i(40, 12, 16, 4), Color8(204, 236, 255))
		"fallen_necromancer":
			_draw_rect(image, Rect2i(40, 18, 16, 14), Color8(214, 206, 220))
			_draw_rect(image, Rect2i(34, 32, 28, 34), Color8(36, 26, 52))
			_draw_rect(image, Rect2i(46, 34, 4, 32), Color8(142, 78, 216))
			_draw_rect(image, Rect2i(30, 22, 8, 44), Color8(70, 48, 86))
			_draw_rect(image, Rect2i(62, 28, 8, 12), Color8(124, 72, 168))
			_draw_rect(image, Rect2i(28, 18, 6, 6), Color8(162, 96, 232))
			_draw_rect(image, Rect2i(62, 18, 6, 6), Color8(162, 96, 232))
		_:
			_draw_rect(image, Rect2i(32, 30, 32, 32), Color8(114, 84, 144))
			_draw_rect(image, Rect2i(40, 20, 16, 12), Color8(214, 210, 220))
	if enemy_id not in ["poison_toad", "wailing_spirit", "iron_golem", "wind_king", "fallen_necromancer"]:
		_draw_rect(image, Rect2i(40, 28, 3, 3), Color8(255, 255, 255))
		_draw_rect(image, Rect2i(54, 28, 3, 3), Color8(255, 255, 255))


static func _draw_shadow(image: Image, rect: Rect2i) -> void:
	_draw_rect(image, rect, SHADOW)


static func _draw_blob(image: Image, rect: Rect2i, base: Color, highlight: Color, shade: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var nx := float(x - rect.position.x) / max(1.0, float(rect.size.x - 1))
			var ny := float(y - rect.position.y) / max(1.0, float(rect.size.y - 1))
			var dx := (nx - 0.5) / 0.5
			var dy := (ny - 0.5) / 0.5
			if dx * dx + dy * dy <= 1.0:
				var color := base
				if nx < 0.35 and ny < 0.45:
					color = highlight
				elif nx > 0.65 or ny > 0.75:
					color = shade
				image.set_pixel(x, y, color)


static func _draw_roof(image: Image, rect: Rect2i, roof: Color, shade: Color) -> void:
	var center := rect.position.x + rect.size.x / 2
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var progress := float(y - rect.position.y) / max(1.0, float(rect.size.y))
		var half := int(progress * float(rect.size.x) * 0.5)
		for x in range(center - half, center + half):
			if x >= rect.position.x and x < rect.position.x + rect.size.x:
				var color := roof if ((x + y) % 4) != 0 else shade
				image.set_pixel(x, y, color)


static func _draw_polygon(image: Image, polygon: PackedVector2Array, color: Color) -> void:
	var min_x := int(polygon[0].x)
	var max_x := int(polygon[0].x)
	var min_y := int(polygon[0].y)
	var max_y := int(polygon[0].y)
	for point in polygon:
		min_x = mini(min_x, int(point.x))
		max_x = maxi(max_x, int(point.x))
		min_y = mini(min_y, int(point.y))
		max_y = maxi(max_y, int(point.y))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x, y), polygon):
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)


static func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				image.set_pixel(x, y, color)


static func _outline(image: Image) -> void:
	var copy := image.duplicate()
	for y in range(copy.get_height()):
		for x in range(copy.get_width()):
			if copy.get_pixel(x, y).a <= 0.0:
				continue
			for offset in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var nx := x + offset.x
				var ny := y + offset.y
				if nx < 0 or nx >= copy.get_width() or ny < 0 or ny >= copy.get_height():
					continue
				if copy.get_pixel(nx, ny).a <= 0.0:
					image.set_pixel(nx, ny, OUTLINE)
