import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/personagem.dart';

class TelaDetalhePersonagem extends StatefulWidget {
  final Personagem personagem;
  const TelaDetalhePersonagem({super.key, required this.personagem});

  @override
  State<TelaDetalhePersonagem> createState() => _TelaDetalhePersonagemState();
}

class _TelaDetalhePersonagemState extends State<TelaDetalhePersonagem> {
  bool _favorito = false;

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
  }

  Future<void> _carregarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() =>
        _favorito = prefs.getInt('favorito_id') == widget.personagem.id);
  }

  // item 10: marca/desmarca como favorito e salva só o id
  Future<void> _alternarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorito) {
      await prefs.remove('favorito_id');
    } else {
      await prefs.setInt('favorito_id', widget.personagem.id);
    }
    if (!mounted) return;
    setState(() => _favorito = !_favorito);
  }

  Color _corStatus() {
    switch (widget.personagem.status) {
      case 'Alive': return Colors.green;
      case 'Dead':  return Colors.red;
      default:      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.personagem;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.nome),
        actions: [
          IconButton(
            tooltip: _favorito ? 'Remover dos favoritos' : 'Marcar como favorito',
            onPressed: _alternarFavorito,
            icon: Icon(
              _favorito ? Icons.star : Icons.star_border,
              color: _favorito ? Colors.amber : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(p.imagem,
                width: 240, height: 240, fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image, size: 120)),
          ),
          const SizedBox(height: 16),
          Text(p.nome,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(Icons.circle, size: 12, color: _corStatus()),
            label: Text(p.status),
          ),
          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Espécie'),
            subtitle: Text(p.especie)),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Origem'),
            subtitle: Text(p.origem)),

          // item 7: gênero e localização atual
          ListTile(
            leading: const Icon(Icons.wc),
            title: const Text('Gênero'),
            subtitle: Text(p.genero)),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Localização atual'),
            subtitle: Text(p.localizacao)),

          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('ID'),
            subtitle: Text('${p.id}')),
        ]),
      ),
    );
  }
}