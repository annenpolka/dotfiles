# Instrumentation Patterns

Language-specific logging patterns for Debug Mode.

All patterns output NDJSON to `debug.log` (one JSON object per line).

## Log Format

```json
{"h":"H1","l":"label","v":{"key":"value"},"ts":1702567890123}
```

## Region Syntax

| Language | Start | End |
|----------|-------|-----|
| JS/TS | `//#region debug:H1` | `//#endregion` |
| Python | `# region debug:H1` | `# endregion` |
| Ruby | `# region debug:H1` | `# endregion` |
| Go | `// region debug:H1` | `// endregion` |
| Rust | `// region debug:H1` | `// endregion` |
| Java/Kotlin | `// region debug:H1` | `// endregion` |
| Swift | `// region debug:H1` | `// endregion` |
| C/C++ | `// region debug:H1` | `// endregion` |
| Dart | `// region debug:H1` | `// endregion` |
| C# | `#region debug:H1` | `#endregion` |

---

## Web / JavaScript / TypeScript

### HTTP Method (Client + Server)

Requires collector server running. Works in browser and Node.js.

```javascript
//#region debug:H1
fetch('http://localhost:4567',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({h:'H1',l:'label',v:{key:value},ts:Date.now()})}).catch(()=>{});
//#endregion
```

### File Method (Server only)

Node.js only. Does NOT work in browser.

```javascript
//#region debug:H1
require('fs').appendFileSync('debug.log',JSON.stringify({h:'H1',l:'label',v:{key:value},ts:Date.now()})+'\n');
//#endregion
```

### Expanded (readable)

```javascript
//#region debug:H1
fetch('http://localhost:4567', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    h: 'H1',
    l: 'user_state',
    v: { userId, cart, timestamp: new Date().toISOString() },
    ts: Date.now()
  })
}).catch(() => {});
//#endregion
```

---

## Python

```python
# region debug:H1
import json, time; open('debug.log','a').write(json.dumps({'h':'H1','l':'label','v':{'key':value},'ts':int(time.time()*1000)})+'\n')
# endregion
```

### Expanded

```python
# region debug:H1
import json
import time

with open('debug.log', 'a') as f:
    f.write(json.dumps({
        'h': 'H1',
        'l': 'user_state',
        'v': {'user_id': user_id, 'cart': cart},
        'ts': int(time.time() * 1000)
    }) + '\n')
# endregion
```

---

## Ruby

```ruby
# region debug:H1
File.open('debug.log','a'){|f|f.puts({h:'H1',l:'label',v:{key:value},ts:(Time.now.to_f*1000).to_i}.to_json)}
# endregion
```

### Expanded

```ruby
# region debug:H1
require 'json'

File.open('debug.log', 'a') do |f|
  f.puts({
    h: 'H1',
    l: 'user_state',
    v: { user_id: user.id, cart: cart.to_h },
    ts: (Time.now.to_f * 1000).to_i
  }.to_json)
end
# endregion
```

---

## Go

```go
// region debug:H1
func(){f,_:=os.OpenFile("debug.log",os.O_APPEND|os.O_CREATE|os.O_WRONLY,0644);defer f.Close();json.NewEncoder(f).Encode(map[string]any{"h":"H1","l":"label","v":value,"ts":time.Now().UnixMilli()})}()
// endregion
```

### Expanded

```go
// region debug:H1
func() {
    f, _ := os.OpenFile("debug.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    defer f.Close()
    json.NewEncoder(f).Encode(map[string]any{
        "h":  "H1",
        "l":  "user_state",
        "v":  map[string]any{"userId": userId, "cart": cart},
        "ts": time.Now().UnixMilli(),
    })
}()
// endregion
```

---

## Rust

```rust
// region debug:H1
{use std::fs::OpenOptions;use std::io::Write;if let Ok(mut f)=OpenOptions::new().create(true).append(true).open("debug.log"){let _=writeln!(f,"{{\"h\":\"H1\",\"l\":\"label\",\"v\":{:?},\"ts\":{}}}",value,std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_millis());}}
// endregion
```

### Expanded

```rust
// region debug:H1
{
    use std::fs::OpenOptions;
    use std::io::Write;
    
    if let Ok(mut f) = OpenOptions::new()
        .create(true)
        .append(true)
        .open("debug.log")
    {
        let ts = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis();
        let _ = writeln!(f, r#"{{"h":"H1","l":"user_state","v":{:?},"ts":{}}}"#, value, ts);
    }
}
// endregion
```

