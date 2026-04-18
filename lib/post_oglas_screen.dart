import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostOglasScreen extends StatefulWidget {
  const PostOglasScreen({super.key});
  @override
  State<PostOglasScreen> createState() => _PostOglasScreenState();
}

class _PostOglasScreenState extends State<PostOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Promenljive
  String? izabranBrend, izabranModel, stanje, materijal, staklo, godina, precnik;
  final cenaController = TextEditingController();

  // BAZA: 25 Brendova i njihovi top modeli
  final Map<String, List<String>> brendoviIModeli = {
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Oyster Perpetual'],
    'Omega': ['Speedmaster', 'Seamaster', 'Aqua Terra', 'Constellation', 'Planet Ocean'],
    'Patek Philippe': ['Nautilus', 'Aquanaut', 'Calatrava', 'Complications', 'Grand Complications'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore', 'Code 11.59', 'Millenary', 'Jules Audemars'],
    'Seiko': ['Prospex', 'Presage', 'Astron', '5 Sports', 'King Seiko'],
    'Grand Seiko': ['Heritage', 'Elegance', 'Sport', 'Evolution 9', 'Masterpiece'],
    'Breitling': ['Navitimer', 'Superocean', 'Chronomat', 'Avenger', 'Premier'],
    'Tudor': ['Black Bay', 'Pelagos', 'Ranger', '1926', 'Royal'],
    'IWC': ['Pilot', 'Portugieser', 'Portofino', 'Aquatimer', 'Ingenieur'],
    'Cartier': ['Santos', 'Tank', 'Pasha', 'Ballon Bleu', 'Panthère'],
    'Panerai': ['Luminor', 'Radiomir', 'Submersible', 'Luminor Due', 'Ferrari'],
    'Hublot': ['Big Bang', 'Classic Fusion', 'Spirit of Big Bang', 'MP Collection', 'King Power'],
    'Zenith': ['Chronomaster', 'Defy', 'Pilot', 'Elite', 'Port Royal'],
    'Vacheron Constantin': ['Overseas', 'Patrimony', 'Traditionnelle', 'FiftySix', 'Historiques'],
    'Jaeger-LeCoultre': ['Reverso', 'Master Control', 'Polaris', 'Rendez-Vous', 'Master Ultra Thin'],
    'Blancpain': ['Fifty Fathoms', 'Villeret', 'Air Command', 'Léman', 'Women'],
    'A. Lange & Söhne': ['Lange 1', 'Zeitwerk', 'Saxonia', '1815', 'Richard Lange'],
    'Tag Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia'],
    'Longines': ['Master Collection', 'HydroConquest', 'Spirit', 'Heritage', 'DolceVita'],
    'Tissot': ['PRX', 'Seastar', 'Le Locle', 'Gentleman', 'Chemin des Tourelles'],
    'Breguet': ['Classique', 'Marine', 'Tradition', 'Type XX', 'Reine de Naples'],
    'Richard Mille': ['RM 11', 'RM 35', 'RM 67', 'RM 65', 'RM 72'],
    'Nomos': ['Tangente', 'Club', 'Metro', 'Ludwig', 'Orion'],
    'Hamilton': ['Khaki Field', 'Khaki Aviation', 'Jazzmaster', 'Ventura', 'American Classic'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Vintage', 'Oceanus'],
  };

  final List<String> stanja = ['Novo (Nenošeno)', 'Odlično (Kao novo)', 'Vrlo dobro', 'Dobro', 'Za delove'];
  final List<String> materijali = ['Čelik', 'Zlato', 'Titanijum', 'Keramika', 'Platina', 'Karbon'];
  final List<String> stakla = ['Safirno', 'Mineralno', 'Akrilno (Plexi)'];
  
  // Generisane liste za Godine (1950-2024) i Prečnik (28mm - 55mm)
  final List<String> godine = List.generate(75, (index) => (2024 - index).toString());
  final List<String> precnici = List.generate(28, (index) => "${28 + index} mm");

  Future<void> _postaviOglas() async {
    if (_formKey.currentState!.validate() && izabranBrend != null && izabranModel != null) {
      final user = Supabase.instance.client.auth.currentUser;
      try {
        await Supabase.instance.client.from('satovi').insert({
          'user_email': user?.email,
          'brend': izabranBrend,
          'model': izabranModel, // Sada je ovo iz padajućeg menija!
          'cena': int.tryParse(cenaController.text.trim()) ?? 0,
          'godina': godina,
          'precnik': precnik,
          'stanje': stanje,
          'materijal': materijal,
          'staklo': staklo,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno postavljen!"), backgroundColor: Colors.green));
          // Resetuj formu nakon slanja
          setState(() { izabranBrend = null; izabranModel = null; cenaController.clear(); });
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e"), backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni sva obavezna polja!"), backgroundColor: Colors.orange));
    }
  }

  // Moderni Expense-Tracker dizajn padajućih menija
  Widget _napraviDropdown(String label, String? vrednost, List<String> opcije, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        value: vrednost,
        items: opcije.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Obavezno polje' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Premium svetlo siva pozadina
      appBar: AppBar(
        title: const Text("Detalji Oglasa", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Osnovne informacije", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            
            // DEPENDENT DROPDOWN: Prvo biraš brend...
            _napraviDropdown("Brend", izabranBrend, brendoviIModeli.keys.toList(), (v) {
              setState(() {
                izabranBrend = v;
                izabranModel = null; // Resetuj model kad promeniš brend
              });
            }),

            // ...Onda ti nudi modele samo za taj brend!
            _napraviDropdown("Model", izabranModel, izabranBrend == null ? [] : brendoviIModeli[izabranBrend]!, (v) => setState(() => izabranModel = v)),

            // Jedino polje koje se kuca je Cena
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: cenaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Cena (€)",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  prefixIcon: const Icon(Icons.euro, color: Colors.black54),
                ),
                validator: (v) => v!.isEmpty ? 'Unesi cenu' : null,
              ),
            ),

            const SizedBox(height: 10),
            const Text("Specifikacije", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _napraviDropdown("Godina", godina, godine, (v) => setState(() => godina = v))),
                const SizedBox(width: 16),
                Expanded(child: _napraviDropdown("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
              ],
            ),
            
            _napraviDropdown("Stanje", stanje, stanja, (v) => setState(() => stanje = v)),
            _napraviDropdown("Materijal", materijal, materijali, (v) => setState(() => materijal = v)),
            _napraviDropdown("Staklo", staklo, stakla, (v) => setState(() => staklo = v)),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 5,
              ),
              onPressed: _postaviOglas,
              child: const Text("OBJAVI OGLAS", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}