import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PraceniScreen extends StatefulWidget {
  const PraceniScreen({super.key});

  @override
  State<PraceniScreen> createState() => _PraceniScreenState();
}

class _PraceniScreenState extends State<PraceniScreen> {
  final user = Supabase.instance.client.auth.currentUser;

  Future<void> _ukloniPraceni(int oglasId) async {
    try {
      await Supabase.instance.client.from('praceni_oglasi').delete().eq('user_id', user!.id).eq('oglas_id', oglasId);
      setState(() {}); // Osvezava ekran nakon brisanja
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text("Praćeni Oglasi")),
        body: const Center(child: Text("Morate biti prijavljeni da biste videli praćene oglase.")),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Praćeni Oglasi", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      // Koristimo rpc funkciju ili obican join ako supabase dozvoli (ovde radimo najsigurniju metodu)
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Prvo uzimamo ID-jeve pracenih oglasa za ovog korisnika
        future: Supabase.instance.client.from('praceni_oglasi').select('oglas_id').eq('user_id', user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Niste zapratili nijedan oglas.", style: TextStyle(color: Colors.grey)));

          // Vadimo samo ID brojeve
          final List<int> praceniIds = snapshot.data!.map((e) => e['oglas_id'] as int).toList();

          // Sada ucitavamo same oglase na osnovu tih ID-jeva
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Supabase.instance.client.from('satovi').select().inFilter('id', praceniIds),
            builder: (context, oglasSnapshot) {
              if (oglasSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator());
              if (!oglasSnapshot.hasData || oglasSnapshot.data!.isEmpty) return const Center(child: Text("Oglasi koje pratite su možda obrisani."));

              final satovi = oglasSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: satovi.length,
                itemBuilder: (context, index) {
                  final sat = satovi[index];
                  final oglasId = sat['id'] as int;
                  final slikeStr = sat['slike']?.toString() ?? "";
                  final prvaSlika = slikeStr.isNotEmpty ? slikeStr.split(',')[0] : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60, height: 60, color: Colors.grey[200],
                          child: prvaSlika != null ? Image.network(prvaSlika, fit: BoxFit.cover, cacheWidth: 200) : const Icon(Icons.watch, color: Colors.grey),
                        ),
                      ),
                      title: Text("${sat['brend']} ${sat['model']}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: Text(sat['cena_dogovor'] == true ? "Po dogovoru" : "${sat['cena']} €", style: const TextStyle(color: Colors.blueAccent)),
                      trailing: IconButton(
                        icon: const Icon(CupertinoIcons.heart_fill, color: Colors.red),
                        onPressed: () => _ukloniPraceni(oglasId), // Brise iz pracenih i osvezava listu
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}