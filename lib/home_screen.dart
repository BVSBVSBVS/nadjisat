import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String pretragaText = '';
  
  // Varijable za filtere
  String? filterBrend;
  RangeValues filterCena = const RangeValues(0, 100000);
  RangeValues filterGodina = const RangeValues(1950, 2024);

  final List<String> popularniBrendovi = ['Svi', 'Rolex', 'Omega', 'Patek Philippe', 'Audemars Piguet', 'Seiko', 'Breitling', 'Tag Heuer'];

  void _otvoriFiltere() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  const Text("Napredni Filteri", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // BREND
                  const Text("Brend", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                    value: filterBrend ?? 'Svi',
                    items: popularniBrendovi.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) {
                      setModalState(() => filterBrend = v == 'Svi' ? null : v);
                    },
                  ),
                  const SizedBox(height: 25),

                  // CENA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Cena (€)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text("${filterCena.start.toInt()} € - ${filterCena.end.toInt()} €", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  RangeSlider(
                    values: filterCena,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey[300],
                    onChanged: (v) => setModalState(() => filterCena = v),
                  ),
                  const SizedBox(height: 25),

                  // GODINA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Godina", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text("${filterGodina.start.toInt()} - ${filterGodina.end.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  RangeSlider(
                    values: filterGodina,
                    min: 1950,
                    max: 2024,
                    divisions: 74,
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey[300],
                    onChanged: (v) => setModalState(() => filterGodina = v),
                  ),
                  
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      setState(() {}); // Primeni u pozadini
                      Navigator.pop(context); // Zatvori prozor
                    },
                    child: const Text("PRIKAŽI REZULTATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Pretraga Satova", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // GLAVNI DEO ZA PRETRAGU I FILTERE (Moderni blok)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Upiši model (npr. Daytona)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => pretragaText = v.toLowerCase()),
                ),
                const SizedBox(height: 12),
                // OVO JE NOVO DUGME ZA FILTERE
                InkWell(
                  onTap: _otvoriFiltere,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Napredni Filteri (Cena, Godina, Brend)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Ostatak ekrana: Mreža oglasa
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.black));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nema oglasa u bazi.", style: TextStyle(color: Colors.grey)));

                final satovi = snapshot.data!.where((sat) {
                  final modelSata = (sat['model'] ?? '').toString().toLowerCase();
                  if (pretragaText.isNotEmpty && !modelSata.contains(pretragaText)) return false;
                  
                  if (filterBrend != null && sat['brend'] != filterBrend) return false;

                  final cena = sat['cena'] is int ? sat['cena'] : int.tryParse(sat['cena'].toString()) ?? 0;
                  if (cena < filterCena.start || cena > filterCena.end) return false;

                  final godinaSata = int.tryParse((sat['godina'] ?? '').toString()) ?? 0;
                  if (godinaSata != 0 && (godinaSata < filterGodina.start || godinaSata > filterGodina.end)) return false;

                  return true;
                }).toList();

                if (satovi.isEmpty) return const Center(child: Text("Nijedan sat ne odgovara filterima.", style: TextStyle(color: Colors.grey)));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.72
                  ),
                  itemCount: satovi.length,
                  itemBuilder: (context, index) {
                    final sat = satovi[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              ),
                              child: const Center(child: Icon(Icons.watch, size: 50, color: Colors.grey)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${sat['cena']} €", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                                const SizedBox(height: 4),
                                Text("${sat['brend']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
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