import 'dart:convert';
import 'dart:math'; // item 5
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaPokemon extends StatefulWidget {
  const TelaPokemon({super.key});

  @override
  State<TelaPokemon> createState() => _TelaPokemonState();
}

class _TelaPokemonState extends State<TelaPokemon> {
  final controle = TextEditingController(text: 'pikachu');
  Map<String, dynamic>? pokemon;
  String? erro;
  bool carregando = false;

  String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> buscarPokemon() async {
    final busca = controle.text.trim().toLowerCase();
    if (busca.isEmpty) {
      setState(() { erro = 'Digite um nome ou número.'; });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { carregando = true; erro = null; pokemon = null; });
    try {
      final resposta = await http.get(Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/${Uri.encodeComponent(busca)}'));
      if (resposta.statusCode != 200) throw Exception('Não encontrado');
      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() { pokemon = dados; });
    } catch (e) {
      if (!mounted) return;
      setState(() { erro = 'Pokémon não encontrado ou sem conexão.'; });
    } finally {
      if (mounted) setState(() { carregando = false; });
    }
  }

  void _sortearPokemon() {
    final numero = Random().nextInt(151) + 1;
    controle.text = '$numero';
    buscarPokemon();
  }

  @override
  void dispose() { controle.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sprite = pokemon?['sprites']?['front_default'];
    final tipos = (pokemon?['types'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: controle,
            decoration: const InputDecoration(
              labelText: 'Nome ou número do Pokémon',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: carregando ? null : buscarPokemon,
                child: const Text('Buscar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: carregando ? null : _sortearPokemon,
                icon: const Icon(Icons.casino),
                label: const Text('Aleatório'),
              ),
            ),
          ]),

          if (carregando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (erro != null) Text(erro!),

          if (pokemon != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // item 4: mostrar o ID também
                  Text(
                    '#${pokemon!['id']} · ${_capitalizar('${pokemon!['name']}')}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (sprite != null)
                    Image.network(sprite,
                        width: 180, height: 180, fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Text('Sem imagem')),
                  Text('Altura: ${pokemon!['height']} décimos de metro'),
                  Text('Peso: ${pokemon!['weight']} décimos de kg'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: tipos.map((t) {
                      final nome = t['type']['name'] as String;
                      return Chip(
                        avatar: const Icon(Icons.bolt, size: 16),
                        label: Text(_capitalizar(nome)),
                      );
                    }).toList(),
                  ),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}