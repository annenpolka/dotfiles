import subprocess

keyboard.send_key("<escape>")
keyboard.send_key("<escape>")
subprocess.run(["fcitx5-remote", "-c"])