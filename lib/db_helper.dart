import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  static final DBHelper instance = DBHelper._init();

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      unique_id TEXT,
      qr_code TEXT,
      id_card TEXT,
      selfie TEXT,
      name TEXT,
      email TEXT,
      razorpay_customer_id TEXT,
      age INTEGER,
      type_of_school TEXT,
      therapy_center_name TEXT,
      gender TEXT,
      child_name TEXT,
      dob TEXT,
      blood_group TEXT,
      total_family_income_per_month TEXT,
      address_address_line TEXT,
      address_street_address TEXT,
      address_city TEXT,
      address_state TEXT,
      address_postal_zipcode TEXT,
      type_of_disability TEXT,
      emergency_address_street TEXT,
      emergency_address_address_line TEXT,
      emergency_address_city TEXT,
      emergency_address_country TEXT,
      emergency_address_zipcode TEXT,
      emergency_phone TEXT,
      doctor_name TEXT,
      doctor_contact TEXT,
      height TEXT,
      participated_in_any_sport TEXT,
      help_us_understand_about_the_condition TEXT,
      address_country TEXT,
      primary_language TEXT,
      school_name TEXT,
      weight TEXT,
      bmi TEXT,
      secondary_language TEXT,
      udid_card_number TEXT,
      hospital_clinic_name TEXT,
      reffered_by TEXT,
      zoho_lead_id TEXT,
      fathers_id INTEGER,
      mothers_id INTEGER,
      notify_father INTEGER,
      notify_mother INTEGER,
      is_active INTEGER,
      center_location_id INTEGER,
      created_at TEXT,
      updated_at TEXT,
      source_location TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE payments(
      id INTEGER PRIMARY KEY,
      enrollment_id INTEGER,
      franchise_id INTEGER,
      amount TEXT,
      is_payment_modified INTEGER,
      old_amount TEXT,
      payment_link TEXT,
      order_id TEXT,
      payment_id TEXT,
      payment_gateway_object TEXT,
      payment_status TEXT,
      payment_date TEXT,
      payment_week TEXT,
      payment_month TEXT,
      created_at TEXT,
      updated_at TEXT,
      payment_screenshot TEXT,
      transaction_id TEXT,
      mode_of_payment TEXT,
      payment_received_by TEXT,
      cash TEXT,
      invoice_path TEXT,
      FOREIGN KEY (enrollment_id) REFERENCES enrollment (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE enrollment(
      id INTEGER PRIMARY KEY,
      student_id INTEGER,
      course_id INTEGER,
      session_id INTEGER,
      start_date TEXT,
      end_date TEXT,
      is_active INTEGER,
      created_at TEXT,
      updated_at TEXT,
      enrolled_at TEXT,
      franchise_id INTEGER,
      FOREIGN KEY (student_id) REFERENCES students (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE student_checkins(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      lat REAL,
      lng REAL,
      date TEXT,
      is_checked_in INTEGER,
      check_in_time TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (student_id) REFERENCES students (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE franchises(
      id INTEGER PRIMARY KEY,
      franchise_name TEXT,
      location_id INTEGER,
      franchise_owner_id INTEGER,
      created_at TEXT,
      updated_at TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE franchise_sessions(
      id INTEGER PRIMARY KEY,
      franchise_id INTEGER,
      session_name TEXT,
      start_time TEXT,
      end_time TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (franchise_id) REFERENCES franchises (id)
    )
    ''');
  }

  // CRUD methods for students table
  Future<void> insertStudent(Map<String, dynamic> student) async {
    final db = await instance.database;
    await db.insert('students', student, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return await db.query('students');
  }

  Future<void> updateStudent(Map<String, dynamic> student) async {
    final db = await instance.database;
    await db.update('students', student, where: 'id = ?', whereArgs: [student['id']]);
  }

  // CRUD methods for payments table
  Future<void> insertPayment(Map<String, dynamic> payment) async {
    final db = await instance.database;
    await db.insert('payments', payment, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPayments() async {
    final db = await instance.database;
    return await db.query('payments');
  }

  // CRUD methods for enrollment table
  Future<void> insertEnrollment(Map<String, dynamic> enrollment) async {
    final db = await instance.database;
    await db.insert('enrollment', enrollment, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEnrollments() async {
    final db = await instance.database;
    return await db.query('enrollment');
  }

  // CRUD methods for student_checkins table
  Future<void> insertStudentCheckIn(Map<String, dynamic> checkIn) async {
    final db = await instance.database;
    await db.insert('student_checkins', checkIn, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStudentCheckIns() async {
    final db = await instance.database;
    return await db.query('student_checkins');
  }

  Future<void> deleteStudentCheckIn(int id) async {
    final db = await instance.database;
    await db.delete('student_checkins', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD methods for franchises table
  Future<void> insertFranchise(Map<String, dynamic> franchise) async {
    final db = await instance.database;
    await db.insert('franchises', franchise, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFranchises() async {
    final db = await instance.database;
    return await db.query('franchises');
  }

  // CRUD methods for franchise_sessions table
  Future<void> insertFranchiseSession(Map<String, dynamic> session) async {
    final db = await instance.database;
    await db.insert('franchise_sessions', session, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFranchiseSessions(int franchiseId) async {
    final db = await instance.database;
    return await db.query('franchise_sessions', where: 'franchise_id = ?', whereArgs: [franchiseId]);
  }
}
