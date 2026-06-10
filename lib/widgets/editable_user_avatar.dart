import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditableUserAvatar extends StatefulWidget {
  const EditableUserAvatar({
    super.key,
    required this.userId,
    required this.initial,
    this.size = 60,
    this.gradientColors,
    this.onUpdated,
  });

  final int userId;
  final String initial;
  final double size;
  final List<Color>? gradientColors;
  final ValueChanged<String?>? onUpdated;

  @override
  State<EditableUserAvatar> createState() => _EditableUserAvatarState();
}

class _EditableUserAvatarState extends State<EditableUserAvatar> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  bool _uploading = false;
  String? _localAvatarUrlOverride;

  Future<ImageSource?> _chooseSource(BuildContext context) async {
    if (!context.mounted) return null;
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: scheme.primary,
                      ),
                    ),
                    title: const Text(
                      'Kamera',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: scheme.secondary,
                      ),
                    ),
                    title: const Text(
                      'Galeri',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    if (_uploading) return;

    try {
      final source = await _chooseSource(context);
      if (source == null) return;

      setState(() => _uploading = true);

      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return;

      final fileExt = _safeExtension(picked.name) ?? 'jpg';
      final objectPath =
          '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final file = File(picked.path);
      final contentType = _contentTypeForExt(fileExt);

      await _supabase.storage.from('avatars').upload(
            objectPath,
            file,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(
            objectPath,
          );

      await _supabase
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('user_id', widget.userId);

      _localAvatarUrlOverride = publicUrl;
      widget.onUpdated?.call(publicUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellendi.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final colors = widget.gradientColors ??
        [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary];

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('users')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', widget.userId),
      builder: (context, snapshot) {
        final row = snapshot.data?.isNotEmpty == true ? snapshot.data!.first : null;
        final remoteUrl = row?['avatar_url'] as String?;
        final url = _localAvatarUrlOverride ?? remoteUrl;

        final avatar = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: (url != null && url.isNotEmpty)
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
          ),
          child: (url != null && url.isNotEmpty)
              ? null
              : Center(
                  child: Text(
                    widget.initial,
                    style: TextStyle(
                      fontSize: size * 0.40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
        );

        return InkWell(
          onTap: () => _pickAndUpload(context),
          borderRadius: BorderRadius.circular(size),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: _uploading ? 0.55 : 1,
                child: avatar,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: size * 0.34,
                  height: size * 0.34,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _uploading
                        ? SizedBox(
                            width: size * 0.16,
                            height: size * 0.16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_rounded,
                            size: size * 0.18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String? _safeExtension(String name) {
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return null;
  final ext = name.substring(dot + 1).toLowerCase();
  if (ext.isEmpty) return null;
  if (ext.length > 5) return null;
  return ext;
}

String _contentTypeForExt(String ext) {
  switch (ext.toLowerCase()) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'heic':
    case 'heif':
      return 'image/heic';
    case 'jpeg':
    case 'jpg':
    default:
      return 'image/jpeg';
  }
}

