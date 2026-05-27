extends RefCounted
class_name CloudSaveService

# Offline-only placeholder kept for future integration.
const PROJECT_URL := ""
const PUBLISHABLE_KEY := ""


func is_available() -> bool:
	return false


func get_status_message() -> String:
	return "Cloud save indisponível no MVP offline."


func upload_save(_payload: Dictionary) -> Dictionary:
	return {"ok": false, "message": get_status_message()}


func download_save() -> Dictionary:
	return {"ok": false, "message": get_status_message()}
