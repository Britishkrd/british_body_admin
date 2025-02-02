import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

sendingnotification(String title, String body, String token) async {
  final credentials = ServiceAccountCredentials.fromJson({
    "private_key_id": "acd50d3a157701ada09fa7d74160c2321ea016f9",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCjiR23bf944Iqe\nhZOlHJPhDS2QUohVOR1RTKUfOFRzSellTMTkDq0vwNzqIylh97JdaYeXhRkYW/i2\nlWBYiGTfT4SxkWLmw3TrmMxdTkq3qk9J8GhtyleYTLQwjirD+ZwYxVwB4F/EqJ4s\neIZUT+fOkt4+xLI9/2jp7nasBnMSIiYgvuPDXRk6Xl0RdJLdCm9TRdeAieBe+I6/\nOeb94Zy1J6Xmkt/UrVaYWgNZ2w9NLD89D206q+MGz4F3QgzSk77gkAcU6X9tNNJL\nfjSjzZgWtRKhFdj3b9NMXytVMa+q5Tw56mwAJclhFII1PDi0tAnFscZXVE1Eoxie\nffqP4wIFAgMBAAECggEADBlw0OmlsrBOS+nkdsgKquZ6M141MbT+6yJ0FGoVrs1O\nTuKOA1+QnGK1FZT8vVUBuzE7ySVIVN83zhkhiTtXgewqDFHjkuDtjXbUe/zMa2gB\njh4S4+NKIChgq+JWM1dhn2A5bUwdWc6t8UAI6ZkF32ifYokpX4vo8RHlxtbX/Fnb\nBGJ46oWwpdIUvrhgYYywlMiUXm9uSgURq3fJ1mKqOefM6MmB4erVgSX6Xwc6s4xF\nmjM73MyAEO0mjtNBsYfFDQMHUXHilW5igGZo3YZG+kqBpGEGSTz3Px/nwMOObiHt\nO0Yu3SoFpB2kB3lWsAbGA5zjI2Pg9jm7FQwHLmOM+wKBgQDi3KiFqGM3bGDlxCpf\nHPjye1QVjFRKFN41jaf7lMSXES5dDD+pX5EZQMBvUggTf721uAdiIQ2ZLGnQxKF2\nAWI0X85XyVZNovY/4rP416KuIwB3uPWPDjMF2QgVU/UoSUWkPx0stjtutla/vBj/\ng8bdxZd4pVvk1aUlAUWM6m2pwwKBgQC4ikEL1yLcS7HQfDXhCkUHB7vqQRdXMRpE\nnCZv0HY5YIi02gV/Hik/zFMPH+TXzqXDTDs52XFmuAq24o72h8PF/4rfqG7KPW4H\ny6NRTECjr3echehXqNAWUDbBNsgn3zBrvBNYMLGVBqCAvqIXy7xcEYxdgHbWFfVo\npg7W2N6glwKBgEhWNcIQlDpa63a4Gw6i7VpcKs6IJWRNzSDkX1jf8eN9jfwLaM03\n9MtJk1KrpHmbNMGZwXjvsydROxhfamB3RnoOxnvFbihpOv3Z6qsBDxVZgc+rAVmx\nHGHT9zjdwYEsA/HAUiwsmzzNFVIjxxDKUwHp/Edy6p9H5FWtVyD8qyUDAoGBAIq+\nX2NAj5QjUQAXswaMCxPbC7x2zc6fO0mkQP3GNGy1GHMojANjsM2nmDcB2rMqSdSI\npuq6ghkhe+S+d5AAyP8/PrEjWJCzGNvBjfucoeivDvXec64cXL659kDUKC5aDnSh\nhcXDbnBF+Dxzlzje07JA+1B9OluBTO4uE3ASw2bnAoGAaMemzAx+fb9MGQWN3zmP\nwwvYA7QR3I2RIMdw0qf2TlDmdDXOkju09eJuafUxZBUh4i4doUlU6uerlquoS28j\nxNTBNR1W+CiM3UR+ujo4iusz1fh0aScWAbbeu79FckltSaLpylC/O99vGtlqAaEo\n9DTTci859wcrBUi/XBj976M=\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-fbsvc@british-body-admin.iam.gserviceaccount.com",
    "client_id": "112838954980412165481",
    "type": "service_account"
  });

  final client = http.Client();
  try {
    final authClient = await clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/firebase.messaging']);
    await authClient.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/british-body-admin/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': <String, dynamic>{
            'token': token,
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'android': {
              'notification': <String, dynamic>{
                'title': title,
                'body': body,
                'sound': 'sound',
                'channel_id': 'Notifications'
              },
            },
            'apns': {
              'payload': {
                'aps': {'sound': 'sound.caf', 'badge': 1},
              },
            },
          },
        },
      ),
    );

    client.close();
  } catch (e) {
    client.close();
  }
}
