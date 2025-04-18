import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class EntryViewModel extends ChangeNotifier {
  // 상태 변수들
  File? selectedFile;
  String fileName = '';
  bool isLoading = false;
  String fileContent = '';
  String status = '';

  // 생성자
  EntryViewModel() {
    _initialize();
  }

  // 초기화 메서드
  Future<void> _initialize() async {
    // 초기화 작업이 필요하면 여기에 구현
    // 예: 저장된 설정 불러오기, 초기 상태 설정 등
    debugPrint('EntryViewModel initialized');
  }

  // 파일 선택 함수
  Future<void> pickTextFile() async {
    isLoading = true;
    status = '파일 선택 중...';
    notifyListeners();

    try {
      // TXT 파일만 선택 가능하도록 설정
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        selectedFile = File(result.files.single.path!);
        fileName = path.basename(selectedFile!.path);

        status = '파일 선택됨: $fileName';
        notifyListeners();

        // TXT 파일 내용 읽기
        fileContent = await selectedFile!.readAsString();
        status = '텍스트 파일 읽기 완료';
      } else {
        // 사용자가 파일 선택을 취소한 경우
        status = '파일 선택이 취소되었습니다.';
      }
    } catch (e) {
      status = '오류 발생: $e';
      fileContent = '';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 상태 초기화
  void resetState() {
    selectedFile = null;
    fileName = '';
    fileContent = '';
    status = '';
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // 리소스 해제가 필요한 경우 여기에 구현
    super.dispose();
  }
}