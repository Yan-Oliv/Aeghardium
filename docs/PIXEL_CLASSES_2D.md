# Classes Pixel Art 2D

O player 2D atual usa modo hibrido:

- `mage`, `necromancer`, `warrior`, `assassin` e `paladin` tentam usar sprite real vindo de `assets/pixel/characters/player/`;
- as demais classes continuam com fallback procedural, mantendo o fluxo 100% 2D sem quebrar o jogo.

## Diferencas Visuais

- Necromante: tunica escura, capuz, cajado, orbe e aura roxa.
- Assassino: corpo fino, capuz, scarf escuro e duas adagas.
- Guerreiro: corpo largo, armadura metalica, ombreiras e espada.
- Arqueiro: roupa verde/marrom, cabelo longo, arco e aljava.
- Mago: robe azul/roxo, cabelo longo azul, cajado, livro e aura azul.
- Berserker: corpo largo, torso parcialmente exposto, cabelo selvagem, pele/fur e machado.
- Druida: roupa verde natural, folhas, cabelo terroso e cajado.
- Clerigo: vestes claras, simbolo sagrado, livro e maca/cajado curto.
- Paladino: armadura clara pesada, halo, escudo e espada.

## Animacoes

Cada classe recebe as mesmas animacoes base:

```text
idle_down
idle_up
idle_left
idle_right
walk_down
walk_up
walk_left
walk_right
```

Quando novos spritesheets finais entrarem em `assets/pixel/characters/player/`, basta registrar o caminho e os recortes em `PixelAssetRegistry.gd` para manter os mesmos nomes de animacao.
