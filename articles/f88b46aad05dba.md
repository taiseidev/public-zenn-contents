---
title: "🥇Golden Testを導入してUI開発の不安を解消する"
emoji: "💰"
type: "tech"
topics:
  - "flutter"
  - "test"
  - "dart"
  - "ui"
  - "golden"
published: true
published_at: "2023-12-23 00:14"
---

![](https://storage.googleapis.com/zenn-user-upload/75fd53db41f2-20231221.png)

:::message
本記事は[Arsaga 🎅🏻 Advent Calendar 2023](https://qiita.com/advent-calendar/2023/arsaga)の23日目の記事です。
:::

https://qiita.com/advent-calendar/2023/arsaga

## はじめに

Flutter好きの皆さんこんにちは！
[アルサーガパートナーズ株式会社](https://www.arsaga.jp/)でFlutterエンジニアをしているtaiseiです！

突然ですが皆さん、FlutterでUIの開発を進める中で、「このUIはどんなデバイスでも適切に表示されるのだろうか..?」と不安に感じたことはありませんか？

レスポンシブデザインはもちろんのこと、テキストのフォントや色、ダークモードの表示など複数のデバイスで複数の画面を一回一回チェックするのは骨の折れる作業ですし、開発を進める中で副作用によってUIが変更され、気付かないうちに開発が進んでしまうといったこともあります。

そこで、これらの問題を解決する方法として、**Golden Test**というUIテスト手法があります！！

今回はこの**Golden Test**について、設定から基本的な使い方、私が実際に遭遇したエラーに対するトラブルシューティング等を解説していこうと思います！

この記事が皆さんの開発の一助になれば嬉しいです！

## 対象者
・Golden Testについて興味がある方
・UIテスト方法を迷っている方

では、解説してきます🚀

## Golden Testとは？
Widgetテストの一種で、通常のWidgetテストがコードを探索的に検証するのに対し、Golden Testは開発前後の画面のスクリーンショットを比較して、差分を検出するテスト手法です。ピクセル単位での差分の検出が可能なため、目視で確認するよりも正確かつ効率的にUIのテストを行うことができます。

![](https://storage.googleapis.com/zenn-user-upload/8050f0c5c043-20231205.png)

Golden Testでは、**Golden Image**というアプリのUIがどのように見えるべきかの基準となる画像を元にテストを行います。テスト実施時には、テスト実行中に生成されたスクリーンショットと基準であるGolden Imageが比較され、完全に一致する場合はテストが成功したとみなされます。一方で、一致しない場合はテストが失敗したとみなされ、UIのどの部分で差分が発生しているかの詳細な情報が提供されます。

## Golden Testのメリット

Golden Testを実施するメリットとしては下記が挙げられます。
**- UIの品質担保:**
→ ウィジェットやレイアウトがデザイン通りに実装されているかどうかをスクリーンショットを通じて確認できます。
**- ビジュアルリグレッションの検出:**
→ ピクセル単位での差分を検出してくれるため、UIの意図しない変更にすぐに気づくことができます。
**- 効率的なUIの確認**
→ 複数のシナリオ[^1]を一つのスクリーンショットで一括で確認できるため、目視で確認するより効率的です。

あとは非エンジニアに開発中のUIをすぐに共有することができる点も大きなメリットかなと思います。

[^1]: 例えば、ユーザの権限によって表示するUIを変更する場合、テストコードにそれぞれのケースを書くことによって、一つのスクリーンショットで全てのケースの画面を確認することができます。

## Golden Testの運用
Golden Testの運用について、私が参画しているPJでは下記のように運用しています。

1. ブランチを切ってUI開発
2. `flutter test --update-goldens`コマンドで基準となるGolden Imageを作成・更新
3. 差分を確認して、意図しない画面のGolden Imageが更新されている場合は修正
4. 更新したGolden Imageを含めてPRを作成

![](https://storage.googleapis.com/zenn-user-upload/bfcdb7277937-20231221.png =350x)[^2]

ローカルではテストを行うというよりは、新規画面作成や画面更新時にGolden Imageを更新し、意図しない変更が含まれていないかをチェックするような運用をしています。また、CIのワークフローでgolden testを実施することで、画面更新後のGolden Imageの更新忘れを防いでいます。

PR時にスワイプして開発前後の比較することが出来ます。

![](https://storage.googleapis.com/zenn-user-upload/7813339997b3-20231222.gif)

[^2]: このフローチャートはChatGPTで生成してもらいました。普通にすごい。

## 導入
それでは、Golden Testを導入していきましょう！
本記事では、FlutterでGolden Testを行う際に便利なパッケージである[golden_toolkit](https://pub.dev/packages/golden_toolkit)に焦点を当てます。
https://pub.dev/packages/golden_toolkit

:::message
[golden_toolkit](https://pub.dev/packages/golden_toolkit) = Golden Testの文脈で語られることが多いですが、[golden_toolkit](https://pub.dev/packages/golden_toolkit)はGolden Testを効率的に行うためのパッケージです。Golden Test自体はFlutter標準の[flutter_test](https://github.com/flutter/flutter/wiki/Writing-a-golden-file-test-for-package:flutter#adding-a-new-golden-file-test)でも行うことができます。
:::

:::message
Golden TestはWidgetを網羅的にテストするものではなく、あくまでも視覚的な正しさや差分チェックを行う回帰テストを半自動化するテスト手法です。動作の確認については、別途でUnit TestやWidget Testを実施する必要があります。
:::

### 1. インストール

下記コマンドを実行
```terminal
flutter pub add golden_toolkit
```

もしくは`pubspec.yaml`に直接[golden_toolkit](https://pub.dev/packages/golden_toolkit)のバージョンを指定してください。

```yaml
dependencies:
  golden_toolkit: ^0.15.0
```
以上でインストールは完了です！

### 2. やっておくべき設定
golden_toolkitを使用してGolden Testを実施するためにやっておくべき設定がいくつかあります。

**1. failuresフォルダを`.gitignore`に追加**
テスト失敗時にfailuresディレクトリに失敗したスクリーンショットが格納されます。こちらの画像はgitで管理する理由がないのでgit監視対象外に設定しておきましょう。

```dart
**/failures/*.png
```

**2. 「golden」タグの追加**

`dart_test.yaml`ファイルに「golden」タグを追加します。

```yaml
tags:
  golden:
```

:::details dart_test.yamlとは？
テストの設定をカスタマイズするための設定ファイルです。
詳しい設定方法については下記参照ください。

https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md
:::

Golden Testを記述する`testGoldens`関数には、デフォルトで「golden」タグが設定されているため、例えば`flutter test --tags=golden`といったコマンドを実行すると、goldenタグが設定されているテストのみ実行されるようになり、***テストの効率化***につながります。

:::message
tagの指定のみだと`Incorrect type. Expected "testConfiguration".`エラーが発生するので下記のように`timeout`を設定してあげると解決します。
```yaml
tags:
  golden:
    timeout: 1m
```
:::

https://flutter.salon/error_warning/dart-test-yaml/

**3. VScodeの設定**
エディタにVSCodeを使用している場合、`.vscode/launch.json`に下記設定を追加しておくと便利です。
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Golden",
      "request": "launch",
      "type": "dart",
      "codeLens": {
        "for": ["run-test", "run-test-file"]
      },
      "args": ["--update-goldens"]
    }
  ]
}
```

**4. フォントの読み込み（重要）**
Flutterのテストでは、デフォルトで「Ahem」というテスト専用のフォントが使用されます。このフォントは、すべての文字とアイコンに黒いスペースを表示するように設計されており、アプリの見た目を正確にテストするGolden  Testには適していません。

![](https://storage.googleapis.com/zenn-user-upload/cb1df6a9e95f-20231205.png)

こちらを解決するためには提供されている下記ヘルパーメソッドをテスト前に実行する必要があります。
```dart
await loadAppFonts();
```
テスト時に毎回こちらのメソッドを実行してもいいですが、抜け漏れる可能性があるので、テスト実行前に自動でフォントを読み込んでもらうよう、専用の`flutter_test_config.dart`ファイルを作成します。

```dart
import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
```

:::message
Flutterのテストフレームワークは、テストが実行される前に、`flutter_test_config.dart`という名前のファイルを探します。このファイルが見つかった場合、そのファイルのmainメソッドがテストのmain()メソッドに渡され、実行されます。そのため、***もし設定を行ったのにフォントが読み込まれない場合はファイル名に誤りがないか確認してみてください。***
:::

基本的な設定は以上で完了です！

## Golden Testの基本
下記の画面を使ってGolden Testの基本について解説していきます。

![altテキスト](https://storage.googleapis.com/zenn-user-upload/728f36e1d569-20231211.png =250x)

:::details ソースコード
```dart
import 'package:flutter/material.dart';

enum Weather {
  sunny(
    '晴れ',
    Icons.sunny,
  ),
  cloudy(
    '曇り',
    Icons.cloud,
  ),
  rain(
    '雨',
    Icons.grain,
  ),
  snow(
    '雪',
    Icons.ac_unit,
  );

  const Weather(this.text, this.icon);

  final String text;
  final IconData icon;
}

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      appBar: AppBar(
        title: const Text('Golden Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: Weather.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, index) => WeatherScreenItem(
            weather: Weather.values[index],
          ),
        ),
      ),
    );
  }
}

class WeatherScreenItem extends StatelessWidget {
  const WeatherScreenItem({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.amber,
              ),
              width: 200,
              height: 200,
            ),
            Positioned(
              left: -80,
              top: -80,
              child: Icon(
                weather.icon,
                color: Colors.white,
                size: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  weather.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```
:::

### テスト作成

通常のテストと同様に`任意の名前_test.dart`というファイルを作成し、テストを書いていきます。

```dart
void main() {
  // ゴールデンテストを定義するための関数
  testGoldens(
    'Weather Screen Test',
    (tester) async {
      // 異なるデバイスサイズでWidgetをテストするために使用
      final builder = DeviceBuilder()
        // デバイスの種類を指定。指定した種類分スクリーンショットが作成されます。
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.iphone11,
        ])
	// テストするシナリオを追加。今回はWeatherScreen全体をテスト。
        ..addScenario(
          widget: testableWidget(
	    child: const WeatherScreen(),
	  )
        );
      // addScenarioで指定したWidgetをレンダリング
      await tester.pumpDeviceBuilder(
        builder,
      );
      
      // レンダリングされたWidgetのスクリーンショットを作成し、第二引数で指定したファイルと比較します。
      await screenMatchesGolden(tester, 'weather_screen_test');
    },
  );
}
```

`testableWidget`は、フォントの読み込みやThemeの設定を適用させるため、MaterialAppを返却する関数を作成しています。Themeの部分は、実際に利用するMaterialAppと共通のThemeを指定しておくと良いでしょう。

```dart
Widget testableWidget({required Widget child}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'Murecho',
    ),
    debugShowCheckedModeBanner: false,
    home: child,
  );
}
```
### Golden Imageを作成

テストを作成したら下記コマンドを実行してGolden Imageを作成します。
```dart
flutter test --update-goldens
```
以上でgoldens/ディレクトリ配下にスクリーショットが作成されたかと思います！

![altテキスト](https://storage.googleapis.com/zenn-user-upload/14f1723e600b-20231211.png =400x)

### 全てのGolden Testで複数のデバイスを設定する

`overrideDevicesForAllScenarios`で出力したいデバイスの設定を行うことができますが、テスト毎で指定するのも冗長なので共通化したいところです。golden_toolkitでは`GoldenToolkit.runWithConfiguration()`という設定用クラスが提供されているため、こちらの設定を`flutter_test_config.dart`に追加します。

```dart
import 'dart:async';
import 'dart:io';

import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      // フォントの読み込み
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      // 出力するデバイスを指定
      defaultDevices: const [
        Device.phone,
        Device.iphone11,
      ],
      skipGoldenAssertion: () => !Platform.isMacOS,
    ),
  );
}
```


:::message
`Device.iphone11`のように特定の端末を指定するだけでなく、独自の端末サイズを指定することも可能です。

```dart
        Device(
          name: 'iPhone 13 mini',
          size: const Size(375, 812),
          safeArea: const EdgeInsets.only(top: 44, bottom: 34),
        ),