---

## Java

```java
// region debug:H1
try{var w=new java.io.FileWriter("debug.log",true);w.write("{\"h\":\"H1\",\"l\":\"label\",\"v\":"+new com.google.gson.Gson().toJson(value)+",\"ts\":"+System.currentTimeMillis()+"}\n");w.close();}catch(Exception e){}
// endregion
```

### Expanded

```java
// region debug:H1
try {
    var writer = new java.io.FileWriter("debug.log", true);
    var gson = new com.google.gson.Gson();
    writer.write(String.format(
        "{\"h\":\"H1\",\"l\":\"user_state\",\"v\":%s,\"ts\":%d}\n",
        gson.toJson(Map.of("userId", userId, "cart", cart)),
        System.currentTimeMillis()
    ));
    writer.close();
} catch (Exception e) {}
// endregion
```

### Without Gson

```java
// region debug:H1
try{var w=new java.io.FileWriter("debug.log",true);w.write("{\"h\":\"H1\",\"l\":\"label\",\"v\":\""+value.toString().replace("\"","\\\"")+"\",\"ts\":"+System.currentTimeMillis()+"}\n");w.close();}catch(Exception e){}
// endregion
```

---

## Kotlin (Android)

```kotlin
// region debug:H1
java.io.File("debug.log").appendText("""{"h":"H1","l":"label","v":${org.json.JSONObject(mapOf("key" to value))},"ts":${System.currentTimeMillis()}}"""+"\n")
// endregion
```

### Expanded

```kotlin
// region debug:H1
import org.json.JSONObject
import java.io.File

File("debug.log").appendText(
    JSONObject(mapOf(
        "h" to "H1",
        "l" to "user_state",
        "v" to mapOf("userId" to userId, "cart" to cart),
        "ts" to System.currentTimeMillis()
    )).toString() + "\n"
)
// endregion
```

### Android with Context (writing to app files directory)

```kotlin
// region debug:H1
context.openFileOutput("debug.log", Context.MODE_APPEND).bufferedWriter().use {
    it.write("""{"h":"H1","l":"label","v":${JSONObject(mapOf("key" to value))},"ts":${System.currentTimeMillis()}}""" + "\n")
}
// endregion
```

---

## Swift (iOS)

```swift
// region debug:H1
if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    let file = dir.appendingPathComponent("debug.log")
    let data = try? JSONSerialization.data(withJSONObject: ["h":"H1","l":"label","v":value,"ts":Int(Date().timeIntervalSince1970*1000)])
    if let data = data, var str = String(data: data, encoding: .utf8) {
        str += "\n"
        if let handle = try? FileHandle(forWritingTo: file) {
            handle.seekToEndOfFile()
            handle.write(str.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? str.write(to: file, atomically: true, encoding: .utf8)
        }
    }
}
// endregion
```

### With Codable helper

```swift
// region debug:H1
struct DebugLog: Codable {
    let h: String
    let l: String
    let v: [String: AnyCodable]
    let ts: Int64
}

func debugProbe(_ h: String, _ l: String, _ v: [String: Any]) {
    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let file = dir.appendingPathComponent("debug.log")
    let entry = ["h": h, "l": l, "v": v, "ts": Int64(Date().timeIntervalSince1970 * 1000)] as [String: Any]
    if let data = try? JSONSerialization.data(withJSONObject: entry),
       var str = String(data: data, encoding: .utf8) {
        str += "\n"
        if FileManager.default.fileExists(atPath: file.path) {
            if let handle = try? FileHandle(forWritingTo: file) {
                handle.seekToEndOfFile()
                handle.write(str.data(using: .utf8)!)
                handle.closeFile()
            }
        } else {
            try? str.write(to: file, atomically: true, encoding: .utf8)
        }
    }
}

debugProbe("H1", "user_state", ["userId": userId, "cart": cart])
// endregion
```

---

## React Native

### JavaScript (same as web)

```javascript
//#region debug:H1
fetch('http://localhost:4567',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({h:'H1',l:'label',v:{key:value},ts:Date.now()})}).catch(()=>{});
//#endregion
```

Note: Use your dev machine's IP instead of `localhost` when running on physical device:

