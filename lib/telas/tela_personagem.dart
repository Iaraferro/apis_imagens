import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/personagem.dart';
import 'tela_detalhe_personagem.dart';

class TelaPersonagens extends StatefulWidget {
  const TelaPersonagens({super.key});

  @override
  State<TelaPersonagens> createState() => _TelaPersonagensState();
}

class _TelaPersonagensState extends State<TelaPersonagens> {
  late Future<List<Personagem>> _futuro;

  String _status = ''; // '' = todos, 'alive', 'dead'
  int _pagina = 1;
  int _totalPaginas = 1;
  int? _favoritoId;

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
    _futuro = buscarPersonagens();
  }

  Future<void> _carregarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _favoritoId = prefs.getInt('favorito_id'));
  }

  Future<List<Personagem>> buscarPersonagens() async {
    // item 8: filtro de status na URL; item 9: número da página
    final filtro = _status.isEmpty ? '' : '&status=$_status';
    final resposta = await http.get(Uri.parse(
        'https://rickandmortyapi.com/api/character/?page=$_pagina$filtro'));
    if (resposta.statusCode != 200) {
      throw Exception('Falha na consulta: ${resposta.statusCode}');
    }
    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    final info = dados['info'] as Map<String, dynamic>;
    _totalPaginas = (info['pages'] as num?)?.toInt() ?? 1;

    final lista = dados['results'] as List<dynamic>;
    return lista
        .map((item) => Personagem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  void _mudarStatus(String status) {
    setState(() {
      _status = status;
      _pagina = 1; 
      _futuro = buscarPersonagens();
    });
  }

  void _mudarPagina(int delta) {
    final nova = _pagina + delta;
    if (nova < 1 || nova > _totalPaginas) return;
    setState(() {
      _pagina = nova;
      _futuro = buscarPersonagens();
    });
  }

  // item 10: ao voltar do detalhe, recarrega o favorito salvo
  Future<void> _abrirDetalhe(Personagem p) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => TelaDetalhePersonagem(personagem: p)));
    await _carregarFavorito();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: Column(children: [
        // item 8: três opções de filtro
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '', label: Text('Todos')),
              ButtonSegment(value: 'alive', label: Text('Vivos')),
              ButtonSegment(value: 'dead', label: Text('Mortos')),
            ],
            selected: {_status},
            onSelectionChanged: (s) => _mudarStatus(s.first),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Personagem>>(
            future: _futuro,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Não foi possível carregar os personagens.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () => setState(() {
                              _futuro = buscarPersonagens();
                            }),
                        child: const Text('Tentar de novo')),
                  ]),
                );
              }
              final personagens = snapshot.data!;
              return Column(children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: personagens.length,
                    itemBuilder: (context, i) {
                      final p = personagens[i];
                      final favorito = p.id == _favoritoId;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(p.imagem)),
                          title: Text(p.nome),
                          subtitle: Text('${p.especie} · ${p.status}'),
                          // item 10: estrela no favorito
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (favorito)
                              const Icon(Icons.star, color: Colors.amber),
                            const Icon(Icons.chevron_right),
                          ]),
                          onTap: () => _abrirDetalhe(p),
                        ),
                      );
                    },
                  ),
                ),
                // item 9: navegação entre páginas
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pagina > 1 ? () => _mudarPagina(-1) : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                      ),
                      Text('Página $_pagina de $_totalPaginas'),
                      OutlinedButton.icon(
                        onPressed: _pagina < _totalPaginas
                            ? () => _mudarPagina(1)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Próxima'),
                      ),
                    ],
                  ),
                ),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}