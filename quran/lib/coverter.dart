// To parse this JSON data, do
//
//     final sura = suraFromJson(jsonString);

// import 'dart:convert';

// Sura suraFromJson(String str) => Sura.fromJson(json.decode(str));

// String suraToJson(Sura data) => json.encode(data.toJson());

class Sura {
    Sura({
        required this.result,
    });

    List<Result> result;

    factory Sura.fromJson(Map<String, dynamic> json) => Sura(
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
    };
}

class Result {
    Result({
        required this.id,
        required this.sura,
        required this.aya,
        required this.arabicText,
        required this.translation,
        required this.footnotes,
    });

    String id;
    String sura;
    String aya;
    String arabicText;
    String translation;
    String footnotes;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        sura: json["sura"],
        aya: json["aya"],
        arabicText: json["arabic_text"],
        translation: json["translation"],
        footnotes: json["footnotes"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sura": sura,
        "aya": aya,
        "arabic_text": arabicText,
        "translation": translation,
        "footnotes": footnotes,
    };
}
