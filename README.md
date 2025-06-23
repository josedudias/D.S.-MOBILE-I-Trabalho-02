# Aplicativo Pokédex

Uma aplicação Pokédex desenvolvida com Flutter como projeto de aprendizado. Utiliza a [PokeAPI](https://pokeapi.co/) para buscar dados dos Pokémon e exibi-los em uma interface amigável.

## Como construir o projeto

### Pré-requisitos

- Ter o Flutter instalado ([Guia de instalação](https://docs.flutter.dev/get-started/install)).

### Passos para instalação e execução

```sh
$ git clone https://github.com/josedudidas/D.S.-MOBILE-I-Trabalho-01.git && cd pokedex
$ flutter pub get
$ flutter run
```

### Para gerar o APK

```sh
$ flutter build apk
```

O APK gerado estará em `build/app/outputs/apk/release/app-release.apk`.

**[Clique aqui para baixar o APK](https://seulinkparaapk.com/pokedex.apk)** (substituir quando houver o link oficial).

## Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento mobile multiplataforma
- **Dart** - Linguagem de programação
- **SQLite** - Cache local de dados
- **cached_network_image** - Cache de imagens de rede

## Principais Funcionalidades ✨

- **Navegação e Busca:**

  - Lista de Pokémon com rolagem infinita.
  - Busca por nome de Pokémon com debounce.
  - Filtros por Tipo e Geração.

- **Detalhamento Completo do Pokémon:**

  - **Informações Básicas:** ID, altura, peso, espécie, descrição (aleatória entre versões de jogos), experiência base, felicidade base, taxa de captura, taxa de crescimento, habitat e geração.
  - **Sprites:** Galeria de imagens (frente, costas, padrão e brilhante) com efeito de brilho.
  - **Tipos:** Exibição dos tipos com cores temáticas.
  - **Sons (Cries):** Reprodução dos sons "Moderno" e "Clássico" dos Pokémon.
  - **Atributos Básicos:** Visualização dos atributos (HP, Ataque, Defesa, Ataque Especial, Defesa Especial, Velocidade) com barras coloridas.
  - **Comparação de Atributos:** Comparação dos atributos com outro Pokémon pesquisável.
  - **Efetividade de Tipos:** Exibe fraquezas, resistências, imunidades (defensivo) e vantagens/desvantagens (ofensivo).
  - **Habilidades:** Lista habilidades normais e ocultas, com descrições detalhadas, efeitos e Pokémon relacionados.
  - **Itens Segurados:** Exibe itens que o Pokémon pode carregar na natureza, raridade por versão e descrição dos itens.
  - **Cadeia Evolutiva:** Visualiza toda a linha evolutiva, com condições específicas (nível, item, troca, felicidade, período do dia, etc.).
  - **Movimentos:** Lista detalhada dos golpes que o Pokémon pode aprender, com filtros por método de aprendizado (Level Up, TM/HM, Ovo, Tutor) e ordenação. Inclui detalhes do movimento (Tipo, Classe, Poder, Precisão, PP, descrição).

- **Efeitos Visuais Especiais:**

  - Efeitos de partículas e medalhas para Pokémon Lendários e Míticos.

- **Performance:**
  - Uso de cache local (SQLite) para dados da API, melhorando o desempenho.
  - Cache de imagens com `cached_network_image`.
  - Carregamento paginado de listas (Pokémon, Movimentos, etc.).

## Prints da Aplicação 📸

### Tela de login

![](./media/login.png)

### Tela de registro

![](./media/register.png)

### Tela Inicial

![](./media/image1.png)

### Detalhes do Pokémon

![](./media/image2.png)

#### Informações Básicas

![](./media/image3.png)

#### Itens Segurados

![](./media/image11.png)

#### Atributos Básicos

![](./media/image4.png)
![](./media/image8.png)

#### Fraquezas e Resistências

![](./media/image5.png)
![](./media/image9.png)

#### Habilidades e Sons dos Pokémon

![](./media/image6.png)
![](./media/gif4.gif)

#### Evoluções

![](./media/gif2.gif)

#### Golpes

![](./media/image7.png)
![](./media/image10.png)

### Animações Customizadas

![](./media/gif1.gif)
![](./media/gif3.gif)