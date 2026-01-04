import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

// Import untuk fitur PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ==========================================
// 1. LOGIC & DATA MODELS
// ==========================================

class Kriteria {
  String id;
  String nama;
  double bobot;
  String tipe;
  Kriteria({required this.id, required this.nama, required this.bobot, required this.tipe});
}

class Alternatif {
  String id;
  String nama;
  double nilaiAkhir;
  Alternatif({required this.id, required this.nama, this.nilaiAkhir = 0.0});
}

class Penilaian {
  String idAlternatif;
  String idKriteria;
  double nilai;
  Penilaian({required this.idAlternatif, required this.idKriteria, required this.nilai});
}

class SubKriteria {
  String kriteriaId;
  int rating;
  String deskripsi;
  SubKriteria({required this.kriteriaId, required this.rating, required this.deskripsi});
}

class SpkProvider with ChangeNotifier {
  // Data Dummy Awal
  final List<Kriteria> _kriteriaList = [
    Kriteria(id: 'C1', nama: 'Harga Sewa', bobot: 30, tipe: 'Cost'),
    Kriteria(id: 'C2', nama: 'Jarak', bobot: 25, tipe: 'Cost'),
    Kriteria(id: 'C3', nama: 'Fasilitas', bobot: 20, tipe: 'Benefit'),
    Kriteria(id: 'C4', nama: 'Keamanan', bobot: 15, tipe: 'Benefit'),
    Kriteria(id: 'C5', nama: 'Kenyamanan', bobot: 10, tipe: 'Benefit'),
  ];

  final List<Alternatif> _alternatifList = [
    Alternatif(id: 'A1', nama: 'Kos Mawar'),
    Alternatif(id: 'A2', nama: 'Kos Melati'),
    Alternatif(id: 'A3', nama: 'Kos Anggrek'),
  ];

  final List<Penilaian> _penilaianList = [
    Penilaian(idAlternatif: 'A1', idKriteria: 'C1', nilai: 900000), Penilaian(idAlternatif: 'A1', idKriteria: 'C2', nilai: 350), Penilaian(idAlternatif: 'A1', idKriteria: 'C3', nilai: 3), Penilaian(idAlternatif: 'A1', idKriteria: 'C4', nilai: 3), Penilaian(idAlternatif: 'A1', idKriteria: 'C5', nilai: 3),
    Penilaian(idAlternatif: 'A2', idKriteria: 'C1', nilai: 850000), Penilaian(idAlternatif: 'A2', idKriteria: 'C2', nilai: 250), Penilaian(idAlternatif: 'A2', idKriteria: 'C3', nilai: 4), Penilaian(idAlternatif: 'A2', idKriteria: 'C4', nilai: 4), Penilaian(idAlternatif: 'A2', idKriteria: 'C5', nilai: 4),
    Penilaian(idAlternatif: 'A3', idKriteria: 'C1', nilai: 750000), Penilaian(idAlternatif: 'A3', idKriteria: 'C2', nilai: 500), Penilaian(idAlternatif: 'A3', idKriteria: 'C3', nilai: 5), Penilaian(idAlternatif: 'A3', idKriteria: 'C4', nilai: 4), Penilaian(idAlternatif: 'A3', idKriteria: 'C5', nilai: 5),
  ];

  final List<SubKriteria> _subKriteriaList = [
    SubKriteria(kriteriaId: 'C3', rating: 4, deskripsi: "Sangat lengkap"),
    SubKriteria(kriteriaId: 'C3', rating: 3, deskripsi: "Lengkap"),
    SubKriteria(kriteriaId: 'C3', rating: 2, deskripsi: "Standar"),
    SubKriteria(kriteriaId: 'C3', rating: 1, deskripsi: "Minim fasilitas"),
    SubKriteria(kriteriaId: 'C4', rating: 4, deskripsi: "Sangat aman"),
    SubKriteria(kriteriaId: 'C4', rating: 3, deskripsi: "Aman"),
    SubKriteria(kriteriaId: 'C4', rating: 2, deskripsi: "Cukup aman"),
    SubKriteria(kriteriaId: 'C4', rating: 1, deskripsi: "Kurang aman"),
    SubKriteria(kriteriaId: 'C5', rating: 4, deskripsi: "Sangat nyaman"),
    SubKriteria(kriteriaId: 'C5', rating: 3, deskripsi: "Nyaman"),
    SubKriteria(kriteriaId: 'C5', rating: 2, deskripsi: "Kurang nyaman"),
    SubKriteria(kriteriaId: 'C5', rating: 1, deskripsi: "Tidak nyaman"),
  ];

