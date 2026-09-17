"""Integration test in a separate headless Mango session.

Usage: python3 tests/mango-corners.py --mango /path/to/bin/mango \
    --libx11 /path/to/lib/libX11.so.6
Requires mmsg on PATH. No input is sent to the user's desktop.
"""

import argparse
import ctypes as C
import json
import os
import shlex
import socket
import struct
import subprocess
import sys
import tempfile
import time
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--mango", required=True)
parser.add_argument("--libx11", required=True)
parser.add_argument("--client", action="store_true", help=argparse.SUPPRESS)
args = parser.parse_args()

if not args.client:
    with tempfile.TemporaryDirectory(prefix="mango-corners-") as work:
        directory = Path(work)
        config = directory / "config.conf"
        # Use the production floating rule, with effects disabled for headless rendering.
        config.write_text(
            "animations=0\n"
            "borderpx=2\n"
            "border_radius=6\n"
            "shadows=0\n"
            "blur=0\n"
            "drag_corner=4\n"
            "drag_warp_cursor=0\n"
            "monitorrule=name:HEADLESS-1,scale:1.5\n"
            "windowrule=appid:^[Ss]team$,isfloating:1\n"
        )
        status = directory / "status"
        output = directory / "test.log"
        command = shlex.join(
            [
                sys.executable,
                str(Path(__file__).resolve()),
                "--mango",
                args.mango,
                "--libx11",
                args.libx11,
                "--client",
            ]
        )
        command += (
            " > "
            + shlex.quote(str(output))
            + " 2>&1; echo $? > "
            + shlex.quote(str(status))
        )
        env = dict(
            os.environ,
            XDG_RUNTIME_DIR=work,
            WLR_BACKENDS="headless",
            WLR_HEADLESS_OUTPUTS="1",
            WLR_RENDERER="pixman",
        )
        for key in ("WAYLAND_DISPLAY", "DISPLAY", "MANGO_INSTANCE_SIGNATURE"):
            env.pop(key, None)
        with (directory / "compositor.log").open("w+") as log:
            proc = subprocess.Popen(
                [args.mango, "-c", str(config), "-s", command],
                env=env,
                stdout=log,
                stderr=log,
            )
            try:
                deadline = time.monotonic() + 40
                while (
                    not status.exists()
                    and proc.poll() is None
                    and time.monotonic() < deadline
                ):
                    time.sleep(0.1)
                if output.exists():
                    print(output.read_text(), end="")
                if not status.exists() or status.read_text().strip() != "0":
                    log.seek(0)
                    print(log.read(), file=sys.stderr)
                    raise SystemExit("Headless integration test failed")
            finally:
                proc.terminate()
                try:
                    proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
    raise SystemExit(0)


def query(kind):
    return json.loads(subprocess.check_output(["mmsg", "get", kind]))


def clients():
    return query("all-clients")["clients"]


def wait_client(app):
    for _ in range(100):
        matches = [c for c in clients() if c["appid"] == app]
        if matches:
            return matches[0]
        time.sleep(0.05)
    raise AssertionError("missing " + app + ": " + str(clients()))


x = C.CDLL(args.libx11)


def api(name, restype, args):
    f = getattr(x, name)
    f.restype = restype
    f.argtypes = args
    return f


ptr = C.c_void_p
ul = C.c_ulong
i = C.c_int
api("XOpenDisplay", ptr, [C.c_char_p])
api("XDefaultRootWindow", ul, [ptr])
api("XCreateSimpleWindow", ul, [ptr, ul, i, i, C.c_uint, C.c_uint, C.c_uint, ul, ul])
api("XMapWindow", i, [ptr, ul])
api("XFlush", i, [ptr])
api("XDestroyWindow", i, [ptr, ul])
api("XCloseDisplay", i, [ptr])
api("XStoreName", i, [ptr, ul, C.c_char_p])


class ClassHint(C.Structure):
    _fields_ = [("name", C.c_char_p), ("cls", C.c_char_p)]


api("XSetClassHint", i, [ptr, ul, C.POINTER(ClassHint)])
d = x.XOpenDisplay(None)
assert d
# Xwayland starts lazily; allow its window manager to finish connecting.
time.sleep(1)
root = x.XDefaultRootWindow(d)


