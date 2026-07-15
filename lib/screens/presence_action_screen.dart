import 'package:flutter/material.dart';

class PresenceActionScreen extends StatelessWidget {
  const PresenceActionScreen({
    super.key,
    required this.student,
    required this.isValidation,
  });

  final Map<String, String> student;
  final bool isValidation;

  @override
  Widget build(BuildContext context) {
    final primary = isValidation ? const Color(0xFF2C8C5D) : Colors.red.shade700;
    final background = isValidation ? const Color(0xFFF2FFF8) : const Color(0xFFFFF5F5);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(isValidation ? 'Validation de présence' : 'Rejet de présence'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
                    fit: BoxFit.cover,
                    width: 170,
                    height: 170,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student['prenom']} ${student['nom']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Matricule: ${student['matricule']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Cycle', value: student['cycle'] ?? ''),
                    _InfoRow(label: 'Classe', value: student['classe'] ?? ''),
                    _InfoRow(label: 'Option', value: student['option'] ?? ''),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isValidation
                            ? 'Cliquez sur le bouton ci-dessous pour confirmer la présence.'
                            : 'Cliquez sur le bouton ci-dessous pour rejeter la présence.',
                        style: TextStyle(color: primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(isValidation ? Icons.check_rounded : Icons.close_rounded),
                  label: Text(isValidation ? 'Confirmer la présence' : 'Rejeter la présence'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.w700)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
