//this file contains the static variable for the web system url.

class StaticVars {
  //I've made the API URL variable as static because I want to access it
  // globally and I don't want to change it every time in the home file.
  // static var url = "http://$localIp/apps/myapps/barcodescan/apis/";
  static var url = webHostUrl;
  static var webHostUrl = "https://barcodescaner.000webhostapp.com/APIs/";

  //This is the IP of the remote server that I'll use it when I want to test the
  // app on the remote server or to publish it.
  static var localIp = "192.168.0.29";
  static var serverIp = "193.188.88.148";

  static String userId = "0";
}
