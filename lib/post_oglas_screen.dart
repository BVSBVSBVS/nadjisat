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
  
  String? izabranBrend, izabranModel, stanje, godina, precnik, materijal, staklo;
  final cenaController = TextEditingController();
  final opisController = TextEditingController();
  
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
  final List<String> godine = List.generate(75, (index) => (2024 - index).toString());
  final List<String> precnici = List.generate(28, (index) => "${28 + index} mm");

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        izabraneSlike.addAll(slike);
        if (izabraneSlike.length > 16) {
          izabraneSlike = izabraneSlike.sublist(0, 16);
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 16 slika.")));
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
        'naslov': '$izabranBrend $izabranModel', // Rešava onu grešku u bazi
        'brend': izabranBrend,
        'model': izabranModel,
        'cena': int.tryParse(cenaController.text.trim()) ?? 0,
        'godina': godina,
        'precnik': precnik,
        'stanje': stanje,
        'materijal': materijal,
        'staklo': staklo,
        'opis': opisController.text.trim(),
        'slike': slikeUrls.join(','),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas postavljen!")));
      
      // Vraća nas na prvi tab (Pretraga) ako je ovo deo MainLayout-a
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      if(!mounted) return;
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      appBar: AppBar(title: const Text("Postavi oglas")),
      body: isUploading 
          ? const Center(child: CircularProgressIndicator()) 
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ElevatedButton.icon(
                    onPressed: _izaberiSlike,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Dodaj slike"),
                  ),
                  if (izabraneSlike.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Wrap(
                        spacing: 8,
                        children: izabraneSlike.map((s) => Text(s.name, style: const TextStyle(fontSize: 10))).toList(),
                      ),
                    ),
                  _buildDropdown("Brend", izabranBrend, brendoviIModeli.keys.toList(), (v) => setState(() { izabranBrend = v; izabranModel = null; })),
                  if (izabranBrend != null) 
                    _buildDropdown("Model", izabranModel, brendoviIModeli[izabranBrend]!, (v) => setState(() => izabranModel = v)),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: cenaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Cena (€)", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Unesi cenu' : null,
                    ),
                  ),

                  _buildDropdown("Stanje", stanje, stanja, (v) => setState(() => stanje = v)),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown("Godina", godina, godine, (v) => setState(() => godina = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdown("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
                    ],
                  ),
                  _buildDropdown("Materijal", materijal, materijali, (v) => setState(() => materijal = v)),
                  _buildDropdown("Staklo", staklo, stakla, (v) => setState(() => staklo = v)),
                  
                  TextFormField(
                    controller: opisController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Opis", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: _postaviOglas,
                    child: const Text("Objavi Oglas"),
                  )
                ],
              ),
            ),
    );
  }
}