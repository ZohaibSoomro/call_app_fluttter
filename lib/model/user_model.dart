class MyUser {
  String? id;
  String email;
  String password;
  String name;
  CallInfo? callInfo;

  MyUser({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    this.callInfo,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      callInfo:
          json['callInfo'] != null ? CallInfo.fromJson(json['callInfo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'callInfo': callInfo != null ? callInfo!.toJson() : null,
    };
  }
}

enum CallStatus {
  free,
  inACall,
  beingCalled,
  declined,
}

class CallInfo {
  CallStatus status;
  MyUser? caller;
  String timestamp; // Added timestamp property

  CallInfo({
    required this.status,
    this.caller,
    required this.timestamp,
  });

  factory CallInfo.fromJson(Map<String, dynamic> json) {
    return CallInfo(
      status: CallStatus.values.firstWhere(
        (element) => element.name == json['status'],
        orElse: () => CallStatus.free,
      ),
      caller: json['caller'] != null ? MyUser.fromJson(json['caller']) : null,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'caller': caller?.toJson(),
      'timestamp': timestamp,
    };
  }
}
