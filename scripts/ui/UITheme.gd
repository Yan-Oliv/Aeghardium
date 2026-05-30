extends RefCounted
class_name UITheme

const BG_DARK := Color("0A1128")
const PANEL_DARK := Color("10182F")
const PANEL_STONE := Color("151A26")
const GOLD := Color("FFD700")
const PARCHMENT := Color("F5F5F5")
const BLOOD := Color("8B1E24")
const MIST := Color("3D5A4A")
const MANA := Color("3A6EA5")
const TEXT_MAIN := Color("F5F5F5")
const TEXT_SECONDARY := Color("D8C89A")
const PIXEL_LINE := Color("3B2A12")

static func apply(root: Control) -> void:
	_style_recursive(root)


static func panel_style(kind: String = "stone") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_STONE if kind == "stone" else PANEL_DARK
	if kind == "parchment":
		style.bg_color = Color(0.12, 0.11, 0.09, 0.92)
	style.border_color = GOLD
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 4
	style.content_margin_left = 18
	style.content_margin_top = 16
	style.content_margin_right = 18
	style.content_margin_bottom = 16
	return style


static func button_style(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = GOLD
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style


static func progress_fill(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style


static func progress_bg() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.11, 0.13, 0.95)
	style.border_color = GOLD.darkened(0.2)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func _style_recursive(node: Node) -> void:
	if node is PanelContainer:
		(node as PanelContainer).add_theme_stylebox_override("panel", panel_style())
	elif node is Button:
		var button := node as Button
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 52.0)
		button.add_theme_stylebox_override("normal", button_style(PANEL_DARK))
		button.add_theme_stylebox_override("hover", button_style(Color(0.13, 0.16, 0.20, 1.0)))
		button.add_theme_stylebox_override("pressed", button_style(Color(0.18, 0.14, 0.10, 1.0)))
		button.add_theme_stylebox_override("disabled", button_style(Color(0.09, 0.09, 0.10, 0.85)))
		button.add_theme_color_override("font_color", TEXT_MAIN)
		button.add_theme_color_override("font_hover_color", PARCHMENT)
		button.add_theme_color_override("font_pressed_color", TEXT_MAIN)
		button.add_theme_color_override("font_disabled_color", TEXT_SECONDARY.darkened(0.25))
		button.add_theme_font_size_override("font_size", 17)
	elif node is Label:
		var label := node as Label
		label.add_theme_color_override("font_color", TEXT_MAIN)
		if label.name.to_lower().contains("title"):
			label.add_theme_color_override("font_color", PARCHMENT)
			label.add_theme_font_size_override("font_size", max(22, label.get_theme_font_size("font_size")))
	elif node is RichTextLabel:
		var rich := node as RichTextLabel
		rich.add_theme_color_override("default_color", TEXT_MAIN)
		rich.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	elif node is LineEdit:
		var line := node as LineEdit
		line.add_theme_color_override("font_color", TEXT_MAIN)
		line.add_theme_color_override("font_placeholder_color", TEXT_SECONDARY)
		line.add_theme_stylebox_override("normal", panel_style("parchment"))
		line.add_theme_stylebox_override("focus", panel_style("parchment"))
		line.add_theme_font_size_override("font_size", 17)
	elif node is ItemList:
		var list := node as ItemList
		list.add_theme_stylebox_override("panel", panel_style())
		list.add_theme_stylebox_override("focus", panel_style())
		list.add_theme_color_override("font_color", TEXT_MAIN)
		list.add_theme_color_override("font_selected_color", PARCHMENT)
		list.add_theme_color_override("guide_color", GOLD.darkened(0.5))
	elif node is ProgressBar:
		var bar := node as ProgressBar
		bar.add_theme_stylebox_override("background", progress_bg())
		bar.add_theme_stylebox_override("fill", progress_fill(BLOOD))
		bar.add_theme_color_override("font_color", TEXT_MAIN)

	for child in node.get_children():
		_style_recursive(child)
