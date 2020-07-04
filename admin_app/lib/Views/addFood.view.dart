import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:admin_app/Controllers/image.controller.dart';
import 'package:admin_app/utils/log.dart';

import './../Constants/dialog.dart';
import './../Constants/theme.dart' as theme;
import './../Controllers/category.controller.dart' as cateController;
import './../Controllers/food.controller.dart' as foodController;
import './../Models/category.model.dart' as cate;

class AddFoodScreen extends StatefulWidget {
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  Future<List<cate.Category>> categories = cateController.Controller.instance.categories;

  TextEditingController _idController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  cate.Category _category;

  File _image;

  @override
  Widget build(BuildContext context) {
    TextStyle _itemStyle = TextStyle(
        color: theme.fontColor,
        fontFamily: 'Dosis',
        fontSize: 16.0,
        fontWeight: FontWeight.w500);

    TextStyle _itemStyle2 = TextStyle(
        color: theme.accentColor,
        fontFamily: 'Dosis',
        fontSize: 18.0,
        fontWeight: FontWeight.w500);

    Widget avatar = Column(
      children: <Widget>[
        _image == null
            ? Image.asset(
                'assets/images/food.png',
                width: 122.0,
                height: 122.0,
                fit: BoxFit.fill,
              )
            : Image.file(
                _image,
                width: 122.0,
                height: 122.0,
                fit: BoxFit.fill,
              ),
        Container(
          height: 15.0,
        ),
        RaisedButton(
          color: Colors.lightBlueAccent,
          child: Text(
            'Select Image',
            style: _itemStyle,
          ),
          onPressed: () async {
            var image = await ImageController.getImageFromGallery();
            setState(() {
              _image = image;
            });
          },
        )
      ],
    );

    Widget id = TextField(
      enabled: false,
      controller: _idController,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Auto-ID:*', labelStyle: _itemStyle2),
    );

    Widget name = TextField(
      controller: _nameController,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Name:', labelStyle: _itemStyle2),
    );

    Widget category = Row(
      children: <Widget>[
        Text(
          'Category:  ',
          style: TextStyle(
              color: theme.accentColor,
              fontFamily: 'Dosis',
              fontSize: 13.0,
              fontWeight: FontWeight.w500),
        ),
        FutureBuilder<List<cate.Category>>(
          future: categories,
          builder: (context, snapshot) {
            if (snapshot.hasError) Log.error(snapshot.error);
            if (snapshot.hasData) {
              return _buildCategory(_itemStyle, snapshot.data);
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );

    Widget price = TextField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Price:', labelStyle: _itemStyle2),
    );

    Widget addFood = Container(
      margin: const EdgeInsets.only(top: 15.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: Colors.redAccent,
          child: Text(
            'Add Food',
            style: _itemStyle,
          ),
          onPressed: () {
            _createFood();
          },
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          avatar,
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Card(
              color: theme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[id, name, category, price, addFood],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _idController.text = ' ';
    super.initState();
  }

  Widget _buildCategory(TextStyle _itemStyle, List<cate.Category> categories) {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < categories.length; i++) {
      DropdownMenuItem item = DropdownMenuItem(
        value: categories[i],
        child: Text(
          categories[i].name,
          style: _itemStyle,
        ),
      );
      items.add(item);
    }

    return DropdownButton(
        value: _category,
        items: items,
        onChanged: (value) {
          setState(() {
            _category = value;
          });
        });
  }

  void _createFood() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm', style: theme.titleStyle),
            content: Text('Do you want to create  food?', style: theme.contentStyle),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok', style: theme.okButtonStyle),
                onPressed: () async {
                  /* Pop screens */
                  Navigator.of(context).pop();
                  if (_nameController.text.trim() != '' &&
                      _priceController.text.trim() != '' &&
                      _category.name.trim() != '') {
                    if (await foodController.Controller.instance.insertFood(
                        _nameController.text.trim(),
                        double.parse(_priceController.text.trim()),
                        _category.id,
                        _image != null ? base64Encode(_image.readAsBytesSync()) : '')) {
                      // reload foods
                      foodController.Controller.instance.insertFoodToLocal(
                          _nameController.text.trim(),
                          _category.id,
                          _category.name,
                          double.parse(_priceController.text.trim()),
                          _image != null ? base64Encode(_image.readAsBytesSync()) : '');

                      successDialog(this.context, 'Create food success!');
                      // clear data widget
                      _nameController.clear();
                      _priceController.clear();
                      setState(() {
                        _image = null;
                      });
                    } else
                      errorDialog(
                          this.context, 'Create  food failed.' + '\nPlease try again!');
                    return;
                  }
                  errorDialog(
                      this.context, 'Invalid infomations.' + '\nPlease try again!');
                },
              ),
              FlatButton(
                child: Text('Cancel', style: theme.cancelButtonStyle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