```
:::


### コンポーネント単位でGolden Testを行う
先ほどは`DeviceBuilder`を使用して、端末ごとのGolden Imageの生成を行いましたが、`GoldenBuilder`を使用することによってコンポーネント単位でスクリーンショットを作成することができます。

```dart
  testGoldens(
    'Weather Screen Item Test',
    (tester) async {
      final builder = GoldenBuilder.grid(
        // 横に配置するコンポーネントの数
        columns: 2,
	// カラム数と幅と高さの比率
        widthToHeightRatio: 1,
      )
        // 各Enumの値でシナリオを作成
        ..addScenario(
          'Sunny',
          const WeatherScreenItem(weather: Weather.sunny),
        )
        ..addScenario(
          'Cloudy',
          const WeatherScreenItem(weather: Weather.cloudy),
        )
        ..addScenario(
          'Raining',
          const WeatherScreenItem(weather: Weather.rain),
        )
        ..addScenario(
          'Snow',
          const WeatherScreenItem(weather: Weather.snow),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (child) => TestUtils.buildTestMaterialApp(child),
      );
      
      await screenMatchesGolden(
        tester,
        'weather_types_grid',
        autoHeight: true,
      );
    },
  );
```

![altテキスト](https://storage.googleapis.com/zenn-user-upload/7ca98dff9e56-20231211.png =400x)

出力するコンポーネントによっては、スクリーンショットが見切れてしまう場合があるので`autoHeight: true`を設定することによって、自動的に高さを合わせてくれます。

### Golden Imageの出力先を変更する
デフォルトではテストファイルと同階層にgoldens/ディレクトリが作成され、その配下にGolden Imageが格納されます。もしGolden Imageの出力先を変更したい場合は、`GoldenToolkitConfiguration`の`fileNameFactory`で変更することが可能です。

```dart
    Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      // 省略
    },
    config: GoldenToolkitConfiguration(
      fileNameFactory: (name) {
        return 'goldens/$name.png'; ← Golden Imageの保存先を変更
      },
      // 省略
    ),
  );
}
```

引数で受け取る`name`はテスト実行時の`await screenMatchesGolden(tester, 'counter_screen');`の第二引数に指定した名前が渡されます。

## トラブルシューティング
この章では、私が実際に遭遇したエラーと、それらを解決する方法について解説していきます。

### Golden Imageに黒い枠線が表示される

![](https://storage.googleapis.com/zenn-user-upload/c75cc82018a5-20231219.png =400x)

上記画像のようにWidgetに黒色の枠線がつくことがあります。
これはFlutterのバージョン間（または実行環境）によって影の表示が変わる可能性があるため、デフォルトでは影が黒い枠線に置き換えられて表示されます。

https://pub.dev/documentation/golden_toolkit/latest/golden_toolkit/GoldenToolkitConfiguration/enableRealShadows.html

この黒い枠線を削除したい場合は`GoldenToolkit.runWithConfiguration`に下記設定を加えることで削除することができます。

```dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      // 省略
    },
    config: GoldenToolkitConfiguration(
      enableRealShadows: true,　← 追加
      // 省略
    ),
  );
}
```

![](https://storage.googleapis.com/zenn-user-upload/c1599f14b22d-20231219.png =400x)

### flutter_screenutilパッケージ使用時のエラー
レスポンシブ対応を簡単に実現できるパッケージとして、flutter_screenutilがあります。

https://pub.dev/packages/flutter_screenutil

こちらのパッケージを使用した画面でGolden Testを実施すると下記のようなエラーが発生します。

```shell
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following LateError was thrown building WeatherScreenItem(dirty):
LateInitializationError: Field '_data@32084504' has not been initialized.

