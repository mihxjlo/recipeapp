class Category {
  final String idCategory;
  final String strCategory;
  final String strCategoryThumb;
  final String strCategoryDescription;

  Category({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryDescription,
    required this.strCategoryThumb,
});

  factory Category.fromJson(Map<String,dynamic> json) {
    return Category(
        idCategory: json['idCategory'] ?? '',
        strCategory: json['strCategory'] ?? '',
        strCategoryDescription: json['strCategoryDescription'] ?? '',
        strCategoryThumb: json['strCategoryThumb'] ?? '',
    );
  }


  Map<String,dynamic> toJson(){
    return {
      'idCategory': idCategory,
      'strCategory': strCategory,
      'strCategoryDescription': strCategoryDescription,
      'strCategoryThumb': strCategoryThumb,
    };
  }
}