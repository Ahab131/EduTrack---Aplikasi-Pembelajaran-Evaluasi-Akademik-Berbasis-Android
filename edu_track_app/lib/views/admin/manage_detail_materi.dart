import 'package:flutter/material.dart';
import '../../models/akademik_model.dart';
import '../../controllers/soal_controller.dart';

class ManageMaterialDetailPage extends StatefulWidget {
  final MateriModel materi;

  const ManageMaterialDetailPage({super.key, required this.materi});

  @override
  State<ManageMaterialDetailPage> createState() => _ManageMaterialDetailPageState();
}

class _ManageMaterialDetailPageState extends State<ManageMaterialDetailPage> {
  final Color primaryColor = const Color(0xFF6C63FF);
  final QuestionController _questionController = QuestionController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Detail Materi & Soal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN 1: INFO MATERI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.materi.judul,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.materi.isiMateri,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                ],
              ),
            ),

            // BAGIAN 2: HEADER SOAL
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bank Soal Latihan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showQuestionForm(context, null),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text("Buat Soal", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),

            // BAGIAN 3: LIST SOAL (Realtime)
            StreamBuilder<List<SoalModel>>(
              stream: _questionController.getQuestionsByMaterial(widget.materi.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        "Belum ada soal untuk materi ini.",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                final questions = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Agar bisa discroll bersama parent
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(index + 1, questions[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 40), // Spasi bawah
          ],
        ),
      ),
    );
  }

  // Widget Kartu Soal
  Widget _buildQuestionCard(int number, SoalModel soal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Soal No. $number", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showQuestionForm(context, soal);
                    } else if (value == 'delete') {
                      _confirmDelete(context, soal);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    const PopupMenuItem(value: 'delete', child: Text("Hapus", style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              soal.pertanyaan,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildOptionRow("A", soal.pilihanA, soal.kunciJawaban),
            _buildOptionRow("B", soal.pilihanB, soal.kunciJawaban),
            _buildOptionRow("C", soal.pilihanC, soal.kunciJawaban),
            _buildOptionRow("D", soal.pilihanD, soal.kunciJawaban),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
              child: Text(
                "Kunci Jawaban: ${soal.kunciJawaban}",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String label, String text, String keyAnswer) {
    final bool isCorrect = label == keyAnswer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label. ", style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal, color: isCorrect ? Colors.green : Colors.black)),
          Expanded(child: Text(text, style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal, color: isCorrect ? Colors.green : Colors.black87))),
          if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 16)
        ],
      ),
    );
  }

  // Dialog Form Tambah/Edit Soal
  void _showQuestionForm(BuildContext context, SoalModel? soal) {
    final bool isEdit = soal != null;
    final TextEditingController qController = TextEditingController(text: isEdit ? soal.pertanyaan : '');
    final TextEditingController aController = TextEditingController(text: isEdit ? soal.pilihanA : '');
    final TextEditingController bController = TextEditingController(text: isEdit ? soal.pilihanB : '');
    final TextEditingController cController = TextEditingController(text: isEdit ? soal.pilihanC : '');
    final TextEditingController dController = TextEditingController(text: isEdit ? soal.pilihanD : '');
    
    // Variabel untuk Dropdown Kunci Jawaban
    String selectedKey = isEdit ? soal.kunciJawaban : 'A';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder agar Dropdown bisa berubah state-nya di dalam Dialog
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? "Edit Soal" : "Tambah Soal Baru"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: qController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: "Pertanyaan", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text("Pilihan Jawaban:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCompactField(aController, "Pilihan A"),
                    _buildCompactField(bController, "Pilihan B"),
                    _buildCompactField(cController, "Pilihan C"),
                    _buildCompactField(dController, "Pilihan D"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Kunci Jawaban: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedKey,
                          items: ['A', 'B', 'C', 'D'].map((String val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedKey = val!);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    if (qController.text.isNotEmpty && aController.text.isNotEmpty) {
                      if (isEdit) {
                        await _questionController.updateQuestion(
                          docId: soal.id,
                          pertanyaan: qController.text,
                          a: aController.text,
                          b: bController.text,
                          c: cController.text,
                          d: dController.text,
                          kunci: selectedKey,
                        );
                      } else {
                        await _questionController.addQuestion(
                          pertanyaan: qController.text,
                          a: aController.text,
                          b: bController.text,
                          c: cController.text,
                          d: dController.text,
                          kunci: selectedKey,
                          materiId: widget.materi.id, // Relasi ke Materi saat ini
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCompactField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SoalModel soal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Soal?"),
        content: const Text("Data soal ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await _questionController.deleteQuestion(soal.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}