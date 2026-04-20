import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OglasDetaljiScreen extends StatefulWidget {
  final Map<String, dynamic> oglas;
  const OglasDetaljiScreen({super.key, required this.oglas});

  @override
  State<OglasDetaljiScreen> createState() => _OglasDetaljiScreenState();
}

class _OglasDetaljiScreenState extends State<OglasDetaljiScreen> {
  int _trenutnaSlika = 0;

  Widget _buildSpecRed(String naslov, String? vrednost, bool isDark) {
    if (vrednost == null || vrednost.isEmpty || vrednost == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(naslov, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(vrednost, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final oglas = widget.oglas;
    
    final slikeStr = oglas['slike']?.toString() ?? "";
    final List<String> slike = slikeStr.isNotEmpty ? slikeStr.split(',') : [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${oglas['brend']} ${oglas['model']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (slike.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      itemCount: slike.length,
                      onPageChanged: (index) => setState(() => _trenutnaSlika = index),
                      itemBuilder: (context, index) {
                        return Image.network(slike[index], fit: BoxFit.cover);
                      },
                    ),
                  ),
                  if (slike.length > 1)
                    Positioned(
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                        child: Text("${_trenutnaSlika + 1} / ${slike.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(oglas['naslov'] ?? "Sat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    oglas['cena_dogovor'] == true ? "Cijena po dogovoru" : "${oglas['cena']} ${oglas['valuta'] ?? '€'}", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blue)
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.location_solid, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(oglas['lokacija'] ?? "Lokacija nije navedena", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  const Text("Detalji", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                    child: Column(
                      children: [
                        _buildSpecRed("Brend", oglas['brend'], isDark),
                        _buildSpecRed("Model", oglas['model'], isDark),
                        _buildSpecRed("Ref. broj", oglas['ref_broj'], isDark),
                        _buildSpecRed("Godina", oglas['godina'], isDark),
                        const Divider(height: 20),
                        _buildSpecRed("Stanje", oglas['stanje'], isDark),
                        _buildSpecRed("Kutija", oglas['originalna_kutija'] == true ? "Da" : "Ne", isDark),
                        _buildSpecRed("Papiri", oglas['originalni_papiri'] == true ? "Da" : "Ne", isDark),
                        _buildSpecRed("Garancija", oglas['garancija'], isDark),
                        const Divider(height: 20),
                        _buildSpecRed("Mehanizam", oglas['mehanizam'], isDark),
                        _buildSpecRed("Prečnik", oglas['precnik'], isDark),
                        _buildSpecRed("Materijal", oglas['materijal'], isDark),
                        _buildSpecRed("Narukvica", oglas['materijal_narukvice'], isDark),
                        _buildSpecRed("Cifer", oglas['boja_brojcanika'], isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  if (oglas['opis'] != null && oglas['opis'].toString().isNotEmpty) ...[
                    const Text("Opis prodavca", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(oglas['opis'], style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[300] : Colors.grey[800], height: 1.5)),
                    const SizedBox(height: 25),
                  ],

                  if (oglas['zamena'] == true)
                    Container(
                      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Row(children: [Icon(CupertinoIcons.arrow_right_arrow_left, color: Colors.orange), SizedBox(width: 10), Text("Moguća zamjena", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]),
                    ),
                  if (oglas['servisna_istorija'] != null && oglas['servisna_istorija'].toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [const Icon(CupertinoIcons.wrench_fill, color: Colors.green), const SizedBox(width: 10), Expanded(child: Text("Servis: ${oglas['servisna_istorija']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CupertinoButton(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(15),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chat uskoro!")));
            },
            child: const Text("Kontaktiraj prodavca", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}