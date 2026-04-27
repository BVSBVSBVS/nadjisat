import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IzmeniOglasScreen extends StatefulWidget {
  final Map<String, dynamic> oglas;
  const IzmeniOglasScreen({super.key, required this.oglas});

  @override
  State<IzmeniOglasScreen> createState() => _IzmeniOglasScreenState();
}

class _IzmeniOglasScreenState extends State<IzmeniOglasScreen> {
  late TextEditingController naslovController;
  late TextEditingController cenaController;
  late TextEditingController opisController;
  
  bool isCenaDogovor = false;
  String? odabranoStanje;
  bool isSaving = false;

  final List<String> stanja = [
    'Novo sa folijama', 
    ' Kao novo', 
    'Odlično', 
    'Dobro', 
    'Vidljivi tragovi korišćenja'
  ];

  @override
  void initState() {
    super.initState();
    // Učitavamo trenutne podatke iz oglasa
    naslovController = TextEditingController(text: widget.oglas['naslov'] ?? '');
    cenaController = TextEditingController(text: widget.oglas['cena']?.toString() ?? '');
    opisController = TextEditingController(text: widget.oglas['opis'] ?? '');
    
    isCenaDogovor = widget.oglas['cena_dogovor'] ?? false;
    
    if (stanja.contains(widget.oglas['stanje'])) {
      odabranoStanje = widget.oglas['stanje'];
    }
  }

  Future<void> _sacuvajIzmene() async {
    setState(() => isSaving = true);
    
    try {
      await Supabase.instance.client.from('satovi').update({
        'naslov': naslovController.text.trim(),
        'cena': isCenaDogovor ? null : int.tryParse(cenaController.text.trim()),
        'cena_dogovor': isCenaDogovor,
        'opis': opisController.text.trim(),
        'stanje': odabranoStanje,
      }).eq('id', widget.oglas['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno izmenjen!")));
        // Vraćamo se nazad i šaljemo 'true' signal da se ekran osveži
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška pri čuvanju: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Izmeni oglas", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isSaving
        ? const Center(child: CupertinoActivityIndicator(radius: 20))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NASLOV
                const Text("Naslov oglasa", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: naslovController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                ),
                const SizedBox(height: 20),

                // CENA
                const Text("Cena (€)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: cenaController,
                  keyboardType: TextInputType.number,
                  enabled: !isCenaDogovor, // Ako je po dogovoru, gasimo unos cene
                  style: TextStyle(color: isCenaDogovor ? Colors.grey : (isDark ? Colors.white : Colors.black)),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: Text("Cena po dogovoru", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  value: isCenaDogovor,
                  activeColor: Colors.blueAccent,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      isCenaDogovor = val ?? false;
                      if (isCenaDogovor) cenaController.clear();
                    });
                  },
                ),
                const SizedBox(height: 20),

                // STANJE
                const Text("Stanje sata", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: odabranoStanje,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                  ),
                  dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                  items: stanja.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: isDark ? Colors.white : Colors.black)))).toList(),
                  onChanged: (val) => setState(() => odabranoStanje = val),
                ),
                const SizedBox(height: 20),

                // OPIS
                const Text("Opis oglasa", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: opisController,
                  maxLines: 6,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                ),
                const SizedBox(height: 30),

                // DUGME SAČUVAJ
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: CupertinoButton(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _sacuvajIzmene,
                    child: const Text("Sačuvaj izmene", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}