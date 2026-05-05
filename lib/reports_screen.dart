import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme_controller.dart';
import 'l10n/app_localizations.dart';

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
        final userData = await supabase
            .from('users')
            .select('user_id')
            .eq('email', user.email!)
            .single();
        final robotData = await supabase
            .from('user_robots')
            .select('robot_id')
            .eq('user_id', userData['user_id'])
            .maybeSingle();

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
          if (mounted) {
            setState(() {
              _errorMessage = AppLocalizations.of(context).reports_no_robot;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context).reports_load_error;
            _isLoading = false;
          });
        }
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

  // ─── UI ───────────────────────────────────────────────────────

  LinearGradient _brandGradient(BuildContext c) => LinearGradient(
        colors: [c.appPink, c.appLavender],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).reports_title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _brandGradient(context)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReports,
        color: context.appPink,
        backgroundColor: context.appSurface,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(context.appPink),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: context.appPink,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appTextDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      // Liste boş olsa bile aşağı çekince yenilenebilmesi için ListView kullanıyoruz
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: _brandGradient(context),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.insert_chart_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).reports_empty_title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.appTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).reports_empty_subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.appMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.appLavender, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 16,
                          color: context.appMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context).reports_pull_to_refresh,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.appMuted,
                          ),
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

    // MainScreen extendBody:true + floating nav bar (72 + 16 dış padding +
    // system inset) yüzünden body alt nav'ın arkasına uzanıyor. Son kartın
    // tam görünmesi için bu yüksekliği bottom padding olarak ekliyoruz.
    final bottomInset =
        MediaQuery.of(context).padding.bottom + 72 + 16 + 16;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final date = _formatDate(report['report_date'] ?? '');
        final totalMinutes = report['total_crying_minutes'] ?? 0;
        final totalSessions = report['total_crying_sessions'] ?? 0;
        return _buildReportCard(
          date: date,
          totalMinutes: totalMinutes,
          totalSessions: totalSessions,
        );
      },
    );
  }

  Widget _buildReportCard({
    required String date,
    required dynamic totalMinutes,
    required dynamic totalSessions,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: context.appSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(gradient: _brandGradient(context)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: context.appTextDark,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: _brandGradient(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).reports_session_count(totalSessions),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: context.appHairline),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.appPink,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).reports_total_minutes_label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: context.appMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).reports_minutes_value(totalMinutes),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: context.appTextDark,
                                ),
                              ),
                            ],
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
    );
  }
}
