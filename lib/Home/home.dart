import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? positon;

  var lat;
  var lon;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    positon = await Geolocator.getCurrentPosition();
    lat = positon!.latitude;
    lon = positon!.longitude;
    print("latitude : ${lat},longitude: ${lon}");
    fetchWeatherData();
  }

  Map<String, dynamic>? mapOfWeather;
  Map<String, dynamic>? mapOfForecast;

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=906c0c77ba8058de5f2455853703dc3e";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=906c0c77ba8058de5f2455853703dc3e";
    var weatherResponse = await http.get(Uri.parse(weatherApi));
    var forecastResponse = await http.get(Uri.parse(forecastApi));
    print(weatherResponse.body);
    setState(() {
      mapOfWeather =
      Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      mapOfForecast =
      Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: mapOfWeather == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Scaffold(
        appBar: AppBar(
          title: Text("Weather App",style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),),
              actions: [
              Container(
              height: 20,
              width: 200,
              color:Colors.white,
              child: TextFormField(
                onTap: (){

                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: IconButton(onPressed: (){

                  }, icon: Icon(Icons.search,color: Colors.black,size: 22,)),
                ),
              ),
            ),

            IconButton(onPressed: (){

            }, icon: Icon(Icons.my_location_outlined,size: 33,))
          ],
        ),

       backgroundColor: Colors.amberAccent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${mapOfWeather!["name"]}",
                  style:
                  TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text("${mapOfForecast!["city"]["country"]}",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400)),
                Text(Jiffy(DateTime.now()).yMMMMEEEEdjm,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w200)),
                SizedBox(
                  height: 10,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    mapOfWeather!["main"]["feels_like"] == "clear sky"
                        ? "https://png.pngitem.com/pimgs/s/45-458798_weather-symbols-partly-cloudy-hd-png-download.png"
                        : mapOfWeather!["main"]["feels_like"] == "rainy"
                        ? "https://www.freevector.com/uploads/vector/preview/13313/FreeVector-Sun-Rain-Clouds.jpg"
                        : mapOfWeather!["main"]["feels_like"] ==
                        "cloudy"
                        ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpAUZ4CykflQRHStPs2Fb3ls3jbQHJVXPR6uZZ_jCWTtiH3ZQoBPVkVHMr5PKl17AACi8&usqp=CAU"
                        : "https://thumbs.dreamstime.com/b/thunderstorm-icon-vector-isolated-white-background-thunderstorm-sign-weather-symbols-thunderstorm-icon-vector-isolated-white-134058931.jpg",
                    height: MediaQuery.of(context).size.height * .20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("${mapOfWeather!["main"]["temp"]-273} °C",
                    style: TextStyle(
                        fontSize: 35, fontWeight: FontWeight.bold)),
                Text(
                  "${mapOfWeather!["weather"][0]["description"]}",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                                "${mapOfForecast!["list"][0]["clouds"]["all"]} %",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Clouds",style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400
                            )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 2,
                      color: Colors.black54,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          children: [
                            Text("${mapOfWeather!["main"]["humidity"]} %",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Humidity",style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400
                            )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 2,
                      color: Colors.black54,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                                "${mapOfForecast!["list"][0]["wind"]["speed"]} km/h",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Text("wind",style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400
                            )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${mapOfForecast!["city"]["country"]} forecast",style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  )),
                ),
                SizedBox(
                    height: 250,

                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: mapOfForecast!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width*.4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white54
                            ),
                            margin: EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${Jiffy("${mapOfForecast!["list"][index]["dt_txt"]}").format("EEE h:mm")}",
                                    style: TextStyle(fontSize: 20),),
                                ),
                                ClipRRect(
                                  //borderRadius:BorderRadius.circular(20),
                                  child: Image.network(
                                    mapOfWeather!["main"]["feels_like"] ==
                                        "clear sky"
                                        ? "https://png.pngitem.com/pimgs/s/45-458798_weather-symbols-partly-cloudy-hd-png-download.png"
                                        : mapOfWeather!["main"]
                                    ["feels_like"] ==
                                        "rainy"
                                        ? "https://www.freevector.com/uploads/vector/preview/13313/FreeVector-Sun-Rain-Clouds.jpg"
                                        : mapOfWeather!["main"]
                                    ["feels_like"] ==
                                        "cloudy"
                                        ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpAUZ4CykflQRHStPs2Fb3ls3jbQHJVXPR6uZZ_jCWTtiH3ZQoBPVkVHMr5PKl17AACi8&usqp=CAU"
                                        : "https://thumbs.dreamstime.com/b/thunderstorm-icon-vector-isolated-white-background-thunderstorm-sign-weather-symbols-thunderstorm-icon-vector-isolated-white-134058931.jpg",
                                    height:
                                    MediaQuery.of(context).size.height *
                                        .2,
                                  ),
                                ),
                                Text(
                                  "${mapOfForecast!["list"][index]["main"]["temp_min"]} °C / ${mapOfForecast!["list"][index]["main"]["temp_max"]} °C",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
