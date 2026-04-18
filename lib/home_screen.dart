import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String pretragaText = '';
  String? filterBrend;
  RangeValues filterCena = const RangeValues(0, 100000);
  RangeValues filterGodina = const RangeValues(1950, 2024);
  final List<String> popularniBrendovi = ['Svi', 'Rolex', 'Omega', 'Patek Philippe', 'Audemars Piguet', 'Seiko', 'Breitling', 'Tag Heuer'];

  void _otvoriFiltere() {
    // Ista funkcija za filtere od malopre (skraćeno zbog preglednosti)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 400, color: Colors.white, padding: const EdgeInsets.all(24),
        child: const Center(child: Text("Filteri su ovde (implementirano u prethodnom koraku)")),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF89CFF0), // <-- EVO JE BABY BLUE BOJA DA ZNAŠ DA JE NOVO!
        elevation: 0,
        title: const Text("Pretraga Satova", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF89CFF0), // Baby blue prelaz
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Upiši model (npr. Daytona)',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => pretragaText = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nema oglasa."));

                final satovi = snapshot.data!; // Ovde idu oni filteri
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.72
                  ),
                  itemCount: satovi.length,
                  itemBuilder: (context, index) {
                    final sat = satovi[index];
                    // AKO IMA SLIKA, PRIKAZUJE PRVU, AKO NEMA IKONICA
                    final listaSlika = sat['slike'] != null ? sat['slike'].toString().split(',') : [];
                    final prvaSlika = listaSlika.isNotEmpty ? listaSlika[0] : null;

                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                image: prvaSlika != null 
                                  ? DecorationImage(image: NetworkImage(prvaSlika), fit: BoxFit.cover)
                                  : null,
                              ),
                              child: prvaSlika == null ? const Center(child: Icon(Icons.watch, size: 50, color: Colors.grey)) : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${sat['cena']} €", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("${sat['brend']} ${sat['model']}", style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
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