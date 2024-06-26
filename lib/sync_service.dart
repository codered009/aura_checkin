import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'db_helper.dart';

class SyncService {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> synchronizeData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      await _fetchAndStoreData();
      await _sendLocalDataToServer();
    }
  }

  Future<void> _fetchAndStoreData() async {
    await _fetchStudents();
    await _fetchEnrollments();
    await _fetchPayments();
    await _fetchAndStoreSessions();
  }

 Future<void> _fetchStudents() async {
  final response = await http.get(Uri.parse('https://api.web.ableaura.com/academy/student/all'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData.containsKey('data') && responseData['data'] is List) {
      final List<dynamic> students = responseData['data'];
      for (var student in students) {
        await dbHelper.insertStudent({
          'id': student['id'],
          'unique_id': student['unique_id'],
          'qr_code': student['qr_code'],
          'id_card': student['id_card'],
          'selfie': student['selfie'],
          'name': student['name'],
          'email': student['email'],
          'razorpay_customer_id': student['razorpay_customer_id'],
          'age': student['age'],
          'type_of_school': student['type_of_school'],
          'therapy_center_name': student['therapy_center_name'],
          'gender': student['gender'],
          'child_name': student['child_name'],
          'dob': student['dob'],
          'blood_group': student['blood_group'],
          'total_family_income_per_month': student['total_family_income_per_month'],
          'address_address_line': student['address_address_line'],
          'address_street_address': student['address_street_address'],
          'address_city': student['address_city'],
          'address_state': student['address_state'],
          'address_postal_zipcode': student['address_postal_zipcode'],
          'type_of_disability': student['type_of_disability'],
          'emergency_address_street': student['emergency_address_street'],
          'emergency_address_address_line': student['emergency_address_address_line'],
          'emergency_address_city': student['emergency_address_city'],
          'emergency_address_country': student['emergency_address_country'],
          'emergency_address_zipcode': student['emergency_address_zipcode'],
          'emergency_phone': student['emergency_phone'],
          'doctor_name': student['doctor_name'],
          'doctor_contact': student['doctor_contact'],
          'height': student['height'],
          'participated_in_any_sport': student['participated_in_any_sport'],
          'help_us_understand_about_the_condition': student['help_us_understand_about_the_condition'],
          'address_country': student['address_country'],
          'primary_language': student['primary_language'],
          'school_name': student['school_name'],
          'weight': student['weight'],
          'bmi': student['bmi'],
          'secondary_language': student['secondary_language'],
          'udid_card_number': student['udid_card_number'],
          'hospital_clinic_name': student['hospital_clinic_name'],
          'reffered_by': student['reffered_by'],
          'zoho_lead_id': student['zoho_lead_id'],
          'fathers_id': student['fathers_id'],
          'mothers_id': student['mothers_id'],
          'notify_father': student['notify_father'],
          'notify_mother': student['notify_mother'],
          'is_active': student['is_active'],
          'center_location_id': student['center_location_id'],
          'created_at': student['created_at'],
          'updated_at': student['updated_at'],
          'source_location': student['source_location'],
        });
      }
    }
  }
}

Future<void> _fetchAndStoreSessions() async {
    final response = await http.get(Uri.parse('https://api.web.ableaura.com/academy/franchise/sessions/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final List<dynamic> franchiseSessions = responseData['data'];
        for (var session in franchiseSessions) {
          final franchise = session['franchise'];
          
          await dbHelper.insertFranchise({
            'id': franchise['id'],
            'franchise_name': franchise['franchise_name'],
            'location_id': franchise['location_id'],
            'franchise_owner_id': franchise['franchise_owner_id'],
            'created_at': franchise['created_at'],
            'updated_at': franchise['updated_at'],
          });

          await dbHelper.insertFranchiseSession({
            'id': session['id'],
            'franchise_id': session['franchise_id'],
            'session_name': session['name'],
            'start_time': session['start_time'],
            'end_time': session['end_time'],
            'created_at': session['created_at'],
            'updated_at': session['updated_at'],
          });
        }
      }
    }
  }

   Future<void> _fetchEnrollments() async {
    final response = await http.get(Uri.parse('https://api.web.ableaura.com/academy/enrollments/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final List<dynamic> enrollments = responseData['data'];
        for (var enrollment in enrollments) {
          await dbHelper.insertEnrollment({
            'id': enrollment['id'],
            'student_id': enrollment['student_id'],
            'course_id': enrollment['course_id'],
            'session_id': enrollment['session_id'],
            'start_date': enrollment['start_date'],
            'end_date': enrollment['end_date'],
            'is_active': enrollment['is_active'],
            'created_at': enrollment['created_at'],
            'updated_at': enrollment['updated_at'],
            'enrolled_at': enrollment['enrolled_at'],
            'franchise_id': enrollment['franchise_id'],
          });
        }
      }
    }
  }


  Future<void> _fetchPayments() async {
    final response = await http.get(Uri.parse('https://api.web.ableaura.com/academy/payments/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final List<dynamic> payments = responseData['data'];
        for (var payment in payments) {
          await dbHelper.insertPayment({
            'id': payment['id'],
            'enrollment_id': payment['enrollment_id'],
            'franchise_id': payment['franchise_id'],
            'amount': payment['amount'],
            'is_payment_modified': payment['is_payment_modified'],
            'old_amount': payment['old_amount'],
            'payment_link': payment['payment_link'],
            'order_id': payment['order_id'],
            'payment_id': payment['payment_id'],
            'payment_gateway_object': payment['payment_gateway_object'],
            'payment_status': payment['payment_status'],
            'payment_date': payment['payment_date'],
            'payment_week': payment['payment_week'],
            'payment_month': payment['payment_month'],
            'created_at': payment['created_at'],
            'updated_at': payment['updated_at'],
            'payment_screenshot': payment['payment_screenshot'],
            'transaction_id': payment['transaction_id'],
            'mode_of_payment': payment['mode_of_payment'],
            'payment_received_by': payment['payment_received_by'],
            'cash': payment['cash'],
            'invoice_path': payment['invoice_path'],
          });
        }
      }
    }
  }

  Future<void> _sendLocalDataToServer() async {
    final List<Map<String, dynamic>> checkins = await dbHelper.getStudentCheckIns();
    for (var checkin in checkins) {
      final response = await http.post(
        Uri.parse('https://api.web.ableaura.com/academy/students/checkin/entry'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': checkin['student_id'],
          'latitude': checkin['lat'],
          'longitude': checkin['lng'],
          'check_in_time': checkin['check_in_time'],
        }),
      );

      if (response.statusCode == 200) {
        await dbHelper.deleteStudentCheckIn(checkin['id']);
      }
    }
  }
}