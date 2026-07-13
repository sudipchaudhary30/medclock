import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_code_provider.dart';

class QrCodePainter extends CustomPainter {
  final String qrData;

  QrCodePainter(this.qrData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F6D95)
      ..style = PaintingStyle.fill;

    final double pixelSize = size.width / 21; // 21x21 QR Grid

    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, pixelSize * 7, pixelSize * 7), paint);
      canvas.drawRect(
        Rect.fromLTWH(
          x + pixelSize,
          y + pixelSize,
          pixelSize * 5,
          pixelSize * 5,
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          x + pixelSize * 2,
          y + pixelSize * 2,
          pixelSize * 3,
          pixelSize * 3,
        ),
        paint,
      );
    }

    // Corners
    drawFinderPattern(0, 0);
    drawFinderPattern((21 - 7) * pixelSize, 0);
    drawFinderPattern(0, (21 - 7) * pixelSize);

    // Timing lines
    for (int i = 8; i < 21 - 8; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(pixelSize * 6, pixelSize * i, pixelSize, pixelSize),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(pixelSize * i, pixelSize * 6, pixelSize, pixelSize),
          paint,
        );
      }
    }

    // Pseudo-random data blocks
    final int hash = qrData.hashCode;
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if ((r < 8 && c < 8) ||
            (r < 8 && c >= 21 - 8) ||
            (r >= 21 - 8 && c < 8)) {
          continue;
        }
        if (r == 6 || c == 6) {
          continue;
        }
        final int val = (r * 37 + c * 17 + hash) % 100;
        if (val < 45) {
          canvas.drawRect(
            Rect.fromLTWH(c * pixelSize, r * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QrLinkScreen extends ConsumerStatefulWidget {
  const QrLinkScreen({super.key});

  @override
  ConsumerState<QrLinkScreen> createState() => _QrLinkScreenState();
}

class _QrLinkScreenState extends ConsumerState<QrLinkScreen> {
  bool _allowAccess = true;
  bool _allowRefills = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      final userId = user?.id ?? 'MC-8829-NP';
      final userName = user?.name ?? 'Animesh Prasad';
      if (ref.read(syncCodeProvider) == null) {
        ref.read(syncCodeProvider.notifier).generateCode(userId, userName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final syncCodeInfo = ref.watch(syncCodeProvider);
    final String userId = user?.id ?? 'MC-8829-NP';
    final String userName = user?.name ?? 'Animesh Prasad';
    final String code = syncCodeInfo?.code ?? '';
    final String encodedName = Uri.encodeComponent(userName);
    final String userQrData =
        'medclock://invite/caregiver?patientId=$userId&patientName=$encodedName&code=$code&meds=$_allowAccess&refills=$_allowRefills';

    if (user?.isCaregiver == true) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: true,
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Text('Only patients can generate a caregiver sync code.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F1E24)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Share with your caregiver',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F1E24),
            fontFamily: 'serif',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.profile),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBDCDD),
                    width: 1.5,
                  ),
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF536A73),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
        shape: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 0.8,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. QR Code Card Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Mock QR layout frame
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE5EFF2),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              4,
                              (index) => Container(
                                width: 40,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5EFF2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF0F1E24),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F6D95,
                                  ).withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              size: const Size(160, 160),
                              painter: QrCodePainter(userQrData),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Caregiver scans this code to sync',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF536A73),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Expiration Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F3EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Color(0xFFD35400),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'QR code expires in 24 hours',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD35400),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Permissions Section Header
              const Text(
                'Permissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F1E24),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),

              // 4. Permissions Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _allowAccess,
                      title: const Text(
                        'Allow access to medication list',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F1E24),
                        ),
                      ),
                      subtitle: const Text(
                        'REQUIRED FOR SYNC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9AA7B3),
                          letterSpacing: 0.5,
                        ),
                      ),
                      activeColor: const Color(0xFF0F6D95),
                      onChanged: (val) {
                        setState(() {
                          _allowAccess = val ?? true;
                        });
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    CheckboxListTile(
                      value: _allowRefills,
                      title: const Text(
                        'Allow refill alerts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F1E24),
                        ),
                      ),
                      subtitle: const Text(
                        'SYNC NOTIFICATION DATA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9AA7B3),
                          letterSpacing: 0.5,
                        ),
                      ),
                      activeColor: const Color(0xFF0F6D95),
                      onChanged: (val) {
                        setState(() {
                          _allowRefills = val ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 5. Share Button
              ElevatedButton.icon(
                onPressed: () => _showShareSheet(context, userQrData, userName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6B94),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text(
                  'Share QR Code',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, String qrData, String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DBDF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Row(
                children: const [
                  Text(
                    'Share Link',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F1E24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Link Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        qrData,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF536A73),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: qrData));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: const Text('Invitation link copied!'),
                            backgroundColor: const Color(0xFF0F6D95),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6DBDF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Color(0xFF536A73),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Contacts Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildContactItem(
                    name: 'Sofia',
                    avatarColor: const Color(0xFFE78F68),
                    badgeIcon: Icons.chat_bubble_rounded,
                    badgeColor: const Color(0xFF25D366),
                    onTap: () => _mockShareApp(context, 'WhatsApp', userName),
                  ),
                  _buildContactItem(
                    name: 'Lucas',
                    avatarColor: const Color(0xFF4A89DC),
                    badgeIcon: Icons.chat_bubble_rounded,
                    badgeColor: const Color(0xFF25D366),
                    onTap: () => _mockShareApp(context, 'WhatsApp', userName),
                  ),
                  _buildContactItem(
                    name: 'Ana',
                    avatarColor: const Color(0xFF4FC1E9),
                    badgeIcon: Icons.work_rounded,
                    badgeColor: const Color(0xFF0077B5),
                    onTap: () => _mockShareApp(context, 'LinkedIn', userName),
                  ),
                  _buildContactItem(
                    name: 'Pedro',
                    avatarColor: const Color(0xFFAC92EC),
                    badgeIcon: Icons.camera_alt_rounded,
                    badgeColor: const Color(0xFFE1306C),
                    onTap: () => _mockShareApp(context, 'Instagram', userName),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Apps Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAppItem(
                    label: 'WhatsApp',
                    iconColor: const Color(0xFF25D366),
                    icon: Icons.chat_bubble_rounded,
                    onTap: () => _mockShareApp(context, 'WhatsApp', userName),
                  ),
                  _buildAppItem(
                    label: 'Gmail',
                    iconColor: const Color(0xFFEA4335),
                    icon: Icons.mail_rounded,
                    onTap: () => _mockShareApp(context, 'Gmail', userName),
                  ),
                  _buildAppItem(
                    label: 'Instagram',
                    iconColor: const Color(0xFFE1306C),
                    icon: Icons.camera_alt_rounded,
                    onTap: () => _mockShareApp(context, 'Instagram', userName),
                  ),
                  _buildAppItem(
                    label: 'Facebook',
                    iconColor: const Color(0xFF1877F2),
                    icon: Icons.facebook_rounded,
                    onTap: () => _mockShareApp(context, 'Facebook', userName),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F4F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F1E24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem({
    required String name,
    required Color avatarColor,
    required IconData badgeIcon,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor,
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(badgeIcon, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF536A73),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppItem({
    required String label,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF536A73),
            ),
          ),
        ],
      ),
    );
  }

  void _mockShareApp(BuildContext context, String appName, String userName) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully shared code via $appName!'),
        backgroundColor: const Color(0xFF0F6D95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
