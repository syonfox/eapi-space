<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Local Mod Manager / Pioneer Config Editor</title>
  <style>
    body { font-family: sans-serif; padding: 20px; max-width: 700px; }
    code, pre { background: #f3f3f3; padding: 10px; border-radius: 5px; display: block; white-space: pre; }
    input[type="file"] { margin-top: 10px; }
    #output { margin-top: 20px; }
  </style>
</head>
<body>
  <h2>Local Mod Manager / Pioneer Config Editor</h2>

  <p>This file is meant to be opened locally from <code>~/.pioneer/mods/eapi-space/</code>.</p>

  <p>
    If your browser does not allow local file access, please upload your <code>~/.pioneer/config.ini</code> file manually below.
  </p>

  <input type="file" id="fileInput" accept=".ini,.txt">
  <div id="output">
    <h3>Example <code>~/.pioneer/config.ini</code>:</h3>
    <pre><code id="iniPreview">Var1=0

[ModLoader]
eapi-space=0
honk=disabled</code></pre>
  </div>

  <p>
    Once modified, you will be able to download the updated config back to your system and replace the original manually.
  </p>
</body>
</html>
