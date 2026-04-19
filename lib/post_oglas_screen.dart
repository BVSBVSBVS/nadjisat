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
  
  String? izabranBrend, izabranModel, stanje, godina, precnik, materijal, staklo, mehanizam, vodootpornost, kutijaPapiri;
  final cenaController = TextEditingController();
  final opisController = TextEditingController();
  bool cenaPoDogovoru = false;
  
  List<XFile> izabraneSlike = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

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
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 16 slika.")));
        }
      });
    }
  }

  Future<void> _postaviOglas() async {
    if (izabranBrend == null || izabranModel == null) {
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
        'slike': slikeUrls.join(','),
      });

      if (!mounted) return; // Fix za Async Gaps
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno postavljen!")));
      Navigator.pop(context); 
      
    } catch (e) {
      if (!mounted) return; // Fix za Async Gaps
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  void _prikaziIOSPicker(String naslov, List<String> opcije, Function(String) onOdabrano) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(child: const Text('Otkaži'), onPressed: () => Navigator.of(context).pop()),
                  Text(naslov, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  CupertinoButton(child: const Text('Gotovo'), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
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
        title: const Text("Novi oglas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
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
                        activeColor: CupertinoColors.activeBlue, // Fix za deprecated activeColor
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
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(10),
                onPressed: _postaviOglas,
                child: const Text("Objavi Oglas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}