  List<Kriteria> get kriteriaList => _kriteriaList;
  List<Alternatif> get alternatifList => _alternatifList;
  List<SubKriteria> get subKriteriaList => _subKriteriaList;
  List<Penilaian> get penilaianList => _penilaianList;

  void tambahAlternatif(String nama) {
    String newId = 'A${_alternatifList.length + 1}';
    _alternatifList.add(Alternatif(id: newId, nama: nama));
    for (var k in _kriteriaList) {
      _penilaianList.add(Penilaian(idAlternatif: newId, idKriteria: k.id, nilai: 0));
    }
    notifyListeners();
  }

  void hapusAlternatif(String id) {
    _alternatifList.removeWhere((x) => x.id == id);
    _penilaianList.removeWhere((x) => x.idAlternatif == id);
    notifyListeners();
  }

  void updatePenilaian(String idAlt, String idKrit, double nilai) {
    var index = _penilaianList.indexWhere((p) => p.idAlternatif == idAlt && p.idKriteria == idKrit);
    if (index != -1) {
      _penilaianList[index].nilai = nilai;
    } else {
      _penilaianList.add(Penilaian(idAlternatif: idAlt, idKriteria: idKrit, nilai: nilai));
    }
    notifyListeners();
  }

  double getNilai(String idAlt, String idKrit) {
    var data = _penilaianList.firstWhere(
      (p) => p.idAlternatif == idAlt && p.idKriteria == idKrit, 
      orElse: () => Penilaian(idAlternatif: idAlt, idKriteria: idKrit, nilai: 0)
    );
    return data.nilai;
  }

  List<SubKriteria> getSubKriteriaByKriteria(String kriteriaId) {
    return _subKriteriaList
        .where((s) => s.kriteriaId == kriteriaId)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  void hitungSmart() {
    if (_alternatifList.isEmpty) return;

    double totalBobot = _kriteriaList.fold(0, (sum, item) => sum + item.bobot);
    Map<String, double> minVal = {};
    Map<String, double> maxVal = {};

    for (var k in _kriteriaList) {
      List<double> values = _penilaianList
          .where((p) => p.idKriteria == k.id)
          .map((p) => p.nilai)
          .toList();
      
      if (values.isEmpty) {
        minVal[k.id] = 0;
        maxVal[k.id] = 0;
      } else {
        minVal[k.id] = values.reduce(min);
        maxVal[k.id] = values.reduce(max);
      }
    }

    for (var alt in _alternatifList) {
      double totalSkor = 0;

      for (var k in _kriteriaList) {
        double nilaiAsli = getNilai(alt.id, k.id);
        double cMin = minVal[k.id]!;
        double cMax = maxVal[k.id]!;
        double utility = 0;
        double normBobot = k.bobot / totalBobot;
        double range = cMax - cMin;

        if (range == 0) {
          utility = 1.0; 
        } else {
          if (k.tipe == 'Benefit') {
            utility = (nilaiAsli - cMin) / range;
          } else { 
            utility = (cMax - nilaiAsli) / range;
          }
        }
        totalSkor += (normBobot * utility);
      }
      alt.nilaiAkhir = totalSkor;
    }

    _alternatifList.sort((a, b) => b.nilaiAkhir.compareTo(a.nilaiAkhir));
    notifyListeners();
  }
}

// ==========================================
// 2. MAIN APP & THEME CONFIGURATION
// ==========================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SPK SMART',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Modern Purple
          brightness: Brightness.light,
          surface: const Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), // Menggunakan Google Fonts
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        )
      ),
      home: const MainLayout(),
    );
  }
}

