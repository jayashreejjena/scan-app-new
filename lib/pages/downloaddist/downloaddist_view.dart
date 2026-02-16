import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:odisha_air_map/navigators/navigators.dart';
import 'package:odisha_air_map/pages/downloaddist/downloaddist_controller.dart';
import 'package:odisha_air_map/utils/enum.dart';

class DistrictScreen extends StatefulWidget {
  const DistrictScreen({super.key});

  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  final List<District> districts = [
    District(
      name: 'Puri',
      status: DownloadStatus.downloading,
      progress: 0.45,
      image:
          'https://media.istockphoto.com/id/1069137628/photo/top-of-the-jagannath-temple-puri-odisha-india.jpg?s=612x612&w=0&k=20&c=QIj54CAlnD_CKzb1roAVms9f2fdWnqwOb3BMSMvbee4=',
    ),
    District(
      name: 'Khordha',
      status: DownloadStatus.completed,
      size: '',
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8mF6j6KHmSc6IvbqbW0M-DScWRuRwKP1C8g&s',
    ),
    District(
      name: 'Cuttack',
      status: DownloadStatus.notDownloaded,
      size: '',
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8mF6j6KHmSc6IvbqbW0M-DScWRuRwKP1C8g&s',
    ),
    District(
      name: 'Ganjam',
      status: DownloadStatus.notDownloaded,
      size: '',
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8mF6j6KHmSc6IvbqbW0M-DScWRuRwKP1C8g&s',
    ),
    District(
      name: 'Sambalpur',
      status: DownloadStatus.notDownloaded,
      size: '',
      image:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8mF6j6KHmSc6IvbqbW0M-DScWRuRwKP1C8g&s',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloaddistController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F9FD),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
            ),
            title: const Text(
              'Download District Content',
              style: TextStyle(
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for an Odisha district...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: districts.length,
                  itemBuilder: (context, index) =>
                      DistrictCard(district: districts[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DistrictCard extends StatelessWidget {
  final District district;
  const DistrictCard({super.key, required this.district});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: district.status == DownloadStatus.downloading
            ? Border.all(color: const Color(0xFF0D47A1), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    district.image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        district.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusSubtitle(),
                    ],
                  ),
                ),
                _buildActionWidget(),
              ],
            ),
            if (district.status == DownloadStatus.downloading) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: district.progress,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF0D47A1),
                  minHeight: 8,
                ),
              ),
            ],
            if (district.status == DownloadStatus.completed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    RouteManagement.goToScanner();
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Scan District'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D47A1),
                    backgroundColor: const Color(0xFFE3F2FD),
                    side: BorderSide.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSubtitle() {
    switch (district.status) {
      case DownloadStatus.downloading:
        return Text(
          'DOWNLOADING... ${(district.progress! * 100).toInt()}%',
          style: const TextStyle(
            color: Color(0xFF1976D2),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
      case DownloadStatus.completed:
        return Text(
          'Completed',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        );
      case DownloadStatus.notDownloaded:
        return Text(
          district.size ?? '',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        );
    }
  }

  Widget _buildActionWidget() {
    if (district.status == DownloadStatus.downloading) {
      return const Icon(Icons.cancel, color: Color(0xFF90CAF9));
    } else if (district.status == DownloadStatus.completed) {
      return const CircleAvatar(
        radius: 12,
        backgroundColor: Color(0xFFC8E6C9),
        child: Icon(Icons.check, size: 16, color: Color(0xFF2E7D32)),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download_outlined, size: 18),
        label: const Text('Download'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      );
    }
  }
}

class District {
  final String name;
  final DownloadStatus status;
  final String? size;
  final double? progress;
  final String image;

  District({
    required this.name,
    required this.status,
    this.size,
    this.progress,
    required this.image,
  });
}

class RoundedRectanglePlatform {
  static BorderRadius borderRadius(double r) => BorderRadius.circular(r);
}