def window(app):
    w = x.XCreateSimpleWindow(d, root, 100, 100, 300, 200, 0, 0, 0xFFFFFF)
    x.XSetClassHint(d, w, C.byref(ClassHint(app.encode(), app.encode())))
    x.XStoreName(d, w, app.encode())
    x.XMapWindow(d, w)
    x.XFlush(d)
    return w


w = window("steam")
c = wait_client("steam")
print("initial Steam floating:", c["is_floating"], flush=True)
assert c["is_floating"]
# Registry + virtual pointer, using Wayland wire messages to send a held drag.
s = socket.socket(socket.AF_UNIX)
s.connect(os.environ["XDG_RUNTIME_DIR"] + "/" + os.environ["WAYLAND_DISPLAY"])
s.settimeout(3)


def msg(obj, op, data=b""):
    s.sendall(struct.pack("II", obj, ((8 + len(data)) << 16) | op) + data)


def ints(*a):
    return struct.pack("I" * len(a), *a)


def string(v):
    b = v.encode() + b"\0"
    return ints(len(b)) + b + b"\0" * ((-len(b)) % 4)


msg(1, 1, ints(2))
msg(1, 0, ints(3))
buf = b""
manager = None
done = False
while not done:
    buf += s.recv(65536)
    while len(buf) >= 8:
        obj, header = struct.unpack("II", buf[:8])
        n = header >> 16
        op = header & 65535
        if len(buf) < n:
            break
        data = buf[8:n]
        buf = buf[n:]
        if obj == 2 and op == 0:
            name, length = struct.unpack("II", data[:8])
            iface = data[8 : 8 + length - 1].decode()
            if iface == "zwlr_virtual_pointer_manager_v1":
                manager = name
        if obj == 3:
            done = True
assert manager
msg(2, 0, ints(manager) + string("zwlr_virtual_pointer_manager_v1") + ints(1, 4))
msg(4, 0, ints(0, 5))


def motion(dx, dy):
    msg(
        5,
        0,
        struct.pack(
            "Iii",
            int(time.monotonic() * 1000) & 0xFFFFFFFF,
            round(dx * 256),
            round(dy * 256),
        ),
    )
    msg(5, 4)
    time.sleep(0.08)


def button(state):
    msg(5, 2, ints(int(time.monotonic() * 1000) & 0xFFFFFFFF, 272, state))
    msg(5, 4)
    time.sleep(0.08)


def move_to(x, y):
    p = query("cursorpos")
    motion(x - p["x"], y - p["y"])


for name, right, bottom in [
    ("NW", False, False),
    ("NE", True, False),
    ("SW", False, True),
    ("SE", True, True),
]:
    c = wait_client("steam")
    gx = c["x"] + (c["width"] - 6 if right else 6)
    gy = c["y"] + (c["height"] - 6 if bottom else 6)
    move_to(gx, gy)
    button(1)
    motion(24 if right else -24, 20 if bottom else -20)
    button(0)
    n = wait_client("steam")
    print(
        name,
        "before",
        [c[k] for k in ("x", "y", "width", "height")],
        "after",
        [n[k] for k in ("x", "y", "width", "height")],
        flush=True,
    )
    assert n["width"] == c["width"] + 24 and n["height"] == c["height"] + 20
    assert n["x"] == c["x"] + (0 if right else -24)
    assert n["y"] == c["y"] + (0 if bottom else -20)
# Late identity: models an X11 app that sets WM_CLASS after mapping.
w2 = window("late-client")
late = wait_client("late-client")
assert not late["is_floating"]
x.XSetClassHint(d, w2, C.byref(ClassHint(b"steam", b"steam")))
x.XFlush(d)
time.sleep(0.2)
late = next(c for c in clients() if c["id"] == late["id"])
print("late Steam identity floating:", late["is_floating"], flush=True)
assert late["is_floating"]
w3 = window("steam_app_123")
game = wait_client("steam_app_123")
assert not game["is_floating"]
print("Steam games remain tiled: PASS", flush=True)
x.XCloseDisplay(d)
s.close()
