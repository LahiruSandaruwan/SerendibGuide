import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/attraction.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Widget to display and share QR code for an attraction
class QRCodeWidget extends StatelessWidget {
  final Attraction attraction;

  const QRCodeWidget({
    super.key,
    required this.attraction,
  });

  String _getAttractionUrl() {
    // Generate Google Maps URL for the attraction
    return Helpers.getDirectionsUrl(
      attraction.latitude,
      attraction.longitude,
    );
  }

  String _getQRData() {
    // Create a comprehensive QR data string
    return '''
${attraction.nameEn}
${attraction.category} in ${attraction.province}

Location: ${attraction.latitude}, ${attraction.longitude}
Map: ${_getAttractionUrl()}

Explore Sri Lanka with Serendib Guide
''';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share via QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showInfo(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: _getQRData(),
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                embeddedImage: const AssetImage('assets/images/logo/icon.png'),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Text(
              'Scan to view ${attraction.nameEn} on maps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copyUrl(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.deepOceanBlue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _shareQRCode(context),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.tropicalGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: AppConstants.tropicalGreen),
            SizedBox(width: 8),
            Text('QR Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This QR code contains:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoItem(Icons.place, 'Location name and details'),
            _buildInfoItem(Icons.map, 'GPS coordinates'),
            _buildInfoItem(Icons.directions, 'Google Maps link'),
            const SizedBox(height: 12),
            Text(
              'Anyone can scan this code to instantly get directions to ${attraction.nameEn}!',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppConstants.tropicalGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _copyUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _getAttractionUrl()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareQRCode(BuildContext context) {
    final shareText = '''
📍 ${attraction.nameEn}
${attraction.category} in ${attraction.province}, Sri Lanka

View on map: ${_getAttractionUrl()}

Shared from Serendib Guide - Your complete Sri Lanka travel companion
''';

    Share.share(shareText, subject: attraction.nameEn);
  }
}
