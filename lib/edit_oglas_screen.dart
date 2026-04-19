import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditOglasScreen extends StatefulWidget {
  final Map<String, dynamic> oglas; // Prima podatke o oglasu
  const EditOglasScreen({super.key, required this.oglas});

  @override
  State<EditOglasScreen> createState() => _EditOglasScreenState();
}

class _EditOglasScreenState extends State<EditOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? izabranBrend, izabranModel, stanje, godina, precnik, materijal, staklo, mehanizam, vodootpornost, kutijaPapiri;
  final cenaController = TextEditingController();
  final opisController = TextEditingController();
  bool cenaPoDogovoru = false;
  
  List<XFile> noveSlike = [];
  String stareSlikeUrl = "";
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // ONA PROŠIRENA BAZA DA BI MOGAO DA MENJAŠ U BILO ŠTA
  final Map<String, List<String>> brendoviIModeli = {
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Oyster Perpetual', 'Sea-Dweller', 'Yacht-Master', 'Sky-Dweller', 'Explorer', 'Milgauss'],
    'Omega': ['Speedmaster', 'Seamaster', 'Aqua Terra', 'Planet Ocean', 'De Ville', 'Constellation', 'Railmaster'],
    'Patek Philippe': ['Nautilus', 'Aquanaut', 'Calatrava', 'Complications', 'Grand Complications', 'Gondolo', 'Ellipse'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore', 'Code 11.59', 'Millenary', 'Jules Audemars'],
    'Vacheron Constantin': ['Overseas', 'Patrimony', 'Traditionnelle', 'Fiftysix', 'Historiques'],
    'Richard Mille': ['RM 011', 'RM 035', 'RM 055', 'RM 067', 'RM 11-03'],
    'Cartier': ['Santos', 'Tank', 'Ballon Bleu', 'Pasha', 'Panthere', 'Drive de Cartier'],
    'IWC': ['Portugieser', 'Pilot', 'Portofino', 'Aquatimer', 'Ingenieur', 'Da Vinci'],
    'Breitling': ['Navitimer', 'Superocean', 'Chronomat', 'Avenger', 'Endurance Pro', 'Premier'],
    'Tudor': ['Black Bay', 'Pelagos', 'Ranger', '1926', 'Royal'],
    'Panerai': ['Luminor', 'Radiomir', 'Submersible', 'Luminor Due'],
    'Hublot': ['Big Bang', 'Classic Fusion', 'Spirit of Big Bang'],
    'Zenith': ['Defy', 'Chronomaster', 'Elite', 'Pilot'],
    'TAG Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia'],
    'Seiko': ['Prospex', 'Presage', '5 Sports', 'Astron', 'King Seiko'],
    'Grand Seiko': ['Heritage', 'Elegance', 'Sport', 'Evolution 9'],
    'Tissot': ['PRX', 'Seastar', 'Le Locle', 'Gentleman', 'Supersport'],
    'Longines': ['HydroConquest', 'Master Collection', 'Spirit', 'Heritage', 'DolceVita'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Vintage'],
  };

  final List<String> stanja = ['Novo (Nenošeno)', 'Odlično', 'Vrlo dobro', 'Dobro', 'Za delove'];
  final List<String> materijali = ['Čelik', 'Zlato', 'Titanijum', 'Keramika', 'Platina', 'Karbon'];
  final List<String> stakla = ['Safirno', 'Mineralno', 'Akrilno (Plexi)'];
  final List<String> mehanizmi = ['Automatik', 'Kvarcni', 'Ručno navijanje', 'Spring Drive'];
  final List<String> vodootpornosti = ['Nije vodootporan', '30m (3 ATM)', '50m (5 ATM)', '100m (10 ATM)', '200m+ (Diver)'];
  final List<String> opcijeKutija = ['Full Set (Kutija i papiri)', 'Samo kutija', 'Samo papiri', 'Samo sat'];
  final List<String> godine = List.generate(75, (index) => (2024 - index).toString());
  final List<String> precnici = List.generate(33, (index) => "${28 + index} mm");

  @override
  void initState() {
    super.initState();
    // POPUNJAVANJE PODATAKA IZ BAZE KAD SE EKRAN OTVORI
    final oglas = widget.oglas;
    
    // Provere da li brend postoji u listi (da ne puca drop down)
    if (brendoviIModeli.containsKey(oglas['brend'])) {
      izabranBrend = oglas['brend'];
      if (brendoviIModeli[izabranBrend]!.contains(oglas['model'])) {
        izabranModel = oglas['model'];
      }
    }
    
    cenaPoDogovoru = oglas['cena_dogovor'] ?? false;
    if (!cenaPoDogovoru && oglas['cena'] != null) cenaController.text = oglas['cena'].toString();
    
    if (stanja.contains(oglas['stanje'])) stanje = oglas['stanje'];
    if (godine.contains(oglas['godina']?.toString())) godina = oglas['godina']?.toString();
    if (precnici.contains(oglas['precnik'])) precnik = oglas['precnik'];
    if (materijali.contains(oglas['materijal'])) materijal = oglas['materijal'];
    if (stakla.contains(oglas['staklo'])) staklo = oglas['staklo'];
    if (mehanizmi.contains(oglas['mehanizam'])) mehanizam = oglas['mehanizam'];
    if (vodootpornosti.contains(oglas['vodootpornost'])) vodootpornost = oglas['vodootpornost'];
    if (opcijeKutija.contains(oglas['kutija_papiri'])) kutijaPapiri = oglas['kutija_papiri'];
    
    opisController.text = oglas['opis'] ?? '';
    stareSlikeUrl = oglas['slike'] ?? '';
  }

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        noveSlike = slike; // Zamenjujemo stare slike novim
        if (noveSlike.length > 16) {
          noveSlike = noveSlike.sublist(0, 16);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 16 slika.")));
        }
      });
    }
  }

  Future<void> _azurirajOglas() async {
    if (izabranBrend == null || izabranModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni obavezna polja!")));
      return;
    }

    setState(() => isUploading = true);

    try {
      String konacneSlike = stareSlikeUrl;

      // Ako je dodao nove slike, uploaduj ih i pregazi stare
      if (noveSlike.isNotEmpty) {
        List<String> slikeUrls = [];
        for (var slika in noveSlike) {
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
        konacneSlike = slikeUrls.join(',');
      }

      // KOMANDA UPDATE UMESTO INSERT
      await Supabase.instance.client.from('satovi').update({
        'naslov': '$izabranBrend $izabranModel',
        'brend': izabranBrend,
        'model': izabranModel,
        'cena': cenaPoDogovoru ? null : (int.tryParse(cenaController.text.trim()) ?? 0), 
        'cena_dogovor': cenaPoDogovoru,
        'godina': godina,
        'precnik': precnik,
        'stanje': stanje,
        'materijal': materijal,
        'staklo': staklo,
        'mehanizam': mehanizam,
        'vodootpornost': vodootpornost,
        'kutija_papiri': kutijaPapiri,
        'opis': opisController.text.trim(),
        'slike': konacneSlike,
      }).eq('id', widget.oglas['id']); // <- KLJUČNO: Nalazi tačan oglas

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno izmenjen!")));
      Navigator.pop(context); 
      
    } catch (e) {
      if (!mounted) return;
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  void _prikaziIOSPicker(String naslov, List<String> opcije, Function(String) onOdabrano) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(child: const Text('Gotovo'), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                // Pronadji trenutni index da bi točkić počeo od njega
                scrollController: FixedExtentScrollController(initialItem: 0),
                onSelectedItemChanged: (index) => onOdabrano(opcije[index]),
                children: opcije.map((o) => Center(child: Text(o, style: const TextStyle(fontSize: 18)))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iosPoljeZaBiranje(String label, String? trenutnaVrednost, List<String> opcije, Function(String) onOdabrano) {
    return GestureDetector(
      onTap: opcije.isEmpty ? null : () => _prikaziIOSPicker(label, opcije, onOdabrano),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(trenutnaVrednost ?? label, style: TextStyle(fontSize: 16, color: trenutnaVrednost == null ? Colors.grey : Colors.black)),
            const Icon(CupertinoIcons.chevron_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), 
      appBar: AppBar(
        title: const Text("Izmeni oglas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isUploading ? const Center(child: CupertinoActivityIndicator(radius: 20)) : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _izaberiSlike,
              child: Container(
                height: 120,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera, size: 40, color: Colors.blue),
                    SizedBox(height: 8),
                    Text("Zameni slike (ili ostavi prazno da zadržiš stare)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12), textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _iosPoljeZaBiranje("Brend", izabranBrend, brendoviIModeli.keys.toList(), (v) => setState(() { izabranBrend = v; izabranModel = null; })),
                  _iosPoljeZaBiranje("Model", izabranModel, izabranBrend != null ? brendoviIModeli[izabranBrend]! : [], (v) => setState(() => izabranModel = v)),
                  
                  Row(
                    children: [
                      const Text("Kontakt / Po dogovoru", style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      CupertinoSwitch(
                        value: cenaPoDogovoru,
                        activeTrackColor: Colors.blue, 
                        onChanged: (v) => setState(() { cenaPoDogovoru = v; if(v) cenaController.clear(); }),
                      ),
                    ],
                  ),
                  if (!cenaPoDogovoru)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: CupertinoTextField(
                        controller: cenaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false), 
                        placeholder: "Cena (€)",
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _iosPoljeZaBiranje("Stanje", stanje, stanja, (v) => setState(() => stanje = v)),
                  Row(
                    children: [
                      Expanded(child: _iosPoljeZaBiranje("Godina", godina, godine, (v) => setState(() => godina = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _iosPoljeZaBiranje("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
                    ],
                  ),
                  _iosPoljeZaBiranje("Materijal", materijal, materijali, (v) => setState(() => materijal = v)),
                  _iosPoljeZaBiranje("Staklo", staklo, stakla, (v) => setState(() => staklo = v)),
                  _iosPoljeZaBiranje("Mehanizam", mehanizam, mehanizmi, (v) => setState(() => mehanizam = v)),
                  _iosPoljeZaBiranje("Vodootpornost", vodootpornost, vodootpornosti, (v) => setState(() => vodootpornost = v)),
                  _iosPoljeZaBiranje("Kutija i Papiri", kutijaPapiri, opcijeKutija, (v) => setState(() => kutijaPapiri = v)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: opisController,
              maxLines: 4,
              placeholder: "Opis",
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CupertinoButton(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
                onPressed: _azurirajOglas,
                child: const Text("Sačuvaj izmene", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}