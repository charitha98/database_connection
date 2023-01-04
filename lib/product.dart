class Product{

  late int id;
  late String name;
  late String price;
  late int quantity;

  Product({required this.id, required this.name, required this.price, required this.quantity});

  //From Map to product object
  static Product fromMap(Map<dynamic, dynamic> query){
    Product product = Product(id: 0, name: '', price: '', quantity: 0);
    product.id = query['id'];
    product.name = query['name'];
    product.price = query['price'];
    product.quantity = query['quantity'];
    return product;
  }

  //Product to map
  static Map<String, dynamic> toMap(Product product){
    return <String, dynamic>{
      'id' : product.id,
      'name' : product.name,
      'price' : product.price,
      'quantity' : product.quantity,
    };
  }

  //From map list to product list
  static List<Product>  fromMapList(List<Map<dynamic, dynamic>> query){
    List<Product> products = <Product>[];
    for(Map mp in query){
      products.add(fromMap(mp));
    }
    return products;
  }

}