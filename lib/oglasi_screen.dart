import 'package:flutter/material.dart';

class OglasiScreen extends StatelessWidget {
  const OglasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ovo je samo test data, sutra cemo ovo vuci iz baze!
    final List<Map<String, String>> testOglasi = [
      {
        'naslov': 'Rolex Submariner Date',
        'cena': '12.500 €',
        'slika': 'https://images.unsplash.com/photo-1619229725920-ac8b489d6e8e?q=80&w=400',
      },
      {
        'naslov': 'Seiko SKX007K',
        'cena': '350 €',
        'slika': 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?q=80&w=400',
      },
      {
        'naslov': 'Omega Speedmaster Pro',
        'cena': '6.800 €',
        'slika': 'https://images.unsplash.com/photo-1614149162883-504ce4d13909?q=80&w=400',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("NadjiSat.rs", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 oglasa u redu
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Odnos sirine i visine kartice
          ),
          itemCount: testOglasi.length,
          itemBuilder: (context, index) {
            final oglas = testOglasi[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        oglas['slika']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(oglas['naslov']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(oglas['cena']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}