# 🐶APIS de Imagens

Aplicativo **Flutter** desenvolvido como atividade prática da disciplina, com o objetivo de consumir **APIs públicas** e manipular respostas JSON, estados e persistência local.

O app reúne três telas independentes, cada uma consumindo uma API diferente e aplicando conceitos progressivos de Flutter (setState, FutureBuilder, ChoiceChip, Card, Chip, SharedPreferences etc.).

---

## Telas e funcionalidades

### 🐶 Galeria de Cães — [Dog CEO API](https://dog.ceo/dog-api/)
- Sorteio de fotos aleatórias de cachorros.
- Escolha da **raça** por `ChoiceChip` (hound, husky, pug, labrador).
- **Contador** de fotos sorteadas, atualizado com `setState`.
- Personalização de título, cor de fundo, frase acima da imagem e texto do botão.

### Pokédex — [PokéAPI](https://pokeapi.co/)
- Busca por **nome ou número** do Pokémon.
- Botão de **Pokémon aleatório** (nº 1 a 151) usando `Random().nextInt(151) + 1`.
- Resultado exibido em um **`Card`** com **ID**, nome, sprite, altura e peso.
- Exibição dos **tipos** do Pokémon como `Chip` dentro de um `Wrap`.

### 👽 Personagens — [Rick and Morty API](https://rickandmortyapi.com/)
- Listagem de personagens em `Card` + `ListTile`.
- **Filtro** por status (Todos / Vivos / Mortos) via `?status=alive` ou `?status=dead`.
- **Paginação** com botões Anterior/Próxima usando `?page=N` e `info.pages`.
- Tela de detalhe mostrando **gênero** e **localização atual**.
- **Favorito** persistido com `SharedPreferences` (salva apenas o `id`) e exibido com uma ⭐ na lista.

---

## Tecnologias utilizadas

- **[Flutter](https://flutter.dev/)** — framework de UI multiplataforma.
- **[http](https://pub.dev/packages/http)** — requisições HTTP para as APIs.
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** — persistência local do personagem favorito.
- **dart:convert** — decodificação de respostas JSON.

---

## Como executar

### Pré-requisitos
- Flutter instalado ([guia oficial](https://docs.flutter.dev/get-started/install)).
- Um emulador, dispositivo físico ou navegador para rodar o app.

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/SEU_USUARIO/apis_imagens.git
cd apis_imagens

# 2. Instale as dependências
flutter pub get

# 3. Rode o app
flutter run