The relevant error-causing widget was:
  WeatherScreenItem
  WeatherScreenItem:file:///Users/t-z/workspace/flutter/advent_calendar_2023/test/ui/weather_screen_test.dart:46:17
```
エラー内容を読むと、weather_screen_test.dartの46行目で`_data@32084504`というフィールドが初期化されていないというエラー内容になりますが、46行目にはテスト対象画面が指定されおり、テスト対象の画面ではflutter_screenutilパッケージを使用しています。

flutter_screenutilパッケージを使用する際には、ScreenUtilInitウィジェットを用いて、アプリケーションの画面が描画される前にScreenUtilを初期化する必要があります。Golden Testでも同様にテスト実行前にScreenUtilの初期化をする必要があるため、冒頭で作成したWrapper関数を下記のように修正します。

```dart
class _Wrapper extends StatelessWidget {
  final Widget child;
  const _Wrapper(this.child);
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(430.0, 932.0),
    );
    return child;
  }
}

Widget testableWidget({required Widget child}) {
  return _Wrapper(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'Murecho',
    ),
    debugShowCheckedModeBanner: false,
    home: child,
  ));
}
```

![](https://storage.googleapis.com/zenn-user-upload/ead9dc51c0d0-20231220.png =400x)

自分の環境では発生しませんでしたが、[【Flutter】screenutilに対応したGolden Testの実装](https://qiita.com/tai_miya/items/55e96f8acd881a729a4b)の記事の通りスクリーンショット解像度がおかしくなる場合はがあるので、その場合は`MediaQuery`でラップしてあげる必要があります。

```dart
Widget testableWidget({required Widget child}) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: _Wrapper(MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Murecho',
      ),
      debugShowCheckedModeBanner: false,
      home: child,
    )),
  );
}

