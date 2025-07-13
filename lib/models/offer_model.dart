class OfferModel {
   final int id;
   final String price;
   final String? description;
   final List<String> imagesUrls;
   final String status;
   final DateTime createdAt;
   final String? agentName;
   final String? agentPhoto;
   final int? dealId;
   final String? dealStatus;
 
   OfferModel({
     required this.id,
     required this.price,
     this.description,
     required this.imagesUrls,
     required this.status,
     required this.createdAt,
     this.agentName,
     this.agentPhoto,
     this.dealId,
     this.dealStatus,
   });
 
   factory OfferModel.fromJson(Map<String, dynamic> json) {
     return OfferModel(
       id: json['id'],
       price: json['price'],
       description: json['description'],
       imagesUrls: json['images_urls'] != null ? List<String>.from(json['images_urls']) : [],
       status: json['status'],
       createdAt: DateTime.parse(json['created_at']),
       agentName: json['agent_name'],
       agentPhoto: json['agent_photo'],
       dealId: json['deal_id'],
       dealStatus: json['deal_status'],
     );
   }
 }