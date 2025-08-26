class ActiveSidechain {
  /// Null if sidechain is not yet assigned a slot, i.e. activated
  final int? slot;
  final String title;
  final String description;
  final int nversion;
  final String hashid1;
  final String hashid2;

  ActiveSidechain({
    this.slot,
    required this.title,
    required this.description,
    required this.nversion,
    this.hashid1 = '0000000000000000000000000000000000000000000000000000000000000000',
    this.hashid2 = '0000000000000000000000000000000000000000',
  });

  factory ActiveSidechain.fromJson(Map<String, dynamic> json) {
    return ActiveSidechain(
      slot: json['nSidechain'],
      title: json['title'],
      description: json['description'] ?? '', // Assuming empty string for null values
      // first one is for createsidechainproposal, second is for listactivesidechains...
      nversion: json['version'] ?? json['nversion'],
      hashid1: json['hashID1'] ?? json['hashid1'],
      hashid2: json['hashID2'] ?? json['hashid2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nSidechain': slot,
      'title': title,
      'description': description,
      'nversion': nversion,
      'hashid1': hashid1,
      'hashid2': hashid2,
    };
  }
}
