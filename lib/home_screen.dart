import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("NadjiSat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: Colors.black))],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).order('created_at'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final satovi = snapshot.data!;
          
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75
            ),
            itemCount: satovi.length,
            itemBuilder: (context, index) {
              final sat = satovi[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          image: const DecorationImage(image: NetworkImage("https://via.placeholder.com/300"), fit: BoxFit.cover)
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${sat['cena']} €", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                          Text("${sat['brend']} ${sat['model']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${sat['godina']}. god", style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
    );
  }
}