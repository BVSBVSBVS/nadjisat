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
  String? namena, mehanizam, precnik, lugToLug, materijalKucista, materijalNarukvice, bojaBrojcanika;

  // --- 3. STANJE I OPREMA ---
  String? stanjeSata, garancija;
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

  // --- BAZE PODATAKA ---
  final Map<String, List<String>> brendoviIModeli = {
    'Svi': [],
    'A. Lange & Söhne': ['1815', 'Datograph', 'Grand Lange 1', 'Lange 1', 'Saxonia', 'Zeitwerk', 'Richard Lange'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore', 'Code 11.59', 'Jules Audemars', 'Millenary'],
    'Ball Watch': ['Engineer Hydrocarbon', 'Engineer II', 'Engineer III', 'Trainmaster', 'Fireman', 'Roadmaster'],
    'Baume & Mercier': ['Clifton', 'Classima', 'Riviera', 'Hampton', 'Capeland', 'Baumatic'],
    'Blancpain': ['Fifty Fathoms', 'Villeret', 'Bathyscaphe', 'Air Command', 'Léman'],
    'Breguet': ['Classique', 'Marine', 'Type XX', 'Reine de Naples', 'Tradition', 'Heritage'],
    'Breitling': ['Navitimer', 'Chronomat', 'Superocean', 'Avenger', 'Premier', 'Top Time', 'Endurance Pro'],
    'Bulgari': ['Octo Finissimo', 'Octo Roma', 'Serpenti', 'B.zero1', 'Aluminium'],
    'Carl F. Bucherer': ['Manero', 'Patravi', 'Heritage', 'Adamavi', 'ScubaTec'],
    'Cartier': ['Tank', 'Santos', 'Ballon Bleu', 'Pasha', 'Drive de Cartier', 'Panthère'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Baby-G', 'Vintage', 'Oceanus', 'Databank'],
    'Chopard': ['Alpine Eagle', 'L.U.C', 'Mille Miglia', 'Happy Sport', 'Happy Diamonds'],
    'Citizen': ['Promaster', 'Eco-Drive One', 'The Citizen', 'Attesa', 'Series 8', 'Satellite Wave'],
    'Corum': ['Admiral', 'Golden Bridge', 'Bubble', 'Heritage', 'Ti-Bridge'],
    'Czapek': ['Antarctique', 'Quai des Bergues', 'Faubourg de Cracovie', 'Place Vendôme'],
    'Damasko': ['DS30', 'DC56', 'DC57', 'DC66', 'DA36', 'DK10', 'DSub1'],
    'Doxa': ['Sub 200', 'Sub 300', 'Sub 300T', 'Sub 600T', 'Sub 1500T', 'Army'],
    'Eberhard & Co.': ['Chrono 4', 'Tazio Nuvolari', 'Traversetolo', 'Scafograf', '8 Jours'],
    'Eterna': ['KonTiki', 'Heritage', 'Royal Kontiki', 'Eternity', 'Adventic'],
    'F.P. Journe': ['Chronomètre Bleu', 'Chronomètre Souverain', 'Octa Automatique', 'Tourbillon Souverain'],
    'Farer': ['Lander', 'Worldtimer', 'GMT', 'Chronograph', 'Aqua Compressor', 'Field'],
    'Fortis': ['Flieger', 'Marinemaster', 'Cosmonaut', 'Aeromaster', 'Stratoliner'],
    'Franck Muller': ['Vanguard', 'Cintrée Curvex', 'Casablanca', 'Master Square', 'Long Island'],
    'Girard-Perregaux': ['Laureato', 'Bridges', 'Vintage 1945', '1966', 'Free Bridge'],
    'Glashütte Original': ['PanomaticLunar', 'Senator', 'SeaQ', 'Sixties', 'Seventies'],
    'Grand Seiko': ['Heritage', 'Elegance', 'Sport', 'Evolution 9', 'Masterpiece'],
    'Hamilton': ['Khaki Field', 'Khaki Aviation', 'Khaki Navy', 'Ventura', 'Jazzmaster', 'American Classic'],
    'Hanhart': ['417 ES', 'Pioneer', 'Primus', 'Stopwatches'],
    'Hublot': ['Big Bang', 'Classic Fusion', 'Spirit of Big Bang', 'MP Collection', 'King Power'],
    'IWC Schaffhausen': ['Portugieser', 'Big Pilot', 'Pilot\'s Watch', 'Ingenieur', 'Portofino', 'Da Vinci'],
    'Jaeger-LeCoultre': ['Reverso', 'Master Control', 'Polaris', 'Atmos', 'Rendez-Vous', 'Geophysic'],
    'Junghans': ['Max Bill', 'Meister', 'Form', 'Spektrum'],
    'Laco': ['Flieger', 'Navy', 'Squad', 'Classic', 'Chronograph'],
    'Longines': ['HydroConquest', 'Spirit', 'Master Collection', 'Heritage', 'Conquest', 'DolceVita', 'Legend Diver'],
    'Louis Moinet': ['Tourbillon', 'Chronograph', 'Moon Race', 'Space Walker'],
    'Maurice Lacroix': ['Aikon', 'Masterpiece', 'Pontos', 'Eliros'],
    'MB&F': ['Horological Machine', 'Legacy Machine', 'Performance Art'],
    'Montblanc': ['Heritage', 'Star Legacy', '1858', 'Summit', 'TimeWalker'],
    'Mido': ['Multifort', 'Ocean Star', 'Baroncelli', 'Commander'],
    'Nomos Glashütte': ['Tangente', 'Club', 'Orion', 'Ludwig', 'Metro', 'Ahoi'],
    'Omega': ['Speedmaster', 'Seamaster', 'Constellation', 'De Ville', 'Aqua Terra'],
    'Oris': ['Aquis', 'Big Crown', 'Divers Sixty-Five', 'Artelier', 'ProPilot'],
    'Panerai': ['Luminor', 'Radiomir', 'Submersible', 'Due'],
    'Parmigiani Fleurier': ['Tonda', 'Kalpa', 'Toric', 'Bugatti'],
    'Patek Philippe': ['Nautilus', 'Calatrava', 'Aquanaut', 'Grand Complications', 'Annual Calendar'],
    'Piaget': ['Altiplano', 'Polo', 'Possession', 'Limelight'],
    'Rado': ['Captain Cook', 'Ceramica', 'DiaStar', 'True Thinline', 'Centrix'],
    'Raymond Weil': ['Freelancer', 'Maestro', 'Toccata', 'Tango'],
    'Richard Mille': ['RM 011', 'RM 027', 'RM 035', 'RM 055', 'RM 067'],
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Explorer', 'Day-Date', 'Sea-Dweller'],
    'Roger Dubuis': ['Excalibur', 'Velvet', 'Knights of the Round Table'],
    'Seiko': ['Prospex', 'Presage', 'Astron', '5 Sports', 'King Seiko', 'Premier'],
    'Sinn': ['U1', '104', '556', '903', '356', 'EZM'],
    'TAG Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia', 'Connected'],
    'Tissot': ['PRX', 'Seastar', 'Le Locle', 'Gentleman', 'T-Touch', 'Chemin des Tourelles'],
    'Tudor': ['Black Bay', 'Pelagos', 'Ranger', 'Royal', '1926'],
    'Ulysse Nardin': ['Freak', 'Marine', 'Diver', 'Blast', 'Executive'],
    'Vacheron Constantin': ['Overseas', 'Patrimony', 'Traditionnelle', 'Fiftysix', 'Historiques'],
    'Zenith': ['Chronomaster', 'Defy', 'Elite', 'Pilot'],
    'Zodiac': ['Sea Wolf', 'Super Sea Wolf', 'Grandrally', 'Olympos'],
  };

  final List<String> godine = List.generate(127, (index) => (2026 - index).toString());
  final List<String> precnici = List.generate(41, (index) => "${20 + index}mm");
  final List<String> lugToLugLista = List.generate(41, (index) => "${30 + index}mm");
  
  final List<String> namene = ['Dres (Dress)', 'Ronilački (Diver)', 'Hronograf (Chronograph)', 'Pilot (Aviator)', 'Sportski/GADA', 'Luksuzni', 'Smartwatch'];
  final List<String> mehanizmi = ['Automatik', 'Manuelni', 'Kvarcni', 'Spring Drive', 'Solar', 'Kinetic'];
  final List<String> materijali = ['Čelik', 'Zlato (18k)', 'Titanijum', 'Platina', 'Keramika', 'Bronza', 'Guma/Plastika'];
  final List<String> materijaliNarukvice = ['Čelik', 'Koža', 'Guma', 'Tekstil/Nato', 'Titanijum', 'Zlato'];
  final List<String> bojeBrojcanika = ['Crna', 'Plava', 'Bela/Srebrna', 'Zelena', 'Siva', 'Zlatna', 'Druga'];
  final List<String> stanja = ['1. Novo sa folijama', '2. Kao novo', '3. Odlično', '4. Dobro', '5. Vidljivi tragovi korišćenja'];
  final List<String> opcijeGarancije = ['Nema garanciju', 'Radna garancija', '1 godina', '2+ godine', 'Važeća fabrička'];
  final List<String> valute = ['EUR', 'RSD', 'KM'];

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        izabraneSlike.addAll(slike);
        if (izabraneSlike.length > 6) {
          izabraneSlike = izabraneSlike.sublist(0, 6);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Možete dodati maksimalno 6 slika.")));
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
        'lug_to_lug': lugToLug,
        'materijal': materijalKucista,
        'materijal_narukvice': materijalNarukvice,
        'boja_brojcanika': bojaBrojcanika,
        'stanje': stanjeSata,
        'garancija': garancija,
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

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno postavljen!")));
      Navigator.pop(context); 

    } catch (e) {
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
                        _buildDropdown("Brend *", izabranBrend, brendoviIModeli.keys.where((b) => b != 'Svi').toList(), (v) => setState(() { izabranBrend = v; izabranModel = null; })),
                        if (izabranBrend != null) 
                          _buildDropdown("Model *", izabranModel, brendoviIModeli[izabranBrend]!, (v) => setState(() => izabranModel = v)),
                        CupertinoTextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
                        _buildDropdown("Kategorija / Namena", namena, namene, (v) => setState(() => namena = v)),
                        _buildDropdown("Mehanizam", mehanizam, mehanizmi, (v) => setState(() => mehanizam = v)),
                        Row(
                          children: [
                            Expanded(child: _buildDropdown("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
                            const SizedBox(width: 10),
                            Expanded(child: _buildDropdown("Lug-to-Lug", lugToLug, lugToLugLista, (v) => setState(() => lugToLug = v))),
                          ],
                        ),
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
                        _buildDropdown("Garancija", garancija, opcijeGarancije, (v) => setState(() => garancija = v)),
                        CheckboxListTile(
                          title: Text("Ima originalnu kutiju", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          value: imaKutiju,
                          onChanged: (v) => setState(() => imaKutiju = v!),
                          activeColor: Colors.blue,
                        ),
                        CheckboxListTile(
                          title: Text("Ima originalne papire", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          value: imaPapire,
                          onChanged: (v) => setState(() => imaPapire = v!),
                          activeColor: Colors.blue,
                        ),
                        CupertinoTextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          controller: servisController, placeholder: "Istorija servisa (Opciono)",
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 12),
                        CupertinoTextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          controller: ostecenjaController, placeholder: "Opis oštećenja (Opciono)", maxLines: 2,
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            onPressed: _izaberiSlike,
                            child: const Text("📸 Dodaj slike sata (Max 6)"),
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

                  _buildSectionHeader("4. Cena i lokacija", CupertinoIcons.money_euro_circle_fill),
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
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                controller: cenaController, placeholder: "Cena *", keyboardType: TextInputType.number,
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
                          title: Text("Moguća zamena", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          value: zamena,
                          onChanged: (v) => setState(() => zamena = v!),
                          activeColor: Colors.blue,
                        ),
                        CupertinoTextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          controller: lokacijaController, placeholder: "Lokacija (Grad/Država)",
                          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(height: 12),
                        CupertinoTextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
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