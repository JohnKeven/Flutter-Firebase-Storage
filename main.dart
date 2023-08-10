import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? imagemSelecionada;
  var imagem, urlRecuperada;
  String statusUpload = 'Upload não iniciado';

  Future _recuperarImagem(bool daCamera) async {
    if(daCamera){
      imagem = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      imagem  = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    setState(() {
      imagemSelecionada = File(imagem!.path);
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    print('URL: $url');
    setState(() {
      urlRecuperada = url;
    });
  }

  Future _uploadImagem(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz.child('Fotos').child('foto1.jpg');
    UploadTask task =  arquivo.putFile(image);
    task.snapshotEvents.listen((TaskSnapshot event) {
      if(event.state == TaskState.running){
        setState(() {
          statusUpload = 'Em progresso';
        });
      } else if (event.state == TaskState.success) {
        setState(() {
          statusUpload = 'Finalizado com Sucesso';
        });
      } else {
        setState(() {
          statusUpload = 'Finalizado sem Sucesso';
        });
      }

      task.whenComplete(() => {
        _recuperarUrlImagem(task.snapshot)
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionando Imagens'),
      ) ,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('$statusUpload'),
            ElevatedButton(
              onPressed: () {
                _recuperarImagem(true);
              },
              child: const Text("Câmera"),),
            ElevatedButton(
              onPressed: () {
                _recuperarImagem(false);
              },
              child: const Text("Galeria"),
            ),
            imagemSelecionada == null ? Container() : Image.file(imagemSelecionada!),
            ElevatedButton(
              onPressed: () {
                _uploadImagem(imagemSelecionada!);
              },
              child: const Text("Upload Storage"),
            ),
            urlRecuperada == null ? Container() : Image.network(urlRecuperada!),
          ],
        ),
      ),
    );
  }
}


