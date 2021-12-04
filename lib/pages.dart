import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';




class QranPages2 extends StatefulWidget {
  const QranPages2 ({Key? key}) : super(key: key);

  @override
  State<QranPages2> createState() => _QranPages();
}

class _QranPages extends State<QranPages2 > {
  static const int quranPages = 604;
  static int currentPage = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          fit: StackFit.passthrough,
          children:[
            CarouselSlider.builder(
              options: CarouselOptions(
                  initialPage:currentPage ,
                  height: double.infinity,
                  reverse: true,
                  viewportFraction: 1
              ),
              itemCount: quranPages,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  child: buildImage(index+1),
                );
              },
            ),


            InkWell(
                highlightColor: Colors.yellowAccent,
                splashColor: Colors.green,

                child: CustomPaint(
                  painter: YourRect( (MediaQuery.of(context).size.width * 166 /1024 ),
                      (MediaQuery.of(context).size.height * 231 /1664),
                      (MediaQuery.of(context).size.width * 103/1024)  ,
                      (MediaQuery.of(context).size.height *88.3248/1664 ) ,
                      Colors.amber.withOpacity(0.5) ),),
                onTap: () => { showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('jdkkd'),
                      content: Text('انفراده من انفرادات حفص حيث ينطقها بالهمزة'),
                    )
                )
                }

            ),

          ]

      ),
    );
  }

/*  Slider(
                  value:currentPage ,
                  min: 1,
                  max: 604,
                  divisions: 604,
                  onChanged:(newValue){
                    setState(() {
                      currentPage = newValue;
                    });
                  })*/


  Widget buildImage(currentPage) {
    return Container(
   // HexColor('#F7EBB9'),
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      //color: Colors.white,
      child:Image.asset("assets/QuranImg/${currentPage.round()}.png",
        fit: BoxFit.fill,
        width: MediaQuery.of(context).size.width,
      ),

    );
  }
}

class YourRect extends CustomPainter {
  final double x,y,w,h;
  final Color c;

  YourRect(this.x, this.y, this.w, this.h, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      new Rect.fromLTWH(x,y,w,h),
      new Paint()..color = c,

    );
  }
  @override
  bool shouldRepaint(YourRect oldDelegate) {
    return false;
  }
}