import 'package:control/models/academie.dart';
import 'package:control/models/etablissement.dart';
import 'package:flutter/material.dart';
import 'package:control/screens/physical_control_screen.dart';
import 'package:control/screens/statistics_screen.dart';
import 'package:control/services/auth_service.dart';

class SchoolSearchScreen extends StatefulWidget {
  const SchoolSearchScreen({super.key});

  @override
  State<SchoolSearchScreen> createState() => _SchoolSearchScreenState();
}

class _SchoolSearchScreenState extends State<SchoolSearchScreen> {
  final AuthService _authService = AuthService();
  List<Academie> academies = [];
  String? selectedAcademyCode;
  bool _isAcademiesLoading = true;
  String? _academiesError;

  List<Etablissement> etablissements = [];
  String? selectedEtablissementSigle;
  bool _isEtablissementsLoading = false;
  String? _etablissementsError;

  @override
  void initState() {
    super.initState();
    academies = const [
      Academie(code: 'BKO-RD', nom: 'BKO-RD'),
      Academie(code: 'BKO-RG', nom: 'BKO-RG'),
      Academie(code: 'KATI', nom: 'KATI'),
      Academie(code: 'KALABANCORO', nom: 'KALABANCORO'),
    ];
    selectedAcademyCode = academies.first.code;
    _loadAcademies();
  }

  void _onAcademyChanged(String? value) {
    if (value == null) return;
    setState(() {
      selectedAcademyCode = value;
      selectedEtablissementSigle = null;
      _etablissementsError = null;
    });
    _loadEtablissementsForAcademy(value);
  }

  Future<void> _loadAcademies() async {
    try {
      final list = await _authService.fetchAcademies();
      setState(() {
        academies = list;
        selectedAcademyCode = academies.isNotEmpty ? academies.first.code : null;
        _academiesError = list.isEmpty ? 'Aucune académie renvoyée par l’API. Utilisation de la liste locale.' : null;
      });
      if (selectedAcademyCode != null) {
        await _loadEtablissementsForAcademy(selectedAcademyCode!);
      }
    } catch (e) {
      setState(() {
        _academiesError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isAcademiesLoading = false;
      });
    }
  }

  Future<void> _loadEtablissementsForAcademy(String academyCode) async {
    final academie = academies.firstWhere(
      (academy) => academy.code == academyCode,
      orElse: () => Academie(code: academyCode, nom: academyCode),
    );

    if (academie.id == null) {
      setState(() {
        etablissements = [];
        selectedEtablissementSigle = null;
        _etablissementsError = 'Impossible de charger les établissements : id d’académie manquant.';
      });
      return;
    }

    setState(() {
      _isEtablissementsLoading = true;
      _etablissementsError = null;
    });

    try {
      final list = await _authService.fetchEtablissements(academie.id!);
      setState(() {
        etablissements = list;
        selectedEtablissementSigle = list.isNotEmpty ? list.first.sigle : null;
      });
    } catch (e) {
      setState(() {
        etablissements = [];
        selectedEtablissementSigle = null;
        _etablissementsError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isEtablissementsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1261A8);
    final accent = const Color(0xFF2C8C5D);
    Etablissement? selectedSchool;
    if (selectedEtablissementSigle != null) {
      final matches = etablissements.where((e) => e.sigle == selectedEtablissementSigle).toList();
      if (matches.isNotEmpty) {
        selectedSchool = matches.first;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Recherche d’établissement'),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    const Text(
                      'Filtrer l’établissement',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (_isAcademiesLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedAcademyCode,
                        decoration: InputDecoration(
                          labelText: 'Académie',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: academies
                            .map((academie) => DropdownMenuItem<String>(
                                  value: academie.code,
                                  child: Text(academie.nom),
                                ))
                            .toList(),
                        onChanged: _onAcademyChanged,
                      ),
                      if (_academiesError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _academiesError!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    if (_isEtablissementsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      )
                    else ...[
                      if (_etablissementsError != null) ...[
                        Text(
                          _etablissementsError!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final options = etablissements.map((e) => e.sigle).toList();
                          if (textEditingValue.text.isEmpty) {
                            return options;
                          }
                          return options
                              .where((sigle) => sigle.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                              .toList();
                        },
                        initialValue: TextEditingValue(text: selectedEtablissementSigle ?? ''),
                        onSelected: (String selection) {
                          setState(() {
                            selectedEtablissementSigle = selection;
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Sigle de l’établissement',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              prefixIcon: const Icon(Icons.school_rounded),
                            ),
                            onFieldSubmitted: (_) => onSubmitted(),
                          );
                        },
                      ),
                  ],
            ]),
              ),
              const SizedBox(height: 16),
              if (selectedSchool != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              selectedSchool.sigle,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedSchool.nom,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(title: 'Académie', value: academies.firstWhere((a) => a.code == selectedAcademyCode, orElse: () => Academie(code: selectedAcademyCode ?? '', nom: selectedAcademyCode ?? '')).nom),
                      _InfoRow(title: 'Ville', value: selectedSchool.nom),
                      _InfoRow(title: 'Contact', value: selectedSchool.telEtb ?? ''),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text('Aucun établissement correspondant à ce filtre.'),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: selectedSchool == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PhysicalControlScreen(
                                    selectedEtablissement: selectedSchool,
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.fitness_center_rounded),
                      label: const Text('Contrôle physique'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const StatisticsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text('Statistiques'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$title : ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