```javascript
fetch('http://192.168.1.100:4567', ...)
```

### With AsyncStorage (persisted on device)

```javascript
//#region debug:H1
import AsyncStorage from '@react-native-async-storage/async-storage';
AsyncStorage.getItem('debug.log').then(log => {
  const entry = JSON.stringify({h:'H1',l:'label',v:{key:value},ts:Date.now()}) + '\n';
  AsyncStorage.setItem('debug.log', (log || '') + entry);
});
//#endregion
```

---

## Flutter (Dart)

```dart
// region debug:H1
import 'dart:convert';
import 'dart:io';
File('debug.log').writeAsStringSync(jsonEncode({'h':'H1','l':'label','v':{'key':value},'ts':DateTime.now().millisecondsSinceEpoch})+'\n', mode: FileMode.append);
// endregion
```

### Expanded

```dart
// region debug:H1
import 'dart:convert';
import 'dart:io';

final entry = {
  'h': 'H1',
  'l': 'user_state',
  'v': {'userId': userId, 'cart': cart},
  'ts': DateTime.now().millisecondsSinceEpoch,
};

File('debug.log').writeAsStringSync(
  jsonEncode(entry) + '\n',
  mode: FileMode.append,
);
// endregion
```

### With path_provider (app documents directory)

```dart
// region debug:H1
import 'package:path_provider/path_provider.dart';

Future<void> debugProbe(String h, String l, Map<String, dynamic> v) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/debug.log');
  final entry = jsonEncode({
    'h': h,
    'l': l,
    'v': v,
    'ts': DateTime.now().millisecondsSinceEpoch,
  });
  await file.writeAsString('$entry\n', mode: FileMode.append);
}

await debugProbe('H1', 'user_state', {'userId': userId, 'cart': cart});
// endregion
```

---

## C / C++

```c
// region debug:H1
{FILE*f=fopen("debug.log","a");if(f){fprintf(f,"{\"h\":\"H1\",\"l\":\"label\",\"v\":\"%s\",\"ts\":%lld}\n",value,(long long)(time(NULL)*1000));fclose(f);}}
// endregion
```

### Expanded

```c
// region debug:H1
#include <stdio.h>
#include <time.h>

{
    FILE* f = fopen("debug.log", "a");
    if (f) {
        long long ts = (long long)(time(NULL)) * 1000;
        fprintf(f, "{\"h\":\"H1\",\"l\":\"user_state\",\"v\":{\"userId\":%d},\"ts\":%lld}\n", 
                user_id, ts);
        fclose(f);
    }
}
// endregion
```

### C++ with nlohmann/json

```cpp
// region debug:H1
#include <fstream>
#include <nlohmann/json.hpp>
#include <chrono>

{
    std::ofstream f("debug.log", std::ios::app);
    nlohmann::json entry = {
        {"h", "H1"},
        {"l", "user_state"},
        {"v", {{"userId", userId}, {"cart", cart}}},
        {"ts", std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()).count()}
    };
    f << entry.dump() << "\n";
}
// endregion
```

---

## C#

```csharp
#region debug:H1
System.IO.File.AppendAllText("debug.log", System.Text.Json.JsonSerializer.Serialize(new{h="H1",l="label",v=new{key=value},ts=DateTimeOffset.Now.ToUnixTimeMilliseconds()})+"\n");
#endregion
```

### Expanded

```csharp
#region debug:H1
using System.Text.Json;

var entry = new
{
    h = "H1",
    l = "user_state",
    v = new { userId = userId, cart = cart },
    ts = DateTimeOffset.Now.ToUnixTimeMilliseconds()
};

File.AppendAllText("debug.log", JsonSerializer.Serialize(entry) + "\n");
#endregion
```

---

## Retrieving Logs from Mobile Devices

### iOS

```bash
# Via Xcode
# Window > Devices and Simulators > Select device > Download Container

# Via libimobiledevice
idevice_id -l
ideviceinstaller -l
```

Or add a "Export Logs" button in debug builds that shares the file.

### Android

```bash
adb shell run-as com.yourapp cat /data/data/com.yourapp/files/debug.log > debug.log

# Or from external storage (if saved there)
adb pull /sdcard/Android/data/com.yourapp/files/debug.log
```

### React Native / Flutter

Use the HTTP method with collector server when possible - logs go directly to your dev machine.
