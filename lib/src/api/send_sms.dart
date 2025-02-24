import 'package:http/http.dart' as http;

void sendSms(String code,String destNumber,String content) async {
  final headers = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Origin': 'http://192.168.5.150',
    'Referer': 'http://192.168.5.150/cgi/WebCGI?15000',
    'Sec-GPC': '1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
    'Cookie': 'loginname=admin; password=OV%5B2%5CFXo%5CI%5CmOFK4O%7CS%7BQVOzPlHj%5CoHlPIPoPFe%7BQVm%3F; language=en; Series=; Product=TG100; current=sms; Backto=; TabIndex=0; TabIndexwithback=0; applychange=; OsVer=51.18.0.50; defaultpwd=; curUrl=15000',
  };

  final data = {
    'calling_code': code,
    'destinations': destNumber,
    'select_port': '1',
    'content': content,
  };

  final url = Uri.parse('http://192.168.5.150/cgi/WebCGI?15001');

  final res = await http.post(url, headers: headers, body: data);
  final status = res.statusCode;
  if (status != 200) throw Exception('http.post error: statusCode= $status');

  print(res.body);
}