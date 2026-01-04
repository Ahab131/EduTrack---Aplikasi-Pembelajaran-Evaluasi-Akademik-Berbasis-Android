import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/nilai_controller.dart';
import '../../models/akademik_model.dart';

class HistoryScorePage extends StatefulWidget {
  const HistoryScorePage({super.key});

  @override
  State<HistoryScorePage> createState() => _HistoryScorePageState();
}

class _HistoryScorePageState extends State<HistoryScorePage> {
  final Color headerColor = const Color(0xFF001144);
  final GradeController _gradeController = GradeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          /// ================= HEADER KOTAK =================
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(color: headerColor),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Riwayat Nilai",
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ================= LIST RIWAYAT =================
          Expanded(
            child: StreamBuilder<List<NilaiModel>>(
              stream: _gradeController.getStudentHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_edu, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("Belum ada riwayat nilai", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                final history = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(history[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(NilaiModel nilai) {
    
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(nilai.tanggal);

    // Warna skor: Hijau jika >= 70, Merah jika < 70
    Color scoreColor = nilai.nilai >= 70 ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.assignment_turned_in, color: Colors.blue),
        ),
        title: Text(
          nilai.judulMateri,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scoreColor, width: 1),
          ),
          child: Text(
            "${nilai.nilai}",
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}