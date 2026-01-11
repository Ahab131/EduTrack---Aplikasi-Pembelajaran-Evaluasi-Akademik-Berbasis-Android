import 'package:flutter/material.dart';
import '../../controllers/soal_controller.dart';
import '../../models/akademik_model.dart';
import '../../controllers/nilai_controller.dart';

class QuizStudentPage extends StatefulWidget {
  final MateriModel materi;

  const QuizStudentPage({super.key, required this.materi});

  @override
  State<QuizStudentPage> createState() => _QuizStudentPageState();
}

class _QuizStudentPageState extends State<QuizStudentPage> {
  final Color headerColor = const Color(0xFF001144);
  final QuestionController _questionController = QuestionController();
  final GradeController _gradeController = GradeController();
  bool _isSaved = false;

  // State untuk Logika Kuis
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isFinished = false;

  // List soal
  List<SoalModel> _questions = [];

  // --- LOGIKA KONFIRMASI KELUAR ---
  Future<bool> _showExitConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Batal Mengerjakan?"),
            content: const Text(
              "Progres Anda akan hilang jika keluar sekarang. Yakin ingin keluar?",
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Tidak jadi keluar
                child: const Text("Lanjut Mengerjakan"),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Yakin keluar
                child: const Text(
                  "Keluar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false; // Default false jika dialog ditutup paksa
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Izinkan keluar langsung HANYA jika kuis sudah selesai (_isFinished)
      // Jika belum selesai, canPop = false (blokir keluar langsung)
      canPop: _isFinished,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop)
          return; // Jika sudah berhasil keluar (karena _isFinished true), biarkan

        // Jika belum selesai, panggil dialog konfirmasi
        final bool shouldExit = await _showExitConfirmation();
        if (shouldExit && context.mounted) {
          Navigator.pop(context); // Keluar manual jika user pilih "Ya"
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: StreamBuilder<List<SoalModel>>(
          stream: _questionController.getQuestionsByMaterial(widget.materi.id),
          builder: (context, snapshot) {
            // 1. Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Data Kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            // 3. Ada Data Soal
            if (_questions.isEmpty) {
              _questions = snapshot.data!;
            }

            // Jika Kuis Selesai, Tampilkan Hasil
            if (_isFinished) {
              return _buildResultScreen();
            }

            // Tampilkan Soal
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildQuestionCard(_questions[_currentIndex]),
                        const SizedBox(height: 20),
                        _buildOptions(_questions[_currentIndex]),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(color: headerColor),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () async {
                  // Cek konfirmasi dulu sebelum keluar
                  final bool shouldExit = await _showExitConfirmation();
                  if (shouldExit && context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 10),
              // ... (kode Text judul tetap sama)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Latihan Soal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Soal ${_currentIndex + 1} dari ${_questions.length}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET KARTU PERTANYAAN ---
  Widget _buildQuestionCard(SoalModel soal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        soal.pertanyaan,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // --- WIDGET PILIHAN JAWABAN ---
  Widget _buildOptions(SoalModel soal) {
    return Column(
      children: [
        _buildOptionItem("A", soal.pilihanA),
        _buildOptionItem("B", soal.pilihanB),
        _buildOptionItem("C", soal.pilihanC),
        _buildOptionItem("D", soal.pilihanD),
      ],
    );
  }

  Widget _buildOptionItem(String key, String text) {
    final bool isSelected = _selectedAnswer == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswer = key;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? headerColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? headerColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? headerColor : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  key,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? headerColor : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TOMBOL LANJUT ---
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: headerColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _selectedAnswer == null ? null : _nextQuestion,
          child: Text(
            _currentIndex == _questions.length - 1 ? "Selesai" : "Selanjutnya",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIKA PINDAH SOAL ---
  void _nextQuestion() async {
    // 1. Hitung Skor Jawaban Saat Ini
    final currentSoal = _questions[_currentIndex];
    if (_selectedAnswer == currentSoal.kunciJawaban) {
      _score++;
    }

    // 2. Cek apakah ini soal terakhir
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      // KUIS SELESAI
      if (!_isSaved) {
        _isSaved = true;

        // Hitung Nilai Akhir (0-100)
        double finalScore = (_score / _questions.length) * 100;

        // SIMPAN KE FIREBASE
        await _gradeController.saveScore(
          widget.materi.id,
          widget.materi.judul,
          finalScore.toInt(),
        );

        setState(() {
          _isFinished = true;
        });
      }
    }
  }

  // --- TAMPILAN HASIL SKOR ---
  Widget _buildResultScreen() {
    double finalScore = (_score / _questions.length) * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                finalScore >= 70
                    ? Icons.emoji_events
                    : Icons.sentiment_dissatisfied,
                size: 100,
                color: finalScore >= 70 ? Colors.orange : Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                "Kuis Selesai!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Skor Kamu: ${finalScore.toInt()}",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: headerColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Benar $_score dari ${_questions.length} soal",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Kembali ke Materi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        title: const Text("Kuis Kosong"),
      ),
      body: const Center(child: Text("Belum ada soal untuk materi ini.")),
    );
  }
}