import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/data/models/auth_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart' show LoadStatus;
import '../../data/models/onboarding_models.dart';
import '../cubit/driver_onboarding_cubit.dart' show DocSlot, DocUploadStatus;
import '../cubit/driver_status_cubit.dart';
import '../widgets/document_tile.dart';

/// Shown while the application is pending, rejected, suspended
/// (and briefly when approved, before the router sends the driver to the dashboard).
class DriverStatusScreen extends StatelessWidget {
  const DriverStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DriverStatusCubit>()..load(),
      child: const _StatusView(),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<DriverStatusCubit>().load();
    if (context.mounted) await context.read<AuthCubit>().refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverStatusCubit, DriverStatusState>(
      listenWhen: (a, b) =>
          a.info?.status != b.info?.status || a.error != b.error,
      listener: (context, state) {
        if (state.info?.status == VerificationStatus.approved) {
          // Updating the user makes the router open the dashboard.
          context.read<AuthCubit>().refreshUser();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final info = state.info;
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'حالة طلبك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.read<AuthCubit>().logout(),
                child: const Text('خروج'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (info == null && state.status == LoadStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (info == null)
                  _Message(
                    icon: Icons.wifi_off,
                    color: AppColors.error,
                    title: 'تعذّر تحميل الحالة',
                    body: state.error ?? 'اسحب للأسفل لإعادة المحاولة',
                  )
                else
                  ..._body(context, state, info),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(
    BuildContext context,
    DriverStatusState state,
    VerificationInfo info,
  ) {
    switch (info.status) {
      case VerificationStatus.pending:
        return const [
          _Message(
            icon: Icons.hourglass_top_rounded,
            color: AppColors.primary,
            title: 'طلبك قيد المراجعة',
            body: 'بنراجع مستنداتك. بعد الموافقة أحضر السوزوكي لموقف العبور '
                'لفحص السيارة، ثم يتم تفعيل حسابك.\nاسحب للأسفل للتحديث.',
          ),
        ];
      case VerificationStatus.approved:
        return [
          const _Message(
            icon: Icons.check_circle,
            color: Colors.green,
            title: 'تم قبولك ككابتن 🎉',
            body: 'حسابك جاهز.',
          ),
          ElevatedButton(
            onPressed: () => context.read<AuthCubit>().refreshUser(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 58),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ابدأ العمل'),
          ),
        ];
      case VerificationStatus.suspended:
        return const [
          _Message(
            icon: Icons.block,
            color: AppColors.error,
            title: 'تم إيقاف حسابك',
            body: 'تواصل مع الدعم لمعرفة السبب.',
          ),
        ];
      case VerificationStatus.rejected:
        final rejected = info.documents.where((d) => d.isRejected).toList();
        return [
          _Message(
            icon: Icons.error_outline,
            color: AppColors.error,
            title: 'يلزم تعديل بعض المستندات',
            body: info.rejectionReason ??
                'ارفع المستندات المرفوضة من جديد وسنراجعها.',
          ),
          for (final d in rejected)
            DocumentTile(
              label: d.type.labelAr,
              icon: Icons.description_outlined,
              rejectReason: d.rejectReason,
              slot: DocSlot(
                status: state.replacing.contains(d.type)
                    ? DocUploadStatus.uploading
                    : DocUploadStatus.empty,
              ),
              onPicked: (path) =>
                  context.read<DriverStatusCubit>().replaceDocument(d.type, path),
            ),
        ];
      case VerificationStatus.none:
      case VerificationStatus.draft:
        return const [
          _Message(
            icon: Icons.edit_note,
            color: AppColors.primary,
            title: 'أكمل التسجيل',
            body: 'لم يتم إرسال طلبك بعد.',
          ),
        ];
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 72, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
