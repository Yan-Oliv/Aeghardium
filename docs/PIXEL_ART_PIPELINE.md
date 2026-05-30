# Biblia Visual Pixel Art

## Direcao

Noxxon Aeghardium usa pixel art top-down levemente angulada, com fantasia aventureira, cores vibrantes e contraste sombrio. O alvo visual e legivel em celular: silhuetas claras, animacoes curtas e poucos detalhes pequenos demais para telas pequenas.

## Resolucao E Escala

- Resolucao base de gameplay: `320x180` unidades visuais, escalada para a janela do projeto.
- Viewport do projeto: `1280x720`.
- Escala visual recomendada: `4x` para sprites pixel art quando exibidos em UI/preview; no mapa, manter leitura de `2x` a `3x` via `Camera2D.zoom`.
- Filtro: nearest/pixelado. Texturas pixel devem ser importadas sem suavizacao.

## Tile Size

- Tile base: `16x16 px`.
- Props pequenos: multiplos de `16x16`.
- Casas/objetos grandes: compostos em blocos de `16x16`, normalmente `48x48`, `64x64` ou `96x64`.
- Colisao: simplificar em retangulos por bloco grande, evitando colisao pixel-perfect.

## Tamanhos De Sprite

- Player: `24x32 px`.
- NPCs humanoides: `24x32 px`.
- Inimigos pequenos: `24x24 px`.
- Inimigos medios: `32x32 px`.
- Bosses: `48x48 px` ou maior, conforme arena.
- Portraits UI: `96x96 px`.

## Animacoes

- Direcoes minimas: `down`, `up`, `left`, `right`.
- Idle: `2 frames`, 350 ms por frame.
- Walk: `4 frames`, 110 ms por frame.
- Run, se existir: `4 frames`, 85 ms por frame.
- Attack/cast: `4 a 6 frames`.
- Hit: `2 frames`.
- Death: `4 a 6 frames`.

Convenção de nome:

```text
<classe>_<estado>_<direcao>.png
mage_idle_down.png
mage_walk_left.png
warrior_cast_down.png
```

## Estrutura De Assets

```text
assets/pixel/
├── tilesets/
├── characters/
│   ├── player/
│   ├── npcs/
│   └── enemies/
├── equipment/
├── props/
├── ui/
├── portraits/
└── effects/
```

## Classes Do Player

Cada classe deve ter silhueta e paleta reconheciveis:

- Mago: tunica azul/roxa, cabelo azul/prateado, cajado, aura azul.
- Necromante: preto/roxo, rosto palido, cajado/livro, aura sombria.
- Guerreiro: armadura cinza, espada, ombros largos.
- Assassino: escuro, capuz, duas adagas, silhueta fina.
- Paladino: branco/dourado, escudo, espada, brilho sagrado.
- Arqueiro: verde/marrom, arco, capa curta.
- Berserker: vermelho/marrom, machado, corpo largo.
- Druida: verde/musgo, cajado natural, folhas.
- Clerigo: branco/dourado, livro/cajado, luz suave.

## Modularidade Visual

O MVP pode usar sprites completos por classe. A evolucao planejada e modular:

- Base body: corpo/cabeca/pele.
- Hair layer: cabelo/capuz.
- Outfit layer: tunica/armadura.
- Weapon layer: arma principal.
- Offhand layer: escudo/livro/adaga.
- Aura/effects layer: brilho, fogo, molhado, veneno.

Ordem de desenho recomendada:

```text
shadow
body
outfit
hair_or_helmet
weapon_back
weapon_front
status_effects
```

## Mapas

Vila/base:

- Grama, pedra, caminho de terra, agua, casas, fogueira, fonte, portal.
- Vegetacao densa nas bordas para esconder limites.
- Colisoes simples em casas, arvores, pedras e cercas.

Dungeon:

- Piso escuro, paredes de pedra, pilares, lama, fogo, agua, bau e inimigos.
- Layout em salas compactas para mobile.

## UI Pixel

- Fontes devem ser legiveis antes de decorativas.
- Botoes mobile grandes o suficiente para toque.
- Molduras podem usar 9-slice futuramente.

## Estado Atual

Enquanto sprites reais nao existirem, `Player2DController.gd` gera placeholders por codigo com `ImageTexture` e monta `SpriteFrames` para `AnimatedSprite2D`. Eles servem para validar gameplay, animacoes e troca de classe.

## Player Atual

O player ativo usa:

- `CharacterBody2D`
- `AnimatedSprite2D`
- `SpriteFrames` gerados por codigo
- Animacoes `idle_down`, `idle_up`, `idle_left`, `idle_right`
- Animacoes `walk_down`, `walk_up`, `walk_left`, `walk_right`

O movimento e 8 direcoes; a animacao usa a direcao dominante do vetor de movimento.
