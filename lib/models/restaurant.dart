// Restaurant Model for Ikiraha Mobile Backend Integration

class Restaurant {
  final int id;
  final String uuid;
  final int ownerId;
  final int? categoryId;
  final String name;
  final String slug;
  final String? description;
  final String? logo;
  final String? coverImage;
  final String? phone;
  final String? email;
  final String? website;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final double deliveryRadius;
  final double minimumOrderAmount;
  final double deliveryFee;
  final int estimatedDeliveryTime;
  final double rating;
  final int totalReviews;
  final bool isFeatured;
  final bool isActive;
  final bool isOpen;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for display purposes
  final String? categoryName;
  final String? ownerName;

  Restaurant({
    required this.id,
    required this.uuid,
    required this.ownerId,
    this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    this.logo,
    this.coverImage,
    this.phone,
    this.email,
    this.website,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.deliveryRadius = 10.0,
    this.minimumOrderAmount = 0.0,
    this.deliveryFee = 0.0,
    this.estimatedDeliveryTime = 30,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.isOpen = true,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.ownerName,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      ownerId: json['owner_id'] ?? 0,
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      logo: json['logo'],
      coverImage: json['cover_image'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      city: json['city'] ?? '',
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      deliveryRadius: (json['delivery_radius'] ?? 10.0).toDouble(),
      minimumOrderAmount: (json['minimum_order_amount'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: json['estimated_delivery_time'] ?? 30,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      isOpen: json['is_open'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      categoryName: json['category_name'],
      ownerName: json['owner_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'owner_id': ownerId,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'logo': logo,
      'cover_image': coverImage,
      'phone': phone,
      'email': email,
      'website': website,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_radius': deliveryRadius,
      'minimum_order_amount': minimumOrderAmount,
      'delivery_fee': deliveryFee,
      'estimated_delivery_time': estimatedDeliveryTime,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_featured': isFeatured,
      'is_active': isActive,
      'is_open': isOpen,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category_name': categoryName,
      'owner_name': ownerName,
    };
  }

  // Helper methods for display
  String get fullAddress {
    final parts = [addressLine1, addressLine2, city, state, postalCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get shortAddress {
    return '$city, $country';
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (!isOpen) return 'Closed';
    return 'Open';
  }

  String get ratingText {
    return '$rating ($totalReviews reviews)';
  }

  // Copy with method for updates
  Restaurant copyWith({
    int? id,
    String? uuid,
    int? ownerId,
    int? categoryId,
    String? name,
    String? slug,
    String? description,
    String? logo,
    String? coverImage,
    String? phone,
    String? email,
    String? website,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    double? deliveryRadius,
    double? minimumOrderAmount,
    double? deliveryFee,
    int? estimatedDeliveryTime,
    double? rating,
    int? totalReviews,
    bool? isFeatured,
    bool? isActive,
    bool? isOpen,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? ownerName,
  }) {
    return Restaurant(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      ownerId: ownerId ?? this.ownerId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}

// Restaurant Category Model
class RestaurantCategory {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantCategory({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantCategory.fromJson(Map<String, dynamic> json) {
    return RestaurantCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
