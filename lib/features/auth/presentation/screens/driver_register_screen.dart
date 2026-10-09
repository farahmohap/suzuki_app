import 'package:flutter/material.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final DriverRegistrationModel _formData = DriverRegistrationModel();

  // أحياء مدينة العبور للاختيار منها
  final List<String> _elObourDistricts = [
    'الحي الأول',
    'الحي الثاني',
    'الحي الخامس',
    'الحي السابع',
    'الحي التاسع',
    'المنطقة الصناعية',
    'العبور الجديدة',
    'حي الشباب',
    'الترانزيت / المحور الرئيسي',
  ];

  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131B2E)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'تسجيل سائق جديد',
          style: TextStyle(
            color: Color(0xFF131B2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF131B2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderBanner(),
              const SizedBox(height: 20),

              // 1. البيانات الشخصية
              _buildSectionCard(
                stepText: 'خطوة ١ من ٥',
                title: 'البيانات الشخصية',
                subtitle: 'الاسم ورقم الموبايل والتفاصيل الأساسية',
                icon: Icons.person_outline,
                child: _buildPersonalFields(),
              ),
              const SizedBox(height: 16),

              // 2. مستندات التوثيق
              _buildSectionCard(
                stepText: 'خطوة ٢ من ٥',
                title: 'المستندات الرسمية',
                subtitle: 'البطاقة الشخصية، الرخصة، والفيش والتشبيه',
                icon: Icons.verified_user_outlined,
                child: _buildDocumentsFields(),
              ),
              const SizedBox(height: 16),

              // 3. صور السيارة السوزوكي (قسم الصور المخصص)
              _buildSectionCard(
                stepText: 'خطوة ٣ من ٥',
                title: 'معرض صور السوزوكي',
                subtitle: 'التقط صوراً واضحة للسيارة والصالون الداخلي',
                icon: Icons.add_a_photo_outlined,
                child: _buildVehiclePhotosUpload(),
              ),
              const SizedBox(height: 16),

              // 4. بيانات اللوحة والفحص
              _buildSectionCard(
                stepText: 'خطوة ٤ من ٥',
                title: 'بيانات اللوحة والسيارة',
                subtitle: 'رقم اللوحة المعدنية وحالة الفحص',
                icon: Icons.directions_car_outlined,
                child: _buildPlateAndVehicleData(),
              ),
              const SizedBox(height: 16),

              // 5. نطاق العمل في مدينة العبور والتسوية المالية
              _buildSectionCard(
                stepText: 'خطوة ٥ من ٥',
                title: 'خط السير والمحفظة',
                subtitle: 'تحديد أحياء مدينة العبور ومحفظة استلام المستحقات',
                icon: Icons.alt_route_rounded,
                child: _buildZoneAndPaymentFields(),
              ),
              const SizedBox(height: 20),

              // الشروط والأحكام
              _buildTermsCheckbox(),
              const SizedBox(height: 16),

              // زر الإرسال
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00288E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _termsAccepted ? _submitRegistration : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إرسال طلب التسجيل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('🚀', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Header Banner Component
  Widget _buildHeaderBanner() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEA619).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: Color(0xFF684000)),
              SizedBox(width: 6),
              Text(
                'شريك نقل معتمد - مدينة العبور',
                style: TextStyle(
                  color: Color(0xFF684000),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تسجيل حساب سائق جديد',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'انضم لشبكة مواصلات مدينة العبور وأحيائها وابدأ استقبال الرحلات',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF757684)),
        ),
      ],
    );
  }

  // General Card Container
  Widget _buildSectionCard({
    required String stepText,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFDDE1FF),
                    child: Icon(icon, color: const Color(0xFF00288E), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757684),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stepText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF444653),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  // 1. Personal Fields
  Widget _buildPersonalFields() {
    return Column(
      children: [
        TextFormField(
          initialValue: 'محمد أحمد الشناوي',
          decoration: const InputDecoration(
            labelText: 'الاسم بالكامل (كما بالبطاقة)',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _formData.fullName = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: '01012345678',
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الموبايل',
            prefixIcon: Icon(Icons.phone_iphone),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _formData.phoneNumber = v,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: '34',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السن',
                  suffixText: 'سنة',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _formData.age = int.tryParse(v) ?? 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Gender>(
                value: _formData.gender,
                decoration: const InputDecoration(
                  labelText: 'النوع',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: Gender.male, child: Text('ذكر')),
                  DropdownMenuItem(value: Gender.female, child: Text('أنثى')),
                ],
                onChanged: (val) => setState(() => _formData.gender = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Documents Fields
  Widget _buildDocumentsFields() {
    return Column(
      children: [
        _buildDocumentUploadTile(
          'بطاقة الرقم القومي (الوجهان)',
          Icons.credit_card,
          isUploaded: true,
        ),
        const SizedBox(height: 8),
        _buildDocumentUploadTile(
          'رخصة القيادة (مهنية / خاصة)',
          Icons.contact_emergency,
          isUploaded: true,
        ),
        const SizedBox(height: 8),
        _buildDocumentUploadTile(
          'رخصة تسيير السوزوكي',
          Icons.drive_eta,
          isUploaded: true,
        ),
        const SizedBox(height: 8),
        _buildDocumentUploadTile(
          'صحيفة الحالة الجنائية (الفيش والتشبيه)',
          Icons.verified,
          isUploaded: false,
        ),
      ],
    );
  }

  Widget _buildDocumentUploadTile(
    String title,
    IconData icon, {
    required bool isUploaded,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00288E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          isUploaded
              ? const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'تم الرفع',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ],
                )
              : SizedBox(
                  width: 60,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {},
                    child: const Text('رفع', style: TextStyle(fontSize: 12)),
                  ),
                ),
        ],
      ),
    );
  }

  // 3. Vehicle Photos Section (الكاميرا والصور)
  Widget _buildVehiclePhotosUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التقط أو اختر صور السوزوكي الواضحة:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPhotoTile('الواجهة الأمامية', Icons.directions_car),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoTile(
                'الجهة الخلفية',
                Icons.directions_car_filled,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoTile(
                'الفرش الداخلي (٧ كراسي)',
                Icons.airline_seat_recline_normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoTile(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF00288E)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00288E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'التقاط',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Vehicle Plate Component
  Widget _buildPlateAndVehicleData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رقم اللوحة المعدنية (لوحة أجرة مصر):',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDAE2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEA619),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مـصــر',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'EGYPT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '٢ ٨ ٤ ٥',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30, child: VerticalDivider(thickness: 2)),
                    Text(
                      'ق ن ص',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. El-Obour Zones & Payment
  Widget _buildZoneAndPaymentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر أحياء مدينة العبور المفضل العمل بها:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: _elObourDistricts.map((district) {
            final isSelected = _formData.selectedElObourDistricts.contains(
              district,
            );
            return FilterChip(
              label: Text(
                district,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF00288E),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _formData.selectedElObourDistricts.add(district);
                  } else {
                    _formData.selectedElObourDistricts.remove(district);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: '01012345678',
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم محفظة كاش للتسويات المالية',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _formData.cashWalletNumber = v,
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (v) => setState(() => _termsAccepted = v ?? false),
        ),
        const Expanded(
          child: Text(
            'أوافق على الشروط والأحكام الخاصة بنقل الركاب داخل مدينة العبور',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري إرسال طلب تسجيل السائق في مدينة العبور...'),
        ),
      );
    }
  }
}
