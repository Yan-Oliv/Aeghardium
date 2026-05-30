# Dungeon e Equipamentos 2D

## Dungeon funcional

A dungeon ativa fica em `res://scenes/2d/maps/DungeonFloor2D.tscn`.

Ela contem:

- Entrada com `PlayerSpawn`.
- Caminho principal visual.
- Paredes e pilares com `StaticBody2D`.
- Escombros bloqueando passagem.
- Fogo, agua, lama e fonte de cura com `EnvironmentalArea2D`.
- Inimigo no mapa com `Interactable2D`.
- Bau interativo.
- Portal de saida para a base.

## Areas ambientais

- `fire`: aplica `burning`.
- `water`: aplica `wet` e remove `burning`.
- `swamp`: aplica lentidao.
- `healing`: aplica regeneracao.

## Batalha

O inimigo da dungeon usa `interaction_type = "battle_trigger"`.

Ao encostar ou interagir, ele chama:

```gdscript
GameManager.start_dungeon_battle(enemy_id, "dungeon_floor_2d")
```

Quando a batalha termina com vitoria:

- `GameManager` marca o `enemy_id` como derrotado.
- O jogo volta para `DungeonFloor2D`.
- O inimigo derrotado nao aparece mais nessa sessao.

Derrota ou fuga retornam para a base.

## Equipamentos visuais

Os dados base ficam em:

```text
res://scripts/2d/items/EquipmentVisualData.gd
```

Categorias preparadas:

- armas
- escudos/offhand
- capacetes
- peitorais
- luvas
- pernas
- botas
- capas
- acessorios

Itens iniciais:

- `short_sword`
- `long_sword`
- `simple_staff`
- `wooden_bow`
- `twin_daggers`
- `hand_axe`
- `light_shield`
- `basic_robe`
- `iron_armor`
- `shadow_cape`

## Como testar

1. Rode `res://scenes/2d/main/Main2D.tscn`.
2. Crie ou carregue um personagem.
3. Na base, entre no portal da dungeon.
4. Na dungeon, teste fogo, agua, lama e fonte.
5. Encoste no inimigo para iniciar batalha.
6. Vença a batalha e confirme que volta para a dungeon sem o inimigo.
7. Abra o player com classes diferentes para ver armas/offhand/capas padrao mudando.
