# Noxxon Aeghardium - Fluxo e UI 2D

Este documento consolida o fluxo ativo do pivot pixel art 2D. O fluxo 3D antigo permanece no projeto como legado, mas nao deve ser carregado pela cena principal.

## Fluxo ativo

```text
Main2D
  -> TitleScreen
  -> IntroScreen
  -> ClassSelectionScreen
  -> CharacterCreationScreen
  -> BaseVillage2D
  -> DungeonFloor2D
  -> BattleScreen
  -> BaseVillage2D
```

## Cenas principais

- Cena principal do projeto: `res://scenes/2d/main/Main2D.tscn`
- Host de jogo: `Main2D/SceneHost`
- Host de overlays/menu: `Main2D/UILayer`
- Base ativa: `res://scenes/2d/maps/BaseVillage2D.tscn`
- Dungeon ativa: `res://scenes/2d/maps/DungeonFloor2D.tscn`
- Player ativo: `res://scenes/2d/player/Player2D.tscn`

## Direcao visual

- Estetica: fantasia sombria mobile, com bordas douradas, paineis azul-noturno e leitura clara.
- Cores principais: dourado `#FFD700`, bordo `#8B0000`, azul noturno `#0A1128`, branco gelo `#F5F5F5`.
- Titulos: serifados quando houver fonte importada, como Cinzel Decorative.
- Texto comum: sans-serif quando houver fonte importada, como Roboto.
- Botoes: cantos arredondados, borda dourada, alto contraste e tamanho confortavel para toque.

## Telas planejadas

- Slots/personagens salvos.
- Criacao de personagem.
- Selecao de classe.
- Base/vila.
- Status do personagem.
- Inventario.
- Batalha por turnos.
- Habilidades.
- Loja.
- Forja.
- Missoes/conquistas.
- Configuracoes.
- Construcao da base.
- Sala secreta/eventos.
- Fim de batalha.

## Regras do fluxo ativo

- Nao instanciar `Node3D`, `Camera3D`, `MeshInstance3D`, `WorldEnvironment` ou `SkyController` no fluxo ativo.
- Nao usar `BaseExplore.tscn`, `InitialForest.tscn`, `DungeonFloor01.tscn` ou `Player.tscn` 3D no fluxo ativo.
- Previews de personagem no fluxo 2D devem usar sprites/labels/placeholders 2D ate existirem assets finais.
- O menu de pausa deve ser aberto pelo `GameManager.toggle_pause_menu()` usando `UILayer`.

## Base/vila 2D

A vila atual contem:

- Spawn do player.
- Fogueira central.
- Portal da dungeon.
- Agua.
- Fonte de cura.
- Descanso.
- Salvamento.
- Loja placeholder.
- Forja placeholder.
- Casas, arvores, cercas, pedras e caixas com colisao 2D.

## Teste rapido

1. Abra o projeto no Godot.
2. Aperte Play.
3. Confirme que a primeira tela e a tela inicial, nao o mapa 3D.
4. Clique em Novo Jogo, avance por introducao, selecao de classe e criacao.
5. Na base 2D, teste WASD/setas, joystick mobile, botao Menu e botao Interagir.
6. Interaja com descanso, salvar, loja/forja placeholders e portal da dungeon.
