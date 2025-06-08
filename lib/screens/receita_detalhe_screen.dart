import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receitas_trabalho_2/services/auth_service.dart';
import '/repositories/receita_repository.dart';
import '/models/receita.dart';
import '/screens/receita_edit_screen.dart'; // Mantido para editar dados gerais

class ReceitaDetalheScreen extends StatefulWidget {
  const ReceitaDetalheScreen({super.key});
  static const routeName = '/receita_detalhe';
  @override
  State<ReceitaDetalheScreen> createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  Receita? _receita;
  bool _isLoading = true;
  // AJUSTE: Estado temporário para os checkboxes dos ingredientes
  late List<bool> _ingredientesMarcados;

  final _receitaRepository = ReceitaRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_receita == null) {
      final receitaInicial =
          ModalRoute.of(context)!.settings.arguments as Receita;
      setState(() {
        _receita = receitaInicial;
        // Inicializa a lista de marcadores com 'false'
        _ingredientesMarcados = List<bool>.filled(
          receitaInicial.ingredientes.length,
          false,
        );
      });
      _carregarDadosCompletos();
    }
  }

  Future<void> _carregarDadosCompletos() async {
    if (!mounted) return;
    if (!_isLoading) setState(() => _isLoading = true);

    final userId = Provider.of<AuthService>(context, listen: false).userId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (_receita != null) {
      final receitaCompleta = await _receitaRepository.buscarReceitaCompleta(
        _receita!.id,
        userId,
      );
      if (mounted) {
        setState(() {
          _receita = receitaCompleta;
          // AJUSTE: Reinicializa os marcadores com base nos dados carregados
          if (receitaCompleta != null) {
            _ingredientesMarcados = List<bool>.filled(
              receitaCompleta.ingredientes.length,
              false,
            );
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editarInformacoesGerais() {
    if (_receita == null) return;
    // Navega para a tela de edição apenas para nome, nota, tempo, etc.
    Navigator.pushNamed(
      context,
      ReceitaEditScreen.routeName,
      arguments: _receita,
    ).then((_) => _carregarDadosCompletos());
  }

  @override
  Widget build(BuildContext context) {
    if (_receita == null || _isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // A AppBar agora é simples, sem botões de ação
      appBar: AppBar(
        title: const Text('Receita'),
        actions: [
          // Botão para editar as informações gerais da receita (nome, nota, tempo)
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Editar informações da receita',
            onPressed: _editarInformacoesGerais,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagemReceita(),
            _buildTituloEDescricao(),
            const Divider(height: 32, indent: 16, endIndent: 16),
            _buildListaIngredientes(),
            const Divider(height: 32, indent: 16, endIndent: 16),
            _buildListaInstrucoes(),
            const SizedBox(height: 32), // Espaço no final
          ],
        ),
      ),
    );
  }

  // AJUSTE: Widget apenas para a imagem
  Widget _buildImagemReceita() {
    final String? url = _receita!.urlImagem;
    if (url == null || url.isEmpty) {
      return SizedBox(
        height: 250,
        width: double.infinity,
        child: Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 100,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 250,
        width: double.infinity,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
            );
          },
        ),
      );
    }
  }

  // AJUSTE: Widget para o título e a descrição abaixo da imagem
  Widget _buildTituloEDescricao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _receita!.nome,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _receita?.descricao ?? 'Descrição não informada',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // AJUSTE: Lista de ingredientes com Checkbox
  Widget _buildListaIngredientes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _receita!.ingredientes.length,
            itemBuilder: (context, index) {
              final ingrediente = _receita!.ingredientes[index];
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('${ingrediente.nome} (${ingrediente.quantidade})'),
                value: _ingredientesMarcados[index],
                onChanged: (bool? value) {
                  setState(() {
                    _ingredientesMarcados[index] = value!;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // AJUSTE: Lista de instruções com subtítulos
  Widget _buildListaInstrucoes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instruções', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _receita!.instrucoes.length,
            itemBuilder: (context, index) {
              final instrucao = _receita!.instrucoes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passo ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instrucao.instrucao,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[800]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
