import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('name');
}
Future<String> updateName(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('name',name);
  Firestore.instance.document(await getDocumentPath()).updateData({
    'name': name
  });
}
Future<String> getDocumentPath() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('document_path');
}