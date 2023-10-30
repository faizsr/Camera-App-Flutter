import 'dart:io';

import 'package:camera_app_flutter/functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

File? selectedImage;
List<Map<String, dynamic>> imageList = [];

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    initializeSelectedImage();

    super.initState();
  }

  Future<void> initializeSelectedImage() async {
    File? returnImage = await getImageFromCamera(context);
    if (returnImage != null) {
      insertImagetoDatabase(returnImage.path);
    }
    fetchImage();
  }

  Future<void> fetchImage() async {
    List<Map<String, dynamic>> listFroDatabase = await getImageFromDatabase();
    setState(() {
      imageList = listFroDatabase;
    });
  }

  Future<File?> getImageFromCamera(BuildContext context) async {
    File? image;
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        image = File(pickedImage
            .path); // Change this line to add the picked image to the list
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, e.toString(), Colors.red);
    }
    return image;
  }

  void showSnackbar(BuildContext context, String content, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== Appbar =====
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          'Gallery',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              initializeSelectedImage();
            },
            icon: const Icon(Icons.arrow_back_outlined)),
        backgroundColor: Colors.brown[400],
      ),

      // ===== Body =====
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            final imageMap = imageList[index];
            final fileImage = File(imageMap['imageSrc']);
            final id = imageMap['id'];
            return Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Image.file(
                          fileImage,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  children: [

                    // ===== Gallery Image =====
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Image.file(
                          fileImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {

                            // ===== Dialog Box =====
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: const Text(
                                    'Do you want to delete?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'No',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await deleteImageFromDatabase(id);
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop();
                                        fetchImage();
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Image deleted succesfully'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },

                          // ===== Delete button =====
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
