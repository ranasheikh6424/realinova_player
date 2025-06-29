import 'package:permission_handler/permission_handler.dart';

class PermissionService{}

Future<bool> requestStorage() async{
  return await _request(Permission.storage);
}

Future<bool> requestManageExternalStoragr() async{
  return await _request(Permission.manageExternalStorage);
}

Future<bool> _request(Permission permission) async{
  final status = await permission.status;
  if(status.isGranted){
    return true;
  }
  final result = await permission.request();
  if(result.isGranted){
    return true;
  }
  else if(result.isPermanentlyDenied){
    openAppSettings();
  }else{
    print("${permission.toString()} denied");
  }
  return false;
}
