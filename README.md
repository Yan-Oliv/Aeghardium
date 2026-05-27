# Noxxon Aeghardium

MVP offline em Godot 4.2+ com fluxo principal fechado para teste local e preparo de APK debug Android.

## Nome oficial

O nome oficial do projeto e do aplicativo é `Noxxon Aeghardium`.

## Fluxo atual

`Título > Intro > Classe > Criação > Base > Batalha em Turnos`

## Como rodar no editor

1. Abrir o projeto no Godot `4.2` ou superior.
2. Confirmar a cena principal em `Project > Project Settings > Application > Run`.
3. Verificar que a main scene é `res://scenes/main/Main.tscn`.
4. Rodar o projeto.
5. Testar o fluxo: `Título > Intro > Classe > Criação > Base > Batalha`.

## Como exportar APK debug

1. Instalar os export templates do Godot.
2. Configurar Android SDK e OpenJDK 17 no editor do Godot.
3. Abrir `Project > Export`.
4. Selecionar o preset `Android Debug`.
5. Confirmar o caminho de saída `builds/android/Noxxon_Aeghardium_debug.apk`.
6. Exportar o APK.
7. Instalar no celular.
8. Testar toque, layout e save local.

## Preset Android esperado

- Preset: `Android Debug`
- Output: `builds/android/Noxxon_Aeghardium_debug.apk`
- Package: `com.bannedsystem.noxxonaeghardium`
- App name: `Noxxon Aeghardium`
- Version name: `0.1.0`
- Build: `debug`
- Arquitetura principal: `arm64-v8a`
- Internet permission: desativada

## Checklist no Godot

- [ ] Abre sem erro vermelho.
- [ ] Novo Jogo funciona.
- [ ] Intro aparece.
- [ ] Seleção de classe funciona.
- [ ] Criação de personagem funciona.
- [ ] Base aparece.
- [ ] Entrar na Dungeon funciona.
- [ ] Batalha inicia.
- [ ] Atacar funciona.
- [ ] Skill 1 funciona.
- [ ] Skill 2 funciona.
- [ ] Poção funciona.
- [ ] Defender funciona.
- [ ] Fugir funciona.
- [ ] Vitória volta para base.
- [ ] Derrota volta para base.
- [ ] Salvar Agora funciona.
- [ ] Continuar funciona.
- [ ] Apagar Save funciona.
- [ ] Não exige internet.

## Checklist no celular

- [ ] Botões respondem ao toque.
- [ ] Texto cabe na tela.
- [ ] Criação de personagem funciona.
- [ ] Base não corta botões.
- [ ] Entrar na dungeon funciona.
- [ ] Batalha aceita comandos.
- [ ] Save/Continuar funciona.
- [ ] Não pede internet.

## Offline e Supabase

- O projeto continua `100% offline`.
- `CloudSaveService.gd` permanece desativado e sem URL/chave real.
- Não existe `HTTPRequest` em uso no fluxo do MVP.
- Supabase não é necessário para abrir, jogar, salvar ou continuar.
- Nenhuma senha de banco ou connection string real deve ir para o APK.

## Ícone placeholder

Foi incluído um ícone placeholder simples em `res://assets/ui/noxxon_icon.svg`.

Se quiser trocar depois:

1. Substituir o arquivo por um ícone final.
2. Ajustar os ícones do preset Android no editor, se necessário.