```

https://github.com/OpenFlutter/flutter_screenutil/issues/115

:::message
本業のpjではScreeUtilInitにdesignSizeを設定するのではなく、

```dart
 return MediaQuery(
    data: const MediaQueryData(
      size: Size(430.0, 932.0),
    ),
    child: // 省略,
  );
```
上記のように`MediaQueryData`のsizeにデバイスサイズを設定することが解決したので、もし解決しない場合はこちらを試してみてもいいかもしれません。
:::

:::message
トラブルシューティングは随時追加していきます。
:::

## まとめ
今回はgolden_toolkitを使ったGolden Testについて解説しました！
まだまだ発展途上な部分もありますが、導入も簡単なので皆さんプロジェクトにもぜひ取り入れてみてください！

ちなみにFlutter公式のUI test手法としても紹介されているのでこれからの進化が楽しみです！
https://youtu.be/vka33yBz5e4?feature=shared

それでは良いGoldenライフを!!

## 参考
・[FutureCon2022 Flutter Golden Testのすすめ](https://www.youtube.com/watch?v=qC-jts8pZJ4)
・[Flutter でCI/CDの取り組む前に知っておきたかったテスト関連の覚え書き](https://flutter.salon/others/cicd/)
・[Flutterパッケージを管理する際に役立つCI/CD (GitHub Actions)](https://zenn.dev/antman/articles/b24c28e01ec502)
・[FlutterにGolden Testを導入しました](https://note.com/shift_tech/n/nb4d72c1ca3ee)

## 余談
今回の記事を書くにあたって「なぜGolden TestはGoldenというのか？」について気になったのでChatGPTに聞いてみました。

```
あなた
Golden TestのGoldenとはどういう意味で使用されていますか？？

ChatGPT
「ゴールデンテスト」または「ゴールデンファイルテスト」という用語は、ソフトウェアテストの分野で使われる言葉です。この用語の「ゴールデン」という部分は、テストの基準となる出力や結果が「金のように価値がある」、つまり非常に信頼性が高く、正確であることを意味しています。ゴールデンファイルは、テストの正確な基準点として機能し、新しいテスト結果がこの基準とどのように異なるかを評価するために使用されます。

この用語の由来は、一般的に「ゴールデンスタンダード」または「黄金基準」という表現に由来しています。これは、何かが最高水準または最も信頼性の高い例として認識されることを意味します。ソフトウェアテストの文脈では、ゴールデンファイルはそのような最高水準の例と見なされ、テストの信頼性と正確性を保証するための基準点として機能します。
```
※一部改変しています。

>「ゴールデン」という部分は、テストの基準となる出力や結果が「金のように価値がある」、つまり非常に信頼性が高く、正確であることを意味しています

なるほど！！納得！！







