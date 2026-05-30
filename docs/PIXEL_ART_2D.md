# Fluxo Ativo Pixel Art 2D

Cena principal ativa:

```text
res://scenes/2d/main/Main2D.tscn
```

O `main_scene` do projeto aponta para `Main2D.tscn`. A versao 3D continua no repositorio como legado, mas nao participa do fluxo ativo.

## Estrutura

- `scenes/2d/main/Main2D.tscn`: entrada principal do MVP 2D.
- `scenes/2d/player/Player2D.tscn`: player top-down com `CharacterBody2D`, `Camera2D`, colisao e area de interacao.
- `scenes/2d/maps/BaseVillage2D.tscn`: base com colisao, agua, fogueira, fonte e portal.
- `scenes/2d/maps/DungeonFloor2D.tscn`: dungeon simples com bau, areas ambientais e gatilho de batalha.
- `scenes/2d/ui/MobileControls2D.tscn`: joystick esquerdo, botao Menu e botao Interagir.

## Controles

- PC: WASD/setas movem, `E` interage.
- Android: joystick esquerdo move, botao `Interagir` aciona portal/bau/gatilhos.
- Camera: `Camera2D` filha do player, sem controle manual.

## Reaproveitado

- `GameManager`, save, dados de classe e tela de batalha continuam sendo usados.
- `GameManager.BASE_SCENE` aponta para `res://scenes/2d/maps/BaseVillage2D.tscn`.
- `GameManager.DUNGEON_FLOOR_01_SCENE` aponta para `res://scenes/2d/maps/DungeonFloor2D.tscn`.
- Ao acionar gatilho de batalha na dungeon, a tela de batalha existente pode ser chamada por `GameManager.start_dungeon_battle()`.

## Nao Usado No Fluxo Ativo

- `scenes/base/BaseExplore.tscn`
- `scenes/dungeon/DungeonFloor01.tscn`
- `scenes/world/InitialForest.tscn`
- `scripts/world/SkyController.gd`
- `scenes/player/Player.tscn` 3D
- `scenes/ui/MobileControls.tscn` 3D

## Placeholders

O fluxo 2D agora e hibrido:

- classes `mage`, `necromancer`, `warrior`, `assassin` e `paladin` tentam carregar assets reais de `assets/pixel/characters/player/`;
- portraits de batalha e alguns inimigos tentam carregar assets reais via `PixelAssetRegistry.gd`;
- quando um asset nao existe ou falha, o jogo cai para o fallback procedural em `Player2DController.gd` e `PixelArtFactory.gd`.
