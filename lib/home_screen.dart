import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kontroleri za pretragu i filtere
  String pretragaText = '';
  String? filterBrend;
  
  final minCenaController = TextEditingController();
  final maxCenaController = TextEditingController();
  final minGodinaController = TextEditingController();
  final maxGodinaController = TextEditingController();

  final List<String> popularniBrendovi = ['Svi', 'Rolex', 'Omega', 'Patek Philippe', 'Audemars Piguet', 'Seiko', 'Breitling', 'Tag Heuer', 'Tissot', 'Casio'];

  // Puni iOS Filteri
  void _otvoriFiltere() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text("Filteri", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // BRENDOVI
              const Text("BREND", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: popularniBrendovi.map((b) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(b),
                      selected: (filterBrend ?? 'Svi') == b,
                      onSelected: (selected) => setState(() => filterBrend = (b == 'Svi' ? null : b)),
                      selectedColor: const Color(0xFF89CFF0),
                    ),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 30),

              // CENA
              const Text("CENA (€)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CupertinoTextField(
                    controller: minCenaController,
                    placeholder: "Od",
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  )),
                  const SizedBox(width: 15),
                  Expanded(child: CupertinoTextField(
                    controller: maxCenaController,
                    placeholder: "Do",
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  )),
                ],
              ),

              const SizedBox(height: 30),

              // GODINA
              const Text("GODINA PROIZVODNJE", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CupertinoTextField(
                    controller: minGodinaController,
                    placeholder: "Od",
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  )),
                  const SizedBox(width: 15),
                  Expanded(child: CupertinoTextField(
                    controller: maxGodinaController,
                    placeholder: "Do",
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  )),
                ],
              ),

              const SizedBox(height: 40),

              // DUGME
              SizedBox(
                width: double.infinity,
                height: 55,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () {
                    setState(() {}); 
                    Navigator.pop(context);
                  },
                  child: const Text("Primeni filtere", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF89CFF0), // Baby Blue
        title: const Text("NadjiSat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // PRETRAGA BAR SA IKONICOM ZA FILTERE
          Container(
            color: const Color(0xFF89CFF0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    backgroundColor: Colors.white,
                    placeholder: "Pretraži npr. Submariner",
                    borderRadius: BorderRadius.circular(15),
                    onChanged: (v) => setState(() => pretragaText = v.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _otvoriFiltere,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(CupertinoIcons.slider_horizontal_3, color: Colors.black),
                  ),
                )
              ],
            ),
          ),

          // LISTA SATOVA (PUNI KARTICE)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nema dostupnih satova."));

                // LOGIKA FILTRIRANJA
                final satovi = snapshot.data!.where((sat) {
                  // Pretraga po tekstu (Naslov ili Brend)
                  final naslov = (sat['naslov'] ?? '').toString().toLowerCase();
                  final brend = (sat['brend'] ?? '').toString().toLowerCase();
                  final pretraga = pretragaText.toLowerCase();
                  if (pretraga.isNotEmpty && !naslov.contains(pretraga) && !brend.contains(pretraga)) return false;

                  // Brend filter
                  if (filterBrend != null && sat['brend'] != filterBrend) return false;

                  // Cena filter
                  final cena = int.tryParse(sat['cena'].toString()) ?? 0;
                  final minC = int.tryParse(minCenaController.text) ?? 0;
                  final maxC = int.tryParse(maxCenaController.text) ?? 9999999;
                  if (cena < minC || cena > maxC) return false;

                  // Godina filter
                  final god = int.tryParse(sat['godina'].toString()) ?? 0;
                  final minG = int.tryParse(minGodinaController.text) ?? 0;
                  final maxG = int.tryParse(maxGodinaController.text) ?? 2025;
                  if (god != 0 && (god < minG || god > maxG)) return false;

                  return true;
                }).toList();

                if (satovi.isEmpty) return const Center(child: Text("Nema satova za ove filtere.", style: TextStyle(color: Colors.grey)));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.72
                  ),
                  itemCount: satovi.length,
                  itemBuilder: (context, index) {
                    final sat = satovi[index];
                    final slikeStr = sat['slike']?.toString() ?? "";
                    final prvaSlika = slikeStr.isNotEmpty ? slikeStr.split(',')[0] : null;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15), // Bezbedna senka, bez crvenih linija
                            blurRadius: 10, 
                            offset: const Offset(0, 5)
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: Container(
                                color: Colors.grey[100],
                                width: double.infinity,
                                child: prvaSlika != null 
                                  ? Image.network(prvaSlika, fit: BoxFit.cover)
                                  : const Icon(Icons.watch, size: 50, color: Colors.grey), // Bezbedna ikonica
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sat['cena_dogovor'] == true ? "Po dogovoru" : "${sat['cena']} €",
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                                ),
                                const SizedBox(height: 4),
                                Text("${sat['brend']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent)),
                                Text("${sat['model']}", style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}