import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/screen_util_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/landmark_entity.dart';
import '../cubit/passenger_cubits.dart';
import '../cubit/passenger_states.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Passenger profile: user info header + saved landmarks list.
class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LandmarkCubit>().loadLandmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.savedLandmarks,
                      style: AppTextStyles.titleMedium),
                  SizedBox(height: AppSpacing.vmd),
                  BlocBuilder<LandmarkCubit, LandmarkState>(
                    builder: (context, state) {
                      if (state is LandmarkLoading) {
                        return const Center(child: LoadingIndicator());
                      }
                      if (state is LandmarkError) {
                        return ErrorView(
                          message: state.message,
                          onRetry: () =>
                              context.read<LandmarkCubit>().loadLandmarks(),
                        );
                      }
                      if (state is LandmarksLoaded) {
                        if (state.landmarks.isEmpty) {
                          return EmptyView(
                            title: 'لا توجد معالم محفوظة',
                            message: 'أضف معالمك المفضلة للوصول السريع',
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.landmarks.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSpacing.vsm),
                          itemBuilder: (_, i) => _LandmarkTile(
                            landmark: state.landmarks[i],
                            onDelete: () => context
                                .read<LandmarkCubit>()
                                .deleteLandmark(state.landmarks[i].id),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLandmarkDialog(context),
        child: const Icon(Icons.add_location_alt_rounded),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppColors.onPrimary.withOpacity(0.2),
                  child: Icon(Icons.person_rounded,
                      color: AppColors.onPrimary, size: 40.sp),
                ),
                SizedBox(height: AppSpacing.vsm),
                Text(AppStrings.profile,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.onPrimary)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.onPrimary),
          onPressed: () {
            context.read<AuthCubit>().logout();
            context.go('/login');
          },
          tooltip: AppStrings.logout,
        ),
      ],
    );
  }

  void _showAddLandmarkDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const _AddLandmarkSheet(),
    );
  }
}

class _LandmarkTile extends StatelessWidget {
  const _LandmarkTile({required this.landmark, required this.onDelete});
  final LandmarkEntity landmark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
      leading: Text(landmark.type.icon, style: TextStyle(fontSize: 24.sp)),
      title: Text(landmark.name, style: AppTextStyles.titleSmall),
      subtitle: landmark.address != null
          ? Text(landmark.address!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.grey600))
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
        onPressed: onDelete,
      ),
    );
  }
}

class _AddLandmarkSheet extends StatefulWidget {
  const _AddLandmarkSheet();

  @override
  State<_AddLandmarkSheet> createState() => _AddLandmarkSheetState();
}

class _AddLandmarkSheetState extends State<_AddLandmarkSheet> {
  final _nameController = TextEditingController();
  LandmarkType _type = LandmarkType.custom;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.addLandmark, style: AppTextStyles.titleMedium),
          SizedBox(height: AppSpacing.vmd),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppStrings.landmarkName,
              prefixIcon:
                  const Icon(Icons.place_outlined, color: AppColors.grey600),
            ),
          ),
          SizedBox(height: AppSpacing.vmd),
          CustomButton(
            label: AppStrings.save,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
