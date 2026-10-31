class Personagem {
  final int id;
  final String nome;
  final String status;
  final String especie;
  final String origem;
  final String imagem;
  final String genero;
  final String localizacao;

  Personagem({
    required this.id,
    required this.nome,
    required this.status,
    required this.especie,
    required this.origem,
    required this.imagem,
    required this.genero,
    required this.localizacao,
  });

  factory Personagem.fromMap(Map<String, dynamic> m) => Personagem(
    id: m['id'],
    nome: m['name'],
    status: m['status'],
    especie: m['species'],
    origem: m['origin']['name'],
    imagem: m['image'],
    genero: m['gender'] ?? 'Desconhecido',
    localizacao: (m['location']?['name'] as String?) ?? 'Desconhecida',
  );
}