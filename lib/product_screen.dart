import 'package:database_app/product.dart';
import 'package:database_app/product_db_helper.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<Product> productList = [];

  late Product _selectedProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ProductDBHelper.instance.getProductsList().then((value){
      setState(() {
        productList = value;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: productList.length,
                    itemBuilder: (BuildContext context, index){
                      if(productList.isNotEmpty){
                        return GestureDetector(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  spreadRadius: 3,
                                  color: Colors.grey.withOpacity(0.2)
                                )
                              ]
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.all_inbox),
                              title: Text(productList[index].name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('AED ${productList[index].price}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              trailing: Container(
                                width: 100,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  children: [
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            _selectedProduct = productList[index];
                                            showProductDialogBox(context, InputType.UpdateProduct);
                                          });
                                        },
                                        icon: Icon(Icons.edit),
                                    ),
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            _selectedProduct = productList[index];
                                          });
                                          ProductDBHelper.instance.deleteProduct(_selectedProduct).then((value){
                                            ProductDBHelper.instance.getProductsList().then((value){
                                              setState(() {
                                                productList = value;
                                              });
                                            });
                                          });
                                        },
                                        icon: Icon(Icons.delete, color: Colors.red,)
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }else{
                        return Container(
                          child: const Center(
                            child: Text('List is Empty'),
                          ),
                        );
                      }
                    }
                )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _emptyTextFields();
          showProductDialogBox(context, InputType.AddProduct);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  showProductDialogBox(BuildContext context, InputType type){

    bool isUpdateProduct = false;

    isUpdateProduct = (type == InputType.UpdateProduct) ? true : false;

    if(isUpdateProduct){

      _nameController.text = _selectedProduct.name;
      _priceController.text = _selectedProduct.price;
      _quantityController.text = _selectedProduct.quantity.toString();

    }

    Widget saveButton = TextButton(
        onPressed: (){
          if(_nameController.text.isNotEmpty && _priceController.text.isNotEmpty && _quantityController.text.isNotEmpty){
            Product product = Product(id: 1, name: '', price: '', quantity: 0);
            product.name = _nameController.text;
            product.price = _priceController.text;
            product.quantity = int.parse(_quantityController.text);

            if(!isUpdateProduct){
              setState(() {
                ProductDBHelper.instance.insertProduct(product).then((value){
                  ProductDBHelper.instance.getProductsList().then((value){
                    setState(() {
                      productList = value;
                    });
                  });
                  Navigator.pop(context);
                  _emptyTextFields();
                });
              });
            }else{
              setState(() {

                _selectedProduct.name = _nameController.text;
                _selectedProduct.price = _priceController.text;
                _selectedProduct.quantity = int.parse(_quantityController.text);

                ProductDBHelper.instance.updateProduct(_selectedProduct).then((value){

                  //Refresh products list
                  ProductDBHelper.instance.getProductsList().then((value){
                    setState(() {
                      productList = value;
                    });
                  });
                  Navigator.pop(context);
                  _emptyTextFields();
                });
              });
            }
          }
        },
        child: Text('Save'));

    Widget cancelButton = TextButton(
        onPressed: (){
          Navigator.of(context).pop();
        }, 
        child: Text('Cancel'));

    AlertDialog productDetailsBox = AlertDialog(
      title: Text(!isUpdateProduct ? 'Add new product' : 'Update Product'),
      content: Container(
        child: Wrap(
          children: [
            Container(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name'
                ),
              ),
            ),
            Container(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'Price'
                ),
              ),
            ),
            Container(
              child: TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                    labelText: 'Quantity'
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        saveButton,
        cancelButton
      ],
    );
    showDialog(context: context, builder: (BuildContext context){
      return productDetailsBox;
    });
  }

  void _emptyTextFields(){
    _nameController.text = '';
    _priceController.text = '';
    _quantityController.text = '';
  }
}

enum InputType {AddProduct, UpdateProduct}
