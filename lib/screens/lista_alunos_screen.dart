import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Importando para ter acesso às cores

class ListaAlunosScreen extends StatefulWidget {
  const ListaAlunosScreen({super.key});

  @override
  State<ListaAlunosScreen> createState() => _ListaAlunosScreenState();
}

class _ListaAlunosScreenState extends State<ListaAlunosScreen> {
  // A lógica permanece a mesma, sem alterações
  bool _isLoading = true;
  List<Map<String, dynamic>> _alunosList = [];
  String _busca = '';
  bool _agruparPorCurso = false;
  StreamSubscription? _alunosSubscription;

  @override
  void initState() {
    super.initState();
    _fetchAlunos();
    _alunosSubscription = Supabase.instance.client
        .from('alunos')
        .stream(primaryKey: ['id']).listen((_) {
      _fetchAlunos(isRefresh: true);
    }, onError: (error) {
      print('Erro no Stream do Realtime: $error');
    });
  }

  @override
  void dispose() {
    _alunosSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchAlunos({bool isRefresh = false}) async {
    if (!isRefresh && _alunosList.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await Supabase.instance.client.from('alunos').select();
      if (mounted) {
        setState(() {
          _alunosList = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao carregar alunos: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _marcarPresenca(int alunoId, bool novaPresenca) async {
    final alunoIndex = _alunosList.indexWhere((aluno) => aluno['id'] == alunoId);
    if (alunoIndex == -1) return;
    final Map<String, dynamic> alunoOriginal = Map.from(_alunosList[alunoIndex]);
    final bool presencaOriginal = alunoOriginal['presente'] ?? false;
    setState(() {
      _alunosList[alunoIndex]['presente'] = novaPresenca;
    });
    try {
      await Supabase.instance.client
          .from('alunos')
          .update({'presente': novaPresenca})
          .eq('id', alunoId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _alunosList[alunoIndex]['presente'] = presencaOriginal;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Falha ao marcar presença. Tente novamente.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final alunosFiltrados = _alunosList.where((aluno) {
      final nome = aluno['nome'].toString().toLowerCase();
      final ra = aluno['ra'].toString().toLowerCase();
      final buscaLower = _busca.toLowerCase();
      return nome.contains(buscaLower) || ra.contains(buscaLower);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Presença'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Lista',
            onPressed: () => _fetchAlunos(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Painel de controle (Busca e Agrupamento) com novo visual
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _busca = value),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por Nome ou RA...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Agrupar por Curso', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _agruparPorCurso,
                  onChanged: (value) => setState(() => _agruparPorCurso = value),
                  activeColor: brightGreenTitle,
                  tileColor: cardBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          ),
          // Lista de alunos com RefreshIndicator
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _fetchAlunos(isRefresh: true),
                    color: brightGreenTitle,
                    child: alunosFiltrados.isEmpty
                        ? Center(child: Text(_alunosList.isEmpty ? 'Nenhum aluno cadastrado.' : 'Nenhum resultado para a busca.'))
                        : _agruparPorCurso
                            ? _buildGroupedList(alunosFiltrados)
                            : _buildSimpleList(alunosFiltrados),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<Map<String, dynamic>> alunos) {
    return GroupedListView<Map<String, dynamic>, String>(
      padding: const EdgeInsets.all(8),
      elements: alunos,
      groupBy: (element) => element['curso'] as String,
      groupSeparatorBuilder: (String groupByValue) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Text(
          groupByValue.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: brightGreenTitle, // Título do grupo em verde
            letterSpacing: 1.2,
          ),
        ),
      ),
      itemBuilder: (context, element) => _buildAlunoCard(element),
      itemComparator: (item1, item2) => (item1['nome'] as String).compareTo(item2['nome'] as String),
      order: GroupedListOrder.ASC,
    );
  }

  Widget _buildSimpleList(List<Map<String, dynamic>> alunos) {
    alunos.sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: alunos.length,
      itemBuilder: (context, index) => _buildAlunoCard(alunos[index]),
    );
  }

  // Card do Aluno com o novo visual
  Widget _buildAlunoCard(Map<String, dynamic> aluno) {
    final bool isPresente = aluno['presente'] ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: isPresente ? brightGreenTitle : Colors.grey[700],
          child: Icon(
            isPresente ? Icons.check : Icons.person_outline,
            color: isPresente ? Colors.black : Colors.white,
          ),
        ),
        title: Text(
          aluno['nome'],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'RA: ${aluno['ra']}',
          style: TextStyle(color: Colors.grey[400]),
        ),
        onTap: () {
          _marcarPresenca(aluno['id'], !isPresente);
        },
      ),
    );
  }
}