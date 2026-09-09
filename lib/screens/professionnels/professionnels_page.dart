import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/professionnel.dart';
import 'professionnel_edit_page.dart';

class ProfessionnelsPage extends StatefulWidget {
  const ProfessionnelsPage({super.key});

  @override
  State<ProfessionnelsPage> createState() => _ProfessionnelsPageState();
}

class _ProfessionnelsPageState extends State<ProfessionnelsPage> {
  // Liste des professionnels venant de SQLite
  List<Professionnel> professionnels = [];

  int? selectedIndex;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProfessionnels();
  }

  // Charger les professionnels depuis SQLite
  Future<void> _chargerProfessionnels() async {
    final liste = await DatabaseHelper.instance.getProfessionnels();

    if (!mounted) return;

    setState(() {
      professionnels = liste;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF159E9E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF159E9E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Professionnels',
          style: TextStyle(fontSize: 28),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // =========================
          // LISTE DES PROFESSIONNELS
          // =========================
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : professionnels.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun professionnel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        itemCount: professionnels.length,
                        itemBuilder: (context, index) {
                          final professionnel = professionnels[index];

                          final isSelected =
                              selectedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },

                            child: Card(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.white.withOpacity(0.12),

                              child: Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // NOM
      Text(
        professionnel.nom,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      // SOCIÉTÉ
      Row(
        children: [
          const Icon(
            Icons.business,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              professionnel.societe?.isNotEmpty == true
                  ? professionnel.societe!
                  : 'Non renseignée',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 6),

      // FONCTION / PROFESSION
      Row(
        children: [
          const Icon(
            Icons.work,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              professionnel.fonction?.isNotEmpty == true
                  ? professionnel.fonction!
                  : 'Non renseignée',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 6),

      // TÉLÉPHONE
      Row(
        children: [
          const Icon(
            Icons.phone,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              professionnel.telephone?.isNotEmpty == true
                  ? professionnel.telephone!
                  : 'Non renseigné',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 6),

      // EMAIL
      Row(
        children: [
          const Icon(
            Icons.email,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              professionnel.email?.isNotEmpty == true
                  ? professionnel.email!
                  : 'Non renseigné',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
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
                        },
                      ),
          ),

          // =========================
          // BOUTONS
          // =========================
          Padding(
            padding: const EdgeInsets.only(
              left: 40,
              right: 40,
              bottom: 25,
            ),

            child: Column(
              children: [
                // NOUVEAU
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: _nouveauProfessionnel,

                    icon: const Icon(Icons.add),

                    label: const Text(
                      'Nouveau',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // MODIFIER
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: selectedIndex == null
                        ? null
                        : _modifierProfessionnel,

                    icon: const Icon(Icons.edit),

                    label: const Text(
                      'Modifier',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // SUPPRIMER
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: selectedIndex == null
                        ? null
                        : _supprimerProfessionnel,

                    icon: const Icon(Icons.delete),

                    label: const Text(
                      'Supprimer',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NOUVEAU PROFESSIONNEL
  // ==========================================
  Future<void> _nouveauProfessionnel() async {
    final result = await Navigator.push<Map<String, String>>(
      context,

      MaterialPageRoute(
        builder: (context) => const ProfessionnelEditPage(),
      ),
    );

    if (result == null) return;

    // Transformer le résultat du formulaire
    // en objet Professionnel
    final professionnel = Professionnel(
      nom: result['nom'] ?? '',
      societe: result['societe'] ?? '',
      fonction: result['profession'] ?? '',
      telephone: result['telephone'] ?? '',
      email: result['email'] ?? '',
    );

    // Enregistrer dans SQLite
    await DatabaseHelper.instance.insertProfessionnel(
      professionnel,
    );

    // Recharger la liste
    await _chargerProfessionnels();

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });
  }

  // ==========================================
  // MODIFIER PROFESSIONNEL
  // ==========================================
  Future<void> _modifierProfessionnel() async {
    if (selectedIndex == null) return;

    final professionnelActuel =
        professionnels[selectedIndex!];

    // Convertir l'objet en Map pour le formulaire actuel
    final professionnelMap = <String, String>{
      'nom': professionnelActuel.nom,
      'societe': professionnelActuel.societe ?? '',
      'profession': professionnelActuel.fonction ?? '',
      'telephone': professionnelActuel.telephone ?? '',
      'email': professionnelActuel.email ?? '',
    };

    final result = await Navigator.push<Map<String, String>>(
      context,

      MaterialPageRoute(
        builder: (context) => ProfessionnelEditPage(
          professionnel: professionnelMap,
        ),
      ),
    );

    if (result == null) return;

    // Créer la version modifiée
    // en conservant l'ID SQLite
    final professionnelModifie = Professionnel(
      idProfessionnel:
          professionnelActuel.idProfessionnel,

      nom: result['nom'] ?? '',

      societe: result['societe'] ?? '',

      fonction: result['profession'] ?? '',

      telephone: result['telephone'] ?? '',

      email: result['email'] ?? '',
    );

    // Modifier dans SQLite
    await DatabaseHelper.instance.updateProfessionnel(
      professionnelModifie,
    );

    // Recharger la liste
    await _chargerProfessionnels();

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });
  }

  // ==========================================
  // SUPPRIMER PROFESSIONNEL
  // ==========================================
  Future<void> _supprimerProfessionnel() async {
    if (selectedIndex == null) return;

    final professionnel =
        professionnels[selectedIndex!];

    final confirmation = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),

          content: Text(
            'Voulez-vous vraiment supprimer '
            '${professionnel.nom} ?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Annuler'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    // Supprimer de SQLite
    await DatabaseHelper.instance.deleteProfessionnel(
      professionnel.idProfessionnel!,
    );

    // Recharger la liste
    await _chargerProfessionnels();

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });
  }
}