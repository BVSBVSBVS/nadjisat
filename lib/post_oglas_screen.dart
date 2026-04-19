import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PostOglasScreen extends StatefulWidget {
  const PostOglasScreen({super.key});
  @override
  State<PostOglasScreen> createState() => _PostOglasScreenState();
}

class _PostOglasScreenState extends State<PostOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isUploading = false;

  // --- 1. IDENTIFIKACIJA ---
  String? izabranBrend, izabranModel, godina;
  final refBrojController = TextEditingController();

  // --- 2. TEHNIČKE SPECIFIKACIJE ---
  String? namena, mehanizam, precnik, materijalKucista, materijalNarukvice, bojaBrojcanika, vodootpornost;

  // --- 3. STANJE I OPREMA ---
  String? stanjeSata;
  bool imaKutiju = false;
  bool imaPapire = false;
  final servisController = TextEditingController();
  final ostecenjaController = TextEditingController();
  List<XFile> izabraneSlike = [];
  final ImagePicker _picker = ImagePicker();

  // --- 4. FINANSIJE I LOKACIJA ---
  final cenaController = TextEditingController();
  String valuta = 'EUR';
  bool zamena = false;
  final lokacijaController = TextEditingController();
  final opisController = TextEditingController();

  // --- BAZE PODATAKA ZA MENIJE ---
  final Map<String, List<String>> brendoviIModeli = {
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Oyster Perpetual', 'Sea-Dweller', 'Yacht-Master'],
    'Omega': ['Speedmaster', 'Seamaster', 'Aqua Terra', 'Planet Ocean', 'De Ville'],
    'Patek Philippe': ['Nautilus', 'Aquanaut', 'Calatrava', 'Complications'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore', 'Code 11.59'],
    'Seiko': ['Prospex', 'Presage', '5 Sports', 'Astron'],
    'Breitling': ['Navitimer', 'Superocean', 'Chronomat', 'Avenger'],
    'Tudor': ['Black Bay', 'Pelagos', 'Ranger', '1926'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Vintage'],
  }; 

  final List<String> godine = List.generate(75, (index) => (2024 - index).toString());
  final List<String> namene = ['Dres (Dress)', 'Ronilački (Diver)', 'Hronograf (Chronograph)', 'Pilot (Aviator)', 'Sportski/GADA', 'Luksuzni', 'Smartwatch'];
  final List<String> mehanizmi = ['Automatik', 'Manuelni', 'Kvarcni', 'Spring Drive', 'Solar', 'Kinetic'];
  final List<String> precnici = ['Do 34mm', '36mm', '38mm', '40mm', '42mm', '44mm', '46mm+'];
  final List<String> materijali = ['Čelik', 'Zlato (18k)', 'Titanijum', 'Platina', 'Keramika', 'Bronza', 'Guma/Plastika'];
  final List<String> materijaliNarukvice = ['Čelik', 'Koža', 'Guma', 'Tekstil/Nato', 'Titanijum', 'Zlato'];
  final List<String> bojeBrojcanika = ['Crna', 'Plava', 'Bela/Srebrna', 'Zelena', 'Siva', 'Zlatna', 'Druga'];
  final List<String> stanja = ['1. Novo sa folijama', '2. Kao novo', '3. Odlično', '4. Dobro', '5. Vidljivi tragovi korišćenja'];
  final List<String> valute = ['EUR', 'RSD', 'KM'];

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        izabraneSlike.addAll(slike);
        if (izabraneSlike.length > 16) {
          izabraneSlike = izabraneSlike.sublist(0, 16);
          // OVO JE PRVI FIX (context.mounted)
          if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 16 slika.")));
        }
      });
    }
  }

  Future<void> _postaviOglas() async {
    if (izabranBrend == null || izabranModel == null || cenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni osnovna obavezna polja (Brend, Model, Cena)!")));
      return;
    }
    if (izabraneSlike.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Moraš dodati barem 1 sliku.")));
      return;
    }

    setState(() => isUploading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      List<String> slikeUrls = [];
      for (var slika in izabraneSlike) {
        final bytes = await slika.readAsBytes();
        final imeFajla = '${DateTime.now().millisecondsSinceEpoch}_${slika.name}';
        try {
          await Supabase.instance.client.storage.from('slike_oglasi').uploadBinary(imeFajla, bytes);
          slikeUrls.add(Supabase.instance.client.storage.from('slike_oglasi').getPublicUrl(imeFajla));
        } catch (_) {
          await Supabase.instance.client.storage.from('slike-oglasi').uploadBinary(imeFajla, bytes);
          slikeUrls.add(Supabase.instance.client.storage.from('slike-oglasi').getPublicUrl(imeFajla));
        }
      }

      await Supabase.instance.client.from('satovi').insert({
        'user_id': user?.id,
        'user_email': user?.email,
        'naslov': '$izabranBrend $izabranModel',
        'brend': izabranBrend,
        'model': izabranModel,
        'ref_broj': refBrojController.text.trim(),
        'godina': godina,
        'namena': namena,
        'mehanizam': mehanizam,
        'precnik': precnik,
        'materijal': materijalKucista,
        'materijal_narukvice': materijalNarukvice,
        'boja_brojcanika': bojaBrojcanika,
        'stanje': stanjeSata,
        'originalna_kutija': imaKutiju,
        'originalni_papiri': imaPapire,
        'servisna_istorija': servisController.text.trim(),
        'ostecenja': ostecenjaController.text.trim(),
        'cena': int.tryParse(cenaController.text.trim()) ?? 0,
        'valuta': valuta,
        'zamena': zamena,
        'lokacija': lokacijaController.text.trim(),
        'opis': opisController.text.trim(),
        'slike': slikeUrls.join(','),
      });

      // OVO JE DRUGI FIX (context.mounted umesto samo mounted)
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspješno postavljen!")));
      Navigator.pop(context); 

    } catch (e) {
      // OVO JE TREĆI FIX
      if(!context.mounted) return;
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: isDark ? Colors.white : Colors.black)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Postavi oglas", style: TextStyle(fontWeight: FontWeight.bold))),
      body: isUploading 
          ? const Center(child: CupertinoActivityIndicator(radius: 20)) 
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader("1. Identifikacija sata", CupertinoIcons.tag_fill),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildDropdown("Brend *", izabranBrend, brendoviIModeli.keys.toList(), (v) => setState(() { izabranBrend = v; izabranModel = null; })),
                        if (izabranBrend != null) 
                          _buildDropdown("Model *", izabranModel, brendoviIModeli[izabranBrend]!, (v) => setState(() => izabranModel = v)),
                        CupertinoTextField(
                          controller: refBrojController, placeholder: "Referentni broj (npr. 116610LN)",
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown("Godina proizvodnje", godina, godine, (v) => setState(() => godina = v)),
                      ],
                    ),
                  ),

                  _buildSectionHeader("2. Tehničke specifikacije", CupertinoIcons.gear_alt_fill),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildDropdown("Kategorija / Namjena", namena, namene, (v) => setState(() => namena = v)),
                        _buildDropdown("Mehanizam", mehanizam, mehanizmi, (v) => setState(() => mehanizam = v)),
                        _buildDropdown("Prečnik kućišta", precnik, precnici, (v) => setState(() => precnik = v)),
                        _buildDropdown("Materijal kućišta", materijalKucista, materijali, (v) => setState(() => materijalKucista = v)),
                        _buildDropdown("Materijal narukvice", materijalNarukvice, materijaliNarukvice, (v) => setState(() => materijalNarukvice = v)),
                        _buildDropdown("Boja brojčanika", bojaBrojcanika, bojeBrojcanika, (v) => setState(() => bojaBrojcanika = v)),
                      ],
                    ),
                  ),

                  _buildSectionHeader("3. Stanje i oprema", CupertinoIcons.checkmark_seal_fill),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildDropdown("Stanje sata", stanjeSata, stanja, (v) => setState(() => stanjeSata = v)),
                        CheckboxListTile(
                          title: const Text("Ima originalnu kutiju"),
                          value: imaKutiju,
                          onChanged: (v) => setState(() => imaKutiju = v!),
                          activeColor: Colors.blue,
                        ),
                        CheckboxListTile(
                          title: const Text("Ima originalne papire/garanciju"),
                          value: imaPapire,
                          onChanged: (v) => setState(() => imaPapire = v!),
                          activeColor: Colors.blue,
                        ),
                        CupertinoTextField(
                          controller: servisController, placeholder: "Istorija servisa (Opciono)",
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 12),
                        CupertinoTextField(
                          controller: ostecenjaController, placeholder: "Opis oštećenja (Opciono)", maxLines: 2,
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            onPressed: _izaberiSlike,
                            child: const Text("📸 Dodaj slike sata (Max 16)"),
                          ),
                        ),
                        if (izabraneSlike.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Wrap(
                              spacing: 8, runSpacing: 8,
                              children: izabraneSlike.map((s) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(s.path, width: 60, height: 60, fit: BoxFit.cover))).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  _buildSectionHeader("4. Cijena i lokacija", CupertinoIcons.money_euro_circle_fill),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CupertinoTextField(
                                controller: cenaController, placeholder: "Cijena *", keyboardType: TextInputType.number,
                                padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: _buildDropdown("Valuta", valuta, valute, (v) => setState(() => valuta = v!)),
                            ),
                          ],
                        ),
                        CheckboxListTile(
                          title: const Text("Moguća zamjena"),
                          value: zamena,
                          onChanged: (v) => setState(() => zamena = v!),
                          activeColor: Colors.blue,
                        ),
                        CupertinoTextField(
                          controller: lokacijaController, placeholder: "Lokacija (Grad/Država)",
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 12),
                        CupertinoTextField(
                          controller: opisController, placeholder: "Dodatni opis (Sve što nije pokriveno gore)", maxLines: 4,
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: CupertinoButton(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                      onPressed: _postaviOglas,
                      child: const Text("🚀 Objavi Oglas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}