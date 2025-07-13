
class RequestModel {
  final int id;
  final String title;
  final String? description;
  final String? city;
  final String? country;
  final String? price; 
  final String status;
  final DateTime createdAt;
  final String? investorName;
  final String? investorPhoto;

  RequestModel({
    required this.id,
    required this.title,
    this.description,
    this.city,
    this.country,
    this.price,
    required this.status,
    required this.createdAt,
    this.investorName,
    this.investorPhoto,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      city: json['city'],
      country: json['country'],
      price: json['price'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      investorName: json['investor_name'],
      investorPhoto: json['investor_photo'],
    );
  }
}