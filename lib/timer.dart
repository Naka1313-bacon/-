import 'dart:async';
import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  Timer? _timer;
  int _timeInSeconds = 0;
  double _selectedTime = 1; // スライダーで選択された時間（分）
  bool _isRunning = false; // タイマーが動作中かどうかを追跡

  void toggleTimer() {
    if (_isRunning) {
      _timer?.cancel(); // タイマーを一時停止
      setState(() {
        _isRunning = false;
      });
    } else {
      // 一時停止からの再開の場合、_timeInSeconds の再設定を行わない
      if (_timeInSeconds <= 0) {
        // タイマーが一度もスタートしていない、または前回のカウントダウンが完了していた場合のみ、_timeInSeconds を再設定
        _timeInSeconds = (_selectedTime * 60).round();
      }

      _timer?.cancel(); // 既存のタイマーがあればキャンセル
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timeInSeconds == 0) {
          setState(() {
            timer.cancel(); // カウントダウンが0になったらタイマーを停止
            _isRunning = false;
          });
          // タイマー終了時にダイアログを表示
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('タイマー終了'),
              content: Text('設定した時間が終了しました。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _timeInSeconds--;
          });
        }
      });

      setState(() {
        _isRunning = true;
      });
    }
  }

  void startTimer() {
    // _timeInSeconds の初期設定をここから削除
    if (!_isRunning) {
      setState(() {
        _timeInSeconds = (_selectedTime * 60).round(); // 分を秒に変換
      });
    }

    setState(() {
      _isRunning = true;
    });

    _timer?.cancel(); // 既存のタイマーがあればキャンセル
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeInSeconds == 0) {
        setState(() {
          timer.cancel(); // カウントダウンが0になったらタイマーを停止
          _isRunning = false;
        });
        // タイマー終了時にダイアログを表示
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('タイマー終了'),
            content: Text('設定した時間が終了しました。'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // ダイアログを閉じる
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _timeInSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ウィジェットが破棄されるときにタイマーをキャンセル
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Slider(
          value: _selectedTime,
          min: 1,
          max: 60,
          divisions: 59,
          label: _selectedTime.round().toString(),
          onChanged: (double value) {
            setState(() {
              _selectedTime = value;
              if (!_isRunning) {
                // スライダーを動かした時点で時間をリセット
                _timeInSeconds = (_selectedTime * 60).round();
              }
            });
          },
        ),
        ElevatedButton(
          onPressed: toggleTimer,
          child: Text(_isRunning ? '一時停止' : 'スタート'),
        ),
        SizedBox(height: 20),
        Text(
          '残り時間: ${_timeInSeconds ~/ 60}分${_timeInSeconds % 60}秒',
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}
