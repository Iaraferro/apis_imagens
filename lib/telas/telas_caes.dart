import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaCaes extends StatefulWidget {
  const TelaCaes({super.key});

  @override
  State<TelaCaes> createState() => _TelaCaesState();
}

class _TelaCaesState extends State<TelaCaes> {
  static const _racas = ['hound', 'husky', 'pug', 'labrador'];
  String _raca = 'hound';

  String? imagem;
  String? erro;
  bool carregando = false;
  int _contador = 0;

  String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> buscarCao() async {
    setState(() { carregando = true; erro = null; });
    try {
      final resposta = await http.get(Uri.parse(
          'https://dog.ceo/api/breed/$_raca/images/random'));
      if (resposta.statusCode != 200) throw Exception('Falha na consulta');
      final dados = jsonDecode(resposta.body);
      if (!mounted) return;
      setState(() {
        imagem = dados['message'];
        _contador++; // item 2: contador de fotos sorteadas
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { erro = 'Não foi possível carregar a foto.'; });
    } finally {
      if (mounted) setState(() { carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // item 1: cor de fundo personalizada
    backgroundColor: const Color(0xFFE8F5E9),
    appBar: AppBar(
      title: const Text('🐶 Galeria de Cães'), 
      backgroundColor: const Color(0xFFA5D6A7),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          
          const Text(
            'Escolha uma raça e descubra um novo amigo!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // item 3: ChoiceChip dentro de um Wrap
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: _racas.map((r) => ChoiceChip(
              label: Text(_capitalizar(r)),
              selected: _raca == r,
              onSelected: (_) => setState(() => _raca = r),
            )).toList(),
          ),

          const SizedBox(height: 12),
          Text('Fotos sorteadas: $_contador',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),
          if (carregando) const CircularProgressIndicator(),
          if (erro != null) Text(erro!),
          if (imagem != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagem!, height: 260, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Text('Imagem indisponível'),
              ),
            ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: carregando ? null : buscarCao,
            child: const Text('Quero um cachorro!'),
          ),
        ]),
      ),
    ),
  );
}