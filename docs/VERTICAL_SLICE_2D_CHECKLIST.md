# Vertical Slice 2D - Checklist

## Fluxo principal

- [x] Titulo abre pelo `Main2D`.
- [x] Intro entra pelo `GameManager`.
- [x] Selecao de classe usa dados existentes de classe.
- [x] Criacao de personagem salva nome e aparencia.
- [x] Base/Vila 2D carrega `Player2D`.
- [x] Portal leva para `DungeonFloor2D`.
- [x] Dungeon tem inimigo no mapa.
- [x] Inimigo inicia batalha por turnos existente.
- [x] Vitoria marca inimigo como derrotado e retorna para dungeon.
- [x] Fuga/derrota retornam para base.

## Player 2D

- [x] Usa `CharacterBody2D`.
- [x] Usa `AnimatedSprite2D` com fallback procedural.
- [x] Tem fallback humanoide 2D visivel.
- [x] Suporta idle/walk em 4 direcoes.
- [x] Movimento aceita WASD, setas e joystick mobile.
- [x] Classes possuem cores, armas e silhuetas distintas.

## Customizacao

- [x] Nome.
- [x] Tipo visual.
- [x] Tom de pele.
- [x] Estilo de cabelo.
- [x] Cor de cabelo.
- [x] Cor dos olhos.
- [x] Variante de roupa base.
- [x] Aura da classe.
- [x] Preview usa `Player2D.tscn`.
- [x] Aparencia persiste em `player_state.appearance`.

## Equipamentos visuais

- [x] Dados base em `EquipmentVisualData.gd`.
- [x] Arma principal altera o visual.
- [x] Offhand/escudo altera o visual.
- [x] Peitoral/robe altera o visual.
- [x] Capa altera o visual.
- [x] Estrutura de pastas preparada para PNGs finais.

## UI

- [x] Tema central em `UITheme.gd`.
- [x] Bordas douradas consistentes.
- [x] Paineis escuros com bom contraste.
- [x] Botoes com tamanho mobile confortavel.
- [x] Criacao, selecao, titulo, batalha e pause usam o tema compartilhado.

## Teste no editor

1. Rodar `res://scenes/2d/main/Main2D.tscn`.
2. Novo Jogo.
3. Avancar intro.
4. Escolher classe.
5. Criar personagem e alterar aparencia.
6. Confirmar que o preview muda.
7. Entrar na base.
8. Confirmar que o player aparece com classe/aparencia.
9. Entrar no portal.
10. Encostar no inimigo.
11. Vencer batalha.
12. Confirmar retorno para dungeon e inimigo removido.

## Teste Android debug

1. Exportar APK debug.
2. Desinstalar APK antigo.
3. Instalar APK novo.
4. Confirmar que abre na versao 2D.
5. Criar personagem.
6. Testar joystick mobile.
7. Entrar na dungeon.
8. Iniciar batalha.
9. Confirmar retorno apos vitoria.

## Riscos restantes

- Nem todas as classes e inimigos usam arte final; parte do elenco ainda depende de fallback procedural.
- Save ainda guarda apenas a base de aparencia/equipamento visual, nao inventario/equipamento completo.
- O inimigo derrotado e lembrado por sessao, nao por save persistente.
- Algumas telas planejadas como loja completa, inventario completo, forja e habilidades ainda sao placeholders.
