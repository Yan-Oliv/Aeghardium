extends Node

const SAVE_PATH: String = "user://savegame.json"
const PLAYER_RESPAWN_MESSAGE: String = "Sua essência retorna ao véu."
const INTRO_TEXT: String = "O Sistema Nexus foi ativado. Uma dungeon infinita surgiu no centro do continente e distorceu a realidade.\nVocê é um dos Escolhidos. Sem memória, mas com poder para evoluir, construir uma base e desafiar os andares que levaram o mundo à Queda."
const LORE_TEXT: String = "A base cresce ao redor da entrada da dungeon. Cada vitória revela mais sobre a Queda."

const CLASS_IDS: PackedStringArray = [
	"necromancer",
	"assassin",
	"warrior",
	"archer",
	"mage",
	"berserker",
	"druid",
	"cleric",
	"paladin"
]

const RANK_ORDER: PackedStringArray = ["F", "E", "D", "C", "B", "A", "S", "SS"]
