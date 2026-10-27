import json, os, socket, subprocess, time, unittest
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
class AppTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.logs = []
        cls.proc, cls.base = cls.start({"APP_VERSION":"test-v1"})
    @classmethod
    def start(cls, extra):
        with socket.socket() as s:
            s.bind(('127.0.0.1', 0)); port = s.getsockname()[1]
        proc = subprocess.Popen(['java','-cp','build/classes','App'], cwd=ROOT,
            env={**os.environ, 'PORT':str(port), **extra}, stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL)
        base = 'http://127.0.0.1:'+str(port)
        for _ in range(80):
            if proc.poll() is not None: raise RuntimeError('App exited before startup')
            try:
                with urlopen(base, timeout=1): return proc, base
            except (URLError, OSError): time.sleep(.1)
        proc.terminate();proc.wait(timeout=5);raise RuntimeError('App startup timed out')
    @classmethod
    def tearDownClass(cls):
        cls.proc.terminate();cls.proc.wait(timeout=5)
    def test_health(self):
        with urlopen(self.base+'/health') as r: self.assertEqual(json.load(r),{'status':'UP'})
    def test_version(self):
        with urlopen(self.base) as r: self.assertEqual(json.load(r)['version'],'test-v1')
    def test_unknown_path(self):
        with self.assertRaises(HTTPError) as e: urlopen(self.base+'/missing')
        self.assertEqual(e.exception.code,404)
    def test_exact_health_path(self):
        with self.assertRaises(HTTPError) as e: urlopen(self.base+'/health/not-valid')
        self.assertEqual(e.exception.code,404)
    def test_reject_post(self):
        with self.assertRaises(HTTPError) as e: urlopen(Request(self.base+'/health',data=b'x',method='POST'))
        self.assertEqual(e.exception.code,405)
        self.assertEqual(e.exception.headers['Allow'],'GET')
    def test_metrics_increase(self):
        def metric():
            with urlopen(self.base+'/metrics') as r: return int(r.read().decode().splitlines()[-1].split()[-1])
        before=metric(); after=metric(); self.assertGreater(after,before)
    def test_unhealthy_release(self):
        proc,base=self.start({'FAIL_HEALTH':'true'})
        try:
            with self.assertRaises(HTTPError) as e: urlopen(base+'/health')
            self.assertEqual(e.exception.code,503)
        finally: proc.terminate();proc.wait(timeout=5)
    def test_invalid_port_exits(self):
        r=subprocess.run(['java','-cp','build/classes','App'],cwd=ROOT,
            env={**os.environ,'PORT':'0'},capture_output=True,timeout=5)
        self.assertNotEqual(r.returncode,0)
if __name__=='__main__': unittest.main(verbosity=2)
