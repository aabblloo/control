import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key, required this.establishmentName});

  final String establishmentName;

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController anneeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController matriculeController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  List<String> academies = [];
  bool _isAcademiesLoading = true;
  String? _academiesError;

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

  String selectedAcademy = 'BKO-RD';
  String selectedCycle = 'Lycée';
  String selectedClass = '10è';
  String selectedOption = 'CG';

  bool hasSearched = false;
  bool hasAdded = false;

  @override
  void initState() {
    super.initState();
    _loadAcademies();
  }

  Future<void> _loadAcademies() async {
    try {
      //final list = await _authService.fetchAcademies();
      final list = null;
      setState(() {
        academies = list.isNotEmpty ? list : const ['BKO-RD', 'BKO-RG', 'KATI', 'KALABANCORO'];
        selectedAcademy = academies.first;
        _academiesError = list.isEmpty ? 'Aucune académie renvoyée par l’API. Utilisation de la liste locale.' : null;
      });
    } catch (e) {
      setState(() {
        academies = const ['BKO-RD', 'BKO-RG', 'KATI', 'KALABANCORO'];
        selectedAcademy = academies.first;
        _academiesError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isAcademiesLoading = false);
    }
  }

  @override
  void dispose() {
    anneeController.dispose();
    placeController.dispose();
    matriculeController.dispose();
    nomController.dispose();
    prenomController.dispose();
    super.dispose();
  }

  void _searchStudent() {
    setState(() {
      hasSearched = true;
      matriculeController.text = anneeController.text.isEmpty ? 'AUTO-001' : '${anneeController.text}-001';
      nomController.text = 'Diallo';
      prenomController.text = 'Mamadou';
      selectedCycle = 'Lycée';
      selectedClass = '10è';
      selectedOption = 'CG';
      hasAdded = false;
    });
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
        title: const Text('Ajouter un élève'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      child: const Text('EPPM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('EPPM', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('École primaire publique de M’Bé', style: TextStyle(color: Color(0xFFEAF3FF), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recherche d’élève', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: anneeController,
                      decoration: const InputDecoration(
                        labelText: 'Année',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isAcademiesLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedAcademy.isEmpty ? null : selectedAcademy,
                        decoration: const InputDecoration(
                          labelText: 'Académie',
                          border: OutlineInputBorder(),
                        ),
                        items: academies.map((academy) => DropdownMenuItem(value: academy, child: Text(academy))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedAcademy = value);
                          }
                        },
                      ),
                      if (_academiesError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _academiesError!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: placeController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de place',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _searchStudent,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Afficher l’élève correspondant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (hasSearched)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informations élève', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: matriculeController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Matricule', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nomController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: prenomController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCycle,
                        decoration: const InputDecoration(labelText: 'Cycle', border: OutlineInputBorder()),
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
                        initialValue: selectedOption,
                        decoration: const InputDecoration(labelText: 'Option / Série', border: OutlineInputBorder()),
                        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedOption = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedClass,
                        decoration: const InputDecoration(labelText: 'Classe', border: OutlineInputBorder()),
                        items: classes.map((className) => DropdownMenuItem(value: className, child: Text(className))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedClass = value);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Ajouter cet élève au compte de ${widget.establishmentName} concerné.',
                          style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final studentData = {
                              'matricule': matriculeController.text.isEmpty ? 'AUTO-001' : matriculeController.text,
                              'nom': nomController.text.isEmpty ? 'Non renseigné' : nomController.text,
                              'prenom': prenomController.text.isEmpty ? 'Non renseigné' : prenomController.text,
                              'classe': selectedClass,
                              'cycle': selectedCycle,
                              'option': selectedOption,
                            };

                            setState(() => hasAdded = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${studentData['prenom']} ${studentData['nom']} ajouté à ${widget.establishmentName}'),
                                backgroundColor: accent,
                              ),
                            );
                            Navigator.of(context).pop(studentData);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Ajouter'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (hasAdded)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6EE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Élève ajouté avec succès.', style: TextStyle(color: Color(0xFF2C8C5D), fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
