import 'package:flutter/material.dart';
import 'package:control/models/etablissement.dart';
import 'package:control/models/eleve.dart';
import 'package:control/screens/add_student_screen.dart';
import 'package:control/screens/presence_action_screen.dart';
import 'package:control/services/auth_service.dart';

class PhysicalControlScreen extends StatefulWidget {
  final Etablissement? selectedEtablissement;

  const PhysicalControlScreen({super.key, this.selectedEtablissement});

  @override
  State<PhysicalControlScreen> createState() => _PhysicalControlScreenState();
}

class _PhysicalControlScreenState extends State<PhysicalControlScreen> {
  final List<String> cycles = const [
    'Lycée',
    'BT-IND',
    'BT-AD',
    'BT-AP',
    'CAP-IND',
    'CAP-AD',
    'Lycée technique',
  ];

  final Map<String, List<String>> classesByCycle = const {
    'Lycée': ['10è', '11è', '12è'],
    'BT-IND': ['1A', '2A', '3A', '4A'],
    'BT-AD': ['1A', '2A', '3A', '4A'],
    'BT-AP': ['1A', '2A', '3A', '4A'],
    'CAP-IND': ['1A', '2A'],
    'CAP-AD': ['1A', '2A'],
    'Lycée technique': ['10è', '11è', '12è'],
  };

  final Map<String, List<String>> optionsByCycle = const {
    'Lycée': ['CG', 'SES', 'S', 'L'],
    'BT-IND': ['Comptabilité', 'Secrétariat', 'Informatique'],
    'BT-AD': ['Comptabilité', 'Secrétariat', 'Informatique'],
    'BT-AP': ['Comptabilité', 'Secrétariat', 'Informatique'],
    'CAP-IND': ['Comptabilité', 'Secrétariat', 'Informatique'],
    'CAP-AD': ['Comptabilité', 'Secrétariat', 'Informatique'],
    'Lycée technique': ['TSS', 'TSE', 'TLL', 'TSEXP', 'TAL', 'TSECO'],
  };

  String selectedCycle = 'Lycée';
  String selectedClass = '10è';
  String selectedOption = 'CG';
  final TextEditingController matriculeController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isElevesLoading = false;
  String? _elevesError;
  ElevesResponse? _elevesResponse;

  void _addStudent(Map<String, String> student) {
    setState(() {
      students.add({...student, 'status': 'Nouveau'});
    });
  }

  final List<Map<String, String>> initialStudents = const [
    {'matricule': '1001', 'nom': 'Amadou', 'prenom': 'Kéita', 'classe': '10è', 'cycle': 'Lycée', 'option': 'CG', 'status': 'En attente'},
    {'matricule': '1002', 'nom': 'Fatima', 'prenom': 'Diallo', 'classe': '10è', 'cycle': 'Lycée', 'option': 'CG', 'status': 'Rejeté'},
    {'matricule': '1003', 'nom': 'Moussa', 'prenom': 'Demba', 'classe': '11è', 'cycle': 'Lycée', 'option': 'S', 'status': 'Validé'},
    {'matricule': '1004', 'nom': 'Awa', 'prenom': 'Sow', 'classe': '1A', 'cycle': 'BT-IND', 'option': 'Comptabilité', 'status': 'En attente'},
  ];

  late final List<Map<String, String>> students = List.from(initialStudents);

  List<Map<String, String>> get filteredStudents {
    final query = matriculeController.text.toLowerCase();
    return students.where((student) {
      final matchesCycle = student['cycle'] == selectedCycle;
      final matchesClass = student['classe'] == selectedClass;
      final matchesOption = student['option'] == selectedOption;
      final matchesMatricule = query.isEmpty || student['matricule']!.toLowerCase().contains(query);
      return matchesCycle && matchesClass && matchesOption && matchesMatricule;
    }).toList();
  }

