import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  String? _robotId;
  List<Map<String, dynamic>> _reports = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  // Yenileme işlemi için bu fonksiyonu onRefresh'e bağlıyoruz
  Future<void> _fetchReports() async {
    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final userData = await supabase.from('users').select('user_id').eq('email', user.email!).single();
        final robotData = await supabase.from('user_robots').select('robot_id').eq('user_id', userData['user_id']).maybeSingle();

        if (robotData != null) {
          _robotId = robotData['robot_id'];
          
          final data = await supabase
              .from('daily_crying_reports')
              .select()
              .eq('robot_id', _robotId!)
              .order('report_date', ascending: false);

          if (mounted) {
            setState(() {
              _reports = List<Map<String, dynamic>>.from(data);
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() { _errorMessage = 'Robot eşleşmesi bulunamadı.'; _isLoading = false; });
        }
      } catch (e) {
        if (mounted) setState(() { _errorMessage = 'Raporlar yüklenirken bir hata oluştu.'; _isLoading = false; });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) return '${parts[2]}.${parts[1]}.${parts[0]}';
    } catch (e) {
      return dateString;
    }
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Günlük Raporlarım', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // RefreshIndicator tüm gövdeyi sarmalıyor
      body: RefreshIndicator(
        onRefresh: _fetchReports,
        color: Colors.purple,
        backgroundColor: Colors.white,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)));

    if (_reports.isEmpty) {
      // Liste boş olsa bile aşağı çekince yenilenebilmesi için ListView kullanıyoruz
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Henüz rapor verisi yok.', style: TextStyle(fontSize: 18, color: Colors.black54)),
                Text('Yenilemek için aşağı çekin.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      // Bu özellik listenin her zaman (boş olsa bile) çekilebilir olmasını sağlar
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final date = _formatDate(report['report_date'] ?? '');
        final totalMinutes = report['total_crying_minutes'] ?? 0;
        final totalSessions = report['total_crying_sessions'] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('$totalSessions Seans', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Toplam Ağlama Süresi: $totalMinutes dk', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}