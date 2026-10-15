import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Pets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MinhasAbas(),
    );
  }
}

class MinhasAbas extends StatefulWidget {
  const MinhasAbas({super.key});

  @override
  State<MinhasAbas> createState() => _MinhasAbasState();
}

class _MinhasAbasState extends State<MinhasAbas> {
  final TextEditingController _nomeSalvarController = TextEditingController();
  final TextEditingController _idadeSalvarController = TextEditingController();

  final TextEditingController _idAtualizarController = TextEditingController();
  final TextEditingController _nomeAtualizarController =
      TextEditingController();
  final TextEditingController _idadeAtualizarController =
      TextEditingController();

  final TextEditingController _idApagarController = TextEditingController();

  List<Map<String, dynamic>> _listaPets = [];

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  Future<void> _atualizarLista() async {
    final dados = await DatabaseHelper.listarPets();
    setState(() {
      _listaPets = dados;
    });
  }

  Future<void> _salvarPet() async {
    final nome = _nomeSalvarController.text;
    final idade = int.tryParse(_idadeSalvarController.text) ?? 0;

    if (nome.isNotEmpty) {
      await DatabaseHelper.inserirPet({'nome': nome, 'idade': idade});
      _nomeSalvarController.clear();
      _idadeSalvarController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet salvo com sucesso!')),
      );
      _atualizarLista();
    }
  }

  Future<void> _atualizarPet() async {
    final id = int.tryParse(_idAtualizarController.text);
    final nome = _nomeAtualizarController.text;
    final idade = int.tryParse(_idadeAtualizarController.text) ?? 0;

    if (id != null && nome.isNotEmpty) {
      int linhasAfetadas = await DatabaseHelper.atualizarPet(id, nome, idade);

      if (linhasAfetadas > 0) {
        _idAtualizarController.clear();
        _nomeAtualizarController.clear();
        _idadeAtualizarController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet atualizado com sucesso!')),
        );
        _atualizarLista();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID não encontrado!')),
        );
      }
    }
  }

  Future<void> _apagarPet() async {
    final id = int.tryParse(_idApagarController.text);

    if (id != null) {
      int linhasAfetadas = await DatabaseHelper.apagarPet(id);

      if (linhasAfetadas > 0) {
        _idApagarController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet apagado com sucesso!')),
        );
        _atualizarLista();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID não encontrado!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SQLite - Pets'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Salvar'),
              Tab(icon: Icon(Icons.list), text: 'Listar'),
              Tab(icon: Icon(Icons.edit), text: 'Atualizar'),
              Tab(icon: Icon(Icons.delete), text: 'Apagar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nomeSalvarController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do pet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _idadeSalvarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Idade do pet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _salvarPet,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                  ),
                ],
              ),
            ),

            // ABA 2: LISTAR (ID na frente + Nome + Idade)
            ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _listaPets.length,
              itemBuilder: (context, index) {
                final pet = _listaPets[index];
                return ListTile(
                  title: Text(
                      '${pet['id']} - ${pet['nome']} - ${pet['idade']} anos'),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _idAtualizarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID do pet a atualizar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomeAtualizarController,
                    decoration: const InputDecoration(
                      labelText: 'Novo Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _idadeAtualizarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nova Idade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _atualizarPet,
                    icon: const Icon(Icons.update),
                    label: const Text('Atualizar'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _idApagarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID do pet a apagar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _apagarPet,
                    icon: const Icon(Icons.delete),
                    label: const Text('Apagar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