// ==========================================
// 3. LAYOUT UTAMA (SIDEBAR + CONTENT)
// ==========================================

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const AlternatifView(),
    const KriteriaView(),
    const SubKriteriaView(),
    const PenilaianView(),
    const PerhitunganView(),
    const HasilView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Responsive: Jika layar kecil (HP), gunakan BottomNav, jika besar (Tablet/Web) gunakan Rail
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF6C63FF).withOpacity(0.1),
            selectedIconTheme: const IconThemeData(color: Color(0xFF6C63FF)),
            unselectedIconTheme: IconThemeData(color: Colors.grey.shade400),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Icon(Icons.analytics_rounded, size: 32, color: const Color(0xFF6C63FF)),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dash')),
              NavigationRailDestination(icon: Icon(Icons.home_work_outlined), selectedIcon: Icon(Icons.home_work), label: Text('Alt')),
              NavigationRailDestination(icon: Icon(Icons.tune), selectedIcon: Icon(Icons.tune), label: Text('Krit')),
              NavigationRailDestination(icon: Icon(Icons.layers_outlined), selectedIcon: Icon(Icons.layers), label: Text('Sub')),
              NavigationRailDestination(icon: Icon(Icons.edit_note), selectedIcon: Icon(Icons.edit), label: Text('Nilai')),
              NavigationRailDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: Text('Hitung')),
              NavigationRailDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: Text('Hasil')),
            ],
          ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.all(20.0),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dash'),
          NavigationDestination(icon: Icon(Icons.home), label: 'Alt'),
          NavigationDestination(icon: Icon(Icons.edit), label: 'Nilai'),
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Hitung'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Hasil'),
        ],
      ),
    );
  }
}

