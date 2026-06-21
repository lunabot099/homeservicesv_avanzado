/// storage_service.dart
/// Servicio de subida y eliminación de archivos en Supabase Storage.
/// Todos los nombres de bucket se leen desde Env (que carga .env en runtime).
/// NO hardcodear nombres de bucket aquí — siempre usar Env.bucket*.
///
/// Métodos *Binary trabajan con Uint8List y son compatibles con Flutter Web.
/// Métodos de File (dart:io) se mantienen para uso en plataformas nativas.
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/config/env.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ── Método genérico de subida ─────────────────────────────────

  /// Sube [file] al [bucket] en la ruta [path].
  /// Usa upsert para sobreescribir si ya existe.
  /// Retorna la URL pública del archivo subido.
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
    String contentType = 'image/jpeg',
    bool upsert = true,
  }) async {
    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: upsert,
          ),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // ── Fotos de perfil ───────────────────────────────────────────

  /// Sube la foto de perfil de un usuario.
  /// Bucket: perfil-fotos (Env.bucketPerfilFotos)
  /// Path: {userId}/perfil.jpg
  Future<String> uploadFotoPerfil({
    required String userId,
    required File file,
  }) async {
    return uploadFile(
      bucket: Env.bucketPerfilFotos,
      path: '$userId/perfil.jpg',
      file: file,
    );
  }

  // ── Documentos del trabajador ─────────────────────────────────

  /// Sube la foto del DUI del trabajador.
  /// Bucket: dui-documentos (Env.bucketDuiDocumentos)
  /// Path: {userId}/dui.jpg
  Future<String> uploadFotoDui({
    required String userId,
    required File file,
  }) async {
    return uploadFile(
      bucket: Env.bucketDuiDocumentos,
      path: '$userId/dui.jpg',
      file: file,
    );
  }

  /// Sube el documento de antecedentes penales del trabajador.
  /// Bucket: antecedentes-documentos (Env.bucketAntecedentesDocumentos)
  /// Path: {userId}/antecedentes.{ext}
  /// [contentType]: 'application/pdf' o 'image/jpeg' según el archivo.
  Future<String> uploadAntecedentes({
    required String userId,
    required File file,
    String contentType = 'application/pdf',
  }) async {
    final ext = contentType == 'application/pdf' ? 'pdf' : 'jpg';
    return uploadFile(
      bucket: Env.bucketAntecedentesDocumentos,
      path: '$userId/antecedentes.$ext',
      file: file,
      contentType: contentType,
    );
  }

  // ── Solicitudes ───────────────────────────────────────────────

  /// Sube una imagen adjunta a una solicitud de servicio.
  /// Bucket: solicitudes-imagenes (Env.bucketSolicitudesImagenes)
  Future<String> uploadSolicitudImagen({
    required String solicitudId,
    required int index,
    required File file,
  }) async {
    return uploadFile(
      bucket: Env.bucketSolicitudesImagenes,
      path: '$solicitudId/$index.jpg',
      file: file,
    );
  }

  /// Sube una imagen adjunta a una solicitud usando bytes.
  Future<String> uploadSolicitudImagenBytes({
    required String solicitudId,
    required int index,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return uploadBinaryData(
      bucket: Env.bucketSolicitudesImagenes,
      path: '$solicitudId/${ts}_$index.jpg',
      bytes: bytes,
      contentType: contentType,
    );
  }

  // ── Chat ──────────────────────────────────────────────────────

  /// Sube una imagen enviada en el chat.
  /// Bucket: chat-imagenes (Env.bucketChatImagenes)
  /// Path: {chatId}/{userId}_{timestamp}.jpg
  Future<String> uploadChatImage({
    required String chatId,
    required String userId,
    required File file,
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return uploadFile(
      bucket: Env.bucketChatImagenes,
      path: '$chatId/${userId}_$ts.jpg',
      file: file,
    );
  }

  // ── Eliminación ───────────────────────────────────────────────

  /// Elimina un archivo de un bucket específico.
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  // ── Métodos Binary (Uint8List) — compatibles con Flutter Web ──
  // Usa uploadBinary de Supabase Storage en lugar de upload(File).

  /// Sube bytes a un bucket. Funciona en web, móvil y escritorio.
  Future<String> uploadBinaryData({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    bool upsert = true,
  }) async {
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: upsert,
          ),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Sube foto de perfil usando bytes.
  /// Bucket: perfil-fotos | Path: {userId}/perfil.jpg
  Future<String> uploadFotoPerfilBytes({
    required String userId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    return uploadBinaryData(
      bucket: Env.bucketPerfilFotos,
      path: '$userId/perfil.jpg',
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Sube foto del DUI usando bytes.
  /// Bucket: dui-documentos | Path: {userId}/dui.jpg
  Future<String> uploadFotoDuiBytes({
    required String userId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    return uploadBinaryData(
      bucket: Env.bucketDuiDocumentos,
      path: '$userId/dui.jpg',
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Sube documento de antecedentes penales usando bytes.
  /// Bucket: antecedentes-documentos | Path: {userId}/antecedentes.{ext}
  Future<String> uploadAntecedentesBytes({
    required String userId,
    required Uint8List bytes,
    String contentType = 'application/pdf',
  }) async {
    final ext = contentType == 'application/pdf' ? 'pdf' : 'jpg';
    return uploadBinaryData(
      bucket: Env.bucketAntecedentesDocumentos,
      path: '$userId/antecedentes.$ext',
      bytes: bytes,
      contentType: contentType,
    );
  }
}
