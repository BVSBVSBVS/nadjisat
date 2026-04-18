import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PostOglasScreen extends StatefulWidget {
  const PostOglasScreen({super.key});
  @override
  State<PostOglasScreen> createState() => _PostOglasScreenState();
}

class _PostOglasScreenState extends State<PostOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? izabranBrend, izabranModel, stanje, godina;
  final cenaController = TextEditingController();
  final opisController = TextEditingController(); // OBAVEZAN OPIS
  
  // SLIKE
  List<XFile> izabraneSlike = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false; // Da vrtimo loading dok se dižu slike

  final Map<String, List<String>> brendoviIModeli = {
    'Rolex': ['Submariner', 'Daytona', 'Datejust'],
    'Omega': ['Speedmaster', 'Seamaster'],
  };

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        izabraneSlike.addAll(slike);
        if (izabraneSlike.length > 16) {
          izabraneSlike = izabraneSlike.sublist(0, 16);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Maksimalno 16 slika!")));
        }
      });
    }
  }

  Future<void> _postaviOglas() async {
    if (!_formKey.currentState!.validate() || izabranBrend == null || izabranModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni sva obavezna polja!")));
      return;
    }
    if (izabraneSlike.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Moraš dodati barem 1 sliku!")));
      return;
    }

    setState(() => isUploading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      // 1. UPLOAD SLIKA U STORAGE
      List<String> slikeUrls = [];
      for (var slika in izabraneSlike) {
        final bytes = await slika.readAsBytes();
        final ext = slika.name.split('.').last;
        final imeFajla = '${DateTime.now().millisecondsSinceEpoch}_${slika.name}';
        
        // Šaljemo bajtove u Supabase
        await Supabase.instance.client.storage.from('slike_oglasi').uploadBinary(imeFajla, bytes);
        // Dobijamo javni link slike
        final url = Supabase.instance.client.storage.from('slike_oglasi').getPublicUrl(imeFajla);
        slikeUrls.add(url);
      }

      // 2. ČUVANJE OGLASA U BAZI SA LINKOVIMA SLIKA
      final slikeString = slikeUrls.join(','); // Spajamo URL-ove zarezom

      await Supabase.instance.client.from('satovi').insert({
        'user_email': user?.email,
        'brend': izabranBrend,
        'model': izabranModel,
        'cena': int.tryParse(cenaController.text.trim()) ?? 0,
        'godina': godina,
        'stanje': stanje,
        'opis': opisController.text.trim(),
        'slike': slikeString, // <--- OVO SMO DODALI U BAZU!
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas i slike uspešno postavljeni!")));
        setState(() { izabraneSlike.clear(); opisController.clear(); cenaController.clear(); isUploading = false; });
      }
    } catch (e) {
      setState(() => isUploading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Da sprečimo gosta da kuca oglas
    if (Supabase.instance.client.auth.currentUser == null) {
      return const Scaffold(body: Center(child: Text("Samo ulogovani korisnici mogu da postave oglas.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Postavi Oglas"), backgroundColor: const Color(0xFF89CFF0)), // Baby blue
      body: isUploading 
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Otpremanje slika i oglasa...")]))
        : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // DUGME ZA SLIKE
            InkWell(
              onTap: _izaberiSlike,
              child: Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue, width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(15)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                    Text("Dodaj do 16 slika", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // PRIKAZ IZABRANIH SLIKA (Mali kvadratići)
            if (izabraneSlike.isNotEmpty)
              Wrap(
                spacing: 8, runSpacing: 8,
                children: izabraneSlike.map((slika) => Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(slika.path, fit: BoxFit.cover),
                  ),
                )).toList(),
              ),
            
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Brend"),
              items: brendoviIModeli.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() { izabranBrend = v; izabranModel = null; }),
            ),
            if (izabranBrend != null)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Model"),
                items: brendoviIModeli[izabranBrend]!.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => izabranModel = v),
              ),
            TextFormField(
              controller: cenaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cena (€)"),
              validator: (v) => v!.isEmpty ? 'Unesi cenu' : null,
            ),
            
            // OBAVEZAN OPIS
            const SizedBox(height: 15),
            TextFormField(
              controller: opisController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Opis oglasa", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Opis je obavezan' : null,
            ),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18)),
              onPressed: _postaviOglas,
              child: const Text("OBJAVI OGLAS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}