// Widget Helper untuk Header Halaman
class HeaderContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const HeaderContent({super.key, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN DASHBOARD (POWERFUL UI)
// ==========================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);
    // Jalankan hitungan sekilas agar data rekomendasi muncul
    if(provider.alternatifList.isNotEmpty && provider.alternatifList.first.nilaiAkhir == 0) {
       Future.microtask(() => provider.hitungSmart());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeaderContent(title: "Selamat Datang, Admin!", subtitle: "Sistem Pendukung Keputusan Metode SMART"),
        
        Row(
          children: [
            _buildStatCard("Total Alternatif", "${provider.alternatifList.length}", Icons.home_work, const Color(0xFF6C63FF)),
            const SizedBox(width: 16),
            _buildStatCard("Total Kriteria", "${provider.kriteriaList.length}", Icons.tune, Colors.orange),
            const SizedBox(width: 16),
            _buildStatCard("Rekomendasi", provider.alternatifList.isNotEmpty ? provider.alternatifList.first.nama : "-", Icons.emoji_events, Colors.green),
          ],
        ),
        const SizedBox(height: 24),
        
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tentang Metode SMART", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Text(
                  "Metode Simple Multi Attribute Rating Technique (SMART) merupakan metode pengambilan keputusan multi-kriteria yang didasarkan pada teori bahwa setiap alternatif terdiri dari sejumlah kriteria yang memiliki nilai-nilai dan setiap kriteria memiliki bobot yang menggambarkan seberapa penting kriteria tersebut dibandingkan dengan kriteria lain.",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, height: 1.6),
                ),
                const Spacer(),
                Center(
                  child: Icon(Icons.bar_chart_rounded, size: 100, color: Colors.grey.shade200),
                ),
                Center(child: Text("Silakan masuk ke menu Perhitungan", style: TextStyle(color: Colors.grey.shade400))),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN ALTERNATIF (DENGAN SCROLL FIX)
// ==========================================

class AlternatifView extends StatelessWidget {
  const AlternatifView({super.key});

  // Fungsi untuk menampilkan Detail Nilai
  void _showDetailAlternatif(BuildContext context, SpkProvider provider, Alternatif alt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Izinkan modal mengambil tinggi penuh
      backgroundColor: Colors.transparent, // Transparan agar rounded corner terlihat
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              // PERBAIKAN SCROLLING: Menggunakan satu ListView.separated untuk Header + Isi
              // Item index 0 = Header, index > 0 = List Item
              child: ListView.separated(
                controller: controller,
                padding: EdgeInsets.zero, // Padding nol agar header mentok atas
                itemCount: provider.kriteriaList.length + 1, // +1 untuk Header
                separatorBuilder: (context, index) => index == 0 ? const SizedBox.shrink() : const Divider(height: 1),
                itemBuilder: (context, index) {
                  // === BAGIAN HEADER ===
                  if (index == 0) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C63FF),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40, height: 4, 
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2))
                            )
                          ),
                          const Text("Rincian Penilaian", style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 5),
                          Text(
                            alt.nama,
                            style: GoogleFonts.poppins(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white
                            ),
                          ),
                          Text("ID: ${alt.id}", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }

                  // === BAGIAN LIST ITEM ===
                  // Karena index 0 dipakai header, data diambil dari index - 1
                  final kriteria = provider.kriteriaList[index - 1];
                  final nilai = provider.getNilai(alt.id, kriteria.id);
                  final isBenefit = kriteria.tipe == 'Benefit';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isBenefit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isBenefit ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isBenefit ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      title: Text(kriteria.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${kriteria.id} • ${kriteria.tipe}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: Text(
                          nilai.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);
    TextEditingController namaController = TextEditingController();

    return Column(
      children: [
        HeaderContent(
          title: "Data Alternatif", 
          subtitle: "Ketuk kartu alternatif untuk melihat rincian nilai",
          action: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Tambah Baru"),
            onPressed: () {
              namaController.clear();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Tambah Kost"),
                  content: TextField(
                    controller: namaController, 
                    decoration: const InputDecoration(labelText: "Nama Kost", border: OutlineInputBorder())
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white),
                      onPressed: () {
                        if (namaController.text.isNotEmpty) {
                          provider.tambahAlternatif(namaController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Simpan"),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.alternatifList.length,
            itemBuilder: (context, index) {
              final alt = provider.alternatifList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showDetailAlternatif(context, provider, alt), // AKSI KLIK DISINI
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                          child: Text(alt.id, style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alt.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.touch_app, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text("Lihat Rincian", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => provider.hapusAlternatif(alt.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 6. HALAMAN KRITERIA
// ==========================================

class KriteriaView extends StatelessWidget {
  const KriteriaView({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);
    return Column(
      children: [
        const HeaderContent(title: "Data Kriteria", subtitle: "Bobot dan Atribut penilaian"),
        Expanded(
          child: ListView.builder(
            itemCount: provider.kriteriaList.length,
            itemBuilder: (context, index) {
              final k = provider.kriteriaList[index];
              final isBenefit = k.tipe == 'Benefit';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text(k.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Bobot: ${k.bobot}%", style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isBenefit ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isBenefit ? Colors.green.shade200 : Colors.red.shade200),
                        ),
                        child: Text(k.tipe, style: TextStyle(color: isBenefit ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 7. HALAMAN SUB KRITERIA (DENGAN SCROLL VIEW)
// ==========================================

class SubKriteriaView extends StatelessWidget {
  const SubKriteriaView({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);
    final kriteriaKualitatif = provider.kriteriaList.where((k) => k.tipe == 'Benefit').toList();

    return Column(
      children: [
        const HeaderContent(title: "Sub Kriteria", subtitle: "Panduan rating untuk kriteria kualitatif"),
        
        // PENGGUNAAN SINGLE CHILD SCROLL VIEW (SCROLLVIEW)
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: kriteriaKualitatif.map((kriteria) {
                final subList = provider.getSubKriteriaByKriteria(kriteria.id);
                if (subList.isEmpty) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.05),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        ),
                        child: Text("${kriteria.nama} (${kriteria.id})", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                      ),
                      ...subList.map((sub) => ListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey.shade200,
                          child: Text("${sub.rating}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(sub.deskripsi, style: GoogleFonts.poppins(fontSize: 14)),
                      )),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 8. HALAMAN PENILAIAN
// ==========================================

class PenilaianView extends StatelessWidget {
  const PenilaianView({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);
    
    return Column(
      children: [
        const HeaderContent(title: "Input Penilaian", subtitle: "Masukkan nilai untuk setiap alternatif"),
        Expanded(
          child: ListView.builder(
            itemCount: provider.alternatifList.length,
            itemBuilder: (context, index) {
              final alt = provider.alternatifList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.edit, color: Color(0xFF6C63FF), size: 20),
                    ),
                    title: Text(alt.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    childrenPadding: const EdgeInsets.all(20),
                    children: provider.kriteriaList.map((kriteria) {
                      final key = ValueKey('${alt.id}-${kriteria.id}');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(kriteria.nama, style: const TextStyle(fontWeight: FontWeight.w500))),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                key: key,
                                initialValue: provider.getNilai(alt.id, kriteria.id).toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  suffixText: " Pt",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  provider.updatePenilaian(alt.id, kriteria.id, double.tryParse(val) ?? 0);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 9. HALAMAN PERHITUNGAN
// ==========================================

class PerhitunganView extends StatelessWidget {
  const PerhitunganView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);
    provider.hitungSmart(); 

    return Column(
      children: [
        const HeaderContent(title: "Tabel Perhitungan", subtitle: "Matriks keputusan dan Normalisasi"),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    labelColor: const Color(0xFF6C63FF),
                    unselectedLabelColor: Colors.grey,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Data Mentah"),
                      Tab(text: "Hasil Akhir"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1
                      SingleChildScrollView(
                        child: Card(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFF6C63FF).withOpacity(0.05)),
                              columns: [
                                const DataColumn(label: Text("Alternatif", style: TextStyle(fontWeight: FontWeight.bold))),
                                ...provider.kriteriaList.map((k) => DataColumn(label: Text(k.nama, style: const TextStyle(fontWeight: FontWeight.bold)))),
                              ],
                              rows: provider.alternatifList.map((alt) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(alt.nama, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    ...provider.kriteriaList.map((k) => DataCell(Text(provider.getNilai(alt.id, k.id).toStringAsFixed(0)))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      // Tab 2
                      ListView(
                        children: [
                          Card(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1)),
                                columns: const [
                                  DataColumn(label: Text("Rank")),
                                  DataColumn(label: Text("Nama Alternatif")),
                                  DataColumn(label: Text("Nilai Akhir")),
                                ],
                                rows: provider.alternatifList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final alt = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(CircleAvatar(radius: 12, backgroundColor: index == 0 ? Colors.amber : Colors.grey.shade200, child: Text("${index+1}", style: const TextStyle(fontSize: 12)))),
                                      DataCell(Text(alt.nama, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(alt.nilaiAkhir.toStringAsFixed(4))),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 10. HALAMAN HASIL & PDF
// ==========================================

class HasilView extends StatelessWidget {
  const HasilView({super.key});

  Future<void> _generatePdf(BuildContext context, List<Alternatif> list) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text("Laporan Hasil Seleksi (SMART)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18))),
              pw.SizedBox(height: 20),
              pw.Text("Pemenang / Rekomendasi Utama:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                color: PdfColors.green100,
                child: pw.Text("${list.first.nama} (Nilai: ${list.first.nilaiAkhir.toStringAsFixed(4)})", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Rank', 'ID', 'Nama Kost', 'Nilai Akhir'],
                data: List<List<dynamic>>.generate(list.length, (index) => [index + 1, list[index].id, list[index].nama, list[index].nilaiAkhir.toStringAsFixed(4)]),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
                cellAlignments: {0: pw.Alignment.center, 3: pw.Alignment.centerRight},
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'Laporan_SPK.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpkProvider>(context);

    return Column(
      children: [
        const HeaderContent(title: "Hasil & Rekomendasi", subtitle: "Keputusan akhir berdasarkan metode SMART"),
        if(provider.alternatifList.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
              const SizedBox(height: 10),
              Text("REKOMENDASI TERBAIK", style: GoogleFonts.poppins(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(provider.alternatifList.first.nama, style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              Text("Total Skor: ${provider.alternatifList.first.nilaiAkhir.toStringAsFixed(4)}", style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0, side: BorderSide(color: Colors.grey.shade300)),
              icon: const Icon(Icons.refresh),
              label: const Text("Hitung Ulang"),
              onPressed: () {
                provider.hitungSmart();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ranking Diperbarui!")));
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
              icon: const Icon(Icons.print),
              label: const Text("Cetak PDF"),
              onPressed: () {
                if(provider.alternatifList.isNotEmpty) _generatePdf(context, provider.alternatifList);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            child: ListView.separated(
              itemCount: provider.alternatifList.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final alt = provider.alternatifList[index];
                if (index == 0) return const SizedBox.shrink(); // Hide winner (already shown above)
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Text("${index + 1}")),
                  title: Text(alt.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(alt.nilaiAkhir.toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}