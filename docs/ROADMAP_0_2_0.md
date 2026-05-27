# ROADMAP 0.2.0

## Objetivo da versão 0.2.0

Preparar a transição do MVP 0.1.0 para uma fase jogável com exploração simples, mantendo o projeto offline, o APK Android exportável e o fluxo atual intacto como fallback seguro.

Objetivo central:

- sair de um fluxo principalmente em UI para uma base técnica que suporte exploração leve, interação local e ida/volta entre base e batalha sem quebrar o save local nem a estrutura atual.

## Escopo principal da 0.2.0

1. Personagem visual placeholder por classe.
2. Base 3D navegável simples.
3. Joystick virtual/mobile básico.
4. Câmera orbital simples.
5. Interação com portal da dungeon.
6. Transição da exploração para batalha em turnos.
7. Retorno para base após batalha.

## Sistemas planejados

- placeholders visuais por classe para diferenciar o personagem em jogo;
- cena de base separada da UI atual, com navegação simples;
- camada de exploração organizada em pastas próprias;
- ponto de interação local para entrada da dungeon;
- transição controlada entre exploração e batalha;
- retorno consistente para base após vitória, derrota ou fuga;
- preservação do save local no fluxo novo;
- manutenção do build Android debug offline.

## Fora do escopo nesta fase

- customização completa;
- transmog;
- forja real;
- loja real;
- skill tree;
- 30 habilidades por classe;
- multiplayer;
- Supabase;
- sistema online;
- mapas gigantes;
- mundo aberto complexo;
- reescrita total do MVP 0.1.0.

## Ordem de implementação

1. Consolidar estrutura de pastas e contratos de dados da 0.2.0.
2. Criar personagem visual placeholder por classe.
3. Criar cena simples de base navegável.
4. Revisar joystick virtual e entrada mobile.
5. Implementar câmera orbital simples.
6. Adicionar portal interativo da dungeon.
7. Ligar transição exploração > batalha em turnos.
8. Garantir retorno para base após a batalha.
9. Validar save local, Android debug e fallback para o fluxo atual.

## Proteções para não quebrar o MVP 0.1.0

- `res://scenes/main/Main.tscn` continua como cena principal.
- fluxo atual `Título > Intro > Classe > Criação > Base > Batalha em Turnos` deve permanecer funcional.
- novos sistemas devem entrar atrás de flags ou em cenas separadas.
- nenhuma integração online deve ser adicionada.
- save local atual deve continuar compatível.
- export Android deve continuar viável.

## Branch e escopo recomendados

- branch recomendada para desenvolvimento: `feature/0.2.0-foundation`
- estratégia recomendada: pequenas entregas incrementais sobre cenas/pastas novas, sem substituir o fluxo existente até haver equivalência funcional mínima.

## Riscos

- mistura entre cenas antigas de UI e novas cenas de exploração;
- regressão no fluxo atual se o `GameManager` passar a apontar cedo demais para cenas novas;
- duplicação de dados entre personagem de batalha e personagem explorável;
- quebra de input mobile ao trocar HUD antes de validar Android;
- incompatibilidade do save local se o schema mudar sem migração;
- aumento de complexidade de câmera e navegação em aparelho físico.

## Checklist de aceite da 0.2.0

- [ ] `Main.tscn` continua como cena principal.
- [ ] Nome oficial continua `Noxxon Aeghardium`.
- [ ] Projeto continua offline.
- [ ] Supabase continua fora de uso.
- [ ] Save local atual continua funcionando.
- [ ] APK Android continua exportável.
- [ ] Estrutura nova de pastas está organizada.
- [ ] Personagem visual placeholder por classe está visível.
- [ ] Base 3D simples é navegável.
- [ ] Joystick mobile básico funciona.
- [ ] Câmera orbital simples funciona.
- [ ] Portal da dungeon inicia a transição.
- [ ] Batalha em turnos continua acessível.
- [ ] Retorno para base após batalha funciona.
- [ ] Fluxo 0.1.0 permanece utilizável como fallback durante a migração.
