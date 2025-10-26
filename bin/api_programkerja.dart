import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../bin/data_programkerja.dart';

DateTime _getStartDate(String dateRange) {
  try {
    final parts = dateRange.split(' s.d. ');
    return DateTime.parse(parts.first.trim());
  } catch (_) {
    return DateTime(3000);
  }
}

String getStatusFromDate(String dateRange) {
  final now = DateTime.now();
  try {
    final parts = dateRange.split(' s.d. ');
    final startDate = DateTime.parse(parts.first.trim());
    final endDate = (parts.length > 1)
        ? DateTime.parse(parts.last.trim())
        : startDate;

    if (now.isBefore(startDate)) {
      return "Akan Datang";
    } else if (now.isAfter(endDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)))) {
      return "Selesai";
    } else {
      return "Sedang Berlangsung";
    }
  } catch (_) {
    return "Tidak Diketahui";
  }
}

Response _programHandler(Request request) {
  final programsToSort = List<Map<String, dynamic>>.from(programList);
  programsToSort.sort((a, b) {
    final dateA = _getStartDate(a['date']);
    final dateB = _getStartDate(b['date']);
    return dateA.compareTo(dateB);
  });

  final enrichedPrograms = programsToSort.map((p) {
    final status = getStatusFromDate(p['date']);
    return {
      ...p,
      'status': status,
      'is_active': status == "Sedang Berlangsung",
    };
  }).toList();

  return Response.ok(
    jsonEncode(enrichedPrograms),
    headers: {
      'content-type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type',
    },
  );
}

final _router = Router()..get('/programs', _programHandler);

void main(List<String> args) async {
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);

  print(
    '✅ Server API berjalan di http://${server.address.host}:${server.port}',
  );
  print('📡 Endpoint data: http://127.0.0.1:8080/programs');
}