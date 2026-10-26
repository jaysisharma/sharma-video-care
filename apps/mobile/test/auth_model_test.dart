import 'package:flutter_test/flutter_test.dart';
import 'package:sharma_video_care_mobile/models/models.dart';

void main() {
  group('UserModel Production Auth Tests', () {
    test('UserModel.fromFirestore parses full data correctly', () {
      final docData = {
        'name': 'Gita Sharma',
        'email': 'gita@example.com',
        'phone': '+977-9801234567',
        'role': 'customer',
        'status': 'ACTIVE',
        'createdAt': '2026-10-19T10:00:00.000Z',
      };

      final user = UserModel.fromFirestore('user-uid-123', docData);

      expect(user.id, 'user-uid-123');
      expect(user.name, 'Gita Sharma');
      expect(user.email, 'gita@example.com');
      expect(user.phone, '+977-9801234567');
      expect(user.role, 'customer');
      expect(user.technicianType, isNull);
      expect(user.status, 'ACTIVE');
      expect(user.createdAt.year, 2026);
    });

    test('UserModel.fromFirestore handles partial and fallback fields gracefully', () {
      final docData = <String, dynamic>{};
      final user = UserModel.fromFirestore('fallback-uid', docData);

      expect(user.id, 'fallback-uid');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.phone, '');
      expect(user.role, 'customer');
      expect(user.status, 'ACTIVE');
    });

    test('UserModel.toMap serializes fields for Firestore storage', () {
      final now = DateTime(2026, 10, 19, 12, 0);
      final user = UserModel(
        id: 'tech-001',
        name: 'Bikash Jha',
        email: 'bikash@sharmavideocare.com',
        phone: '+977-9844001122',
        role: 'technician',
        technicianType: 'INTERNAL',
        status: 'ACTIVE',
        createdAt: now,
      );

      final map = user.toMap();

      expect(map['id'], 'tech-001');
      expect(map['name'], 'Bikash Jha');
      expect(map['email'], 'bikash@sharmavideocare.com');
      expect(map['phone'], '+977-9844001122');
      expect(map['role'], 'technician');
      expect(map['technicianType'], 'INTERNAL');
      expect(map['status'], 'ACTIVE');
      expect(map['createdAt'], now.toIso8601String());
    });

    test('UserModel.copyWith updates specified fields only', () {
      final user = UserModel(
        id: 'cust-1',
        name: 'Original Name',
        email: 'orig@example.com',
        phone: '+977-9800000000',
        role: 'customer',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = user.copyWith(
        name: 'Updated Name',
        phone: '+977-9811111111',
      );

      expect(updated.id, 'cust-1');
      expect(updated.name, 'Updated Name');
      expect(updated.email, 'orig@example.com');
      expect(updated.phone, '+977-9811111111');
      expect(updated.role, 'customer');
    });
  });

  group('UserAddress & RegisteredGear Production Models', () {
    test('UserAddress serialization and default toggle works correctly', () {
      const address = UserAddress(
        id: 'addr-1',
        label: 'Janakpur Studio',
        fullAddress: 'Station Road, Bhanu Chowk',
        city: 'Janakpurdham',
        phone: '+977-9801234567',
        isDefault: true,
      );

      final map = address.toMap();
      final fromMap = UserAddress.fromMap(map);

      expect(fromMap.id, 'addr-1');
      expect(fromMap.label, 'Janakpur Studio');
      expect(fromMap.fullAddress, 'Station Road, Bhanu Chowk');
      expect(fromMap.city, 'Janakpurdham');
      expect(fromMap.phone, '+977-9801234567');
      expect(fromMap.isDefault, true);

      final modified = fromMap.copyWith(isDefault: false);
      expect(modified.isDefault, false);
      expect(modified.label, 'Janakpur Studio');
    });

    test('RegisteredGear serialization and copyWith works correctly', () {
      final now = DateTime(2026, 10, 19, 14, 0);
      final gear = RegisteredGear(
        id: 'gear-101',
        brand: 'SONY',
        model: 'Alpha A7 IV Mirrorless Body',
        serialNumber: 'SN-4920148',
        warrantyStatus: 'Active Lab Warranty',
        registeredAt: now,
      );

      final map = gear.toMap();
      final fromMap = RegisteredGear.fromMap(map);

      expect(fromMap.id, 'gear-101');
      expect(fromMap.brand, 'SONY');
      expect(fromMap.model, 'Alpha A7 IV Mirrorless Body');
      expect(fromMap.serialNumber, 'SN-4920148');
      expect(fromMap.warrantyStatus, 'Active Lab Warranty');
      expect(fromMap.registeredAt, now);
    });
  });
}

