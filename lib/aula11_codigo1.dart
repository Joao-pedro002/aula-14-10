import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// 1. CLASSE HELPER PARA GERENCIAR O BANCO DE DADOS
class DatabaseHelper {
  static Database? _database;

  // Garante que o banco seja inicializado e retorna a conexão ativa
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Cria o arquivo do banco no dispositivo e define a tabela
  static Future<Database> _initDatabase() async {
    String path = '';

    if (Platform.isWindows || Platform.isLinux) {
      // No Windows, salva em uma pasta padrão do FFI
      final databaseFactory = databaseFactoryFfi;
      final caminhoBanco = await databaseFactory.getDatabasesPath();
      path = join(caminhoBanco, 'banco_pets.db');
    } else {
      // No Android/iOS, usa o caminho padrão do celular
      String caminhoBanco = await getDatabasesPath();
      path = join(caminhoBanco, 'banco_pets.db');
    }

    // Abre o banco e roda o CREATE TABLE apenas na primeira vez
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE caes (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            nome TEXT, 
            dono TEXT, 
            idade INTEGER
          )
        ''');
      },
    );
  }

  // Função auxiliar para inserir dados na tabela 'caes'
  static Future<int> inserirCao(Map<String, dynamic> dados) async {
    final db = await DatabaseHelper.database;
    return await db.insert('caes', dados);
  }
}
