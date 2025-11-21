import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../../core/errors/exceptions.dart';

abstract class NotesDataSource {
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel> getNoteById(String id);
  Future<void> saveNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NotesDataSourceImpl implements NotesDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _notesKey = 'user_notes';

  NotesDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final notesJson = sharedPreferences.getString(_notesKey);
      if (notesJson == null) return [];
      
      final List<dynamic> jsonList = json.decode(notesJson);
      final List<NoteModel> notes = [];
      
      for (final item in jsonList) {
        try {
          if (item is Map<String, dynamic>) {
            notes.add(NoteModel.fromJson(item));
          }
        } catch (e) {
          // Ignorar itens inválidos
          continue;
        }
      }
      
      // Ordenar por data de atualização (mais recente primeiro)
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return notes;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    try {
      final notes = await getAllNotes();
      final note = notes.firstWhere((note) => note.id == id);
      return note;
    } catch (e) {
      throw CacheException('Anotação não encontrada: $e');
    }
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    try {
      final notes = await getAllNotes();
      
      // Verificar se já existe
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        // Atualizar existente
        notes[index] = note;
      } else {
        // Adicionar novo
        notes.add(note);
      }
      
      final jsonList = <Map<String, dynamic>>[];
      for (final n in notes) {
        try {
          jsonList.add(n.toJson());
        } catch (e) {
          // Ignorar anotações com erro ao serializar
        }
      }
      
      await sharedPreferences.setString(_notesKey, json.encode(jsonList));
    } catch (e) {
      throw CacheException('Erro ao salvar anotação: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == id);
      
      final jsonList = <Map<String, dynamic>>[];
      for (final n in notes) {
        try {
          jsonList.add(n.toJson());
        } catch (e) {
          // Ignorar anotações com erro ao serializar
        }
      }
      
      await sharedPreferences.setString(_notesKey, json.encode(jsonList));
    } catch (e) {
      throw CacheException('Erro ao deletar anotação: $e');
    }
  }
}

