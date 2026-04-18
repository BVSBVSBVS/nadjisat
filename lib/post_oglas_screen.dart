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
  
  // Sve promenljive
  String? izabranBrend, izabranModel, stanje, godina, precnik, materijal, staklo, mehanizam, vodootpornost, kutijaPapiri;
  final cenaController = TextEditingController();
  final opisController = TextEditingController();
  bool cenaPoDogovoru = false;
  
  List<XFile> izabraneSlike = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // Liste
  final Map<String, List<String>> brendoviIModeli = {
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Oyster Perpetual'],
    'Omega': ['Speedmaster', 'Seamaster', 'Aqua Terra'],
    'Patek Philippe': ['Nautilus', 'Aquanaut', 'Calatrava'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore'],
    'Seiko': ['Prospex', 'Presage', '5 Sports'],
  };
  final List<String> stanja = ['Novo (Nenošeno)', 'Odlično', 'Vrlo dobro', 'Dobro', 'Za delove'];
  final List<String> materijali = ['Čelik', 'Zlato', 'Titanijum', 'Keramika', 'Platina', 'Karbon'];
  final List<String> stakla = ['Safirno', 'Mineralno', 'Akrilno (Plexi)'];
  final List<String> mehanizmi = ['Automatik', 'Kvarcni', 'Ručno navijanje', 'Spring Drive'];
  final List<String> vodootpornosti = ['Nije vodootporan', '30m (3 ATM)', '50m (5 ATM)', '100m (10 ATM)', '200m+ (Diver)'];
  final List<String> opcijeKutija = ['Full Set (Kutija i papiri)', 'Samo kutija', 'Samo papiri', 'Samo sat'];
  final List<String> godine = List.generate(75, (index) => (2024 - index).toString());
  final List<String> precnici = List.generate(33, (index) => "${28 + index} mm");

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        izabraneSlike.addAll(slike);
        if (izabraneSlike.length > 16) {
          izabraneSlike = izabraneSlike.sublist(0, 16);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 16 slika.")));
        }
      });
    }
  }

  Future<void> _postaviOglas() async {
    if (!_formKey.currentState!.validate() || izabranBrend == null || izabranModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni obavezna polja!")));
      return;
    }
    if (izabraneSlike.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Moraš dodati sliku.")));
      return;
    }

    setState(() => isUploading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      List<String> slikeUrls = [];
      for (var slika in izabraneSlike) {
        final bytes = await slika.readAsBytes();
        final imeFajla = '${DateTime.now().millisecondsSinceEpoch}_${slika.name}';
        
        // PAZI OVDE: Promenjeno u 'slike-oglasi' (tvoj naziv)
        await Supabase.instance.client.storage.from('slike-oglasi').uploadBinary(imeFajla, bytes);
        final url = Supabase.instance.client.storage.from('slike-oglasi').getPublicUrl(imeFajla);
        slikeUrls.add(url);
      }

      await Supabase.instance.client.from('satovi').insert({
        'user_id': user?.id, 
        'user_email': user?.email,
        'brend': izabranBrend,
        'model': izabranModel,
        'cena': cenaPoDogovoru ? null : (int.tryParse(cenaController.text.trim()) ?? 0), 
        'cena_dogovor': cenaPoDogovoru,
        'godina': godina,
        'precnik': precnik,
        'stanje': stanje,
        'materijal': materijal,
        'staklo': staklo,
        // Ove tri kolone moraš dodati u bazu (vidi dole)
        'mehanizam': mehanizam,
        'vodootpornost': vodootpornost,
        'kutija_papiri': kutijaPapiri,
        'opis': opisController.text.trim(),
        'slike': slikeUrls.join(','),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas postavljen!")));
        Navigator.pop(context); 
      }
    } catch (e) {
      setState(() => isUploading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Widget _buildIOSDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), 
      appBar: AppBar(
        title: const Text("Novi oglas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: isUploading ? const Center(child: CupertinoActivityIndicator(radius: 20)) : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SLIKE
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
                    Text("Dodaj slike (do 16)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ),
            if (izabraneSlike.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: izabraneSlike.map((s) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(s.path, width: 60, height: 60, fit: BoxFit.cover))).toList(),
                ),
              ),
            const SizedBox(height: 20),
            
            // OSNOVNO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildIOSDropdown("Brend", izabranBrend, brendoviIModeli.keys.toList(), (v) => setState(() { izabranBrend = v; izabranModel = null; })),
                  if (izabranBrend != null) _buildIOSDropdown("Model", izabranModel, brendoviIModeli[izabranBrend]!, (v) => setState(() => izabranModel = v)),
                  
                  Row(
                    children: [
                      const Text("Kontakt / Po dogovoru", style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      CupertinoSwitch(
                        value: cenaPoDogovoru,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() { cenaPoDogovoru = v; if(v) cenaController.clear(); }),
                      ),
                    ],
                  ),
                  if (!cenaPoDogovoru)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        controller: cenaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Cena (€)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        validator: (v) => !cenaPoDogovoru && v!.isEmpty ? 'Unesi cenu' : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // SPECIFIKACIJE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildIOSDropdown("Stanje", stanje, stanja, (v) => setState(() => stanje = v)),
                  Row(
                    children: [
                      Expanded(child: _buildIOSDropdown("Godina", godina, godine, (v) => setState(() => godina = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildIOSDropdown("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
                    ],
                  ),
                  _buildIOSDropdown("Materijal", materijal, materijali, (v) => setState(() => materijal = v)),
                  _buildIOSDropdown("Staklo", staklo, stakla, (v) => setState(() => staklo = v)),
                  _buildIOSDropdown("Mehanizam", mehanizam, mehanizmi, (v) => setState(() => mehanizam = v)),
                  _buildIOSDropdown("Vodootpornost", vodootpornost, vodootpornosti, (v) => setState(() => vodootpornost = v)),
                  _buildIOSDropdown("Kutija i Papiri", kutijaPapiri, opcijeKutija, (v) => setState(() => kutijaPapiri = v)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // OPIS
            TextFormField(
              controller: opisController,
              maxLines: 4,
              decoration: InputDecoration(labelText: "Opis", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _postaviOglas,
                child: const Text("Objavi Oglas", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}