  @override
  void dispose() {
    matriculeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedEtablissement?.id != null) {
      _loadEleves(widget.selectedEtablissement!.id!);
    }
  }

  Future<void> _loadEleves(int etablissementId) async {
    setState(() {
      _isElevesLoading = true;
      _elevesError = null;
    });

    try {
      final resp = await _authService.fetchEleves(etablissementId);
      setState(() {
        _elevesResponse = resp;
        // map API eleves into local students list shape
        students = resp.eleves.map((e) {
          final parts = (e.classroom ?? '').split('-');
          final classe = parts.isNotEmpty ? parts.first : '';
          final option = parts.length > 1 ? parts.sublist(1).join('-') : (e.serie ?? '');
          return {
            'matricule': e.matricule,
            'nom': e.nom,
            'prenom': e.prenoms,
            'classe': classe,
            'cycle': e.serie ?? selectedCycle,
            'option': option,
            'status': 'En attente',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _elevesError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isElevesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1261A8);
    final accent = const Color(0xFF2C8C5D);
    final classes = classesByCycle[selectedCycle] ?? [];
    final options = optionsByCycle[selectedCycle] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Contrôle physique'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Map<String, String>>(
                MaterialPageRoute(
                  builder: (context) => AddStudentScreen(
                    establishmentName: widget.selectedEtablissement?.nom  ?? 'EPPM - École primaire publique de M’Bé',
                  ),
                ),
              );
              if (result != null) {
                _addStudent(result);
              }
            },
            icon: const Icon(Icons.person_add_alt_rounded),
            tooltip: 'Ajouter un élève',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Établissement sélectionné',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.selectedEtablissement?.sigle} - ${widget.selectedEtablissement?.nom}' ,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MiniStat(title: 'Effectif total', value: '180', color: primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MiniStat(title: 'Filles', value: '90', color: accent),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MiniStat(title: 'Garçons', value: '90', color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtres', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCycle,
                      decoration: InputDecoration(
                        labelText: 'Cycle',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: cycles.map((cycle) => DropdownMenuItem(value: cycle, child: Text(cycle))).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedCycle = value;
                          selectedClass = classesByCycle[value]!.first;
                          selectedOption = optionsByCycle[value]!.first;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Classe',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: classes.map((className) => DropdownMenuItem(value: className, child: Text(className))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedClass = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedOption,
                      decoration: InputDecoration(
                        labelText: 'Option/Série/Filière',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedOption = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Expanded(child: _StatusPill(label: 'Présents', value: '10', color: Color(0xFF2C8C5D))),
                    SizedBox(width: 8),
                    Expanded(child: _StatusPill(label: 'Absents', value: '2', color: Colors.orange)),
                    SizedBox(width: 8),
                    Expanded(child: _StatusPill(label: 'Reste', value: '150', color: Color(0xFF1261A8))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: matriculeController,
                decoration: InputDecoration(
                  labelText: 'Matricule',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Liste des élèves', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ...filteredStudents.map((student) => _StudentRow(student: student)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});

  final Map<String, String> student;

  @override
  Widget build(BuildContext context) {
    final status = student['status'] ?? 'En attente';
    final isNew = status == 'Nouveau';
    final color = status == 'Validé'
        ? const Color(0xFF2C8C5D)
        : status == 'Rejeté'
            ? Colors.red.shade600
            : isNew
                ? const Color(0xFFB36B00)
                : const Color(0xFF5BA4E6);
    final icon = status == 'Validé'
        ? Icons.check
        : status == 'Rejeté'
            ? Icons.close
            : isNew
                ? Icons.person_add_alt_rounded
                : Icons.hourglass_empty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFFFF7E6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNew ? const Color(0xFFFFD59A) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${student['prenom']} ${student['nom']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Matricule: ${student['matricule']} • ${student['classe']} • ${student['option']}', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (!isNew)
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PresenceActionScreen(
                          student: student,
                          isValidation: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C8C5D), foregroundColor: Colors.white, minimumSize: const Size(82, 34)),
                  child: const Text('Valider'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PresenceActionScreen(
                          student: student,
                          isValidation: false,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, minimumSize: const Size(82, 34)),
                  child: const Text('Refuser'),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Ajouté', style: TextStyle(color: Color(0xFFB36B00), fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
