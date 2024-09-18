import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressEntry {
  final String label;
  final String address;

  AddressEntry({required this.label, required this.address});

  Map<String, dynamic> toJson() => {
    'label': label,
    'address': address,
  };

  factory AddressEntry.fromJson(Map<String, dynamic> json) => AddressEntry(
    label: json['label'],
    address: json['address'],
  );
}

abstract class AddressBook {
  Future<void> addEntry(AddressEntry entry);
  Future<void> updateEntry(String oldLabel, AddressEntry newEntry);
  Future<void> deleteEntry(String label);
  Future<AddressEntry?> getEntry(String label);
  Future<List<AddressEntry>> getAllEntries();
}

class SharedPreferencesAddressBook implements AddressBook {
  static const String _key = 'address_book';
  late SharedPreferences _prefs;

  SharedPreferencesAddressBook(SharedPreferences prefs) {
    _prefs = prefs;
  }

  Future<Map<String, AddressEntry>> _getAddressBook() async {
    final String? jsonString = _prefs.getString(_key);
    if (jsonString == null) return {};

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, AddressEntry.fromJson(value)));
  }

  Future<void> _saveAddressBook(Map<String, AddressEntry> addressBook) async {
    final jsonString = json.encode(addressBook.map((key, value) => MapEntry(key, value.toJson())));
    await _prefs.setString(_key, jsonString);
  }

  @override
  Future<void> addEntry(AddressEntry entry) async {
    final addressBook = await _getAddressBook();
    addressBook[entry.label] = entry;
    await _saveAddressBook(addressBook);
  }

  @override
  Future<void> updateEntry(String oldLabel, AddressEntry newEntry) async {
    final addressBook = await _getAddressBook();
    addressBook.remove(oldLabel);
    addressBook[newEntry.label] = newEntry;
    await _saveAddressBook(addressBook);
  }

  @override
  Future<void> deleteEntry(String label) async {
    final addressBook = await _getAddressBook();
    addressBook.remove(label);
    await _saveAddressBook(addressBook);
  }

  @override
  Future<AddressEntry?> getEntry(String label) async {
    final addressBook = await _getAddressBook();
    return addressBook[label];
  }

  @override
  Future<List<AddressEntry>> getAllEntries() async {
    final addressBook = await _getAddressBook();
    return addressBook.values.toList();
  }
}
